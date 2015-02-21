/********************************************************************

src/xmpp/MyXmppClient.cpp
-- wrapper between qxmpp library and XmppConnectivity

Copyright (c) 2013-2014 Maciej Janiszewski
heavily based on the work by Anatoliy Kozlov

This file is part of Lightbulb.

Lightbulb is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

*********************************************************************/

#include "MyXmppClient.h"
#include "math.h"

MyXmppClient::MyXmppClient(MyCache *lCache,ContactListManager *lContacts, EventsManager *lEvents) : QObject(0) {
  xmppClient = new QXmppClient( this );
  QObject::connect( xmppClient, SIGNAL(stateChanged(QXmppClient::State)), this, SLOT(clientStateChanged(QXmppClient::State)) );
  QObject::connect( xmppClient, SIGNAL(messageReceived(QXmppMessage)), this, SLOT(messageReceivedSlot(QXmppMessage)) );
  QObject::connect( xmppClient, SIGNAL(presenceReceived(QXmppPresence)), this, SLOT(presenceReceived(QXmppPresence)) );
  QObject::connect( xmppClient, SIGNAL(error(QXmppClient::Error)), this, SLOT(error(QXmppClient::Error)) );

  m_status = Offline;
  m_keepAlive = 60;

  versionManager = xmppClient->findExtension<QXmppVersionManager>();
  versionManager->setClientName("Lightbulb");
  versionManager->setClientVersion(QString(VERSION).mid(1,5));
  connect(versionManager,SIGNAL(versionReceived(QXmppVersionIq)),this,SLOT(versionReceivedSlot(QXmppVersionIq)));

  rosterManager = 0;
  mucManager = 0;
  transferManager = 0;
  serviceDiscovery = 0;
  graph = 0;
  cacheIM = lCache;

  contacts = lContacts;
  events = lEvents;

  // add empty group to list, I hope it works
  rosterGroups << QString("");

  entityTime = xmppClient->findExtension<QXmppEntityTimeManager>();
  connect(entityTime,SIGNAL(timeReceived(QXmppEntityTimeIq)),this,SLOT(entityTimeReceivedSlot(QXmppEntityTimeIq)));

  vCardManager = &xmppClient->vCardManager();
  QObject::connect( vCardManager, SIGNAL(vCardReceived(const QXmppVCardIq &)),
                    this, SLOT(initVCard(const QXmppVCardIq &)),
                    Qt::UniqueConnection  );

  connect(xmppClient,SIGNAL(logMessage(QXmppLogger::MessageType,QString)),this,SLOT(logMessageReceived(QXmppLogger::MessageType,QString)));
}

MyXmppClient::~MyXmppClient() {
  if (vCardManager != NULL) delete vCardManager;
  if (xmppClient != NULL) delete xmppClient;
  if (mucManager != NULL) delete mucManager;
  if (transferManager != NULL) delete transferManager;
  if (serviceDiscovery != NULL) delete serviceDiscovery;
  if (entityTime != NULL) delete entityTime;
}

// ---------- connection ---------------------------------------------------------------------------------------------------------

void MyXmppClient::connectToXmppServer() {
  QXmppConfiguration xmppConfig;

  xmppConfig.setJid(m_myjid);
  xmppConfig.setPassword(m_password);
  xmppConfig.setKeepAliveInterval(m_keepAlive);
  xmppConfig.setResource(m_resource == "" ? "Lightbulb" : m_resource);
  xmppConfig.setAutoAcceptSubscriptions(false);

  // lulz
  if (fuckSecurity) {
      xmppConfig.setNonSASLAuthMechanism(QXmppConfiguration::NonSASLDigest);
      xmppConfig.setUseSASLAuthentication(false);
      xmppConfig.setIgnoreSslErrors(true);
      xmppConfig.setStreamSecurityMode(QXmppConfiguration::TLSDisabled);
    } else {
      xmppConfig.setSaslAuthMechanism("DIGEST-MD5");
      xmppConfig.setUseSASLAuthentication(true);
      xmppConfig.setStreamSecurityMode(QXmppConfiguration::TLSRequired);
    }

  if (!m_host.isEmpty())
    xmppConfig.setHost(m_host);
  if (m_port != 0)
    xmppConfig.setPort(m_port);

  // initialize MUC manager if account is not facebook
  if (!mucManager && xmppConfig.host() != "chat.facebook.com") {
      qDebug() << "MyXmppClient::connectToXmppServer(): initializing MUC manager";
      mucManager = new QXmppMucManager();
      xmppClient->addExtension(mucManager);
    }

  // initialize transfer manager if account is not facebook
  if (!transferManager && xmppConfig.host() != "chat.facebook.com") {
      qDebug() << "MyXmppClient::connectToXmppServer(): initializing transfer manager";
      transferManager = new QXmppTransferManager();
      xmppClient->addExtension(transferManager);
      connect(transferManager,SIGNAL(fileReceived(QXmppTransferJob*)),this,SLOT(incomingTransfer(QXmppTransferJob*)));
    }

  // initialize service discovery if account is not facebook
  if (!serviceDiscovery && xmppConfig.host() != "chat.facebook.com") {
      qDebug() << "MyXmppClient::connectToXmppServer(): initializing Service Discovery manager";
      serviceDiscovery = xmppClient->findExtension<QXmppDiscoveryManager>();
      if (!serviceDiscovery) {
          serviceDiscovery = new QXmppDiscoveryManager();
          xmppClient->addExtension(serviceDiscovery);
        }
      serviceDiscovery->setClientCategory("phone");
      connect(serviceDiscovery,SIGNAL(itemsReceived(QXmppDiscoveryIq)),this,SLOT(itemsReceived(QXmppDiscoveryIq)),Qt::UniqueConnection);
      connect(serviceDiscovery,SIGNAL(infoReceived(QXmppDiscoveryIq)),this,SLOT(infoReceived(QXmppDiscoveryIq)),Qt::UniqueConnection);
    }

  // initialize profile pic downloader if account is facebook
  if (!graph && xmppConfig.host() == "chat.facebook.com") {
      qDebug() << "MyXmppClient::connectToXmppServer(): initializing Graph API extension";
      graph = new GraphAPIExtensions(cacheIM);
      connect(graph,SIGNAL(avatarDownloaded(QString)),this,SLOT(checkIfPersonalityUpdated(QString)),Qt::UniqueConnection);
    }

  xmppClient->connectToServer(xmppConfig);
}

void MyXmppClient::clientStateChanged(QXmppClient::State state) {
  if (state == QXmppClient::ConnectedState) {
      if (!rosterManager) initRosterManager();
      this->presenceReceived(xmppClient->clientPresence());
      if (serviceDiscovery != 0) this->askServer(m_host);
    }

  // avoid spam by checking if state changed
  if (state != previousState) {
      previousState = state;
      emit connectingChanged(m_accountId);
    }
}
void MyXmppClient::error(QXmppClient::Error e) {
  switch (e) {
    case QXmppClient::SocketError: emit errorHappened(m_accountId,xmppClient->socketErrorString()); break;
    case QXmppClient::KeepAliveError: emit errorHappened(m_accountId,"Keep alive failure"); break;
    case QXmppClient::XmppStreamError: emit errorHappened(m_accountId,"Stream error. Check account settings"); break;
    default: return;
    }

  this->setPresence(Offline, m_statusText);
}

// ---------- VCards -------------------------------------------------------------------------------------------------------------

void MyXmppClient::initVCard(const QXmppVCardIq &vCard) {
  QString bareJid = vCard.from();
  vCardData dataVCard;

  // set nickname
  QXmppRosterIq::Item itemRoster = rosterManager->getRosterEntry( bareJid );
  QString nickName = vCard.nickName();
  if( (!nickName.isEmpty()) && (!nickName.isNull()) && (itemRoster.name().isEmpty()) ) {
      qDebug() << "MyXmppClient::initPresence: updating name for"<< bareJid;
      contacts->changeName(m_accountId,bareJid,nickName);
    }

  // check if caching is disabled
  if (!disableAvatarCaching) {
      if (!isFacebook() || legacyAvatarCaching) {
          QString avatarFile = cacheIM->getAvatarCache( bareJid );
          if ((avatarFile.isEmpty() || avatarFile == "qrc:/avatar") && vCard.photo() != "")
            cacheIM->setAvatarCache( bareJid, vCard.photo() );
        } else graph->downloadProfilePic(bareJid);
    }

  dataVCard.nickName = nickName;
  dataVCard.firstName = vCard.firstName();
  dataVCard.fullName = vCard.fullName();;
  dataVCard.middleName = vCard.middleName();
  dataVCard.lastName = vCard.lastName();
  dataVCard.url = vCard.url();
  dataVCard.eMail = vCard.email();

  cacheIM->setVCard( bareJid, dataVCard );

  if (bareJid == m_myjid && !isFacebook())
    emit iFoundYourParentsGoddamit(m_myjid);
}

void MyXmppClient::forceRefreshVCard(QString bareJid) {
  qDebug() << "MyXmppClient::forceRefreshVCard(): called for jid " << bareJid;
  cacheIM->addCacheJid(bareJid);
  vCardManager->requestVCard(bareJid);
}

// ---------- handling messages (receiving/sending) ------------------------------------------------------------------------------

bool MyXmppClient::sendMessage(QString bareJid, QString resource, QString msgBody, int chatState, int msgType) {
  if (xmppClient->state() != QXmppClient::ConnectedState || bareJid == "")
    return false;

  QString jid = bareJid;
  if( resource == "" && !rosterManager->getResources(bareJid).contains(resource) )
      jid += "/resource";
  else
    jid += "/" + resource;

  QXmppMessage xmppMsg;

  if (msgType == QXmppMessage::GroupChat) {
      QXmppMucRoom* room = mucRooms.value(bareJid);
      return (room != NULL && room->isJoined()) ? room->sendMessage(msgBody) : false;
    }

  xmppMsg.setTo(jid);
  xmppMsg.setFrom( m_myjid + "/" + xmppClient->configuration().resource() );

  xmppMsg.setStamp(QDateTime::currentDateTime());
  xmppMsg.setState((QXmppMessage::State)chatState);

  if (msgBody != "") {
      xmppMsg.setBody(msgBody);
      emit insertMessage(m_accountId,QXmppUtils::jidToBareJid(xmppMsg.to()),msgBody,QDateTime::currentDateTime().toString("dd-MM-yy hh:mm:ss"),1,2,"");
    }

  return xmppClient->sendPacket(xmppMsg);
}

bool MyXmppClient::requestAttention(QString bareJid, QString resource) {
  if (xmppClient->state() != QXmppClient::ConnectedState)
    return false;

  QXmppMessage xmppMsg;
  xmppMsg.setTo(bareJid + "/" + resource);
  xmppMsg.setFrom( m_myjid + "/" + xmppClient->configuration().resource() );
  xmppMsg.setAttentionRequested(true);
  emit insertMessage(m_accountId,bareJid,"[[ALERT]] You requested attention from [[bold]][[name]][[/bold]] @[[date]]",QDateTime::currentDateTime().toString("dd-MM-yy hh:mm:ss"),0,4,resource);

  return xmppClient->sendPacket(xmppMsg);
}

void MyXmppClient::messageReceivedSlot( const QXmppMessage &xmppMsg ) {
  QString bareJid_from = QXmppUtils::jidToBareJid(xmppMsg.from());
  QString messageDate = xmppMsg.stamp().isNull() ? QDateTime::currentDateTime().toString("dd-MM-yy hh:mm:ss") : xmppMsg.stamp().toLocalTime().toString("dd-MM-yy hh:mm:ss");

  // chat state support, don't trigger that if JID is empty or it's ours
  if (bareJid_from != "" && bareJid_from != m_myjid) {
    switch (xmppMsg.state()) {
      case QXmppMessage::Active: /* app doesn't handle it because why should it anyway */ break;
      case QXmppMessage::Inactive: /* app doesn't handle it because why should it anyway */ break;
      case QXmppMessage::Gone:
        emit insertMessage(m_accountId,bareJid_from,"has left the conversation.",messageDate,0,4,QXmppUtils::jidToResource(xmppMsg.from()));
        break;
      case QXmppMessage::Composing: emit typingChanged(m_accountId,bareJid_from, true); break;
      case QXmppMessage::Paused: emit typingChanged(m_accountId,bareJid_from, false); break;
      case QXmppMessage::None: break;
      }
    }

  if (xmppMsg.isAttentionRequested()) {
      emit insertMessage(m_accountId,bareJid_from,"[[ALERT]] [[bold]][[name]][[/bold]] requested your attention!",QDateTime::currentDateTime().toString("dd-MM-yy hh:mm:ss"),0,4,QXmppUtils::jidToResource(xmppMsg.from()));
      events->appendAttention(m_accountId,bareJid_from,contacts->getPropertyByJid(m_accountId,bareJid_from,"name"));
    }

  if (!(xmppMsg.body().isEmpty() || bareJid_from == m_myjid)) {
      if (xmppMsg.body().contains("http://talkgadget.google.com/talkgadget/joinpmuc") ||
          (xmppMsg.body().contains("invited you to the room") && xmppMsg.body().contains(QXmppUtils::jidToBareJid(xmppMsg.from()))))
        {
          events->appendMUCInvitation(m_accountId,QXmppUtils::jidToBareJid(xmppMsg.from()),contacts->getPropertyByJid(m_accountId,QXmppUtils::jidToBareJid(xmppMsg.body().split(" ").at(0)),"name"));
          return;
        }

      int isMine = 0;
      if (xmppMsg.type() == QXmppMessage::GroupChat)
        if (getMUCNick(bareJid_from) == QXmppUtils::jidToResource(xmppMsg.from()))
          isMine = 1;

      emit insertMessage(m_accountId,QXmppUtils::jidToBareJid(xmppMsg.from()),xmppMsg.body(),messageDate,isMine,xmppMsg.type(),QXmppUtils::jidToResource(xmppMsg.from()));
    }
}

// ---------- presence -----------------------------------------------------------------------------------------------------------

void MyXmppClient::initPresence(const QString& bareJid, const QString& resource) {
  QXmppPresence xmppPresence = rosterManager->getPresence( bareJid, resource );
  QXmppPresence::Type statusJid = xmppPresence.type();

  QStringList _listResources = this->getResourcesByJid( bareJid );
  if( (_listResources.count() > 0) && (!_listResources.contains(resource)) ) {
      qDebug() << bareJid << "/" << resource << " ****************[" <<_listResources<<"]" ;
      if(statusJid == QXmppPresence::Unavailable)
        return;
    }

  QString picStatus = this->getPicPresence( xmppPresence );
  QString txtStatus = xmppPresence.statusText();

  contacts->changePresence(m_accountId,bareJid,resource,picStatus,txtStatus,initializationState);
  emit presenceChanged(m_accountId,bareJid,resource,picStatus,txtStatus);
}

void MyXmppClient::presenceReceived( const QXmppPresence & presence ) {
  QString bareJid = QXmppUtils::jidToBareJid(presence.from());
  QString resource = QXmppUtils::jidToResource(presence.from());

  QString myResource = xmppClient->configuration().resource();

  // muc participants list management
  if (mucRooms.contains(bareJid)) {
      if (presence.type() == QXmppPresence::Unavailable) {
          int rowId = -1;
          mucParticipants.value(bareJid)->find(presence.from(),rowId);
          mucParticipants.value(bareJid)->takeRow(rowId);
          return;
        }
      QXmppMucItem mucItem = presence.mucItem();
      ParticipantItemModel* participantPresence = (ParticipantItemModel*)mucParticipants.value(bareJid)->find(presence.from());
      if (participantPresence == NULL) {
          participantPresence = new ParticipantItemModel();
          mucParticipants.value(bareJid)->append(participantPresence);
        }
      participantPresence->setPartName(resource);
      participantPresence->setPartPresence(getPicPresence(presence));
      participantPresence->setPartJid(presence.from());
      participantPresence->setPartRole((int)mucItem.affiliation());
      participantPresence->setPartAffilliation((int)mucItem.role());
    }

  if ((presence.from().indexOf( m_myjid ) >= 0 && resource == myResource) || (bareJid == "" && resource == "")) {
      if (presence.type() == QXmppPresence::Unavailable) m_status = Offline;
      else {
          switch (presence.availableStatusType()) {
            case QXmppPresence::Online: m_status = Online; break;
            case QXmppPresence::Chat: m_status = Chat; break;
            case QXmppPresence::Away: m_status = Away; break;
            case QXmppPresence::XA: m_status = XA; break;
            case QXmppPresence::DND: m_status = DND; break;
            case QXmppPresence::Invisible: m_status = Offline; break;
            }
        }
      if (xmppClient->state() != QXmppClient::ConnectingState)
        emit statusChanged(m_accountId);
    }
}

QString MyXmppClient::getPicPresence( const QXmppPresence &presence ) const {
  QString picPresenceName;
  QXmppPresence::Type status = presence.type();
  if( status != QXmppPresence::Available )
    picPresenceName = "qrc:/presence/offline";
  else {
      QXmppPresence::AvailableStatusType availableStatus = presence.availableStatusType();
      if( availableStatus == QXmppPresence::Online ) picPresenceName = "qrc:/presence/online";
      else if ( availableStatus == QXmppPresence::Chat ) picPresenceName = "qrc:/presence/chatty";
      else if ( availableStatus == QXmppPresence::Away ) picPresenceName = "qrc:/presence/away";
      else if ( availableStatus == QXmppPresence::XA ) picPresenceName = "qrc:/presence/xa";
      else if ( availableStatus == QXmppPresence::DND ) picPresenceName = "qrc:/presence/busy";
    }

  return picPresenceName;
}

void MyXmppClient::setStatusText( const QString &__statusText ) {
  QXmppPresence myPresence = xmppClient->clientPresence();
  myPresence.setStatusText( __statusText );
  xmppClient->setClientPresence( myPresence );

  emit statusTextChanged();
}

void MyXmppClient::setStatus( StatusXmpp __status) {
  if (__status != m_status || xmppClient->state() == QXmppClient::ConnectingState) {
      QXmppPresence myPresence = xmppClient->clientPresence();
      m_prevStatus = m_status;

      if (__status != Offline) {
          if( xmppClient->state() == QXmppClient::DisconnectedState )
            this->connectToXmppServer();

          myPresence.setType( QXmppPresence::Available );
        } else {
          if( (xmppClient->state() != QXmppClient::DisconnectedState) )
            xmppClient->disconnectFromServer();
          myPresence.setType( QXmppPresence::Unavailable );
        }

      switch (__status) {
        case Online: myPresence.setAvailableStatusType( QXmppPresence::Online ); break;
        case Chat: myPresence.setAvailableStatusType( QXmppPresence::Chat ); break;
        case Away: myPresence.setAvailableStatusType( QXmppPresence::Away ); break;
        case XA: myPresence.setAvailableStatusType( QXmppPresence::XA ); break;
        case DND: myPresence.setAvailableStatusType( QXmppPresence::DND ); break;
        case Offline: m_status = __status; break;
        default: break;
        }
      xmppClient->setClientPresence( myPresence );
      this->presenceReceived( myPresence );
    }
}

void MyXmppClient::setPresence(StatusXmpp status, QString textStatus) { //Q_INVOKABLE
  qDebug() << "MyXmppClient:: setPresence() called";

  // hackfix for messed up infinite loop (I hate 'em)
  if (xmppClient->state() == QXmppClient::DisconnectedState && status == Offline)
    return;

  setStatus(status);
  setStatusText(textStatus);
}

// ---------- roster management --------------------------------------------------------------------------------------------------

void MyXmppClient::initRosterManager() {
  // initialize roster manager
  rosterManager = &xmppClient->rosterManager();

  qDebug() << "MyXmppClient::clientStateChanged(): initializing roster manager";

  // CONNECT ALL THE SIGNALS!!1111
  QObject::connect( rosterManager, SIGNAL(presenceChanged(QString,QString)), this, SLOT(initPresence(const QString, const QString)), Qt::UniqueConnection );
  QObject::connect( rosterManager, SIGNAL(rosterReceived()), this, SLOT(initRoster()), Qt::UniqueConnection );
  QObject::connect( rosterManager, SIGNAL(subscriptionReceived(QString)), this, SLOT(notifyNewSubscription(QString)), Qt::UniqueConnection );
  QObject::connect( rosterManager, SIGNAL(itemAdded(QString)), this, SLOT(itemAdded(QString)), Qt::UniqueConnection );
  QObject::connect( rosterManager, SIGNAL(itemRemoved(QString)), this, SLOT(itemRemoved(QString)), Qt::UniqueConnection );
  QObject::connect( rosterManager, SIGNAL(itemChanged(QString)), this, SLOT(itemChanged(QString)), Qt::UniqueConnection );
}

void MyXmppClient::initRoster() {
  qDebug() << "MyXmppClient::initRoster() called";

  // put the client in "contact list initialization" state
  initializationState = true;

  // get a list of all JIDs
  QStringList listBareJids = rosterManager->getRosterBareJids();

  // clean up the cache
  contacts->cleanupCache(m_accountId,listBareJids);

  // iterate through the list
  foreach (const QString &bareJid, listBareJids) {
      // prepare cache
      cacheIM->addCacheJid(bareJid);

      // get contact name, we might need it
      QString name = rosterManager->getRosterEntry(bareJid).name();

      // try to get VCard
      vCardData vCdata = cacheIM->getVCard( bareJid );

      // request it from the server if unavailable
      if (vCdata.isEmpty()) {
          qDebug() << "MyXmppClient::initRoster():" << bareJid << "has no VCard. Requesting.";
          vCardManager->requestVCard( bareJid );
        }

      // prepare groups
      QStringList groups_tmp = rosterManager->getRosterEntry(bareJid).groups().toList();

      // iterate through group list and add 'em all to cache
      foreach (const QString &str, groups_tmp) {
               if (!rosterGroups.contains(str))
                   rosterGroups += str;
           }

      // it really sucks that I handle this in such dumb way but whateva'
      QString groups = groups_tmp.join(", ");

      // inform contact list manager that there is something cool coming
      contacts->addContact(m_accountId,bareJid,name,true,false,groups);
    }

  // check if our cache is available, if there isn't - request it
  // it's essential for "personality" feature (shows our name and photo on Events page)
  // I might move it to a place where it makes more sense in the future
  vCardData vCdata = cacheIM->getVCard( m_myjid );
  if (vCdata.isEmpty()) {
      qDebug() << "MyXmppClient::initRoster():" << m_myjid << "has no VCard. Requesting.";
      cacheIM->addCacheJid(m_myjid);
      vCardManager->requestVCard( m_myjid );
    }

  // let the app know we are past "contact list initialization" state
  QTimer::singleShot(1000,this,SLOT(resetInitState()));
}

void MyXmppClient::itemAdded(const QString &bareJid ) {
  QStringList resourcesList = rosterManager->getResources( bareJid );

  foreach (const QString &resource,resourcesList)
      this->initPresence( bareJid, resource);

  // prepare groups
  QStringList groups_tmp = rosterManager->getRosterEntry(bareJid).groups().toList();
  QString groups = groups_tmp.join(", ");

  contacts->addContact(m_accountId,bareJid,"",true,false,groups);
}

void MyXmppClient::itemChanged(const QString &bareJid ) {
  QXmppRosterIq::Item rosterEntry = rosterManager->getRosterEntry( bareJid );
  contacts->changeName(m_accountId,bareJid,rosterEntry.name());
}

void MyXmppClient::itemRemoved(const QString &bareJid ) {
  contacts->removeContact(m_accountId,bareJid);
}

bool MyXmppClient::addContact( QString bareJid, QString nick, QString group, bool sendSubscribe ) {
    bool result = false;
    if( rosterManager ) {
        QSet<QString> gr;
        QString n;
        if( !(group.isEmpty() || group.isNull()) )  { gr.insert( group ); }
        if( !(nick.isEmpty() || nick.isNull()) )  { n = nick; }
        result = rosterManager->addItem(bareJid, n, gr );

        if( sendSubscribe ) rosterManager->subscribe( bareJid );
    }
    return result;
}

bool MyXmppClient::setContactGroup(QString bareJid, QString group) {
  QString nick = contacts->getPropertyByJid(m_accountId,bareJid,"name");

  this->addContact(bareJid,nick,group,false);
  contacts->addContact(m_accountId,bareJid,nick,false,false,group);
}

// --------- XEP-0202: Entity Time ------------------------------------------------------------------------------------------------

void MyXmppClient::requestContactTime(const QString bareJid, QString resource) {
  // provides support for XEP-0202: Entity Time
  QString jid = bareJid + "/" + resource;

  if (resource == "") {
      QStringList resources = rosterManager->getResources(bareJid);
      if (resources.count() > 0)
        jid += resources.value(0);
    }

  entityTime->requestTime(jid);
  qDebug() << "Requested entity time for" << jid;
}

void MyXmppClient::entityTimeReceivedSlot(const QXmppEntityTimeIq &entity) {
  if (entity.type() == QXmppIq::Result) {
      QString time = entity.utc().toString(("hh:mm:ss")) + " " + QXmppUtils::timezoneOffsetToString(entity.tzo());
      emit entityTimeReceived(m_accountId,QXmppUtils::jidToBareJid(entity.from()),QXmppUtils::jidToResource(entity.from()),time);
    }
}

// --------- XEP-0092: Software Version ------------------------------------------------------------------------------------------------

void MyXmppClient::requestContactVersion(const QString bareJid, QString resource) {
  // provides support for XEP-0092: Software Version
  QString jid = bareJid + "/" + resource;

  if (resource == "") {
      QStringList resources = rosterManager->getResources(bareJid);
      if (resources.count() > 0)
        jid += resources.value(0);
    }

  xmppClient->versionManager().requestVersion(jid);
  qDebug() << "Requested version for" << jid;
}

void MyXmppClient::versionReceivedSlot(const QXmppVersionIq &version) {
  if (version.type() == QXmppIq::Result) {
      QString versionStr = version.name() + " " + version.version() + (version.os() != "" ? "@" + version.os() : QString());;
      emit versionReceived(m_accountId,QXmppUtils::jidToBareJid(version.from()),QXmppUtils::jidToResource(version.from()),versionStr);
    }
}

// ---------- muc support --------------------------------------------------------------------------------------------------------

void MyXmppClient::joinMUCRoom(QString room, QString nick, QString password) {
  qDebug() << "MyXmppClient::joinMUCRoom(): attempting to join" << room;
  QXmppMucRoom *mucRoom;

  if (!mucRooms.contains(room)) {
      mucRoom = mucManager->addRoom(room);
      mucRooms.insert(room,mucRoom);
      connect(mucRoom,SIGNAL(joined()),this,SLOT(mucJoinedSlot()));
      connect(mucRoom,SIGNAL(subjectChanged(QString)),this,SLOT(mucTopicChangeSlot(QString)));
      connect(mucRoom,SIGNAL(error(QXmppStanza::Error)),this,SLOT(mucErrorSlot(QXmppStanza::Error)));
      connect(mucRoom,SIGNAL(permissionsReceived(QList<QXmppMucItem>)),this,SLOT(permissionsReceived(QList<QXmppMucItem>)));
      connect(mucRoom,SIGNAL(participantAdded(QString)),this,SLOT(mucParticipantAddedSlot(QString)));
      connect(mucRoom,SIGNAL(participantRemoved(QString)),this,SLOT(mucParticipantRemovedSlot(QString)));
      connect(mucRoom,SIGNAL(kicked(QString,QString)),this,SLOT(mucKickedSlot(QString,QString)));
      connect(mucRoom,SIGNAL(nameChanged(QString)),this,SLOT(mucRoomNameChangedSlot(QString)));
    } else {
      mucRoom = mucRooms.value(room);
    }

  if (!mucParticipants.contains(room)) {
      ParticipantListModel* participants = new ParticipantListModel();
      mucParticipants.insert(room,participants);
    }

  mucRoom->setPassword(password);
  mucRoom->setNickName(nick);
  mucRoom->join();
}

void MyXmppClient::mucJoinedSlot() {
  QXmppMucRoom* room = (QXmppMucRoom*)sender();

  qDebug() << "Requesting permissions";
  room->requestPermissions();

  emit mucRoomJoined(m_accountId,room->jid());

  qDebug() << room->name();
}

void MyXmppClient::leaveMUCRoom(QString room) {
  QXmppMucRoom *mucRoom = mucRooms.value(room);
  mucRoom->leave();
}

QString MyXmppClient::getMUCNick(QString room) {
  QXmppMucRoom *mucRoom = mucRooms.value(room);
  return mucRoom->nickName();
}

QStringList MyXmppClient::getListOfParticipants(QString room) {
  return mucRooms.value(room)->participants();
}

void MyXmppClient::mucTopicChangeSlot(QString subject) {
  QXmppMucRoom* room = (QXmppMucRoom*)sender();
  emit insertMessage(m_accountId,room->jid(),"Chatroom subject is \n" + subject,QDateTime::currentDateTime().toString("dd-MM-yy hh:mm:ss"),0,4,"");
}

void MyXmppClient::permissionsReceived(const QList<QXmppMucItem> &permissions) {
  qDebug() << "received permissions;" << permissions.count();

  foreach (const QXmppMucItem permItem,permissions) {
      QString nameString = permItem.nick() + " (" + permItem.jid() + ")";
      qDebug() << "Permissions for" << qPrintable(nameString);
      qDebug() << "Role:" << permItem.roleToString(permItem.role());
      qDebug() << "Affiliation:" << permItem.affiliationToString(permItem.affiliation());
    }
}

void MyXmppClient::mucErrorSlot(const QXmppStanza::Error &error) {
  QXmppMucRoom* room = (QXmppMucRoom*)sender();
  events->appendError(m_accountId,room->name(),"Error "+QString::number(error.code()) + " occured");
  emit insertMessage(m_accountId,room->jid(),"[[ERR]] Error " + QString::number(error.code()) + " occured",QDateTime::currentDateTime().toString("dd-MM-yy hh:mm:ss"),0,4,"");
}
void MyXmppClient::mucKickedSlot(const QString &jid, const QString &reason) {
  QXmppMucRoom* room = (QXmppMucRoom*)sender();
  QString body = "[[ERR]] You've been [[bold]]kicked out[[/bold]] of the room";
  if (reason != "") {
    body += ". Reason: [[bold]]" + reason + "[[/bold]]";
    events->appendError(m_accountId,room->name(),"You've been kicked out of the room. Reason: "+reason);
  } else events->appendError(m_accountId,room->name(),"You've been kicked out of the room");
  emit insertMessage(m_accountId,room->jid(),body,QDateTime::currentDateTime().toString("dd-MM-yy hh:mm:ss"),0,4,QXmppUtils::jidToResource(jid));
}
void MyXmppClient::mucRoomNameChangedSlot(const QString &name) {
  QXmppMucRoom* room = (QXmppMucRoom*)sender();
  emit insertMessage(m_accountId,room->jid(),"[[INFO]] Room name is \n[[bold]]" + name + "[[/bold]]",QDateTime::currentDateTime().toString("dd-MM-yy hh:mm:ss"),0,4,"");
  emit mucNameChanged(m_accountId,room->jid(),name);
}
void MyXmppClient::mucYourNickChanged(const QString &nickName) {
  QXmppMucRoom* room = (QXmppMucRoom*)sender();
  emit insertMessage(m_accountId,room->jid(),"[[INFO]] Your nickname was changed to \"" + nickName + "\"",QDateTime::currentDateTime().toString("dd-MM-yy hh:mm:ss"),0,4,"");
}
void MyXmppClient::mucParticipantAddedSlot(const QString &jid) {
  QXmppMucRoom* room = (QXmppMucRoom*)sender();
  if (room->nickName() == QXmppUtils::jidToResource(jid) || !room->isJoined())
    return;
  emit insertMessage(m_accountId,room->jid(),"[[INFO]] [[bold]][[mucName]][[/bold]] has joined this room.",QDateTime::currentDateTime().toString("dd-MM-yy hh:mm:ss"),0,4,QXmppUtils::jidToResource(jid));
}
void MyXmppClient::mucParticipantRemovedSlot(const QString &jid) {
  QXmppMucRoom* room = (QXmppMucRoom*)sender();
  if (room->nickName() == QXmppUtils::jidToResource(jid) || !room->isJoined())
    return;
  emit insertMessage(m_accountId,room->jid(),"[[INFO]] [[bold]][[mucName]][[/bold]] has left this room.",QDateTime::currentDateTime().toString("dd-MM-yy hh:mm:ss"),0,4,QXmppUtils::jidToResource(jid));
}

bool MyXmppClient::isActionPossible(int permissionLevel, int action) {
  // checks if QXmppMucRoom::Action is possible on our permission level
  // solution by @invidian, ported to C++ by me (ksiazkowicz)

  QList<int> availableActions = QList<int>() << 8 << 4 << 2 << 1 << 0;

  qDebug() << availableActions;

  foreach (int value,availableActions){
      if (permissionLevel>=value) {
          if(action == value) return true; else permissionLevel -=value;
        }
    }

  return false;
}

// ---------- Service Discovery ----------------------------------------------------------------------------------------------------

void MyXmppClient::askServer(QString jid) {
  serviceDiscovery->requestItems(jid);
}

ServiceListModel* MyXmppClient::serviceModel(QString jid) {
  return this->services(jid);
}

void MyXmppClient::itemsReceived(const QXmppDiscoveryIq &items) {
  ServiceItemModel *item;

  // get list model for services
  ServiceListModel *cache = this->services(items.from());

  foreach (const QXmppDiscoveryIq::Item discItem,items.items()) {
      // check if item already exists
      item = (ServiceItemModel*)cache->find(discItem.jid());

      // it doesn't, create a new one and append it
      if (item == 0) {
          item = new ServiceItemModel(discItem.name(),discItem.jid(),discItem.node());
          cache->append(item);
        }

      // request additional info for this node
      serviceDiscovery->requestInfo(discItem.jid());
    }
}

void MyXmppClient::infoReceived(const QXmppDiscoveryIq &iq) {
  QString path;
  // check if contains @
  if (iq.from().contains("@")) {
      path = iq.from().split("@")[1];
  } else {
      // the most. terrible. solution. EVER.
      path = iq.from().right(iq.from().length() - (iq.from().split(".")[0].length()+1));
  }

  // find a service item model
  ServiceItemModel *item = services(path)->find(QXmppUtils::jidToBareJid(iq.from()));

  // if item found, update with node features
  if (item != 0) {
    foreach (const QXmppDiscoveryIq::Identity &identity, iq.identities()) {
      item->set(identity.category(),ServiceItemModel::Features);
      item->set(identity.type(),ServiceItemModel::Type);

      // if item is a bytestreams proxy, update the data
      if (identity.type() == "bytestreams" && path == m_host && identity.category() == "proxy") {
          defaultTransferProxy = iq.from();
      }
    }
   }
}

ServiceListModel* MyXmppClient::services(QString jid) {
  // check if cache is available
  if (!servicesCache.contains(jid)) {
      // if not, initialize cache
      servicesCache.insert(jid,new ServiceListModel());
    }

  // return cache for JID
  return servicesCache.value(jid);
}


// ---------- file transfer --------------------------------------------------------------------------------------------------------

void MyXmppClient::incomingTransfer(QXmppTransferJob *job) {
  int jobId = transferJobs.count();
  transferJobs.insert(jobId,job);

  connect(job,SIGNAL(error(QXmppTransferJob::Error)),SLOT(transferError(QXmppTransferJob::Error)));
  connect(job,SIGNAL(progress(qint64,qint64)),SLOT(progress(qint64,qint64)));
  connect(job,SIGNAL(stateChanged(QXmppTransferJob::State)),SLOT(transferStateChangeSlot(QXmppTransferJob::State)));

  // don't force inband, because we actually CAN receive files using bytestreams proxy
  transferManager->setSupportedMethods(QXmppTransferJob::AnyMethod);
  // don't force our own proxy too
  transferManager->setProxy("");

  // TODO: try to recognize file type
  events->appendTransferJob(m_accountId,job->jid(),contacts->getPropertyByJid(m_accountId,QXmppUtils::jidToBareJid(job->jid()),"name"),job->fileName(),jobId,true);
}

void MyXmppClient::sendAFile(QString bareJid, QString resource, QString path) {
  // get an ID for a transfer job
  int jobId = transferJobs.count();
  QString jid = bareJid;

  // get a list of valid resources
  QStringList validResources = rosterManager->getResources(bareJid);

  // if resource is invalid, choose default
  jid += "/" + (!validResources.contains(resource) ? validResources.first() : resource);

  // check if bytestreams proxy is available
  if (!defaultTransferProxy.isEmpty()) {
    transferManager->setSupportedMethods(QXmppTransferJob::AnyMethod);
    transferManager->setProxy(defaultTransferProxy);
  } else {
    // force inband as we don't know the JID of bytestreams proxy
    transferManager->setSupportedMethods(QXmppTransferJob::InBandMethod);
  }

  // send a file
  QXmppTransferJob *job = transferManager->sendFile(jid,path);
  transferJobs.insert(jobId,job);

  connect(job,SIGNAL(error(QXmppTransferJob::Error)),SLOT(transferError(QXmppTransferJob::Error)));
  connect(job,SIGNAL(progress(qint64,qint64)),SLOT(progress(qint64,qint64)));
  connect(job,SIGNAL(stateChanged(QXmppTransferJob::State)),SLOT(transferStateChangeSlot(QXmppTransferJob::State)));

  // TODO: try to recognize file type
  events->appendTransferJob(m_accountId,job->jid(),contacts->getPropertyByJid(m_accountId,bareJid,"name"),job->fileName(),jobId,false);
}

void MyXmppClient::acceptTransfer(int jobId, QString path) {
  QXmppTransferJob* job = transferJobs.value(jobId);

  QString recvPath = "";
  QStringList defaultPaths = QStringList() << "F:/Received files/" << "E:/Received files/" << "C:/Data/Received files/" << "C:/Data/";

  // check if path exists, if not, use something else
  if (path == "" || path == "false" || !QFile::exists(path)) {
      // ITERAAATEEEEEE
      foreach (const QString t_path,defaultPaths) {
          // found some crap, test it
          if (QFile::exists(t_path)) {
            recvPath = t_path;
            break;
          }
          // nope nope nope
        }
    } else recvPath = path;

  if (recvPath == "") return; // TODO: show an error if path is useless

  if (job != NULL && job->state() == QXmppTransferJob::OfferState)
      job->accept(recvPath + job->fileName());
}

void MyXmppClient::abortTransfer(int jobId) {
  QXmppTransferJob* job = transferJobs.value(jobId);
  if (job != NULL)
    job->abort();
}

void MyXmppClient::openLocalTransferPath(int jobId) {
  QXmppTransferJob* job = transferJobs.value(jobId);

  qDebug() << job->localFileUrl().toLocalFile();

  if (job != NULL)
    QDesktopServices::openUrl(QUrl(job->localFileUrl()));
}

void MyXmppClient::progress(qint64 done, qint64 total) {
  double slice = ((double)done/(double)total)*100;
  QXmppTransferJob* job = (QXmppTransferJob*)sender();
  int jobId = transferJobs.key(job);
  emit progressChanged(jobId,floor(slice));
}

void MyXmppClient::transferStateChangeSlot(QXmppTransferJob::State state) {
  QXmppTransferJob* job = (QXmppTransferJob*)sender();
  int jobId = transferJobs.key(job);
  emit transferStateChanged(jobId,(int)state);
}

void MyXmppClient::transferError(QXmppTransferJob::Error error) {
  QXmppTransferJob* job = (QXmppTransferJob*)sender();
  int jobId = transferJobs.key(job);
  QString errorString = "";
  switch (error) {
    case QXmppTransferJob::AbortError: errorString = "File transfer aborted for file " + job->fileName(); break;
    case QXmppTransferJob::FileAccessError: errorString = "Unable to access " + job->localFileUrl().toString(); break;
    case QXmppTransferJob::FileCorruptError: errorString = "File " + job->fileName() + " is corrupted"; break;
    case QXmppTransferJob::ProtocolError: errorString = "Connection issue. Aborting (" + job->fileName() + ")."; break;
    case QXmppTransferJob::NoError: break;
    }

  if (errorString != "") {
    events->appendError(m_accountId,contacts->getPropertyByJid(m_accountId,QXmppUtils::jidToBareJid(job->jid()),"name"),errorString);
    events->removeTransferJob(m_accountId,jobId);
    }
}
