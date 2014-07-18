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
#include "src/models/MsgItemModel.h"
#include "src/xmpp/ContactListManager.h"

class XmppConnectivity : public QObject
{
    Q_OBJECT

    Q_PROPERTY(MyXmppClient* client READ getClient NOTIFY accountChanged)
    Q_PROPERTY(RosterListModel* roster READ getRoster NOTIFY rosterChanged)
    Q_PROPERTY(ChatsListModel* chats READ getChats NOTIFY chatsChanged)
    Q_PROPERTY(int page READ getPage WRITE gotoPage NOTIFY pageChanged)
    Q_PROPERTY(int messagesCount READ getMessagesCount NOTIFY pageChanged)
    Q_PROPERTY(SqlQueryModel* messagesByPage READ getSqlMessagesByPage NOTIFY pageChanged)
    Q_PROPERTY(SqlQueryModel* messages READ getSqlMessagesByPage NOTIFY sqlMessagesChanged)
    Q_PROPERTY(MsgListModel* cachedMessages READ getMessages NOTIFY sqlMessagesChanged)
    Q_PROPERTY(QString chatJid READ getChatJid WRITE setChatJid NOTIFY chatJidChanged)
    Q_PROPERTY(QString currentAccount READ getCurrentAccount WRITE changeAccount NOTIFY accountChanged)
    Q_PROPERTY(QString currentAccountName READ getCurrentAccountName NOTIFY accountChanged)
    Q_PROPERTY(int messagesLimit READ getMsgLimit WRITE setMsgLimit NOTIFY msgLimitChanged )

    Q_PROPERTY(bool offlineContactsVisibility READ getVisibility WRITE setVisibility NOTIFY visibilityChanged)
public:
    explicit XmppConnectivity(QObject *parent = 0);
    ~XmppConnectivity();

    bool initializeAccount(QString index, AccountsItemModel* account);
    Q_INVOKABLE void changeAccount(QString GRID);
    QString getCurrentAccount() { return currentClient; }

    // well, this stuff is needed
    int getPage() const { return page; }
    void gotoPage(int nPage);

    QString getChatJid() const { return currentJid; }
    void setChatJid( const QString & value ) {
        if(value!=currentJid) {
            currentJid=value;
            emit chatJidChanged();
        }
    }

    /* --- diagnostics --- */
    Q_INVOKABLE bool dbRemoveDb();
    Q_INVOKABLE bool cleanCache();
    Q_INVOKABLE bool cleanCache(QString path);
    Q_INVOKABLE bool resetSettings();

    //
    Q_INVOKABLE QString generateAccountName(QString host,QString jid);
    Q_INVOKABLE QString getAccountName(QString grid);
    Q_INVOKABLE QString getAccountIcon(QString grid);

    // widget
    void addChat(QString account, QString bareJid) {
      removeChat(account,bareJid,true);
      latestChats.append(account+";"+bareJid);
      if (latestChats.count()>10) latestChats.removeFirst();
    }

    void removeChat(QString account, QString bareJid,bool silent=false) {
      if (latestChats.contains(account+";"+bareJid))
        latestChats.removeAt(latestChats.indexOf(account+";"+bareJid));
    }

    Q_INVOKABLE QString getChatProperty(int index, QString property) {
      if (latestChats.count() >= latestChats.count()-index && latestChats.count()-index >= 0) {          
        QString presenceJid = latestChats.at(latestChats.count()-index);
        if (property == "accountId")
          return presenceJid.split(';').at(0);
        //return contacts->getPropertyByJid(presenceJid.split(';').at(1),property);
        } else if (property == "presence") return "-2";
      return "";
    }

    Q_INVOKABLE QString getChangeProperty(int index, QString property) {
      if (latestStatusChanges.count() >= latestStatusChanges.count()-index && latestStatusChanges.count()-index >= 0) {
        QString presenceJid = latestStatusChanges.at(latestStatusChanges.count()-index);
        if (property == "accountId")
          return presenceJid.split(';').at(0);
        //return contacts->getPropertyByJid(presenceJid.split(';').at(1),property);
        } else if (property == "presence") return "-2";
      return "";
    }

    Q_INVOKABLE int getGlobalUnreadCount();

signals:
    void personalityChanged();
    void accountChanged();
    void rosterChanged();

    void pageChanged();
    void sqlMessagesChanged();
    void chatJidChanged();
    void chatsChanged();
    void notifyMsgReceived(QString name,QString jid,QString body,QString account);
	
    void qmlChatChanged();
    void msgLimitChanged();
    void widgetDataChanged();
    void visibilityChanged();

    // MyXmppClient ones
    void xmppConnectingChanged    (const QString accountId);
    void xmppErrorHappened        (const QString accountId, const QString &errorString);
    void xmppStatusChanged        (const QString accountId);
    void xmppSubscriptionReceived (const QString accountId, const QString bareJid);
    void xmppTypingChanged        (const QString accountId, QString bareJid, bool isTyping);
    void xmppPresenceChanged      (QString m_accountId,QString bareJid,QString resource,QString picStatus,QString txtStatus);
    
public slots:
    void handleXmppStatusChange (const QString accountId);

    void updateContact(QString m_accountId,QString bareJid,QString property,int count) {
        dbWorker->executeQuery(QStringList() << "updateContact" << m_accountId << bareJid << property << QString::number(count));
    }
    void updateMessages() { dbWorker->updateMessages(currentClient,currentJid,page); }
    void insertMessage(QString m_accountId,QString bareJid,QString body,QString date,int mine);

    Q_INVOKABLE QString getAvatarByJid(QString bareJid) { return lCache->getAvatarCache(bareJid); }

    // handling chats list

    Q_INVOKABLE QString getPropertyByJid(QString account,QString property,QString jid);
    Q_INVOKABLE QString getPreservedMsg(QString jid);
    Q_INVOKABLE void preserveMsg(QString jid,QString message);
    Q_INVOKABLE void openChat(QString accountId, QString bareJid);
    Q_INVOKABLE void openChat(QString bareJid) { this->openChat(currentClient,bareJid); }
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

    Q_INVOKABLE void closeChat(QString bareJid) { this->closeChat(currentClient,bareJid); }
    Q_INVOKABLE void resetUnreadMessages(QString accountId, QString bareJid) { contacts->resetUnreadMessages(accountId,bareJid); }
    Q_INVOKABLE void resetUnreadMessages(QString bareJid) { contacts->resetUnreadMessages(currentClient,bareJid); }


    // widget
    void handleContactStatusChange(QString accountId, QString bareJid) {
      if (this->getPropertyByJid(accountId,bareJid,"presence") == "qrc:/presence/offline") return;
      if (latestStatusChanges.contains(accountId+";"+bareJid))
            latestStatusChanges.removeAt(latestStatusChanges.indexOf(accountId+";"+bareJid));
      latestStatusChanges.append(accountId+";"+bareJid);
      if (latestStatusChanges.count()>4) latestStatusChanges.removeFirst();
      emit widgetDataChanged();
    }

    Q_INVOKABLE void setVisibility(bool state)   { contacts->setOfflineContactsState(state); emit rosterChanged(); }
    Q_INVOKABLE bool getVisibility()           { return contacts->getOfflineContactsState(); }
	
    Q_INVOKABLE void updateAvatarCachingSetting(bool setting);
    Q_INVOKABLE void acceptSubscription(QString accountId,QString bareJid) { clients->value(accountId)->acceptSubscribtion(bareJid); }
    Q_INVOKABLE void rejectSubscription(QString accountId,QString bareJid) { clients->value(accountId)->rejectSubscribtion(bareJid); }
    Q_INVOKABLE int  getConnectionStatusByAccountId(QString accountId)     { return clients->value(accountId)->getStateConnect(); }
    Q_INVOKABLE int  getStatusByAccountId(QString accountId)               { return clients->value(accountId)->getStatus(); }
	
    Q_INVOKABLE void addContact(QString accountId, QString bareJid, QString nick) {
      clients->value(accountId)->addContact(bareJid,nick,"",true);
    }
    Q_INVOKABLE void renameContact(QString accountId, QString bareJid, QString newName) {
      clients->value(accountId)->renameContact(bareJid,newName);
    }
    Q_INVOKABLE void removeContact(QString accountId,QString bareJid) { clients->value(accountId)->removeContact(bareJid); }
    Q_INVOKABLE void subscribe(QString accountId,QString bareJid)     { clients->value(accountId)->subscribe(bareJid); }
    Q_INVOKABLE void unsubscribe(QString accountId,QString bareJid)   { clients->value(accountId)->unsubscribe(bareJid); }

    Q_INVOKABLE void updateMyData(QString jid);

private:
    QString currentClient;
    QMap<QString,MyXmppClient*> *clients;
    MyXmppClient* selectedClient;
    MyXmppClient* getClient() { return selectedClient; }

    QMap<QString,MsgListModel*> *cachedMessages;

    RosterListModel* getRoster();
    ContactListManager *contacts;

    QString getCurrentAccountName();

    SqlQueryModel* getSqlMessagesByPage() { return dbWorker->getSqlMessages(); }
    int getMessagesCount() { return dbWorker->getPageCount(currentClient,currentJid); }
    MsgListModel* getMessages() {
      MsgListModel* messages = cachedMessages->value(currentJid);
      if (msgLimit > 0) {
         while (messages->count() > msgLimit) {
             messages->remove(0);
           }
        }
      return messages;
    }

    ChatsListModel* chats;
    ChatsListModel* getChats() { return chats; }

    MyCache* lCache;
    Settings* lSettings;

    DatabaseWorker *dbWorker;
    QThread *dbThread;

    int page; //required for archive view
    QString currentJid;

    static bool removeDir(const QString &dirName); //workaround for qt not able to remove directory recursively
    // http://john.nachtimwald.com/2010/06/08/qt-remove-directory-and-its-contents/

    int globalUnreadCount;
    int msgLimit;

    MessageWrapper *msgWrapper;

    QStringList latestChats;
    QStringList latestStatusChanges;
};

#endif // XMPPCONNECTIVITY_H
