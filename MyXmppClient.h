
#ifndef MYXMPPCLIENT_H
#define MYXMPPCLIENT_H

#include "QXmppVCardIq.h"
#include "QXmppVCardManager.h"
#include "QXmppMessageReceiptManager.h"
#include "QXmppClient.h"

#include <QObject>
#include <QtDeclarative>
#include <QDeclarativeView>
#include <QMap>
#include <QList>
#include <QVariant>

#include "rosteritemmodel.h"
#include "rosterlistmodel.h"

#include "chatsitemmodel.h"
#include "chatslistmodel.h"

#include "mycache.h"
#include "messagewrapper.h"
#include "meegimsettings.h"

#include "qmlvcard.h"


/****************/
/* http://www.developer.nokia.com/Community/Wiki/Workaround_to_hide_VKB_in_QML_apps_%28Known_Issue%29 */
class EventFilter : public QObject
{
protected:
    bool eventFilter(QObject *obj, QEvent *event) {
        QInputContext *ic = qApp->inputContext();
        if (ic)
        {
            if ( (ic->focusWidget() == 0) && prevFocusWidget)
            {
                QEvent closeSIPEvent( QEvent::CloseSoftwareInputPanel );
                ic->filterEvent(&closeSIPEvent);
            }
            else if ( (prevFocusWidget == 0) && (ic->focusWidget()) )
            {
                QEvent openSIPEvent( QEvent::RequestSoftwareInputPanel );
                ic->filterEvent(&openSIPEvent);
            }
            prevFocusWidget = ic->focusWidget();
        }
        return QObject::eventFilter(obj,event);
    }

private:
    QWidget *prevFocusWidget;
};
/****************/

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
    Q_PROPERTY( QString statusText READ getStatusText WRITE setStatusText  NOTIFY statusTextChanged )
    Q_PROPERTY( bool isTyping READ getTyping NOTIFY typingChanged )
    Q_PROPERTY( RosterListModel* roster READ getRoster NOTIFY rosterChanged )
    Q_PROPERTY( QString myBareJid READ getMyJid WRITE setMyJid NOTIFY myJidChanged )
    Q_PROPERTY( QString myPassword READ getPassword() WRITE setPassword  NOTIFY myPasswordChanged )
    Q_PROPERTY( QString host READ getHost WRITE setHost NOTIFY hostChanged )
    Q_PROPERTY( int port READ getPort WRITE setPort NOTIFY portChanged )
    Q_PROPERTY( QString resource READ getResource WRITE setResource NOTIFY resourceChanged )
    Q_PROPERTY( ChatsListModel* openChats READ getOpenChats NOTIFY openChatsChanged )
    Q_PROPERTY( MsgListModel* messages READ getMessages NOTIFY messagesChanged )
    Q_PROPERTY( QString chatJid READ getChatJid WRITE setChatJid NOTIFY chatJidChanged )
    Q_PROPERTY( QString contactName READ getContactName WRITE setContactName NOTIFY contactNameChanged )
    Q_PROPERTY( QMLVCard* vcard READ getVCard NOTIFY vCardChanged )
    Q_PROPERTY( int keepAlive READ getKeepAlive WRITE setKeepAlive NOTIFY keepAliveChanged )
    Q_PROPERTY( bool reconnectOnError READ getReconnectOnError WRITE setReconnectOnError NOTIFY reconnectOnErrorChanged )
    Q_PROPERTY( bool archiveIncMessage READ getArchiveIncMessage WRITE setArchiveIncMessage NOTIFY archiveIncMessageChanged )

    MyCache *cacheIM;
    MessageWrapper *msgWrapper;

    ChatsListModel *listModelChats;

    QXmppClient *xmppClient;
    QXmppRosterManager *rosterManager;
    QXmppVCardManager *vCardManager;
    QXmppMessageReceiptManager * xmppMessageReceiptManager;

    QMap< QString, RosterItemModel*> listRoster;
    RosterListModel *listModelRoster;

    void setQMLListRoster();

    MeegIMSettings *mimOpt;

    QMLVCard * qmlVCard;
    QString flVCardRequest;

    //QXmppConfiguration xmppConfig;

public :
    static QString getBareJidByJid( const QString &jid );

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

    /* --- presence --- */
    Q_INVOKABLE void setMyPresence( StatusXmpp status, QString textStatus );

    /*--- typing ---*/
    Q_INVOKABLE void typingStart( QString bareJid, QString resource );
    Q_INVOKABLE void typingStop( QString bareJid, QString resource );

    /*--- unread msg ---*/
    /*Q_INVOKABLE */void incUnreadMessage( QString bareJid );
    Q_INVOKABLE void resetUnreadMessages( QString bareJid );

    /*--- vCard ---*/
    Q_INVOKABLE void requestVCard( QString bareJid );
    //Q_INVOKABLE void setMyVCard( QMLVCard* vCard );

    /*--- connect/disconnect ---*/
    Q_INVOKABLE void connectToXmppServer();
    Q_INVOKABLE void disconnectFromXmppServer();

    /*--- send msg ---*/
    Q_INVOKABLE bool sendMyMessage( QString bareJid, QString resource, QString msgBody );

    /*--- info by jid ---*/
    Q_INVOKABLE QString getPicPresenceByJid( QString bareJid );
    Q_INVOKABLE QString getStatusTextByJid( QString bareJid );
    Q_INVOKABLE QString getAvatarByJid( QString bareJid );
    Q_INVOKABLE QString getNameByJid( QString bareJid );
    Q_INVOKABLE QStringList getResourcesByJid( QString bareJid );

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
    Q_INVOKABLE void clearChat( const QString bareJid ) { msgWrapper->clearChat( bareJid); }
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

    bool getTyping() const { return m_flTyping; }
    void setTyping( QString &jid, const bool isTyping ) { m_flTyping = isTyping; emit typingChanged(jid, isTyping); }

    RosterListModel* getRoster() const { return listModelRoster; }

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

    ChatsListModel* getOpenChats() const { return listModelChats; }

    MsgListModel* getMessages() const { return msgWrapper->getMessages(); }

    QString getChatJid() const { return m_chatJid; }
    void setChatJid( const QString & value )
    {
        if(value!=m_chatJid) {
            m_chatJid=value;
            msgWrapper->setChatBareJid( m_chatJid );
            emit chatJidChanged();
        }
    }

    QString getContactName() const { return m_contactName; }
    void setContactName( const QString & value )
    {
        if(value!=m_contactName) {
            m_contactName=value;
            emit contactNameChanged();
        }
    }

    QMLVCard* getVCard() const { return qmlVCard; }

    int getKeepAlive() const { return m_keepAlive; }
    void setKeepAlive(int arg)
    {
        if (m_keepAlive != arg) {
            m_keepAlive = arg;
            emit keepAliveChanged();
        }
    }

    bool getReconnectOnError() const { return m_reconnectOnError; }
    void setReconnectOnError(bool arg)
    {
        if (m_reconnectOnError != arg) {
            m_reconnectOnError = arg;
            emit reconnectOnErrorChanged();
        }
    }

    bool getArchiveIncMessage() const { return m_archiveIncMessage; }
    void setArchiveIncMessage(bool arg)
    {
        if (m_archiveIncMessage != arg) {
            m_archiveIncMessage = arg;
            emit archiveIncMessageChanged();
        }
    }
	
signals:
    void versionChanged();
    void messageReceived( QString fromBareJid, QString toBareJid );
    void connectingChanged();
    void statusTextChanged();
    void statusChanged();
    void typingChanged( QString bareJid, bool isTyping );
    void rosterChanged();
    void myJidChanged();
    void myPasswordChanged();
    void hostChanged();
    void portChanged();
    void resourceChanged();
    void openChatsChanged( QString bareJid );
    void chatOpened( QString bareJid );
    void chatClosed( QString bareJid );
    void messagesChanged();
    void chatJidChanged();
    void contactNameChanged();
    void vCardChanged();
    void presenceJidChanged( const QString &presenceBareJid, const QString &presenceTextStatus, const QString &presencePicStatus );
    void errorHappened( const QString &errorString );
    void subscriptionReceived( const QString bareJid );
    void keepAliveChanged();
    void reconnectOnErrorChanged();
    void archiveIncMessageChanged();

public slots:
    void clientStateChanged( QXmppClient::State state );

    Q_INVOKABLE void openChat( QString jid );
    Q_INVOKABLE void closeChat( QString jid );
    Q_INVOKABLE void hideChat() { this->setChatJid(""); msgWrapper->hideChat(); }

private slots:
    void initRoster();
    void initPresence(const QString& bareJid, const QString& resource);
    void initVCard(const QXmppVCardIq &vCard);
    void subscriptionReceivedSlot( const QString &);
    void itemAdded( const QString &);
    void itemRemoved( const QString &);
    void itemChanged( const QString &);
    void messageReceivedSlot( const QXmppMessage &msg );
    void presenceReceived( const QXmppPresence & presence );
    void error(QXmppClient::Error);

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
    QString m_contactName;
    void archiveIncMessage( const QXmppMessage &xmppMsg, bool mine );
    void appendConversationStart( QString bareJid );

    QString getPicPresence( const QXmppPresence &presence ) const;
    QString getTextStatus(const QString &textStatus, const QXmppPresence &presence ) const;


    int m_keepAlive;
    bool m_reconnectOnError;
    bool m_archiveIncMessage;

    bool flSetPresenceWithoutAck;
};

QML_DECLARE_TYPE( MyXmppClient )

#endif
