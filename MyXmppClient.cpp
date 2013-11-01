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

QString MyXmppClient::myVersion = "0.2 Debug";

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

    m_bareJidLastMessage = "";
    m_resourceLastMessage = "";
    m_stateConnect = Disconnect;
    m_status = Offline;
    m_statusText = "";
    m_flTyping = false;
    m_myjid = "";
    m_password = "";
    m_host = "";
    m_port = 0;
    m_resource = "";
    m_chatJid = "";
    m_contactName = "";
    m_keepAlive = 60;
    accounts = 0;
    page = 1;

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

    QXmppConfiguration xmppConfig;

    xmppConfig.setJid( m_myjid );
    xmppConfig.setPassword( m_password );
    xmppConfig.setKeepAliveInterval( m_keepAlive );
    xmppConfig.setAutoAcceptSubscriptions(false);

    /*******************/

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

        if (database->checkIfContactExists(bareJid)) {
            database->updateContact(1,bareJid,"name",name);
        } else {
            qDebug() << "inserting contact " << bareJid << ";" << name << ";" << getPicPresence(QXmppPresence::Unavailable) <<
                        ";" << avatarPath;
            database->insertContact(1,bareJid,name,this->getPicPresence(QXmppPresence::Unavailable),avatarPath);
        }
    }
    emit rosterChanged();

}

void MyXmppClient::initPresence(const QString& bareJid, const QString& resource)
{
    if( !database->checkIfContactExists(bareJid) ) {
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

    database->updateContact(1,bareJid,"resource",resource);
    database->updateContact(1,bareJid,"presence",this->getPicPresence( xmppPresence ));
    database->updateContact(1,bareJid,"statusText",this->getTextStatus( xmppPresence.statusText(), xmppPresence ));
}

QString MyXmppClient::getPicPresence( const QXmppPresence &presence ) const
{
    QString picPresenceName = "qrc:/qml/images/presence-unknown.png";

    QXmppPresence::Type status = presence.type();
    if( status != QXmppPresence::Available )
    {
        picPresenceName = "qrc:/presence/offline";
    }
    else
    {
        QXmppPresence::AvailableStatusType availableStatus = presence.availableStatusType();
        if( availableStatus == QXmppPresence::Online ) {
            picPresenceName = "qrc:/presence/online";
        } else if ( availableStatus == QXmppPresence::Chat ) {
            picPresenceName = "qrc:/presence/chatty";
        } else if ( availableStatus == QXmppPresence::Away ) {
            picPresenceName = "qrc:/presence/away";
        } else if ( availableStatus == QXmppPresence::XA ) {
            picPresenceName = "qrc:/presence/xa";
        } else if ( availableStatus == QXmppPresence::DND ) {
            picPresenceName = "qrc:/presence/busy";
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

    vCardData dataVCard;

    if( true )
    {
        /* set nickname */
        QXmppRosterIq::Item itemRoster = rosterManager->getRosterEntry( bareJid );
        QString nickName = vCard.nickName();
        if( (!nickName.isEmpty()) && (!nickName.isNull()) && (itemRoster.name().isEmpty()) ) {
            database->updateContact( 1, bareJid, "name", nickName );
        }

        /* avatar */
        bool isAvatarCreated = true;
        QString avatarFile = cacheIM->getAvatarCache( bareJid );
        if( avatarFile.isEmpty() || (flVCardRequest != "") ) {
            isAvatarCreated =  cacheIM->setAvatarCache( bareJid, vCard.photo() );
            avatarFile = cacheIM->getAvatarCache( bareJid );
        }
        if( isAvatarCreated ) {
            if( database->checkIfContactExists(bareJid) ) {
                database->updateContact(1, bareJid, "avatarPath", avatarFile);
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
    if (!database->checkIfChatInProgress(bareJid)) {
        database->setChatInProgress( bareJid, true );
    }

    database->mkMessagesTable();

    emit chatOpened( bareJid );
    emit openChatsChanged( bareJid );
}


void MyXmppClient::closeChat( QString bareJid ) //Q_INVOKABLE
{
    this->resetUnreadMessages( bareJid );
    database->setChatInProgress( bareJid, false );
    emit openChatsChanged( bareJid );
    emit chatClosed( bareJid );
}

void MyXmppClient::resetUnreadMessages(QString bareJid) //Q_INVOKABLE
{
    database->updateContact(1,bareJid,"unreadMsg","0");
}

void MyXmppClient::setUnreadMessages(QString bareJid, int count) //Q_INVOKABLE
{
    database->updateContact(1,bareJid,"unreadMsg",QString::number(count));
}


void MyXmppClient::itemAdded(const QString &bareJid )
{
    qDebug() << "MyXmppClient::itemAdded(): " << bareJid;
    QStringList resourcesList = rosterManager->getResources( bareJid );

    database->insertContact(1,bareJid,bareJid,this->getPicPresence( QXmppPresence::Unavailable ),cacheIM->getAvatarCache( bareJid ));

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

        database->updateContact(1,bareJid,"name",name);

        emit rosterChanged();
    }

}


void MyXmppClient::itemRemoved(const QString &bareJid )
{
    qDebug() << "MyXmppClient::itemRemoved(): " << bareJid;

    database->deleteContact(1,bareJid);
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

    if( xmppMsg.state() == QXmppMessage::Active )
    {
        qDebug() << "Msg state is QXmppMessage::Active";
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
        if (bareJid_from != "") {
            m_flTyping = true;
            emit typingChanged( bareJid_from, true);
            qDebug() << bareJid_from << " is composing.";
        }
    }
    else if( xmppMsg.state() == QXmppMessage::Paused )
    {
        if (bareJid_from != "") {
            m_flTyping = false;
            emit typingChanged( bareJid_from, false);
            qDebug() << bareJid_from << " paused.";
        }
    }
    else
    {
        if( xmppMsg.isAttentionRequested() )
        {
            //qDebug() << "ZZZ: attentionRequest !!! from:" <<xmppMsg.from();
            msgWrapper->attention( bareJid_from, false );
        }
        qDebug() << "MessageWrapper::messageReceived(): xmppMsg.state():" << xmppMsg.state();
    }
    if ( !( xmppMsg.body().isEmpty() || xmppMsg.body().isNull() || bareJid_from == m_myjid ) )
    {
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

        if (!database->checkIfContactExists(bareJid_from)) {
            database->insertContact(1,bareJid_from,bareJid_from,this->getPicPresence(QXmppPresence::Unavailable),cacheIM->getAvatarCache(bareJid_from));
        }

        this->openChat( bareJid_from );

        database->incUnreadMessage( 1, bareJid_from );
        archiveIncMessage(xmppMsg, false);
        emit this->messageReceived( bareJid_from, bareJid_to );
    }
}

QString MyXmppClient::parseEmoticons( QString string ) {
    QString nStr = " " + string + " ";
    QString begin = " <img src='qrc:/smileys/";
    QString end = "' /> ";

    nStr.replace(" :) ", begin + ":)" + end);
    nStr.replace(" :-) ", begin + ":)" + end);

    nStr.replace(" :D ", begin + ":D" + end);
    nStr.replace(" :-D ", begin + ":-D" + end);

    nStr.replace(" ;) ", begin + ";)" + end);
    nStr.replace(" ;-) ", begin + ";)" + end);

    nStr.replace(" ;D ", begin + ";D" + end);
    nStr.replace(" ;-D ", begin + ";D" + end);

    nStr.replace(" :( ", begin + ":(" + end);
    nStr.replace(" :-( ", begin + ":(" + end);

    nStr.replace(" :P ", begin + ":P" + end);
    nStr.replace(" :-P ", begin + ":P" + end);

    nStr.replace(" ;( ", begin + ";(" + end);
    nStr.replace(" ;-( ", begin + ";(" + end);

    nStr.replace(" :| ", begin + ":|" + end);
    nStr.replace(" &lt;3 ", begin + "<3" + end);

    nStr.replace(" :\\ ", begin + ":\\" + end);
    nStr.replace(" :-\\ ", begin + ":\\" + end);

    nStr.replace(" :o ", begin + ":O" + end);
    nStr.replace(" :O ", begin + ":O" + end);
    nStr.replace(" o.o ", begin + ":O" + end);

    nStr.replace(" :* ", begin + ":*" + end);
    nStr.replace(" ;* ", begin + ":*" + end);

    nStr.replace(" :X ", begin + ":X" + end);
    nStr.replace(" :x ", begin + ":x" + end);

    nStr.replace(" :&gt; ", begin + ":>" + end);
    nStr.replace(" B) ", begin + "B)" + end);
    nStr.replace(" %) ", begin + "%)" + end);
    nStr.replace(" :@ ", begin + ":@" + end);
    nStr.replace(" ;&gt; ", begin + ";>" + end);
    nStr.replace(" >) ", begin + ">)" + end);
    nStr.replace(" 8) ", begin + "8)" + end);
    nStr.replace(" (=_=) ", begin + "=_=" + end);

    return nStr;
}

void MyXmppClient::archiveIncMessage( const QXmppMessage &xmppMsg, bool mine )
{
    QDateTime currTime = QDateTime::currentDateTime();

    QString from;
    from = this->getBareJidByJid(xmppMsg.from());

    QString to;
    to = this->getBareJidByJid(xmppMsg.to());

    QString time;
    time = currTime.toString("dd-MM-yy hh:mm");

    QString body;
    body = xmppMsg.body();
    body = body.replace(">", "&gt;");  //fix for > stuff
    body = body.replace("<", "&lt;");  //and < stuff too ^^
    body = msgWrapper->parseMsgOnLink(body);
    body = parseEmoticons(body);

    if (mine) {
        database->insertMessage(1,to,body,time,mine);
    } else {
        database->insertMessage(1,from,body,time,mine);
    }
    emit sqlMessagesChanged();
}

QString MyXmppClient::getPicPresenceByJid(QString bareJid)
{
    return database->getContactProperty(1,bareJid,"presence");
}


QString MyXmppClient::getStatusTextByJid(QString bareJid)
{
    return database->getContactProperty(1,bareJid,"statusText");
}

QString MyXmppClient::getAvatarByJid(QString bareJid)
{
    return database->getContactProperty(1,bareJid,"avatarPath");
}

QString MyXmppClient::getNameByJid(QString bareJid)
{
    return database->getContactProperty(1,bareJid,"name");
}


bool MyXmppClient::sendMyMessage(QString bareJid, QString resource, QString msgBody) //Q_INVOKABLE
{
    if( msgBody == "" ) { return false; }

    QXmppMessage xmppMsg;

    QString jid_from = bareJid;
    if( resource == "" ) {
        jid_from += "/resource";
    } else {
        jid_from += "/" + resource;
    }

    xmppMsg.setTo( jid_from );
    QString jid_to = m_myjid + "/" + xmppClient->configuration().resource();
    xmppMsg.setFrom( jid_to );

    xmppMsg.setBody( msgBody );

    xmppMsg.setState( QXmppMessage::Active );

    xmppClient->sendPacket( xmppMsg );

    this->messageReceivedSlot( xmppMsg );

    archiveIncMessage(xmppMsg, true);

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
        errString = "SOCKET_ERROR";
    } else if( e == QXmppClient::KeepAliveError ) {
        errString = "KEEP_ALIVE_ERROR";
    } else if( e == QXmppClient::XmppStreamError ) {
        errString = "XMPP_STREAM_ERROR";
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
    database->insertContact(1,bareJid,nick,this->getPicPresence( QXmppPresence::Unavailable ),cacheIM->getAvatarCache( bareJid ));
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
    if( rosterManager ) rosterManager->removeItem( bareJid );
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

SqlQueryModel* MyXmppClient::getLastSqlMessages()
{
    sqlMessages = new SqlQueryModel(0);
    sqlMessages->setQuery("SELECT * FROM (SELECT * FROM messages WHERE bareJid='" + m_chatJid + "' ORDER BY id DESC limit 10) ORDER BY id ASC",database->db);

    return sqlMessages;
}

SqlQueryModel* MyXmppClient::getSqlMessagesByPage()
{
    int border = page*20;
    sqlMessages = new SqlQueryModel(0);
    sqlMessages->setQuery("SELECT * FROM (SELECT * FROM messages WHERE bareJid='" + m_chatJid + "' ORDER BY id DESC limit " + QString::number(border) + ") ORDER BY id ASC limit 20",database->db);

    return sqlMessages;
}

int MyXmppClient::getSqlMessagesCount()
{
    sqlMessages = new SqlQueryModel(0);
    sqlMessages->setQuery("SELECT * FROM messages WHERE bareJid='" + m_chatJid + "'",database->db);

    return sqlMessages->rowCount();
}

SqlQueryModel* MyXmppClient::getSqlRoster()
{
    sqlRoster = new SqlQueryModel( 0 );
    sqlRoster->setQuery("select * from roster", database->db);

    return sqlRoster;
}

SqlQueryModel* MyXmppClient::getSqlChats()
{
    sqlChats = new SqlQueryModel( 0 );
    sqlChats->setQuery("select * from roster where isChatInProgress=1",database->db);

    return sqlChats;
}

void MyXmppClient::gotoPage(int nPage)
{
    page = nPage;
    emit pageChanged();
}

