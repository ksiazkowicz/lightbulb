#include "MyXmppClient.h"

#include "QXmppRosterManager.h"
#include "QXmppVersionManager.h"
#include "QXmppConfiguration.h"
#include "QXmppClient.h"
#include "DatabaseManager.h"

#include <QDebug>
#include <QCryptographicHash>
#include <QFile>
#include <QDir>

QString MyXmppClient::myVersion = "0.1.1";

QString MyXmppClient::getBareJidByJid( const QString &jid )
{
    QString bareJid = jid;
    if( jid.indexOf('/') >= 0 ) {
        bareJid = jid.split('/')[0];
    }
    return bareJid;
}

MyXmppClient::MyXmppClient() : QObject(0)
{
    cacheIM = new MyCache(this);
    msgWrapper = new MessageWrapper(this);

    database = new DatabaseManager(this);
    database->openDB();
    database->initDB();

    xmppClient = new QXmppClient( this );
    QObject::connect( xmppClient, SIGNAL(stateChanged(QXmppClient::State)), this, SLOT(clientStateChanged(QXmppClient::State)) );
    QObject::connect( xmppClient, SIGNAL(messageReceived(QXmppMessage)), this, SLOT(messageReceivedSlot(QXmppMessage)) );
    QObject::connect( xmppClient, SIGNAL(presenceReceived(QXmppPresence)), this, SLOT(presenceReceived(QXmppPresence)) );
    QObject::connect( xmppClient, SIGNAL(error(QXmppClient::Error)), this, SLOT(error(QXmppClient::Error)) );

    QObject::connect( msgWrapper, SIGNAL(openChat(QString)), this, SLOT(openChat(QString)) );
    //QObject::connect( msgWrapper, SIGNAL(sendMyMsg(QXmppMessage)), xmppClient, SLOT(sendPacket(QXmppPacket)) );

    xmppMessageReceiptManager = new QXmppMessageReceiptManager();
    QObject::connect( xmppMessageReceiptManager, SIGNAL(messageDelivered(QString,QString)), msgWrapper, SLOT(messageDelivered(QString,QString)) );

    listModelChats = new ChatsListModel( this );
    listModelRoster = new RosterListModel( this );

    m_bareJidLastMessage = "";
    m_resourceLastMessage = "";
    m_stateConnect = Disconnect;
    m_status = Offline;
    m_statusText = "";
    m_flTyping = false;
    m_myjid = "";
    m_password = "";
    m_host = "";
    m_port= 0;
    m_resource = "";
    m_chatJid = "";
    m_contactName = "";
    m_reconnectOnError = false;
    m_keepAlive = 60;
    m_archiveIncMessage = false;
    accounts = 0;

    flVCardRequest = "";
    qmlVCard = new QMLVCard();

    this->initXmppClient();

    rosterManager = 0;

    flSetPresenceWithoutAck = true;
}


MyXmppClient::~MyXmppClient()
{
    if( cacheIM != NULL) {
        delete cacheIM;
    }

    if( msgWrapper != NULL) {
        delete msgWrapper;
    }
}

void MyXmppClient::initXmppClient()
{
    /* init home directory */
    cacheIM->createHomeDir();

    xmppClient->versionManager().setClientName("Lightbulb");
    xmppClient->versionManager().setClientVersion( MyXmppClient::myVersion );

    /* add extension */
    xmppClient->addExtension( xmppMessageReceiptManager );
}

void MyXmppClient::clientStateChanged(QXmppClient::State state)
{
    if( state == QXmppClient::ConnectingState )
    {
        m_stateConnect = Connecting;
    }
    else if( state == QXmppClient::ConnectedState )
    {
        m_stateConnect = Connected;

        if( !rosterManager )
        {
            rosterManager = &xmppClient->rosterManager();
            qDebug() << Q_FUNC_INFO << " QObject::connect( rosterManager, SIGNAL(........).....)";
            QObject::connect( rosterManager, SIGNAL(presenceChanged(QString,QString)), this, SLOT(initPresence(const QString, const QString)), Qt::UniqueConnection );
            QObject::connect( rosterManager, SIGNAL(rosterReceived()), this, SLOT(initRoster()), Qt::UniqueConnection );
            QObject::connect( rosterManager, SIGNAL(subscriptionReceived(QString)), this, SLOT(subscriptionReceivedSlot(QString)), Qt::UniqueConnection );
            QObject::connect( rosterManager, SIGNAL(itemAdded(QString)), this, SLOT(itemAdded(QString)), Qt::UniqueConnection );
            QObject::connect( rosterManager, SIGNAL(itemRemoved(QString)), this, SLOT(itemRemoved(QString)), Qt::UniqueConnection );
            QObject::connect( rosterManager, SIGNAL(itemChanged(QString)), this, SLOT(itemChanged(QString)), Qt::UniqueConnection );
        }

        QXmppPresence pr = xmppClient->clientPresence();
        this->presenceReceived( pr );
    }
    else if( state == QXmppClient::DisconnectedState )
    {
        m_stateConnect = Disconnect;
        this->setMyPresence( Offline, m_statusText );
    }
    emit connectingChanged();
}

void MyXmppClient::connectToXmppServer() //Q_INVOKABLE
{
    //xmppConfig = mimOpt->getDefaultAccount();
    msgWrapper->setMyJid( m_myjid );

    QXmppConfiguration xmppConfig;

    xmppConfig.setJid( m_myjid );
    xmppConfig.setPassword( m_password );
    xmppConfig.setKeepAliveInterval( m_keepAlive );
    xmppConfig.setAutoAcceptSubscriptions(false);

    /*******************/
    xmppConfig.setAutoReconnectionEnabled( m_reconnectOnError );

    if( m_resource.isEmpty() || m_resource.isNull() ) {
        xmppConfig.setResource( "Lightbulb" );
    } else {
        xmppConfig.setResource( m_resource );
    }

    if( !m_host.isEmpty() ) { xmppConfig.setHost( m_host ); }
    if( m_port != 0 ) { xmppConfig.setPort( m_port ); }

    xmppClient->connectToServer( xmppConfig );

}

void MyXmppClient::disconnectFromXmppServer() //Q_INVOKABLE
{
    xmppClient->disconnectFromServer();
}

/* it initialises the list of contacts - roster */
void MyXmppClient::initRoster()
{
    qDebug() << "MyXmppClient::initRoster() has been called";
    if( ! rosterManager->isRosterReceived() ) {
        qDebug() << "MyXmppClient::initRoster(): roster has not received yet";
        return;
    }

    if( !vCardManager )
    {
        vCardManager = &xmppClient->vCardManager();
        QObject::connect( vCardManager, SIGNAL(vCardReceived(const QXmppVCardIq &)),
                          this, SLOT(initVCard(const QXmppVCardIq &)),
                          Qt::UniqueConnection  );
    }

    listModelRoster->takeRows(0, listModelRoster->count() );

    QStringList listBareJids = rosterManager->getRosterBareJids();
    for( int j=0; j < listBareJids.length(); j++ )
    {
        QString bareJid = listBareJids.at(j);

        cacheIM->addCacheJid( bareJid );

        QXmppRosterIq::Item itemRoster = rosterManager->getRosterEntry( bareJid );
        QString name = itemRoster.name();
        QList<QString> listOfGroup = itemRoster.groups().toList();
        QString group = "";
        if( listOfGroup.length() > 0 ) {
            group = listOfGroup.at(0);
        }
        QString avatarPath = cacheIM->getAvatarCache( bareJid );
        vCardData vCdata = cacheIM->getVCard( bareJid );

        if ( avatarPath.isEmpty() && vCdata.isEmpty() )
        {
            vCardManager->requestVCard( bareJid );
        }
        else
        {
            QString nickName = vCdata.nickName;
            if( (!nickName.isEmpty()) && (!nickName.isNull()) && (itemRoster.name().isEmpty()) ) {
                name =  nickName;
            }
        }

        RosterItemModel *itemModel = new RosterItemModel( );
        itemModel->setGroup( group );
        itemModel->setPicStatus( this->getPicPresence( QXmppPresence::Unavailable ) );
        itemModel->setContactName( name );
        itemModel->setJid( bareJid );
        itemModel->setAvatar( avatarPath );
        itemModel->setUnreadMsg( 0 );

        listModelRoster->append(itemModel);
    }
    emit rosterChanged();

}

void MyXmppClient::initPresence(const QString& bareJid, const QString& resource)
{
    int indxItem = -1;
    RosterItemModel *item = (RosterItemModel*)listModelRoster->find( bareJid, indxItem );

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
    item->setPicStatus( picStatus );

    QString txtStatus = this->getTextStatus( xmppPresence.statusText(), xmppPresence );
    item->setTextStatus( txtStatus );

    RosterItemModel *itemExists = (RosterItemModel*)listModelRoster->find( bareJid, indxItem );

    if( itemExists != 0 ) {
        itemExists->copy( item );
        QString picStatusPrev = itemExists->picStatus();
        if( picStatusPrev != picStatus )
        {
            emit presenceJidChanged( bareJid, txtStatus, picStatus );
        }
    }

    RosterItemModel* item_chat = reinterpret_cast<RosterItemModel*>( listModelChats->find( bareJid ) );
    if( item_chat )
    {
        item_chat->setResource( resource );
        item_chat->setPicStatus( picStatus );
        item_chat->setTextStatus( txtStatus );
    }
}

QString MyXmppClient::getPicPresence( const QXmppPresence &presence ) const
{
    QString picPresenceName = "qrc:/qml/images/presence-unknown.png";

    QXmppPresence::Type status = presence.type();
    if( status != QXmppPresence::Available )
    {
        picPresenceName = "qrc:/qml/images/presence-offline.svg";
    }
    else
    {
        QXmppPresence::AvailableStatusType availableStatus = presence.availableStatusType();
        if( availableStatus == QXmppPresence::Online ) {
            picPresenceName = "qrc:/qml/images/presence-online.svg";
        } else if ( availableStatus == QXmppPresence::Chat ) {
            picPresenceName = "qrc:/qml/images/presence-chatty.svg";
        } else if ( availableStatus == QXmppPresence::Away ) {
            picPresenceName = "qrc:/qml/images/presence-away.svg";
        } else if ( availableStatus == QXmppPresence::XA ) {
            picPresenceName = "qrc:/qml/images/presence-xa.svg";
        } else if ( availableStatus == QXmppPresence::DND ) {
            picPresenceName = "qrc:/qml/images/presence-busy.svg";
        }
    }

    return picPresenceName;
}

QString MyXmppClient::getTextStatus(const QString &textStatus, const QXmppPresence &presence ) const
{
    if( (!textStatus.isEmpty()) && (!textStatus.isNull()) ) {
        return textStatus;
    }

    QXmppPresence::Type status = presence.type();

    QString txtStat = "";
    if( status == QXmppPresence::Unavailable )
    {
        txtStat = "Offline";
    }
    else
    {
        QXmppPresence::AvailableStatusType availableStatus = presence.availableStatusType();

        if( availableStatus == QXmppPresence::Online ) {
            txtStat = "Online";
        } else if ( availableStatus == QXmppPresence::Chat ) {
            txtStat = "Chatty";
        } else if ( availableStatus == QXmppPresence::Away ) {
            txtStat = "Away";
        } else if ( availableStatus == QXmppPresence::XA ) {
            txtStat = "Extended away";
        } else if ( availableStatus == QXmppPresence::DND ) {
            txtStat = "Do not disturb";
        }
    }

    return txtStat;
}



/* SLOT: it will be called when the vCardReceived signal will be received */
void MyXmppClient::initVCard(const QXmppVCardIq &vCard)
{
    QString bareJid = vCard.from();
    //qDebug() << "## initVCard: " << bareJid;

    RosterItemModel *item = (RosterItemModel*)listModelRoster->find( bareJid );

    vCardData dataVCard;

    if( /*item != 0*/true )
    {
        /* set nickname */
        QXmppRosterIq::Item itemRoster = rosterManager->getRosterEntry( bareJid );
        QString nickName = vCard.nickName();
        if( (!nickName.isEmpty()) && (!nickName.isNull()) && (itemRoster.name().isEmpty()) && (item!=0) ) {
            item->setContactName( nickName );
        }

        /* avatar */
        bool isAvatarCreated = true;
        QString avatarFile = cacheIM->getAvatarCache( bareJid );
        if( avatarFile.isEmpty() || (flVCardRequest != "") ) {
            isAvatarCreated =  cacheIM->setAvatarCache( bareJid, vCard.photo() );
            avatarFile = cacheIM->getAvatarCache( bareJid );
        }
        if( isAvatarCreated ) {
            if( item != 0 ) {
                item->setAvatar( avatarFile );
            }
        }

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


void MyXmppClient::setStatusText( const QString &__statusText )
{
    if( __statusText != m_statusText )
    {
        m_statusText=__statusText;

        QXmppPresence myPresence = xmppClient->clientPresence();
        myPresence.setStatusText( __statusText );
        xmppClient->setClientPresence( myPresence );

        //mimOpt->setStatusText( __statusText );

        emit statusTextChanged();
    }
}


void MyXmppClient::setStatus( StatusXmpp __status)
{
    if( __status != m_status )
    {
        QXmppPresence myPresence = xmppClient->clientPresence();

        if( __status == Online ) {
            myPresence.setType( QXmppPresence::Available );
            myPresence.setAvailableStatusType( QXmppPresence::Online );
        } else if( __status ==  Chat ) {
            myPresence.setType( QXmppPresence::Available );
            myPresence.setAvailableStatusType( QXmppPresence::Chat );
        } else if ( __status == Away ) {
            myPresence.setType( QXmppPresence::Available );
            myPresence.setAvailableStatusType( QXmppPresence::Away );
        } else if ( __status == XA ) {
            myPresence.setType( QXmppPresence::Available );
            myPresence.setAvailableStatusType( QXmppPresence::XA );
        } else if( __status == DND ) {
            myPresence.setType( QXmppPresence::Available );
            myPresence.setAvailableStatusType( QXmppPresence::DND );
        } else if( __status == Offline ) {
            myPresence.setType( QXmppPresence::Unavailable );
            m_status = __status;
            emit statusChanged();
        }

        xmppClient->setClientPresence( myPresence );
        this->presenceReceived( myPresence );
    }
}



void MyXmppClient::setMyPresence( StatusXmpp status, QString textStatus ) //Q_INVOKABLE
{
    qDebug() << Q_FUNC_INFO;
    if( textStatus != m_statusText ) {
        m_statusText =textStatus;
        emit statusTextChanged();
    }

    QXmppPresence myPresence;

    if( status == Online )
    {
        if( xmppClient->state()  == QXmppClient::DisconnectedState ) {
            this->connectToXmppServer();
        }
        myPresence.setType( QXmppPresence::Available );
        myPresence.setStatusText( textStatus );
        myPresence.setAvailableStatusType( QXmppPresence::Online );
    }
    else if( status == Chat )
    {
        if( xmppClient->state()  == QXmppClient::DisconnectedState ) {
            this->connectToXmppServer();
        }
        myPresence.setType( QXmppPresence::Available );
        myPresence.setAvailableStatusType( QXmppPresence::Chat );
        myPresence.setStatusText( textStatus );
    }
    else if( status == Away )
    {
        if( xmppClient->state()  == QXmppClient::DisconnectedState ) {
            this->connectToXmppServer();
        }
        myPresence.setType( QXmppPresence::Available );
        myPresence.setAvailableStatusType( QXmppPresence::Away );
        myPresence.setStatusText( textStatus );
    }
    else if( status == XA )
    {
        if( xmppClient->state()  == QXmppClient::DisconnectedState ) {
            this->connectToXmppServer();
        }
        myPresence.setType( QXmppPresence::Available );
        myPresence.setAvailableStatusType( QXmppPresence::XA );
        myPresence.setStatusText( textStatus );
    }
    else if( status == DND )
    {
        if( xmppClient->state()  == QXmppClient::DisconnectedState ) {
            this->connectToXmppServer();
        }
        myPresence.setType( QXmppPresence::Available );
        myPresence.setAvailableStatusType( QXmppPresence::DND );
        myPresence.setStatusText( textStatus );
    }
    else if( status == Offline )
    {
        if( (xmppClient->state()  == QXmppClient::ConnectedState)  || (xmppClient->state()  == QXmppClient::ConnectingState) )
        {
            xmppClient->disconnectFromServer();
        }
        myPresence.setType( QXmppPresence::Unavailable );
    }

    xmppClient->setClientPresence( myPresence  );
    this->presenceReceived( myPresence );
}



/* it sends information about typing : typing is started */
void MyXmppClient::typingStart(QString bareJid, QString resource) //Q_INVOKABLE
{
    //qDebug() << bareJid << " " << "start typing...";
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

    QDateTime currTime = QDateTime::currentDateTime();
    xmppMsg.setStamp( currTime );

    xmppMsg.setState( QXmppMessage::Composing );

    xmppClient->sendPacket( xmppMsg );
}


/* it sends information about typing : typing is stoped */
void MyXmppClient::typingStop(QString bareJid, QString resource) //Q_INVOKABLE
{
    //qDebug() << bareJid << " " << "stop typing...";
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

    QDateTime currTime = QDateTime::currentDateTime();
    xmppMsg.setStamp( currTime );

    xmppMsg.setState( QXmppMessage::Paused );

    xmppClient->sendPacket( xmppMsg );
}



void MyXmppClient::openChat( QString bareJid ) //Q_INVOKABLE
{
    RosterItemModel *itemRoster =  reinterpret_cast<RosterItemModel*>( listModelRoster->find( bareJid ) );

    RosterItemModel* item = reinterpret_cast<RosterItemModel*>( listModelChats->find( bareJid ) );
    QXmppPresence presence( QXmppPresence::Unavailable );
    RosterItemModel *newItem = new RosterItemModel( );
    newItem->setGroup( "" );
    if (itemRoster)
    {
        newItem->setPicStatus( itemRoster->picStatus() );
        newItem->setContactName( itemRoster->contactName() );
    } else {
        newItem->setPicStatus( this->getPicPresence( presence ) );
        newItem->setContactName( bareJid );
    }
    newItem->setJid( bareJid );
    newItem->setAvatar( "" );
    //newItem->setUnreadMsg( 0 );

    if (!item) {
        listModelChats->append( newItem );
    };

    database->mkMessagesTable();

    emit chatOpened( bareJid );
    emit openChatsChanged( bareJid );

    msgWrapper->initChat( bareJid );
    //this->resetUnreadMessages( bareJid );
}


void MyXmppClient::closeChat( QString bareJid ) //Q_INVOKABLE
{
    int row = -1;
    this->resetUnreadMessages( bareJid );
    RosterItemModel *item = reinterpret_cast<RosterItemModel*>( listModelChats->find( bareJid, row ) );
    if( (item != NULL) && (row >= 0) )
    {
        /*bool res = */listModelChats->takeRow( row );

        if( item->itemType() == 1 )
        {
            /* chat is closed, therefor logout from the chat */
        }

        emit openChatsChanged( bareJid );
        emit chatClosed( bareJid );
        //qDebug() << "MyXmppClient::closeChat("<<bareJid<<"): row:"<<row << " result:"<<res << " listModelChats.count():" <<listModelChats->count();
    }
    msgWrapper->removeListOfChat( bareJid );
}


void MyXmppClient::incUnreadMessage(QString bareJid) //Q_INVOKABLE
{
    RosterItemModel *item = (RosterItemModel*)listModelRoster->find( bareJid );
    RosterItemModel *item2 =(RosterItemModel*)listModelChats->find( bareJid );


    if( item != 0 )
    {
        int cnt = item->unreadMsg();
        item->setUnreadMsg( ++cnt );
    }
    if( item2 != 0 )
    {
        int cnt = item2->unreadMsg();
        item2->setUnreadMsg( ++cnt );
    }
}


void MyXmppClient::resetUnreadMessages(QString bareJid) //Q_INVOKABLE
{
    RosterItemModel *item = (RosterItemModel*)listModelRoster->find( bareJid );
    if( item != 0 ) {
        item->setUnreadMsg( 0 );
    }

    RosterItemModel *itemChat = (RosterItemModel*)listModelChats->find( bareJid );
    if( itemChat != 0 ) {
        itemChat->setUnreadMsg( 0 );
    }
}

void MyXmppClient::setUnreadMessages(QString bareJid, int count) //Q_INVOKABLE
{
    RosterItemModel *item = (RosterItemModel*)listModelRoster->find( bareJid );
    if( item != 0 ) {
        item->setUnreadMsg( count );
    }

    RosterItemModel *itemChat = (RosterItemModel*)listModelChats->find( bareJid );
    if( itemChat != 0 ) {
        itemChat->setUnreadMsg( count );
    }

}


void MyXmppClient::itemAdded(const QString &bareJid )
{
    qDebug() << "MyXmppClient::itemAdded(): " << bareJid;
    QStringList resourcesList = rosterManager->getResources( bareJid );

    QXmppPresence presence( QXmppPresence::Unavailable );
    RosterItemModel *itemModel = new RosterItemModel( );
    itemModel->setGroup("");
    itemModel->setPicStatus( this->getPicPresence( presence ) );
    itemModel->setContactName("");
    itemModel->setJid( bareJid );
    itemModel->setAvatar("");
    itemModel->setUnreadMsg( 0 );
    listModelRoster->append( itemModel );

    for( int L = 0; L<resourcesList.length(); L++ )
    {
        QString resource = resourcesList.at(L);
        this->initPresence( bareJid, resource );
    }
}


void MyXmppClient::itemChanged(const QString &bareJid )
{
    if (bareJid.right(17) == "chat.facebook.com") {
        return;
    } else {
        qDebug() << "MyXmppClient::itemChanged(): " << bareJid;

        QXmppRosterIq::Item rosterEntry = rosterManager->getRosterEntry( bareJid );
        QString name = rosterEntry.name();

        RosterItemModel *item = (RosterItemModel*)listModelRoster->find( bareJid );
        if( item ) {
            item->setContactName( name );
        }
    }

}


void MyXmppClient::itemRemoved(const QString &bareJid )
{
    qDebug() << "MyXmppClient::itemRemoved(): " << bareJid;

    int indxItem = -1;
    RosterItemModel *itemExists = (RosterItemModel*)listModelRoster->find( bareJid, indxItem );
    if( itemExists )
    {
        if( indxItem >= 0 ) {
            listModelRoster->takeRow( indxItem );
        }
    }
}


void MyXmppClient::subscriptionReceivedSlot(const QString &bareJid )
{
    emit this->subscriptionReceived( bareJid );
}


void MyXmppClient::requestVCard(QString bareJid) //Q_INVOKABLE
{
    if (vCardManager && (flVCardRequest == "") )
    {
        vCardManager->requestVCard( bareJid );
        flVCardRequest = bareJid;
    }
}


void MyXmppClient::messageReceivedSlot( const QXmppMessage &xmppMsg )
{
    QString bareJid_from = MyXmppClient::getBareJidByJid( xmppMsg.from() );
    QString bareJid_to = MyXmppClient::getBareJidByJid( xmppMsg.to() );
    qDebug() << Q_FUNC_INFO << " typeMsg: " << xmppMsg.type();

    if( xmppMsg.state() == QXmppMessage::Active )
    {
        qDebug() << "Msg state is QXmppMessage::Active";
        if( !( xmppMsg.body().isEmpty() || xmppMsg.body().isNull()) )
        {
            msgWrapper->textMessage(xmppMsg);
            QString jid = xmppMsg.from();
            if( jid.indexOf('/') >= 0 ) {
                QStringList sl =  jid.split('/');
                m_bareJidLastMessage = sl[0];
                if( sl.count() > 1 ) {
                    m_resourceLastMessage = sl[1];
                }
            } else {
                m_bareJidLastMessage = xmppMsg.from();
            }

            this->incUnreadMessage( bareJid_from );
            emit this->messageReceived( bareJid_from, bareJid_to );
        }
    }
    else if( xmppMsg.state() == QXmppMessage::Inactive )
    {
        qDebug() << "Msg state is QXmppMessage::Inactive";
    }
    else if( xmppMsg.state() == QXmppMessage::Gone )
    {
        qDebug() << "Msg state is QXmppMessage::Gone";
    }
    else if( xmppMsg.state() == QXmppMessage::Composing )
    {
        m_flTyping = true;
        emit typingChanged( bareJid_from, true);
    }
    else if( xmppMsg.state() == QXmppMessage::Paused )
    {
        m_flTyping = false;
        emit typingChanged( bareJid_from, false);
    }
    else
    {
        if( xmppMsg.isAttentionRequested() )
        {
            //qDebug() << "ZZZ: attentionRequest !!! from:" <<xmppMsg.from();
            msgWrapper->attention( bareJid_from, false );
            this->incUnreadMessage( bareJid_from );
            emit this->messageReceived( bareJid_from, bareJid_to );
        }
        else if( !( xmppMsg.body().isEmpty() || xmppMsg.body().isNull()) )
        {
            msgWrapper->textMessage(xmppMsg);
            if (m_archiveIncMessage) { archiveIncMessage(xmppMsg, false); }

            QString jid = xmppMsg.from();
            if( jid.indexOf('/') >= 0 ) {
                QStringList sl =  jid.split('/');
                m_bareJidLastMessage = sl[0];
                if( sl.count() > 1 ) {
                    m_resourceLastMessage = sl[1];
                }
            } else {
                m_bareJidLastMessage = xmppMsg.from();
            }

            this->incUnreadMessage( bareJid_from );
            emit this->messageReceived( bareJid_from, bareJid_to );
        }
        qDebug() << "MessageWrapper::messageReceived(): xmppMsg.state():" << xmppMsg.state();
    }
}

void MyXmppClient::archiveIncMessage( const QXmppMessage &xmppMsg, bool mine )
{
    QDateTime currTime = QDateTime::currentDateTime();

    database->insertMessage(1,getBareJidByJid(xmppMsg.from()),xmppMsg.body(),currTime.toString("dd/MM/yyyy hh:mm:ss"),mine);
    emit sqlMessagesChanged();
}

QString MyXmppClient::getPicPresenceByJid(QString bareJid)
{
    QString ret = "";
    RosterItemModel *itemExists = (RosterItemModel*)listModelRoster->find( bareJid );
    if( itemExists ) {
        ret = itemExists->picStatus();
    }
    return ret;
}


QString MyXmppClient::getStatusTextByJid(QString bareJid)
{
    QString ret = "";
    RosterItemModel *itemExists = (RosterItemModel*)listModelRoster->find( bareJid );
    if( itemExists ) {
        ret = itemExists->textStatus();
    }
    return ret;
}

QString MyXmppClient::getAvatarByJid(QString bareJid)
{
    QString ret = "";
    RosterItemModel *itemExists = (RosterItemModel*)listModelRoster->find( bareJid );
    if( itemExists ) {
        ret = itemExists->picAvatar();
    }
    return ret;
}

QString MyXmppClient::getNameByJid(QString bareJid)
{
    QString ret = "";
    RosterItemModel *itemExists = (RosterItemModel*)listModelRoster->find( bareJid );
    if( itemExists ) {
        ret = itemExists->contactName();
    } else {
        ret = bareJid;
    }
    return ret;
}


bool MyXmppClient::sendMyMessage(QString bareJid, QString resource, QString msgBody) //Q_INVOKABLE
{
    if( msgBody == "" ) { return false; }

    QXmppMessage xmppMsg; //???
    QString jid_from = bareJid;
    if( resource == "" ) {
        jid_from += "/resource";
    } else {
        jid_from += "/" + resource;
    }
    xmppMsg.setTo( jid_from );
    QString jid_to = m_myjid + "/" + xmppClient->configuration().resource();
    xmppMsg.setFrom( jid_to );

    //qDebug() << "SEND MSG: from:[" << jid_to << "] to:[" << jid_from << "] body:[" << msgBody << "]";

    /*QTextDocument doc;
    doc.setHtml( msgBody );
    xmppMsg.setBody( doc.toPlainText() );*/

    xmppMsg.setBody( msgBody );

    xmppMsg.setReceiptRequested( true );  /* request DLR */

    xmppMsg.setState( QXmppMessage::Active );

    //qDebug() << "MyXmppClient::sendMyMessage: "<<jid_from<<" "<<jid_to<<" "<<msgBody;
    xmppClient->sendPacket( xmppMsg );

    msgBody = msgBody.replace(">", "&gt;");  //fix for > stuff
    msgBody = msgBody.replace("<", "&lt;");  //and < stuff too ^^
    xmppMsg.setBody( msgBody );

    this->messageReceivedSlot( xmppMsg );

    xmppMsg.setFrom( jid_from );
    xmppMsg.setTo( jid_to );

    if (m_archiveIncMessage) { archiveIncMessage(xmppMsg, true); }

    return true;
}


QStringList MyXmppClient::getResourcesByJid(QString bareJid)
{
    return rosterManager->getResources(bareJid);
}


void MyXmppClient::presenceReceived( const QXmppPresence & presence )
{
    QString jid = presence.from();
    QString bareJid = jid;
    QString resource = "";
    if( jid.indexOf('/') >= 0 ) {
        bareJid = jid.split('/')[0];
        resource = jid.split('/')[1];
    }
    //this->initPresence( bareJid, resource );
    QString myResource = xmppClient->configuration().resource();

    //qDebug() << "### MyXmppClient::presenceReceived():" << bareJid << "|" << resource << "|" << myResource << "|" << presence.from() << "|" << presence.type()<< "|" << presence.availableStatusType();
    if( (((presence.from()).indexOf( m_myjid ) >= 0) && (resource == myResource)) || ((bareJid == "") && (resource == "")) )
    {
        QXmppPresence::Type __type = presence.type();
        if( __type == QXmppPresence::Unavailable )
        {
            m_status = Offline;
        }
        else
        {
            QXmppPresence::AvailableStatusType __status = presence.availableStatusType();
            if( __status == QXmppPresence::Online ) {
                m_status = Online;
            } else if( __status ==  QXmppPresence::Chat ) {
                m_status = Chat;
            } else if ( __status == QXmppPresence::Away ) {
                m_status = Away;
            } else if ( __status == QXmppPresence::XA ) {
                m_status = XA;
            } else if( __status == QXmppPresence::DND ) {
                m_status = DND;
            }
        }

        emit statusChanged();
    }
}


void MyXmppClient::error(QXmppClient::Error e)
{
    QString errString;
    if( e == QXmppClient::SocketError ) {
        errString = "Socket error";
    } else if( e == QXmppClient::KeepAliveError ) {
        errString = "Keep alive error";
    } else if( e == QXmppClient::XmppStreamError ) {
        errString = "Xmpp stream error";
    }

    if( !errString.isNull() )
    {
        QXmppPresence pr = xmppClient->clientPresence();
        this->presenceReceived( pr );
        QXmppPresence presence( QXmppPresence::Unavailable );
        xmppClient->setClientPresence( presence );

        emit errorHappened( errString );
    }
}

/*--- add/remove contact ---*/
void MyXmppClient::addContact( QString bareJid, QString nick, QString group, bool sendSubscribe )
{
    RosterItemModel *newItem = new RosterItemModel( );
    QXmppPresence presence( QXmppPresence::Unavailable );
    newItem->setGroup( group );
    newItem->setContactName( nick );
    newItem->setContactName( bareJid );
    newItem->setPicStatus( this->getPicPresence( presence ) );
    newItem->setJid( bareJid );
    newItem->setAvatar( "" );
    newItem->setUnreadMsg( 0 );


    listModelRoster->append(newItem);
    if( rosterManager )
    {
        QSet<QString> gr;
        QString n;
        if( !(group.isEmpty() || group.isNull()) )  { gr.insert( group ); }
        if( !(nick.isEmpty() || nick.isNull()) )  { n = nick; }
        rosterManager->addItem(bareJid, n, gr );

        if( sendSubscribe ) {
            rosterManager->subscribe( bareJid );
        }
    }
}

void MyXmppClient::removeContact( QString bareJid ) //Q_INVOKABLE
{
    int row = 0;
    RosterItemModel *itemExists = (RosterItemModel*)listModelRoster->find( bareJid, row );
    if( itemExists )
    {
        int type = itemExists->itemType();
        if ( type == 1 )
        {
            listModelRoster->takeRow( row );
        }
        else
        {
            if( rosterManager ) {
                rosterManager->removeItem( bareJid );
            }
        }
    }
}

void MyXmppClient::renameContact(QString bareJid, QString name) //Q_INVOKABLE
{
    //qDebug() << "MyXmppClient::renameContact(" << bareJid << ", " << name << ")" ;
    if( rosterManager ) {
        rosterManager->renameItem( bareJid, name );
    }
}

bool MyXmppClient::subscribe(const QString bareJid) //Q_INVOKABLE
{
    qDebug() << "MyXmppClient::subscribe(" << bareJid << ")" ;
    bool res = false;
    if( rosterManager && (!bareJid.isEmpty()) && (!bareJid.isNull()) ) {
        res = rosterManager->subscribe( bareJid );
    }
    return res;
}

bool MyXmppClient::unsubscribe(const QString bareJid) //Q_INVOKABLE
{
    qDebug() << "MyXmppClient::unsubscribe(" << bareJid << ")" ;
    bool res = false;
    if( rosterManager && (!bareJid.isEmpty()) && (!bareJid.isNull()) ) {
        res = rosterManager->unsubscribe( bareJid );
    }
    return res;
}

bool MyXmppClient::acceptSubscribtion(const QString bareJid) //Q_INVOKABLE
{
    //qDebug() << "MyXmppClient::acceptSubscribtion(" << bareJid << ")" ;
    bool res = false;
    if( rosterManager && (!bareJid.isEmpty()) && (!bareJid.isNull()) ) {
        res = rosterManager->acceptSubscription( bareJid );
    }
    return res;
}

bool MyXmppClient::rejectSubscribtion(const QString bareJid) //Q_INVOKABLE
{
    //qDebug() << "MyXmppClient::rejectSubscribtion(" << bareJid << ")" ;
    bool res = false;
    if( rosterManager && (!bareJid.isEmpty()) && (!bareJid.isNull()) ) {
        res = rosterManager->refuseSubscription( bareJid );
    }
    return res;
}

void MyXmppClient::attentionSend( QString bareJid, QString resource )
{
    qDebug() << Q_FUNC_INFO;
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

    msgWrapper->attention( bareJid, true );
}

SqlQueryModel* MyXmppClient::getSqlMessages()
{
    sql = new SqlQueryModel(0);
    sql->setQuery("SELECT * FROM messages WHERE bareJid='" + m_chatJid + "'",database->db);
    return sql;
}

