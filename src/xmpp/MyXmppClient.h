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
#include "QXmppUtils.h"
#include "QXmppRosterManager.h"
#include "QXmppVersionManager.h"
#include "QXmppVersionIq.h"
#include "QXmppMucManager.h"
#include "QXmppTransferManager.h"
#include "QXmppDiscoveryManager.h"
#include "QXmppConfiguration.h"
#include "QXmppClient.h"
#include "QXmppMessage.h"
#include "QXmppEntityTimeManager.h"
#include "QXmppEntityTimeIq.h"

#include <QObject>
#include <QTimer>
#include <QList>
#include <QMap>
#include <QVariant>
#include <QCryptographicHash>
#include <QFile>
#include <QDir>
#include <QStringList>
#include <QDebug>
#include <QDesktopServices>

#include "../cache/MyCache.h"
#include "../models/ParticipantListModel.h"
#include "../models/ParticipantItemModel.h"
#include "../api/GraphAPIExtensions.h"
#include "ContactListManager.h"
#include "EventsManager.h"
#include "../models/ServiceListModel.h"
#include "../models/ServiceItemFilter.h"

class MyXmppClient : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY( MyXmppClient )
    Q_PROPERTY(bool isConnected READ isConnected NOTIFY connectingChanged)


    QXmppClient *xmppClient;
    QXmppRosterManager *rosterManager;
    QXmppVCardManager *vCardManager;
    QXmppMucManager *mucManager;
    QXmppTransferManager *transferManager;
    QXmppDiscoveryManager *serviceDiscovery;
    QXmppEntityTimeManager *entityTime;
    QXmppVersionManager *versionManager;
    GraphAPIExtensions *graph;

    ContactListManager *contacts;
    EventsManager *events;
    MyCache* cacheIM;

public :
    bool disableAvatarCaching;
    bool legacyAvatarCaching;

    enum StatusXmpp {
        Offline = 0,
        Online = 1,
        Chat = 2,
        Away = 3,
        XA = 4,
        DND = 5
    };

    Q_ENUMS( StatusXmpp )

    explicit MyXmppClient(MyCache* lCache, ContactListManager *lContacts, EventsManager *lEvents);
    ~MyXmppClient();

    /* --- presence --- */
    Q_INVOKABLE void setPresence( StatusXmpp status, QString textStatus );

    /*--- connect/disconnect ---*/
    Q_INVOKABLE void connectToXmppServer();

    /*--- send msg ---*/
    Q_INVOKABLE bool sendMessage(QString bareJid, QString resource, QString msgBody, int chatState, int msgType);
    Q_INVOKABLE bool requestAttention(QString bareJid, QString resource = "");

    /*--- info by jid ---*/
    Q_INVOKABLE QStringList getResourcesByJid (QString bareJid) { return rosterManager->getResources(bareJid); }

    /*--- add/remove contact ---*/
    Q_INVOKABLE bool addContact(QString bareJid, QString nick, QString group, bool sendSubscribe );
    Q_INVOKABLE bool removeContact( QString bareJid ) { return rosterManager->removeItem( bareJid ); }
    Q_INVOKABLE bool renameContact(QString bareJid, QString name) { return rosterManager->renameItem( bareJid, name ); }

    /*--- subscribe ---*/
    Q_INVOKABLE bool subscribe (const QString bareJid) { return rosterManager->subscribe(bareJid); }
    Q_INVOKABLE bool unsubscribe (const QString bareJid) { return rosterManager->unsubscribe(bareJid); }
    Q_INVOKABLE bool acceptSubscription (const QString bareJid) { return rosterManager->acceptSubscription(bareJid); }
    Q_INVOKABLE bool rejectSubscription (const QString bareJid) { return rosterManager->refuseSubscription(bareJid); }
    Q_INVOKABLE bool setFavContact(const QString bareJid, bool state) { contacts->setContactFavState(m_accountId,bareJid,state); }

    /*----------------------------------*/
    /*--- getter/setter ---*/
    Q_INVOKABLE int getStateConnect() const { return xmppClient->state(); }

    QString getStatusText() const { return m_statusText; }
    void setStatusText( const QString& );

    Q_INVOKABLE StatusXmpp getStatus() const { return m_status; }
    void setStatus( StatusXmpp __status );

    Q_INVOKABLE StatusXmpp getPrevStatus() const { return m_prevStatus; }

    QString getMyJid() const { return m_myjid; }
    void setMyJid( const QString& myjid ) { m_myjid=myjid; }

    QString getPassword() const { return m_password; }
    void setPassword( const QString& value ) { m_password=value; }

    QString getHost() const { return m_host; }
    void setHost( const QString & value ) { m_host=value; }

    int getPort() const { return m_port; }
    void setPort( const int& value ) { m_port=value; }

    QString getResource() const { return m_resource; }
    void setResource( const QString & value ) { m_resource=value; }

    QString getAccountId() const { return m_accountId; }
    void setAccountId( const QString & value ) { m_accountId = value; }
    void setKeepAlive(int arg) { m_keepAlive = arg; }

    // XEP-0202: Entity Time
    Q_INVOKABLE void requestContactTime(const QString bareJid, QString resource);

    // XEP-0092: Software Version
    Q_INVOKABLE void requestContactVersion(const QString bareJid, QString resource);

    // MUC
    Q_INVOKABLE void joinMUCRoom(QString room, QString nick, QString password="");
    void leaveMUCRoom(QString room);
    QString getMUCNick(QString room);
    QStringList getListOfParticipants(QString room);
    Q_INVOKABLE int getPermissionLevel(QString room) { return (int)mucRooms.value(room)->allowedActions(); }
    Q_INVOKABLE bool isActionPossible(int permissionLevel, int action);
    bool isMucRoom(QString bareJid) { return mucRooms.contains(bareJid); }
    Q_INVOKABLE ParticipantListModel* getParticipants(QString bareJid) { return mucParticipants.value(bareJid); }
    Q_INVOKABLE QString getMUCSubject(QString room) { return mucRooms.value(room)->subject(); }
    Q_INVOKABLE void setMUCSubject(QString room, QString subject) { mucRooms.value(room)->setSubject(subject); }
    Q_INVOKABLE void kickMUCUser(QString room, QString userJid, QString reason) { mucRooms.value(room)->kick(userJid,reason); }
    Q_INVOKABLE void banMUCUser(QString room, QString userJid, QString reason) {
      QString userBareJid = QXmppUtils::jidToBareJid(mucRooms.value(room)->participantFullJid(userJid));
      mucRooms.value(room)->ban(userBareJid,reason);
    }

    // File transfer
    Q_INVOKABLE void acceptTransfer(int jobId, QString path);
    Q_INVOKABLE void abortTransfer(int jobId);
    Q_INVOKABLE void openLocalTransferPath(int jobId);
    Q_INVOKABLE void sendAFile(QString bareJid, QString resource, QString path);

    // avatar caching
    Q_INVOKABLE void forceRefreshVCard(QString bareJid);

    // service discovery
    Q_INVOKABLE void askServer(QString jid);
    Q_INVOKABLE void debugThisCrapServices();

    // am I retarded?
    Q_INVOKABLE bool isFacebook() { return m_host == "chat.facebook.com"; }
    Q_INVOKABLE bool isConnected() { return getStateConnect() == QXmppClient::ConnectedState; }
	
signals:
    void statusTextChanged();
    void typingChanged(QString accountId, QString bareJid, bool isTyping);
    void contactStatusChanged(QString accountId, QString bareJid);

    // related to XmppConnectivity class
    void updateContact(QString m_accountId,QString bareJid,QString property,int count);
    void insertMessage(QString m_accountId,QString bareJid,QString body,QString date,int mine,int type,QString resource);
    void attentionRequested(QString m_accountId, QString bareJid);
    void presenceChanged(QString m_accountId,QString bareJid,QString resource,QString picStatus,QString txtStatus);

    void connectingChanged(const QString accountId);
    void errorHappened(const QString accountId,const QString &errorString);
    void subscriptionReceived(const QString accountId,const QString bareJid);
    void statusChanged(const QString accountId);

    void iFoundYourParentsGoddamit(QString jid);

    // XEP-0202: Entity Time
    void entityTimeReceived(QString accountId, QString bareJid, QString resource, QString time);

    //
    void versionReceived(QString accountId, QString bareJid, QString resource, QString version);

    // muc
    void mucRoomJoined(QString accountId,QString bareJid);
    void mucNameChanged(QString accountId,QString bareJid,QString name);

    // file transfer
    void incomingTransferReceived(QString accountId, QString bareJid, QString name, QString description, int transferJob, bool isIncoming);

public slots:
    void clientStateChanged(QXmppClient::State state);

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

    void notifyNewSubscription(QString bareJid) {
      emit subscriptionReceived(m_accountId, bareJid);
      events->appendSubscription(m_accountId, bareJid);
    }

    // XEP-0202: Entity Time
    void entityTimeReceivedSlot(const QXmppEntityTimeIq &entity);

    void versionReceivedSlot(const QXmppVersionIq &version);

    // multi user chat
    void mucTopicChangeSlot(QString subject);
    void mucJoinedSlot();
    void mucErrorSlot(const QXmppStanza::Error &error);
    void mucKickedSlot(const QString &jid, const QString &reason);
    void mucRoomNameChangedSlot(const QString &name);
    void mucYourNickChanged(const QString &nickName);
    void mucParticipantAddedSlot(const QString &jid);
    void mucParticipantRemovedSlot(const QString &jid);
    void permissionsReceived(const QList<QXmppMucItem> &permissions);


    // file transfer
    void incomingTransfer(QXmppTransferJob *job);
    void transferFinished();
    void transferError(QXmppTransferJob::Error error);
    void progress(qint64 done, qint64 total);

    // service discovery
    void itemsReceived (const QXmppDiscoveryIq &items);
    void infoReceived (const QXmppDiscoveryIq &iq);

    //

    void resetInitState() { initializationState = false; }

    void logMessageReceived(QXmppLogger::MessageType type, const QString &text) {
      QString typeStr;

      switch (type) {
        case QXmppLogger::DebugMessage: typeStr = "DEBUG"; break;
        case QXmppLogger::InformationMessage: typeStr = "INFO"; break;
        case QXmppLogger::WarningMessage: typeStr = "WARN"; break;
        case QXmppLogger::ReceivedMessage: typeStr = "RECV"; break;
        case QXmppLogger::SentMessage: typeStr = "SENT"; break;
        }

      qDebug().nospace() << "MyXmppClient(): [" << qPrintable(typeStr) << "] " << text;
    }

private:
    // functions
    void initRosterManager();

    StatusXmpp m_status;
    StatusXmpp m_prevStatus;
    bool initializationState;
    QString m_statusText;
    QString m_myjid;
    QString m_password;
    QString m_host;
    int m_port;
    QString m_resource;

    QString m_accountId;
    QMap<QString,ServiceListModel*> servicesCache;
    ServiceListModel *services(QString jid);

    QString getPicPresence( const QXmppPresence &presence ) const;
    QString getTextStatus(const QString &textStatus, const QXmppPresence &presence ) const;

    QXmppClient::State previousState;
    int m_keepAlive;

    QMap<QString,QXmppMucRoom*> mucRooms;
    QMap<QString,ParticipantListModel*> mucParticipants;

    QMap<int,QXmppTransferJob*> transferJobs;
    QString defaultTransferProxy;
};

#endif
