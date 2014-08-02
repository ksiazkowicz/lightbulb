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
#include "QXmppMucManager.h"
#include "QXmppTransferManager.h"
#include "QXmppDiscoveryManager.h"
#include "QXmppConfiguration.h"
#include "QXmppClient.h"
#include "QXmppMessage.h"

#include <QObject>
#include <QList>
#include <QMap>
#include <QVariant>
#include <QCryptographicHash>
#include <QFile>
#include <QDir>
#include <QStringList>
#include <QDebug>

#include "src/database/Settings.h"

#include "src/cache/MyCache.h"

class MyXmppClient : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY( MyXmppClient )

    Q_PROPERTY( QString bareJidLastMsg READ getJidLastMsg )
    Q_PROPERTY( QString resourceLastMsg READ getResourceLastMsg )
    Q_PROPERTY( StateConnect stateConnect READ getStateConnect NOTIFY connectingChanged )
    Q_PROPERTY( StatusXmpp status READ getStatus WRITE setStatus NOTIFY statusChanged )
    Q_PROPERTY( QString statusText READ getStatusText WRITE setStatusText  NOTIFY statusTextChanged )
    Q_PROPERTY( QString myBareJid READ getMyJid WRITE setMyJid NOTIFY myJidChanged )
    Q_PROPERTY( QString myPassword READ getPassword() WRITE setPassword  NOTIFY myPasswordChanged )
    Q_PROPERTY( QString host READ getHost WRITE setHost NOTIFY hostChanged )
    Q_PROPERTY( int port READ getPort WRITE setPort NOTIFY portChanged )
    Q_PROPERTY( QString resource READ getResource WRITE setResource NOTIFY resourceChanged )
    Q_PROPERTY( QString accountId READ getAccountId WRITE setAccountId NOTIFY accountIdChanged )

    QXmppClient *xmppClient;
    QXmppRosterManager *rosterManager;
    QXmppVCardManager *vCardManager;
    QXmppMucManager *mucManager;
    QXmppTransferManager *transferManager;
    QXmppDiscoveryManager *serviceDiscovery;

    MyCache* cacheIM;

public :
    bool disableAvatarCaching;

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

    /* --- presence --- */
    Q_INVOKABLE void setMyPresence( StatusXmpp status, QString textStatus );

    /*--- connect/disconnect ---*/
    Q_INVOKABLE void connectToXmppServer();

    /*--- send msg ---*/
    bool sendMessage(QString bareJid, QString resource, QString msgBody, int chatState, int msgType);

    /*--- info by jid ---*/
    Q_INVOKABLE QStringList getResourcesByJid (QString bareJid) { return rosterManager->getResources(bareJid); }

    static QString getBareJidByJid( const QString &jid );
    static QString getResourceByJid( const QString &jid );

    /*--- add/remove contact ---*/
    Q_INVOKABLE void addContact(QString bareJid, QString nick, QString group, bool sendSubscribe );
    Q_INVOKABLE void removeContact( QString bareJid ) { rosterManager->removeItem( bareJid ); }
    Q_INVOKABLE void renameContact(QString bareJid, QString name) { rosterManager->renameItem( bareJid, name ); }

    /*--- subscribe ---*/
    Q_INVOKABLE bool subscribe (const QString bareJid) { return rosterManager->subscribe(bareJid); }
    Q_INVOKABLE bool unsubscribe (const QString bareJid) { return rosterManager->unsubscribe(bareJid); }
    Q_INVOKABLE bool acceptSubscribtion (const QString bareJid) { return rosterManager->acceptSubscription(bareJid); }
    Q_INVOKABLE bool rejectSubscribtion (const QString bareJid) { return rosterManager->refuseSubscription(bareJid); }
	
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

    QString getAccountId() const { return m_accountId; }
    void setAccountId( const QString & value ) {
        if (value!=m_accountId) {
            m_accountId = value;
            emit accountIdChanged();
        }
    }
    void setKeepAlive(int arg) { m_keepAlive = arg; }

    void goOnline(QString lastStatus) { this->setMyPresence(Online,lastStatus); }

    void joinMUCRoom(QString room, QString nick);
    void leaveMUCRoom(QString room);
    QString getMUCNick(QString room);
    QString getMUCSubject(QString room);
	
signals:
    void versionChanged();
    void statusTextChanged();
    void myJidChanged();
    void myPasswordChanged();
    void hostChanged();
    void portChanged();
    void resourceChanged();
    void typingChanged(QString accountId, QString bareJid, bool isTyping);
    void accountIdChanged();
    void contactStatusChanged(QString accountId, QString bareJid);

    // related to XmppConnectivity class
    void updateContact(QString m_accountId,QString bareJid,QString property,int count);
    void insertMessage(QString m_accountId,QString bareJid,QString body,QString date,int mine,int type,QString resource);
    void contactRenamed(QString jid,QString name);

    void connectingChanged(const QString accountId);
    void errorHappened(const QString accountId,const QString &errorString);
    void subscriptionReceived(const QString accountId,const QString bareJid);
    void statusChanged(const QString accountId);

    // contact list manager
    void contactAdded(QString acc,QString jid, QString name);
    void presenceChanged(QString m_accountId,QString bareJid,QString resource,QString picStatus,QString txtStatus);
    void nameChanged(QString m_accountId,QString bareJid,QString name);
    void contactRemoved(QString acc,QString bareJid);

    void iFoundYourParentsGoddamit(QString jid);

    // muc
    void mucSubjectChanged(QString bareJid, QString newSubject);
    void mucInvitationReceived(QString accountId, QString bareJid, QString invSender, QString reason);

public slots:
    void clientStateChanged( QXmppClient::State state );

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

    void notifyNewSubscription(QString bareJid) { emit subscriptionReceived(m_accountId, bareJid); }

    void mucTopicChangeSlot(QString subject);

    void incomingTransfer(QXmppTransferJob *job);

private:
    // functions
    void initRosterManager();

    // private variables
    QString m_bareJidLastMessage;
    QString m_resourceLastMessage;

    StateConnect m_stateConnect;
    StatusXmpp m_status;
    QString m_statusText;
    QString m_myjid;
    QString m_password;
    QString m_host;
    int m_port;
    QString m_resource;
    QString m_lastChatJid;

    QString m_accountId;

    QString getPicPresence( const QXmppPresence &presence ) const;
    QString getTextStatus(const QString &textStatus, const QXmppPresence &presence ) const;

    int m_keepAlive;

    QMap<QString,QXmppMucRoom*> mucRooms;
};

#endif
