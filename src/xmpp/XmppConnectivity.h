/********************************************************************

src/xmpp/XmppConnectivity.h
-- used for managing XMPP clients and serves as a bridge between UI and
-- clients

Copyright (c) 2013 Maciej Janiszewski

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

#ifndef XMPPCONNECTIVITY_H
#define XMPPCONNECTIVITY_H

#include <QObject>
#include <QThread>
#include <QMap>
#include "src/models/AccountsItemModel.h"
#include "MyXmppClient.h"
#include "src/database/DatabaseWorker.h"
#include "src/cache/MyCache.h"
#include "src/database/Settings.h"

#include "MessageWrapper.h"

#include "src/models/ChatsListModel.h"
#include "src/models/MsgListModel.h"
#include "src/models/ParticipantListModel.h"
#include "src/models/MsgItemModel.h"
#include "src/xmpp/ContactListManager.h"
#include "src/xmpp/EventsManager.h"

class XmppConnectivity : public QObject
{
    Q_OBJECT

    Q_PROPERTY(RosterListModel* roster READ getRoster NOTIFY rosterChanged)
    Q_PROPERTY(ChatsListModel* chats READ getChats NOTIFY chatsChanged)
    Q_PROPERTY(EventsManager* events READ getEvents)
    Q_PROPERTY(int messagesLimit READ getMsgLimit WRITE setMsgLimit NOTIFY msgLimitChanged )

    Q_PROPERTY(bool offlineContactsVisibility READ getVisibility WRITE setVisibility NOTIFY visibilityChanged)
public:
    explicit XmppConnectivity(QObject *parent = 0);
    ~XmppConnectivity();

    bool initializeAccount(QString index, AccountsItemModel* account);

    /* --- diagnostics --- */
    Q_INVOKABLE bool dbRemoveDb();
    Q_INVOKABLE bool cleanCache();
    Q_INVOKABLE bool cleanCache(QString path);
    Q_INVOKABLE bool resetSettings();

    //
    Q_INVOKABLE QString generateAccountName(QString host,QString jid);
    Q_INVOKABLE QString getAccountName(QString grid);
    Q_INVOKABLE QString getAccountIcon(QString grid);
    Q_INVOKABLE int getGlobalUnreadCount();

signals:
    void personalityChanged();
    void rosterChanged();

    void pageChanged();
    void sqlMessagesChanged();
    void chatsChanged();
    void notifyMsgReceived(QString name,QString jid,QString body,QString account);
	
    void qmlChatChanged();
    void msgLimitChanged();
    void widgetDataChanged();
    void visibilityChanged();

    void unreadCountChanged(int delta);

    // MyXmppClient ones
    void xmppConnectingChanged    (const QString accountId);
    void xmppErrorHappened        (const QString accountId, const QString &errorString);
    void xmppStatusChanged        (const QString accountId);
    void xmppSubscriptionReceived (const QString accountId, const QString bareJid);
    void xmppTypingChanged        (const QString accountId, QString bareJid, bool isTyping);
    void xmppPresenceChanged      (QString m_accountId,QString bareJid,QString resource,QString picStatus,QString txtStatus);

    void mucInvitationReceived    (QString accountId, QString bareJid, QString invSender, QString reason);
    void avatarUpdatedForJid(QString bareJid);
    
public slots:
    void handleXmppStatusChange (const QString accountId);

    void insertMessage(QString m_accountId,QString bareJid,QString body,QString date,int mine, int type, QString resource);
    Q_INVOKABLE QString getAvatarByJid(QString bareJid) { return lCache->getAvatarCache(bareJid); }

    // handling chats list

    Q_INVOKABLE QString getPropertyByJid(QString account,QString property,QString jid);
    Q_INVOKABLE QString getPreservedMsg(QString jid);
    Q_INVOKABLE void preserveMsg(QString accountId,QString jid,QString message);
    Q_INVOKABLE void openChat(QString accountId, QString bareJid);
    Q_INVOKABLE void closeChat(QString accountId, QString bareJid);
    void updateChatName(QString m_accountId,QString bareJid,QString name);

    Q_INVOKABLE void setMsgLimit(int limit) { msgLimit = limit; }

    int getMsgLimit() { return msgLimit; }

    Q_INVOKABLE void emitQmlChat() {
      emit qmlChatChanged();
      emit sqlMessagesChanged();
    }

    // handling clients
    Q_INVOKABLE void accountAdded(QString id);
    Q_INVOKABLE void accountRemoved(QString id);
    Q_INVOKABLE void accountModified(QString id);

    Q_INVOKABLE int getStatusByIndex(QString accountId);

    Q_INVOKABLE void resetUnreadMessages(QString accountId, QString bareJid);
    Q_INVOKABLE int getUnreadCount(QString accountId, QString bareJid);
    Q_INVOKABLE int getChatType(QString accountId, QString bareJid);

    Q_INVOKABLE void setVisibility(bool state)   { contacts->setOfflineContactsState(state); emit rosterChanged(); }
    Q_INVOKABLE bool getVisibility()           { return contacts->getOfflineContactsState(); }
	
    Q_INVOKABLE void updateAvatarCachingSetting(bool setting);
    Q_INVOKABLE void updateKeepAliveSetting(int keepAlive);

    Q_INVOKABLE void updateMyData(QString jid);

    // handle messages and states
    Q_INVOKABLE MsgListModel* getMessages(QString jid);
    Q_INVOKABLE SqlQueryModel* getSqlMessagesByPage(QString accountId, QString bareJid, int page);
    Q_INVOKABLE int getPagesCount(QString accountId, QString bareJid) { return dbWorker->getPageCount(accountId,bareJid); }
    Q_INVOKABLE QString generateLog(QString accountId, QString bareJid, QString contactName, int beginID, int endID) {
      return dbWorker->generateLog(accountId,bareJid,contactName,beginID,endID);
    }

    // handle MUC
    QString getMUCParticipantRoleName(int role) { return QXmppMucItem::roleToString((QXmppMucItem::Role)role); }
    QString getMUCParticipantAffiliationName(int aff) { return QXmppMucItem::affiliationToString((QXmppMucItem::Affiliation)aff); }

    // a clever idea to unclutter this shit
    Q_INVOKABLE MyXmppClient* useClient(QString accountId) { return clients->value(accountId); }

private:
    QString currentClient;
    QMap<QString,MyXmppClient*> *clients;

    QMap<QString,MsgListModel*> *cachedMessages;

    RosterListModel* getRoster();
    ContactListManager *contacts;

    ChatsListModel* chats;
    ChatsListModel* getChats() { return chats; }

    MyCache* lCache;
    Settings* lSettings;

    DatabaseWorker *dbWorker;
    QThread *dbThread;

    static bool removeDir(const QString &dirName); //workaround for qt not able to remove directory recursively
    // http://john.nachtimwald.com/2010/06/08/qt-remove-directory-and-its-contents/

    int globalUnreadCount;
    int msgLimit;

    MessageWrapper *msgWrapper;
    EventsManager *events;
    EventsManager* getEvents() { return events; }

    void plusUnreadChatMsg(QString accountId,QString bareJid);
};

#endif // XMPPCONNECTIVITY_H
