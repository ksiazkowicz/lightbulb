/********************************************************************

src/xmpp/MyXmppClient.cpp
-- wrapper between qxmpp library and XmppConnectivity

Copyright (c) 2013 Maciej Janiszewski
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

QString MyXmppClient::myVersion = "0.3.1";

MyXmppClient::MyXmppClient() : QObject(0) {
    xmppClient = new QXmppClient( this );
    QObject::connect( xmppClient, SIGNAL(stateChanged(QXmppClient::State)), this, SLOT(clientStateChanged(QXmppClient::State)) );
    QObject::connect( xmppClient, SIGNAL(messageReceived(QXmppMessage)), this, SLOT(messageReceivedSlot(QXmppMessage)) );
    QObject::connect( xmppClient, SIGNAL(presenceReceived(QXmppPresence)), this, SLOT(presenceReceived(QXmppPresence)) );
    QObject::connect( xmppClient, SIGNAL(error(QXmppClient::Error)), this, SLOT(error(QXmppClient::Error)) );

    m_status = Offline;
    m_keepAlive = 60;

    qmlVCard = new QMLVCard();

    xmppClient->versionManager().setClientName("Lightbulb");
    xmppClient->versionManager().setClientVersion( MyXmppClient::myVersion );

    rosterManager = 0;
    cacheIM = new MyCache();

    cachedRoster = new RosterListModel( this );

    vCardManager = &xmppClient->vCardManager();
    QObject::connect( vCardManager, SIGNAL(vCardReceived(const QXmppVCardIq &)),
                      this, SLOT(initVCard(const QXmppVCardIq &)),
                      Qt::UniqueConnection  );
}

MyXmppClient::~MyXmppClient() {
    if (cacheIM != NULL) delete cacheIM;
    if (cachedRoster != NULL) delete cachedRoster;
    if (vCardManager != NULL) delete vCardManager;
    if (xmppClient != NULL) delete xmppClient;
    if (qmlVCard != NULL) delete qmlVCard;
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
    xmppConfig.setStreamSecurityMode(QXmppConfiguration::TLSEnabled);

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
      emit connectingChanged(); //check if stateConnect changed
}

void MyXmppClient::error(QXmppClient::Error e) {
    QString errString;
    if( e == QXmppClient::SocketError ) errString = "SOCKET_ERROR";
    else if( e == QXmppClient::KeepAliveError ) errString = "KEEP_ALIVE_ERROR";
    else if( e == QXmppClient::XmppStreamError ) errString = "XMPP_STREAM_ERROR";

    if( !errString.isNull() ) {
        QXmppPresence pr = xmppClient->clientPresence();
        this->presenceReceived( pr );
        QXmppPresence presence( QXmppPresence::Unavailable );
        this->clearPresence();
        xmppClient->setClientPresence( presence );

        emit errorHappened( errString );
    }
}

// ---------- VCards -------------------------------------------------------------------------------------------------------------

void MyXmppClient::initVCard(const QXmppVCardIq &vCard)
{
    QString bareJid = vCard.from();

    RosterItemModel *item = (RosterItemModel*)cachedRoster->find( bareJid );

    vCardData dataVCard;

    if( item != 0 )
    {
        /* set nickname */
        QXmppRosterIq::Item itemRoster = rosterManager->getRosterEntry( bareJid );
        QString nickName = vCard.nickName();
        if( (!nickName.isEmpty()) && (!nickName.isNull()) && (itemRoster.name().isEmpty()) ) {
            qDebug() << "MyXmppClient::initPresence: updating name for"<< bareJid;
            item->setContactName( nickName );
        }

        /* avatar */
        bool isAvatarCreated = true;
        QString avatarFile = cacheIM->getAvatarCache( bareJid );
        if( (avatarFile.isEmpty() || avatarFile == "qrc:/avatar" || (flVCardRequest != "")) && vCard.photo() != "" ) {
            isAvatarCreated =  cacheIM->setAvatarCache( bareJid, vCard.photo() );
        }
        item->setAvatar(cacheIM->getAvatarCache(bareJid));

        dataVCard.nickName = nickName;
        dataVCard.firstName = vCard.firstName();
        dataVCard.fullName = vCard.fullName();;
        dataVCard.middleName = vCard.middleName();
        dataVCard.lastName = vCard.lastName();
        dataVCard.url = vCard.url();
        dataVCard.eMail = vCard.email();

        if( flVCardRequest == bareJid ) {
            qmlVCard->setPhoto( avatarFile );
            qmlVCard->setNickName( vCard.nickName() );
            qmlVCard->setMiddleName( vCard.middleName() );
            qmlVCard->setLastName( vCard.lastName() );
            qmlVCard->setFullName( vCard.fullName() );
            qmlVCard->setName( vCard.firstName() );
            qmlVCard->setBirthday( vCard.birthday().toString("dd.MM.yyyy") );
            qmlVCard->setEMail( vCard.email() );
            qmlVCard->setUrl( vCard.url() );
            qmlVCard->setJid( bareJid );
            flVCardRequest = "";
            emit vCardChanged();
        }

        cacheIM->setVCard( bareJid, dataVCard );
    }

}

void MyXmppClient::requestVCard(QString bareJid) //Q_INVOKABLE
{
    qDebug() << "MyXmppClient::requestVCard(" + bareJid + ") called";
    if (vCardManager && (flVCardRequest == "") ) {
        vCardManager->requestVCard( bareJid );
        flVCardRequest = bareJid;
    }
}

// ---------- Typing notifications (broken) --------------------------------------------------------------------------------------

/* it sends information about typing : typing is started */
void MyXmppClient::typingStart(QString bareJid, QString resource) {
    qDebug() << bareJid << " " << "start typing...";
    QXmppMessage xmppMsg;

    QString jid_to = bareJid;
    if( resource == "" ) jid_to += "/resource"; else jid_to += "/" + resource;
    xmppMsg.setTo( jid_to );

    QString jid_from = m_myjid + "/" + xmppClient->configuration().resource();
    xmppMsg.setFrom( jid_from );

    xmppMsg.setReceiptRequested( false );

    QDateTime currTime = QDateTime::currentDateTime();
    xmppMsg.setStamp( currTime );

    xmppMsg.setState( QXmppMessage::Composing );

    xmppClient->sendPacket( xmppMsg );
}

/* it sends information about typing : typing is stoped */
void MyXmppClient::typingStop(QString bareJid, QString resource) {
    qDebug() << bareJid << " " << "stop typing...";
    QXmppMessage xmppMsg;

    QString jid_to = bareJid;
    if( resource == "" ) jid_to += "/resource"; else jid_to += "/" + resource;
    xmppMsg.setTo( jid_to );

    QString jid_from = m_myjid + "/" + xmppClient->configuration().resource();
    xmppMsg.setFrom( jid_from );

    xmppMsg.setReceiptRequested( false );

    QDateTime currTime = QDateTime::currentDateTime();
    xmppMsg.setStamp( currTime );

    xmppMsg.setState( QXmppMessage::Paused );

    xmppClient->sendPacket( xmppMsg );
}

// ---------- handling messages (receiving/sending) ------------------------------------------------------------------------------

bool MyXmppClient::sendMyMessage(QString bareJid, QString resource, QString msgBody) //Q_INVOKABLE
{
    if (msgBody == "" || m_stateConnect != Connected) return false; // if message is empty or user not connected - BREAK

    QXmppMessage xmppMsg;

    QString jid_from = bareJid;
    if( resource == "" ) jid_from += "/resource"; else jid_from += "/" + resource;

    xmppMsg.setTo( jid_from );
    QString jid_to = m_myjid + "/" + xmppClient->configuration().resource();
    xmppMsg.setFrom( jid_to );

    xmppMsg.setBody( msgBody );

    xmppMsg.setState( QXmppMessage::Active );

    xmppClient->sendPacket( xmppMsg );

    this->messageReceivedSlot( xmppMsg );

    emit insertMessage(m_accountId,this->getBareJidByJid(xmppMsg.to()),msgBody,QDateTime::currentDateTime().toString("dd-MM-yy hh:mm"),1);

    return true;
}

void MyXmppClient::messageReceivedSlot( const QXmppMessage &xmppMsg )
{
    QString bareJid_from = MyXmppClient::getBareJidByJid( xmppMsg.from() );
    QString bareJid_to = MyXmppClient::getBareJidByJid( xmppMsg.to() );

    if( xmppMsg.state() == QXmppMessage::Active ) qDebug() << "Msg state is QXmppMessage::Active";
    else if( xmppMsg.state() == QXmppMessage::Inactive ) qDebug() << "Msg state is QXmppMessage::Inactive";
    else if( xmppMsg.state() == QXmppMessage::Gone ) qDebug() << "Msg state is QXmppMessage::Gone";
    else if( xmppMsg.state() == QXmppMessage::Composing ) {
        if (bareJid_from != "") {
            m_flTyping = true;
            emit typingChanged( bareJid_from, true);
            qDebug() << bareJid_from << " is composing.";
        }
    }
    else if( xmppMsg.state() == QXmppMessage::Paused ) {
        if (bareJid_from != "") {
            m_flTyping = false;
            emit typingChanged( bareJid_from, false);
            qDebug() << bareJid_from << " paused.";
        }
    } else {
        if( xmppMsg.isAttentionRequested() )
        {
            //qDebug() << "ZZZ: attentionRequest !!! from:" <<xmppMsg.from();
            //msgWrapper->attention( bareJid_from, false );
        }
        qDebug() << "MessageWrapper::messageReceived(): xmppMsg.state():" << xmppMsg.state();
    }
    if ( !( xmppMsg.body().isEmpty() || xmppMsg.body().isNull() || bareJid_from == m_myjid ) ) {
        m_bareJidLastMessage = getBareJidByJid(xmppMsg.from());
        m_resourceLastMessage = getResourceByJid(xmppMsg.from());

        this->openChat( bareJid_from );

        RosterItemModel *item = (RosterItemModel*)cachedRoster->find( bareJid_from );
        if( item != 0 ) { int cnt = item->unreadMsg(); item->setUnreadMsg( ++cnt ); } else {
          RosterItemModel *itemModel = new RosterItemModel( );
          itemModel->setPresence( this->getPicPresence( QXmppPresence::Unavailable ) );
          itemModel->setContactName( bareJid_from );
          itemModel->setJid( bareJid_from );
          itemModel->setUnreadMsg( 1 );
          itemModel->setStatusText( "");
          cachedRoster->append(itemModel);
          itemModel = 0;
          delete itemModel;
        }
        item = 0; delete item;

        emit insertMessage(m_accountId,this->getBareJidByJid(xmppMsg.from()),xmppMsg.body(),QDateTime::currentDateTime().toString("dd-MM-yy hh:mm"),0);
    }
}

// ---------- presence -----------------------------------------------------------------------------------------------------------

void MyXmppClient::initPresence(const QString& bareJid, const QString& resource)
{
    int indxItem = -1;
    RosterItemModel *item = (RosterItemModel*)cachedRoster->find( bareJid, indxItem );

    if( item == 0 ) {
        return;
    }

    QXmppPresence xmppPresence = rosterManager->getPresence( bareJid, resource );
    QXmppPresence::Type statusJid = xmppPresence.type();

    QStringList _listResources = this->getResourcesByJid( bareJid );
    if( (_listResources.count() > 0) && (!_listResources.contains(resource)) )
    {
        qDebug() << bareJid << "/" << resource << " ****************[" <<_listResources<<"]" ;
        if( statusJid == QXmppPresence::Unavailable ) {
            return;
        }
    }

    item->setResource( resource );

    QString picStatus = this->getPicPresence( xmppPresence );
    item->setPresence( picStatus );

    QString txtStatus = this->getTextStatus( xmppPresence.statusText(), xmppPresence );
    item->setStatusText( txtStatus );

    RosterItemModel *itemExists = (RosterItemModel*)cachedRoster->find( bareJid, indxItem );

    if( itemExists != 0 ) {
        itemExists->copy( item );
        QString picStatusPrev = itemExists->presence();
        if( picStatusPrev != picStatus )
        {
            //emit presenceJidChanged( bareJid, txtStatus, picStatus );
            emit rosterChanged();
        }
    }
    item = 0; itemExists = 0;
    delete item; delete itemExists;

    emit contactStatusChanged(m_accountId,bareJid);
}

void MyXmppClient::presenceReceived( const QXmppPresence & presence ) {
    QString bareJid = getBareJidByJid(presence.from());
    QString resource = getResourceByJid(presence.from());

    QString myResource = xmppClient->configuration().resource();

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
        emit statusChanged();
    }
}

QString MyXmppClient::getPicPresence( const QXmppPresence &presence ) const
{
    QString picPresenceName;
    QXmppPresence::Type status = presence.type();
    if( status != QXmppPresence::Available ) picPresenceName = "qrc:/presence/offline";
    else
    {
        QXmppPresence::AvailableStatusType availableStatus = presence.availableStatusType();
        if( availableStatus == QXmppPresence::Online ) picPresenceName = "qrc:/presence/online";
        else if ( availableStatus == QXmppPresence::Chat ) picPresenceName = "qrc:/presence/chatty";
        else if ( availableStatus == QXmppPresence::Away ) picPresenceName = "qrc:/presence/away";
        else if ( availableStatus == QXmppPresence::XA ) picPresenceName = "qrc:/presence/xa";
        else if ( availableStatus == QXmppPresence::DND ) picPresenceName = "qrc:/presence/busy";
    }

    return picPresenceName;
}

QString MyXmppClient::getTextStatus(const QString &textStatus, const QXmppPresence &presence ) const
{
  if( (!textStatus.isEmpty()) && (!textStatus.isNull()) ) return textStatus; else return "";
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
            this->clearPresence();
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

    setStatus( status );
    setStatusText( textStatus );
}

// ---------- roster management --------------------------------------------------------------------------------------------------

void MyXmppClient::initRosterManager() {
  rosterManager = &xmppClient->rosterManager();

  qDebug() << "MyXmppClient::clientStateChanged(): initializing roster manager";

  QObject::connect( rosterManager, SIGNAL(presenceChanged(QString,QString)), this, SLOT(initPresence(const QString, const QString)), Qt::UniqueConnection );
  QObject::connect( rosterManager, SIGNAL(rosterReceived()), this, SLOT(initRoster()), Qt::UniqueConnection );
  QObject::connect( rosterManager, SIGNAL(subscriptionReceived(QString)), this, SIGNAL(subscriptionReceived(QString)), Qt::UniqueConnection );
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

    cachedRoster->cleanList();

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
        RosterItemModel *itemExists = (RosterItemModel*)cachedRoster->find(bareJid);
        if (itemExists == 0) {
          RosterItemModel *itemModel = new RosterItemModel( );
          itemModel->setPresence( this->getPicPresence( QXmppPresence::Unavailable ) );
          itemModel->setContactName( name );
          itemModel->setJid( bareJid );
          itemModel->setAvatar(cacheIM->getAvatarCache(bareJid));
          cachedRoster->append(itemModel);
          itemModel = 0;
          delete itemModel;
        } else if (itemExists->name() != name) {
          itemExists->setContactName(name);
          emit contactRenamed(bareJid,name);
        }
        itemExists = 0; delete itemExists;
    }
    emit rosterChanged();
}

void MyXmppClient::clearPresence() {
    qDebug() << "MyXmppClient::clearPresence() called";

    for( int j=0; j < cachedRoster->rowCount(); j++ ) {
        RosterItemModel *itemExists = (RosterItemModel*)cachedRoster->getElementByID(j);
        if (itemExists != 0) {
          itemExists->setPresence( this->getPicPresence( QXmppPresence::Unavailable ) );
        }
        itemExists = 0; delete itemExists;
    }
    emit rosterChanged();
}

void MyXmppClient::itemAdded(const QString &bareJid ) {
    qDebug() << "MyXmppClient::itemAdded(): " << bareJid;
    QStringList resourcesList = rosterManager->getResources( bareJid );

    RosterItemModel *itemExists = (RosterItemModel*)cachedRoster->find(bareJid);

    if (itemExists == 0) {
      RosterItemModel *itemModel = new RosterItemModel( );
      itemModel->setPresence( this->getPicPresence(QXmppPresence::Unavailable) );
      itemModel->setJid( bareJid );
      itemModel->setAvatar(cacheIM->getAvatarCache(bareJid));
      cachedRoster->append( itemModel );
      itemModel = 0; delete itemModel;
    };
    itemExists = 0; delete itemExists;

    for( int L = 0; L<resourcesList.length(); L++ ) {
        QString resource = resourcesList.at(L);
        this->initPresence( bareJid, resource );
    }
}

void MyXmppClient::itemChanged(const QString &bareJid ) {
    qDebug() << "MyXmppClient::itemChanged(): " << bareJid;

    QXmppRosterIq::Item rosterEntry = rosterManager->getRosterEntry( bareJid );
    if (rosterEntry.name() != "") {
        RosterItemModel *item = (RosterItemModel*)cachedRoster->find( bareJid );
        if( item != 0 ) item->setContactName( rosterEntry.name() );
        emit contactRenamed(bareJid,rosterEntry.name());
        item = 0; delete item;
    }
}

void MyXmppClient::itemRemoved(const QString &bareJid ) {
    qDebug() << "MyXmppClient::itemRemoved(): " << bareJid;

    int indxItem = -1;
    RosterItemModel *itemExists = (RosterItemModel*)cachedRoster->find( bareJid, indxItem );
    if( itemExists ) if( indxItem >= 0 ) cachedRoster->takeRow( indxItem );
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

QString MyXmppClient::getPropertyByJid( QString bareJid, QString property ) {
    RosterItemModel *item = (RosterItemModel*)cachedRoster->find( bareJid );
    if (item != 0) {
      if (property == "name") return item->name();
      else if (property == "presence") return item->presence();
      else if (property == "resource") return item->resource();
      else if (property == "statusText") return item->statusText();
      else if (property == "unreadMsg") return QString::number(item->unreadMsg());
      } else return "(unknown)";
}

QString MyXmppClient::getPropertyByOrderID(int id, QString property) {
  bool onlineContactFound;
  int  iterations = id;
  while (!onlineContactFound && cachedRoster->count() >= id+1) {
    RosterItemModel *item = (RosterItemModel*)cachedRoster->getElementByID(id);
    if (item != 0) {
        if (item->presence() != "qrc:/presence/offline") {
            if (iterations == 0) return getPropertyByJid(item->jid(),property);
            else iterations--;
        }
        id++;
    } else break;
  }
  return "";
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
