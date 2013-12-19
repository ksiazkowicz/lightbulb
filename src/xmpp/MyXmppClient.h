
#ifndef MYXMPPCLIENT_H
#define MYXMPPCLIENT_H

#include "QXmppVCardIq.h"
#include "QXmppVCardManager.h"
#include "QXmppClient.h"

#include <QObject>
#include <QtDeclarative>
#include <QDeclarativeView>
#include <QMap>
#include <QList>
#include <QVariant>
#include <QThread>

#include "DatabaseWorker.h"

#include "MyCache.h"
#include "MessageWrapper.h"
#include "Settings.h"
#include <QSqlRecord>
#include "QXmppRosterManager.h"

#include "RosterListModel.h"

#include "QMLVCard.h"

typedef QMap<QString, QVariant> Map;

class MyXmppClient : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY( MyXmppClient )

    Q_PROPERTY( QString version READ getVersion NOTIFY versionChanged )
    Q_PROPERTY( QString bareJidLastMsg READ getJidLastMsg NOTIFY messageReceived )
    Q_PROPERTY( QString resourceLastMsg READ getResourceLastMsg NOTIFY messageReceived )
    Q_PROPERTY( StateConnect stateConnect READ getStateConnect NOTIFY connectingChanged )
    Q_PROPERTY( StatusXmpp status READ getStatus WRITE setStatus NOTIFY statusChanged )
    Q_PROPERTY( int page READ getPage WRITE gotoPage NOTIFY pageChanged )
    Q_PROPERTY( QString statusText READ getStatusText WRITE setStatusText  NOTIFY statusTextChanged )
    Q_PROPERTY( bool isTyping READ getTyping NOTIFY typingChanged )
    Q_PROPERTY( RosterListModel* cachedRoster READ getCachedRoster NOTIFY rosterChanged)
    Q_PROPERTY( QStringList chats READ getChats NOTIFY openChatsChanged )
    Q_PROPERTY( QString myBareJid READ getMyJid WRITE setMyJid NOTIFY myJidChanged )
    Q_PROPERTY( QString myPassword READ getPassword() WRITE setPassword  NOTIFY myPasswordChanged )
    Q_PROPERTY( QString host READ getHost WRITE setHost NOTIFY hostChanged )
    Q_PROPERTY( int port READ getPort WRITE setPort NOTIFY portChanged )
    Q_PROPERTY( QString resource READ getResource WRITE setResource NOTIFY resourceChanged )
    Q_PROPERTY( SqlQueryModel* messagesByPage READ getSqlMessagesByPage NOTIFY pageChanged )
    Q_PROPERTY( SqlQueryModel* messages READ getSqlMessagesByPage NOTIFY sqlMessagesChanged )
    Q_PROPERTY( QString chatJid READ getChatJid WRITE setChatJid NOTIFY chatJidChanged )
    Q_PROPERTY( int accountId READ getAccountId WRITE setAccountId NOTIFY accountIdChanged )
    Q_PROPERTY( QString contactName READ getContactName WRITE setContactName NOTIFY contactNameChanged )
    Q_PROPERTY( QMLVCard* vcard READ getVCard NOTIFY vCardChanged )
    Q_PROPERTY( int keepAlive READ getKeepAlive WRITE setKeepAlive NOTIFY keepAliveChanged )
    Q_PROPERTY( bool reconnectOnError READ getReconnectOnError WRITE setReconnectOnError NOTIFY reconnectOnErrorChanged )

    MyCache *cacheIM;
    MessageWrapper *msgWrapper;

    QXmppClient *xmppClient;
    QXmppRosterManager *rosterManager;
    QXmppVCardManager *vCardManager;

    Settings *mimOpt;

    QMLVCard * qmlVCard;
    QString flVCardRequest;

    DatabaseWorker *dbWorker;
    QThread *dbThread;

    RosterListModel* cachedRoster;

public :
    static QString getBareJidByJid( const QString &jid );
    Q_INVOKABLE QString getAvatarByJid( QString bareJid );

    enum StateConnect {
        Disconnect = 0,
        Connected = 1,
        Connecting = 2
    };

    enum StatusXmpp {
        Offline = 0,
        Online = 1,
        Chat = 2,
        Away = 3,
        XA = 4,
        DND = 5
    };

    Q_ENUMS( StateConnect StatusXmpp )

    explicit MyXmppClient();
    ~MyXmppClient();

    void initXmppClient();
    /* --- diagnostics --- */
    Q_INVOKABLE bool dbRemoveDb();
    Q_INVOKABLE bool cleanCache();
    Q_INVOKABLE bool resetSettings();

    static bool removeDir(const QString &dirName); //workaround for qt not able to remove directory recursively // http://john.nachtimwald.com/2010/06/08/qt-remove-directory-and-its-contents/

    /* --- presence --- */
    Q_INVOKABLE void setMyPresence( StatusXmpp status, QString textStatus );

    /*--- typing ---*/
    Q_INVOKABLE void typingStart( QString bareJid, QString resource );
    Q_INVOKABLE void typingStop( QString bareJid, QString resource );

    /*--- unread msg ---*/
    Q_INVOKABLE void resetUnreadMessages( QString bareJid ) {
        RosterItemModel *item = (RosterItemModel*)cachedRoster->find( bareJid );
        if( item != 0 ) {
            item->setUnreadMsg( 0 );
        }
    }
    Q_INVOKABLE void setUnreadMessages( QString bareJid, int count ) { dbWorker->executeQuery(QStringList() << "updateContact" << QString::number(m_accountId) << bareJid << "unreadMsg" << QString::number(count)); }

    /*--- vCard ---*/
    Q_INVOKABLE void requestVCard( QString bareJid );

    /*--- connect/disconnect ---*/
    Q_INVOKABLE void connectToXmppServer();
    Q_INVOKABLE void disconnectFromXmppServer();

    /*--- send msg ---*/
    Q_INVOKABLE bool sendMyMessage( QString bareJid, QString resource, QString msgBody );

    /*--- info by jid ---*/
    Q_INVOKABLE QString getPropertyByJid( QString bareJid, QString property ) {
        RosterItemModel *item = (RosterItemModel*)cachedRoster->find( bareJid );
        if (property == "name") return item->name();
        else if (property == "presence") return item->presence();
        else if (property == "resource") return item->resource();
        else if (property == "statusText") return item->statusText();
        else if (property == "unreadMsg") return QString::number(item->unreadMsg());
    }
    Q_INVOKABLE QStringList getResourcesByJid( QString bareJid ) { return rosterManager->getResources(bareJid); }

    Q_INVOKABLE QString getPropertyByChatID( int index, QString property ) {
        RosterItemModel *item = (RosterItemModel*)cachedRoster->find( chats.at(index) );
        if (property == "name") return item->name();
        else if (property == "presence") return item->presence();
        else if (property == "resource") return item->resource();
        else if (property == "statusText") return item->statusText();
        else if (property == "unreadMsg") return QString::number(item->unreadMsg());
        else if (property == "jid") return item->jid();
    }

    /*--- add/remove contact ---*/
    Q_INVOKABLE void addContact(QString bareJid, QString nick, QString group, bool sendSubscribe );
    Q_INVOKABLE void removeContact( QString bareJid );
    Q_INVOKABLE void renameContact( QString bareJid, QString name );

    /*--- subscribe ---*/
    Q_INVOKABLE bool subscribe( const QString bareJid );
    Q_INVOKABLE bool unsubscribe( const QString bareJid );
    Q_INVOKABLE bool acceptSubscribtion( const QString bareJid );
    Q_INVOKABLE bool rejectSubscribtion( const QString bareJid );

    /*--- version ---*/
    static QString myVersion;
    QString getVersion() const { return MyXmppClient::myVersion; }
	
    /*--- chat options ---*/
    Q_INVOKABLE void attentionSend( QString bareJid, QString resource = "" );

    /*----------------------------------*/
    /*--- getter/setter ---*/

    QString getJidLastMsg() const { return m_bareJidLastMessage; }
    QString getResourceLastMsg() const { return m_resourceLastMessage; }

    StateConnect getStateConnect() const { return m_stateConnect; }

    QString getStatusText() const { return m_statusText; }
    void setStatusText( const QString& );

    StatusXmpp getStatus() const { return m_status; }
    void setStatus( StatusXmpp __status );

    int getPage() const { return page; }
    void gotoPage(int nPage);

    bool getTyping() const { return m_flTyping; }
    void setTyping( QString &jid, const bool isTyping ) { m_flTyping = isTyping; emit typingChanged(jid, isTyping); }

    RosterListModel* getCachedRoster() const { return cachedRoster; }
    QStringList getChats() {
        QStringList chatsNames;
        for (int i=0; i<chats.count(); i++) {
            QString msg;
            if (getPropertyByChatID(i,"unreadMsg") != "0") msg = "<b>[" + getPropertyByChatID(i,"unreadMsg") + "]</b> ";
            chatsNames.append("<img width=24 height=24 src=\"" + getPropertyByChatID(i,"presence") + "\" /> " + msg + getPropertyByChatID(i,"name"));
        }
        return chatsNames;
    }

    QString latestMessage;

    QString getMyJid() const { return m_myjid; }
    void setMyJid( const QString& myjid ) { if(myjid!=m_myjid) {m_myjid=myjid; emit myJidChanged(); } }

    QString getPassword() const { return m_password; }
    void setPassword( const QString& value ) { if(value!=m_password) {m_password=value; emit myPasswordChanged(); } }

    QString getHost() const { return m_host; }
    void setHost( const QString & value ) { if(value!=m_host) {m_host=value; emit hostChanged(); } }

    int getPort() const { return m_port; }
    void setPort( const int& value ) { if(value!=m_port) {m_port=value; emit portChanged(); } }

    QString getResource() const { return m_resource; }
    void setResource( const QString & value ) { if(value!=m_resource) {m_resource=value; emit resourceChanged(); } }

    SqlQueryModel* getSqlMessagesByPage() { return dbWorker->getSqlMessages(); }
    Q_INVOKABLE QString getLastSqlMessage() { return latestMessage; }
    Q_INVOKABLE int getUnreadCount();

    QString getChatJid() const { return m_chatJid; }
    void setChatJid( const QString & value )
    {
        if(value!=m_chatJid) {
            m_chatJid=value;
            emit chatJidChanged();
        }
    }

    int getAccountId() const { return m_accountId; }
    void setAccountId( const int & value ) {
        if (value!=m_accountId) {
            m_accountId = value;
            emit accountIdChanged();
        }
    }

    QString getContactName() const { return m_contactName; }
    void setContactName( const QString & value ) { if(value!=m_contactName) { m_contactName=value; emit contactNameChanged(); }  }

    QMLVCard* getVCard() const { return qmlVCard; }

    int getKeepAlive() const { return m_keepAlive; }
    void setKeepAlive(int arg) { if (m_keepAlive != arg) { m_keepAlive = arg; emit keepAliveChanged(); } }

    bool getReconnectOnError() const { return m_reconnectOnError; }
    void setReconnectOnError(bool arg) { if (m_reconnectOnError != arg) { m_reconnectOnError = arg; emit reconnectOnErrorChanged(); } }
	
signals:
    void versionChanged();
    void messageReceived( QString fromBareJid, QString toBareJid );
    void connectingChanged();
    void statusTextChanged();
    void statusChanged();
    void rosterChanged();
    void pageChanged();
    void typingChanged( QString bareJid, bool isTyping );
    void myJidChanged();
    void myPasswordChanged();
    void hostChanged();
    void portChanged();
    void resourceChanged();
    void openChatsChanged();
    void chatOpened( QString bareJid );
    void chatClosed( QString bareJid );
    void sqlMessagesChanged();
    void chatJidChanged();
    void accountIdChanged();
    void contactNameChanged();
    void vCardChanged();
    void errorHappened( const QString &errorString );
    void subscriptionReceived( const QString bareJid );
    void keepAliveChanged();
    void reconnectOnErrorChanged();
    void archiveIncMessageChanged();

public slots:
    void clientStateChanged( QXmppClient::State state );

    Q_INVOKABLE void openChat( QString jid ) {
        if (!chats.contains(jid)) chats.append(jid);
        emit chatOpened( jid );
    }
    Q_INVOKABLE void closeChat( QString jid ) { this->resetUnreadMessages( jid ); if (chats.contains(jid)) chats.removeAt(chats.indexOf(jid)); emit chatClosed( jid ); }

private slots:
    void initRoster();
    void initPresence(const QString& bareJid, const QString& resource);
    void initVCard(const QXmppVCardIq &vCard);
    void itemAdded( const QString &);
    void itemRemoved( const QString &);
    void itemChanged( const QString &);
    void messageReceivedSlot( const QXmppMessage &msg );
    void presenceReceived( const QXmppPresence & presence );
    void error(QXmppClient::Error);
    void updateMessages() { dbWorker->updateMessages(m_accountId,m_chatJid,page); }

private:
    QString m_bareJidLastMessage;
    QString m_resourceLastMessage;

    StateConnect m_stateConnect;
    StatusXmpp m_status;
    QString m_statusText;
    bool m_flTyping;
    QString m_myjid;
    QString m_password;
    QString m_host;
    int m_port;
    QString m_resource;
    QString m_chatJid;
    QString m_lastChatJid;
    QString m_contactName;

    int page;

    int m_accountId;

    QString getPicPresence( const QXmppPresence &presence ) const;
    QString getTextStatus(const QString &textStatus, const QXmppPresence &presence ) const;

    QStringList chats;

    int m_keepAlive;
    bool m_reconnectOnError;

    bool flSetPresenceWithoutAck;
};

#endif
