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
#include "DataPublisher.h"
#include "QSettings.h"

const bool xmppDebugEnabled = false;

MyXmppClient::MyXmppClient() : QObject(0) {
    xmppClient = new QXmppClient( this );
    QObject::connect( xmppClient, SIGNAL(stateChanged(QXmppClient::State)), this, SLOT(clientStateChanged(QXmppClient::State)) );
    QObject::connect( xmppClient, SIGNAL(messageReceived(QXmppMessage)), this, SLOT(messageReceivedSlot(QXmppMessage)) );
    QObject::connect( xmppClient, SIGNAL(presenceReceived(QXmppPresence)), this, SLOT(presenceReceived(QXmppPresence)) );
    QObject::connect( xmppClient, SIGNAL(error(QXmppClient::Error)), this, SLOT(error(QXmppClient::Error)) );

    m_status = Offline;
    m_keepAlive = 60;

    xmppClient->versionManager().setClientName("Lightbulb");
    xmppClient->versionManager().setClientVersion( VERSION );

    rosterManager = 0;
    QSettings temp(QDir::currentPath() + QDir::separator() + "Settings.conf",QSettings::NativeFormat);
    temp.beginGroup("paths");
    cacheIM = new MyCache(temp.value("cache","").toString());
    temp.endGroup();

    vCardManager = &xmppClient->vCardManager();
    QObject::connect( vCardManager, SIGNAL(vCardReceived(const QXmppVCardIq &)),
                      this, SLOT(initVCard(const QXmppVCardIq &)),
                      Qt::UniqueConnection  );

    mucManager = new QXmppMucManager();
    xmppClient->addExtension(mucManager);

    transferManager = new QXmppTransferManager();
    xmppClient->addExtension(transferManager);
    connect(transferManager,SIGNAL(fileReceived(QXmppTransferJob*)),this,SLOT(incomingTransfer(QXmppTransferJob*)));

    serviceDiscovery = new QXmppDiscoveryManager();
    xmppClient->addExtension(serviceDiscovery);

    if (xmppDebugEnabled)
      connect(xmppClient,SIGNAL(logMessage(QXmppLogger::MessageType,QString)),this,SLOT(logMessageReceived(QXmppLogger::MessageType,QString)));
}

MyXmppClient::~MyXmppClient() {
    if (cacheIM != NULL) delete cacheIM;
    if (vCardManager != NULL) delete vCardManager;
    if (xmppClient != NULL) delete xmppClient;
    if (mucManager != NULL) delete mucManager;
    if (transferManager != NULL) delete transferManager;
}

// ---------- connection ---------------------------------------------------------------------------------------------------------

void MyXmppClient::connectToXmppServer() {
    QXmppConfiguration xmppConfig;

    xmppConfig.setJid( m_myjid );
    xmppConfig.setPassword( m_password );
    xmppConfig.setKeepAliveInterval( m_keepAlive );
    xmppConfig.setAutoAcceptSubscriptions(false);
    xmppConfig.setSaslAuthMechanism("DIGEST-MD5");
    xmppConfig.setUseSASLAuthentication(true);
    xmppConfig.setStreamSecurityMode(QXmppConfiguration::TLSRequired);

    /*******************/

    if( m_resource.isEmpty() || m_resource.isNull() ) xmppConfig.setResource( "Lightbulb" ); else xmppConfig.setResource( m_resource );

    if( !m_host.isEmpty() ) xmppConfig.setHost( m_host );
    if( m_port != 0 ) xmppConfig.setPort( m_port );

    xmppClient->connectToServer( xmppConfig );
}

void MyXmppClient::clientStateChanged(QXmppClient::State state) {
    StateConnect before = m_stateConnect;
    if( state == QXmppClient::ConnectingState ) m_stateConnect = Connecting;
    else if( state == QXmppClient::ConnectedState ) {
        m_stateConnect = Connected;

        if( !rosterManager )
            initRosterManager();

        QXmppPresence pr = xmppClient->clientPresence();
        this->presenceReceived( pr );
    }
    else if( state == QXmppClient::DisconnectedState ) {
        m_stateConnect = Disconnect;
        this->setMyPresence( Offline, m_statusText );
    }
    if (m_stateConnect != before)
      emit connectingChanged(m_accountId); //check if stateConnect changed
}

void MyXmppClient::error(QXmppClient::Error e) {
    QString errString;
    if( e == QXmppClient::SocketError ) errString = "SOCKET_ERROR: " + xmppClient->socketErrorString();
    else if( e == QXmppClient::KeepAliveError ) errString = "KEEP_ALIVE_ERROR";
    else if( e == QXmppClient::XmppStreamError ) errString = "XMPP_STREAM_ERROR";

    if( !errString.isNull() ) {
        QXmppPresence pr = xmppClient->clientPresence();
        this->presenceReceived( pr );
        QXmppPresence presence( QXmppPresence::Unavailable );
        xmppClient->setClientPresence( presence );

        emit errorHappened(m_accountId,errString);
    }
}

// ---------- VCards -------------------------------------------------------------------------------------------------------------

void MyXmppClient::initVCard(const QXmppVCardIq &vCard)
{
    QString bareJid = vCard.from();
    vCardData dataVCard;

    // set nickname
    QXmppRosterIq::Item itemRoster = rosterManager->getRosterEntry( bareJid );
    QString nickName = vCard.nickName();
    if( (!nickName.isEmpty()) && (!nickName.isNull()) && (itemRoster.name().isEmpty()) ) {
        qDebug() << "MyXmppClient::initPresence: updating name for"<< bareJid;
        emit nameChanged(m_accountId,bareJid,nickName);
    }

    // avatar
    bool isAvatarCreated = true;
    QString avatarFile = cacheIM->getAvatarCache( bareJid );
    if( (avatarFile.isEmpty() || avatarFile == "qrc:/avatar") && vCard.photo() != "" && !disableAvatarCaching) {
        isAvatarCreated =  cacheIM->setAvatarCache( bareJid, vCard.photo() );
    }

    dataVCard.nickName = nickName;
    dataVCard.firstName = vCard.firstName();
    dataVCard.fullName = vCard.fullName();;
    dataVCard.middleName = vCard.middleName();
    dataVCard.lastName = vCard.lastName();
    dataVCard.url = vCard.url();
    dataVCard.eMail = vCard.email();

    cacheIM->setVCard( bareJid, dataVCard );

    if (bareJid == m_myjid) {
        emit iFoundYourParentsGoddamit(m_myjid);
      }
}

// ---------- handling messages (receiving/sending) ------------------------------------------------------------------------------

bool MyXmppClient::sendMessage(QString bareJid, QString resource, QString msgBody, int chatState, int msgType) {
    if (m_stateConnect != Connected)
      return false; // if user not connected - BREAK

    QXmppMessage xmppMsg;

    if (resource == "")
      resource = "default";

    if (msgType == QXmppMessage::GroupChat) {
        qDebug() << "muc message lolololo";
        // finding a room
        QXmppMucRoom* room = mucRooms.value(bareJid);
        if (room != NULL)
            return room->sendMessage(msgBody);
        else
            return false;
      }

    xmppMsg.setTo( bareJid + "/" + resource );
    xmppMsg.setFrom( m_myjid + "/" + xmppClient->configuration().resource() );

    QDateTime currTime = QDateTime::currentDateTime();
    xmppMsg.setStamp( currTime );

    if (msgBody != "")
      xmppMsg.setBody(msgBody);

    xmppMsg.setState((QXmppMessage::State)chatState);
    xmppClient->sendPacket( xmppMsg );

    if (msgBody != "")
      emit insertMessage(m_accountId,this->getBareJidByJid(xmppMsg.to()),msgBody,QDateTime::currentDateTime().toString("dd-MM-yy hh:mm"),1,2,"");

    return true;
}

void MyXmppClient::messageReceivedSlot( const QXmppMessage &xmppMsg )
{
    QString bareJid_from = MyXmppClient::getBareJidByJid( xmppMsg.from() );

    if( xmppMsg.state() == QXmppMessage::Active ) qDebug() << "Msg state is QXmppMessage::Active";
    else if( xmppMsg.state() == QXmppMessage::Inactive ) qDebug() << "Msg state is QXmppMessage::Inactive";
    else if( xmppMsg.state() == QXmppMessage::Gone ) {
        emit insertMessage(m_accountId,this->getBareJidByJid(xmppMsg.from()),"has left the conversation.",QDateTime::currentDateTime().toString("dd-MM-yy hh:mm"),0,4,getResourceByJid(xmppMsg.from()));
        qDebug() << "Msg state is QXmppMessage::Gone";
    }
    else if( xmppMsg.state() == QXmppMessage::Composing ) {
        if (bareJid_from != "") {
            emit typingChanged(m_accountId,bareJid_from, true);
            qDebug() << bareJid_from << " is composing.";
        }
    }
    else if( xmppMsg.state() == QXmppMessage::Paused ) {
        if (bareJid_from != "") {
            emit typingChanged(m_accountId,bareJid_from, false);
            qDebug() << bareJid_from << " paused.";
        }
    } else {
        if (xmppMsg.isAttentionRequested()) {
            qDebug() << "brick";
            //qDebug() << "ZZZ: attentionRequest !!! from:" <<xmppMsg.from();
            //msgWrapper->attention( bareJid_from, false );
        }
        qDebug() << "MessageWrapper::messageReceived(): xmppMsg.state():" << xmppMsg.state();
    }
    if ( !( xmppMsg.body().isEmpty() || xmppMsg.body().isNull() || bareJid_from == m_myjid ) ) {
        m_bareJidLastMessage = getBareJidByJid(xmppMsg.from());
        m_resourceLastMessage = getResourceByJid(xmppMsg.from());

        if (xmppMsg.body().contains("http://talkgadget.google.com/talkgadget/joinpmuc") ||
            (xmppMsg.body().contains("invited you to the room") && xmppMsg.body().contains(getBareJidByJid(xmppMsg.from()))))
          {
            emit mucInvitationReceived(m_accountId,getBareJidByJid(xmppMsg.from()),getBareJidByJid(xmppMsg.body().split(" ").at(0)),"");
            return;
          }

        int isMine = 0;
        if (xmppMsg.type() == QXmppMessage::GroupChat)
            if (getMUCNick(bareJid_from) == getResourceByJid(xmppMsg.from()))
                isMine = 1;

        emit insertMessage(m_accountId,this->getBareJidByJid(xmppMsg.from()),xmppMsg.body(),QDateTime::currentDateTime().toString("dd-MM-yy hh:mm"),isMine,xmppMsg.type(),getResourceByJid(xmppMsg.from()));
    }
}

// ---------- presence -----------------------------------------------------------------------------------------------------------

void MyXmppClient::initPresence(const QString& bareJid, const QString& resource)
{
    QXmppPresence xmppPresence = rosterManager->getPresence( bareJid, resource );
    QXmppPresence::Type statusJid = xmppPresence.type();

    QStringList _listResources = this->getResourcesByJid( bareJid );
    if( (_listResources.count() > 0) && (!_listResources.contains(resource)) ) {
        qDebug() << bareJid << "/" << resource << " ****************[" <<_listResources<<"]" ;
        if( statusJid == QXmppPresence::Unavailable )
            return;
    }

    QString picStatus = this->getPicPresence( xmppPresence );
    QString txtStatus = this->getTextStatus( xmppPresence.statusText(), xmppPresence );

    emit presenceChanged(m_accountId,bareJid,resource,picStatus,txtStatus);
}

void MyXmppClient::presenceReceived( const QXmppPresence & presence ) {
    QString bareJid = getBareJidByJid(presence.from());
    QString resource = getResourceByJid(presence.from());

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
            }
        }
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

QString MyXmppClient::getTextStatus(const QString &textStatus, const QXmppPresence &presence ) const {
  if (!textStatus.isEmpty() && !textStatus.isNull())
    return textStatus;
  else return "";
}

void MyXmppClient::setStatusText( const QString &__statusText )
{
    if( __statusText != m_statusText ) {
        m_statusText=__statusText;

        QXmppPresence myPresence = xmppClient->clientPresence();
        myPresence.setStatusText( __statusText );
        xmppClient->setClientPresence( myPresence );

        emit statusTextChanged();
    }
}

void MyXmppClient::setStatus( StatusXmpp __status) {
    if (__status != m_status || xmppClient->state() == QXmppClient::ConnectingState) {
        QXmppPresence myPresence = xmppClient->clientPresence();

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
          case Online:
            myPresence.setAvailableStatusType( QXmppPresence::Online );
            break;
          case Chat:
            myPresence.setAvailableStatusType( QXmppPresence::Chat );
            break;
          case Away:
            myPresence.setAvailableStatusType( QXmppPresence::Away );
            break;
          case XA:
            myPresence.setAvailableStatusType( QXmppPresence::XA );
            break;
          case DND:
            myPresence.setAvailableStatusType( QXmppPresence::DND );
            break;
          case Offline:
            m_status = __status;
            break;
          default: break;
        }
        xmppClient->setClientPresence( myPresence );
        this->presenceReceived( myPresence );
    }
}

void MyXmppClient::setMyPresence( StatusXmpp status, QString textStatus ) { //Q_INVOKABLE
    qDebug() << "MyXmppClient:: setMyPresence() called";
    if( textStatus != m_statusText ) {
        m_statusText =textStatus;
        emit statusTextChanged();
    }

    setStatusText( textStatus );
    setStatus( status );
}

// ---------- roster management --------------------------------------------------------------------------------------------------

void MyXmppClient::initRosterManager() {
  rosterManager = &xmppClient->rosterManager();

  qDebug() << "MyXmppClient::clientStateChanged(): initializing roster manager";

  QObject::connect( rosterManager, SIGNAL(presenceChanged(QString,QString)), this, SLOT(initPresence(const QString, const QString)), Qt::UniqueConnection );
  QObject::connect( rosterManager, SIGNAL(rosterReceived()), this, SLOT(initRoster()), Qt::UniqueConnection );
  QObject::connect( rosterManager, SIGNAL(subscriptionReceived(QString)), this, SLOT(notifyNewSubscription(QString)), Qt::UniqueConnection );
  QObject::connect( rosterManager, SIGNAL(itemAdded(QString)), this, SLOT(itemAdded(QString)), Qt::UniqueConnection );
  QObject::connect( rosterManager, SIGNAL(itemRemoved(QString)), this, SLOT(itemRemoved(QString)), Qt::UniqueConnection );
  QObject::connect( rosterManager, SIGNAL(itemChanged(QString)), this, SLOT(itemChanged(QString)), Qt::UniqueConnection );
}

void MyXmppClient::initRoster() {
    qDebug() << "MyXmppClient::initRoster() called";
    if (!rosterManager->isRosterReceived()) {
        qDebug() << "MyXmppClient::initRoster(): roster not available yet";
        return;
    }

    QStringList listBareJids = rosterManager->getRosterBareJids();

    for( int j=0; j < listBareJids.length(); j++ )
    {
        QString bareJid = listBareJids.at(j);

        cacheIM->addCacheJid( bareJid );

        QXmppRosterIq::Item itemRoster = rosterManager->getRosterEntry( bareJid );
        QString name = itemRoster.name();
        vCardData vCdata = cacheIM->getVCard( bareJid );

        if ( vCdata.isEmpty() ) {
            qDebug() << "MyXmppClient::initRoster():" << bareJid << "has no VCard. Requesting.";
            vCardManager->requestVCard( bareJid );
        }
        emit contactAdded(m_accountId,bareJid,name);
    }

    vCardData vCdata = cacheIM->getVCard( m_myjid );
    if ( vCdata.isEmpty() ) {
        qDebug() << "MyXmppClient::initRoster():" << m_myjid << "has no VCard. Requesting.";
        cacheIM->addCacheJid(m_myjid);
        vCardManager->requestVCard( m_myjid );
    }
}

void MyXmppClient::itemAdded(const QString &bareJid ) {
    QStringList resourcesList = rosterManager->getResources( bareJid );

    for( int L = 0; L<resourcesList.length(); L++ ) {
        QString resource = resourcesList.at(L);
        this->initPresence( bareJid, resource );
    }

    emit contactAdded(m_accountId,bareJid,"");
}

void MyXmppClient::itemChanged(const QString &bareJid ) {
  QXmppRosterIq::Item rosterEntry = rosterManager->getRosterEntry( bareJid );
  emit nameChanged(m_accountId,bareJid,rosterEntry.name());
}

void MyXmppClient::itemRemoved(const QString &bareJid ) {
  emit contactRemoved(m_accountId,bareJid);
}

void MyXmppClient::addContact( QString bareJid, QString nick, QString group, bool sendSubscribe ) {
    if( rosterManager ) {
        QSet<QString> gr;
        QString n;
        if( !(group.isEmpty() || group.isNull()) )  { gr.insert( group ); }
        if( !(nick.isEmpty() || nick.isNull()) )  { n = nick; }
        rosterManager->addItem(bareJid, n, gr );

        if( sendSubscribe ) rosterManager->subscribe( bareJid );
    }
}

//----------- get information by JID ---------------------------------------------------------------------------------------------

QString MyXmppClient::getBareJidByJid( const QString &jid ) {
  if (jid.indexOf('/') >= 0)
    return jid.split('/')[0];
  else return jid;
}

QString MyXmppClient::getResourceByJid( const QString &jid ) {
  if (jid.indexOf('/') >= 0)
    return jid.split('/')[1];
  else return "";
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
  emit insertMessage(m_accountId,room->jid(),"Chatroom subject is \n" + subject,QDateTime::currentDateTime().toString("dd-MM-yy hh:mm"),0,4,"");
}

void MyXmppClient::permissionsReceived(const QList<QXmppMucItem> &permissions) {
  qDebug() << "received permissions;" << permissions.count();
  for (int i=0;i<permissions.count();i++) {
      QString nameString = permissions.at(i).nick() + " (" + permissions.at(i).jid() + ")";
      qDebug() << "Permissions for" << qPrintable(nameString);
      qDebug() << "Role:" << permissions.at(i).roleToString(permissions.at(i).role());
      qDebug() << "Affiliation:" << permissions.at(i).affiliationToString(permissions.at(i).affiliation());
    }
}

void MyXmppClient::mucErrorSlot(const QXmppStanza::Error &error) {
  QXmppMucRoom* room = (QXmppMucRoom*)sender();
  emit insertMessage(m_accountId,room->jid(),"[[ERR]] Error " + QString::number(error.code()) + " occured",QDateTime::currentDateTime().toString("dd-MM-yy hh:mm"),0,4,"");
}
void MyXmppClient::mucKickedSlot(const QString &jid, const QString &reason) {
  QXmppMucRoom* room = (QXmppMucRoom*)sender();
  QString body = "[[ERR]] You've been [[bold]]kicked out[[/bold]] of the room";
  if (reason != "")
    body += ". Reason: [[bold]]" + reason + "[[/bold]]";
  emit insertMessage(m_accountId,room->jid(),body,QDateTime::currentDateTime().toString("dd-MM-yy hh:mm"),0,4,getResourceByJid(jid));
}
void MyXmppClient::mucRoomNameChangedSlot(const QString &name) {
  QXmppMucRoom* room = (QXmppMucRoom*)sender();
  emit insertMessage(m_accountId,room->jid(),"[[INFO]] Room name is \n[[bold]]" + name + "[[/bold]]",QDateTime::currentDateTime().toString("dd-MM-yy hh:mm"),0,4,"");
  emit mucNameChanged(m_accountId,room->jid(),name);
}
void MyXmppClient::mucYourNickChanged(const QString &nickName) {
  QXmppMucRoom* room = (QXmppMucRoom*)sender();
  emit insertMessage(m_accountId,room->jid(),"[[INFO]] Your nickname was changed to \"" + nickName + "\"",QDateTime::currentDateTime().toString("dd-MM-yy hh:mm"),0,4,"");
}
void MyXmppClient::mucParticipantAddedSlot(const QString &jid) {
  QXmppMucRoom* room = (QXmppMucRoom*)sender();
  if (room->nickName() == getResourceByJid(jid) || !room->isJoined())
    return;
  emit insertMessage(m_accountId,room->jid(),"[[INFO]] [[bold]][[mucName]][[/bold]] has joined this room.",QDateTime::currentDateTime().toString("dd-MM-yy hh:mm"),0,4,getResourceByJid(jid));
}
void MyXmppClient::mucParticipantRemovedSlot(const QString &jid) {
  QXmppMucRoom* room = (QXmppMucRoom*)sender();
  if (room->nickName() == getResourceByJid(jid) || !room->isJoined())
    return;
  emit insertMessage(m_accountId,room->jid(),"[[INFO]] [[bold]][[mucName]][[/bold]] has left this room.",QDateTime::currentDateTime().toString("dd-MM-yy hh:mm"),0,4,getResourceByJid(jid));
}

// ---------- file transfer --------------------------------------------------------------------------------------------------------

void MyXmppClient::incomingTransfer(QXmppTransferJob *job) {
  qDebug() << "received file from" << job->jid() << "with filename" << job->fileName() << "and size" << job->fileSize();

  switch (job->method()) {
    case QXmppTransferJob::NoMethod:
      qDebug() << "no method o.o"; break;
    case QXmppTransferJob::InBandMethod:
      qDebug() << "InBandMethod"; break;
    case QXmppTransferJob::SocksMethod:
      qDebug() << "SocksMethod"; break;
    case QXmppTransferJob::AnyMethod:
      qDebug() << "Any method"; break;
  }

  job->accept("F://Received files//" + job->fileName());
}

// ------------------------//

void MyXmppClient::attentionSend( QString bareJid, QString resource ) {
    qDebug() << "MyXmppClient::attentionSend(" << bareJid << ";" << resource << ")";
    QXmppMessage xmppMsg;

    QString jid_to = bareJid;
    if( resource == "" ) {
        jid_to += "/resource";
    } else {
        jid_to += "/" + resource;
    }
    xmppMsg.setTo( jid_to );

    QString jid_from = m_myjid + "/" + xmppClient->configuration().resource();
    xmppMsg.setFrom( jid_from );

    xmppMsg.setReceiptRequested( false );

    xmppMsg.setState( QXmppMessage::None );
    xmppMsg.setType( QXmppMessage::Headline );
    xmppMsg.setAttentionRequested( true );

    xmppClient->sendPacket( xmppMsg );
}
