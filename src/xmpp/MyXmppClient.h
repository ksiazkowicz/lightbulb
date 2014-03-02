/********************************************************************

src/xmpp/MyXmppClient.h
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

#ifndef MYXMPPCLIENT_H
#define MYXMPPCLIENT_H

#include "QXmppVCardIq.h"
#include "QXmppVCardManager.h"
#include "QXmppClient.h"
#include "QXmppRosterManager.h"
#include "QXmppVersionManager.h"
#include "QXmppConfiguration.h"
#include "QXmppClient.h"
#include "QXmppMessage.h"

#include <QObject>
#include <QList>
#include <QVariant>
#include <QCryptographicHash>
#include <QFile>
#include <QDir>
#include <QStringList>
#include <QDebug>

#include "Settings.h"

#include "RosterListModel.h"
#include "RosterItemModel.h"

#include "QMLVCard.h"
#include "MyCache.h"

class MyXmppClient : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY( MyXmppClient )

    Q_PROPERTY( QString version READ getVersion NOTIFY versionChanged )
    Q_PROPERTY( QString bareJidLastMsg READ getJidLastMsg )
    Q_PROPERTY( QString resourceLastMsg READ getResourceLastMsg )
    Q_PROPERTY( StateConnect stateConnect READ getStateConnect NOTIFY connectingChanged )
    Q_PROPERTY( StatusXmpp status READ getStatus WRITE setStatus NOTIFY statusChanged )
    Q_PROPERTY( QString statusText READ getStatusText WRITE setStatusText  NOTIFY statusTextChanged )
    Q_PROPERTY( bool isTyping READ getTyping NOTIFY typingChanged )
    Q_PROPERTY( RosterListModel* cachedRoster READ getCachedRoster NOTIFY rosterChanged)
    Q_PROPERTY( QString myBareJid READ getMyJid WRITE setMyJid NOTIFY myJidChanged )
    Q_PROPERTY( QString myPassword READ getPassword() WRITE setPassword  NOTIFY myPasswordChanged )
    Q_PROPERTY( QString host READ getHost WRITE setHost NOTIFY hostChanged )
    Q_PROPERTY( int port READ getPort WRITE setPort NOTIFY portChanged )
    Q_PROPERTY( QString resource READ getResource WRITE setResource NOTIFY resourceChanged )
    Q_PROPERTY( int accountId READ getAccountId WRITE setAccountId NOTIFY accountIdChanged )
    Q_PROPERTY( QMLVCard* vcard READ getVCard NOTIFY vCardChanged )
    Q_PROPERTY( int keepAlive READ getKeepAlive WRITE setKeepAlive NOTIFY keepAliveChanged )

    QXmppClient *xmppClient;
    QXmppRosterManager *rosterManager;
    QXmppVCardManager *vCardManager;

    QMLVCard * qmlVCard;
    QString flVCardRequest;
    MyCache* cacheIM;

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
    Q_INVOKABLE void resetUnreadMessages( QString bareJid ) {
        RosterItemModel *item = (RosterItemModel*)cachedRoster->find( bareJid );
        if( item != 0 ) {
            item->setUnreadMsg( 0 );
        }
    }
    Q_INVOKABLE void setUnreadMessages( QString bareJid, int count ) { emit updateContact(m_accountId,bareJid,"unreadMsg",count); }

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
        if (item != 0) {
          if (property == "name") return item->name();
          else if (property == "presence") return item->presence();
          else if (property == "resource") return item->resource();
          else if (property == "statusText") return item->statusText();
          else if (property == "unreadMsg") return QString::number(item->unreadMsg());
          } else return "(unknown)";
    }
    Q_INVOKABLE QStringList getResourcesByJid( QString bareJid ) { return rosterManager->getResources(bareJid); }

    Q_INVOKABLE QString getNameByOrderID( int id ) {
        if (cachedRoster->count() >= id+1) {
            RosterItemModel *item = (RosterItemModel*)cachedRoster->getElementByID(id);
            if (item != 0) return item->name(); else return " ";
        }
        return " ";
    }

    Q_INVOKABLE QString getPresenceByOrderID( int id ) {
        if (cachedRoster->count() >= id+1) {
            RosterItemModel *item = (RosterItemModel*)cachedRoster->getElementByID(id);
            if (item != 0) return item->presence(); else return "";
        }
        return "";
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

    RosterListModel* cachedRoster;

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

    bool getTyping() const { return m_flTyping; }
    void setTyping( QString &jid, const bool isTyping ) { m_flTyping = isTyping; emit typingChanged(jid, isTyping); }

    RosterListModel* getCachedRoster() const { return cachedRoster; }

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

    int getAccountId() const { return m_accountId; }
    void setAccountId( const int & value ) {
        if (value!=m_accountId) {
            m_accountId = value;
            emit accountIdChanged();
        }
    }
    QMLVCard* getVCard() const { return qmlVCard; }

    int getKeepAlive() const { return m_keepAlive; }
    void setKeepAlive(int arg) { if (m_keepAlive != arg) { m_keepAlive = arg; emit keepAliveChanged(); } }
	
signals:
    void versionChanged();
    void connectingChanged();
    void statusTextChanged();
    void statusChanged();
    void rosterChanged();
    void typingChanged( QString bareJid, bool isTyping );
    void myJidChanged();
    void myPasswordChanged();
    void hostChanged();
    void portChanged();
    void resourceChanged();
    void openChatsChanged();
    void chatOpened( int accountId, QString bareJid );
    void chatClosed( QString bareJid );
    void accountIdChanged();
    void vCardChanged();
    void errorHappened( const QString &errorString );
    void subscriptionReceived( const QString bareJid );
    void keepAliveChanged();

    // related to XmppConnectivity class
    void updateContact(int m_accountId,QString bareJid,QString property,int count);
    void insertMessage(int m_accountId,QString bareJid,QString body,QString date,int mine);
    void contactRenamed(QString jid,QString name);

public slots:
    void clientStateChanged( QXmppClient::State state );

    Q_INVOKABLE void openChat( QString jid ) { emit chatOpened( m_accountId, jid ); }
    Q_INVOKABLE void closeChat( QString jid ) {
      this->resetUnreadMessages( jid );
      emit chatClosed( jid );
    }

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
    QString m_lastChatJid;

    int m_accountId;

    QString getPicPresence( const QXmppPresence &presence ) const;
    QString getTextStatus(const QString &textStatus, const QXmppPresence &presence ) const;

    int m_keepAlive;
};

#endif
