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
#include "AccountsItemModel.h"
#include "MyXmppClient.h"
#include "DatabaseWorker.h"
#include "MyCache.h"
#include "Settings.h"

#include "ChatsListModel.h"
#include "MsgListModel.h"
#include "MsgItemModel.h"

class XmppConnectivity : public QObject
{
    Q_OBJECT

    Q_PROPERTY(MyXmppClient* client READ getClient NOTIFY accountChanged)
    Q_PROPERTY(RosterListModel* roster READ getRoster NOTIFY rosterChanged)
    Q_PROPERTY(ChatsListModel* chats READ getChats NOTIFY chatsChanged)
    Q_PROPERTY(int page READ getPage WRITE gotoPage NOTIFY pageChanged)
    Q_PROPERTY(SqlQueryModel* messagesByPage READ getSqlMessagesByPage NOTIFY pageChanged)
    Q_PROPERTY(SqlQueryModel* messages READ getSqlMessagesByPage NOTIFY sqlMessagesChanged)
    Q_PROPERTY(MsgListModel* cachedMessages READ getMessages NOTIFY sqlMessagesChanged)
    Q_PROPERTY(QString chatJid READ getChatJid WRITE setChatJid NOTIFY chatJidChanged)
    Q_PROPERTY(int currentAccount READ getCurrentAccount WRITE changeAccount NOTIFY accountChanged)
    Q_PROPERTY(QString currentAccountName READ getCurrentAccountName NOTIFY accountChanged)
public:
    explicit XmppConnectivity(QObject *parent = 0);
    bool initializeAccount(int index, AccountsItemModel* account);
    Q_INVOKABLE void changeAccount(int index);
    int getCurrentAccount() { return currentClient; }

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
    Q_INVOKABLE bool resetSettings();

signals:
    void accountChanged();
    void rosterChanged();

    void pageChanged();
    void sqlMessagesChanged();
    void chatJidChanged();

    void chatsChanged();

    void notifyMsgReceived(QString name,QString jid,QString body);

    void qmlChatChanged();
    
public slots:
    void changeRoster() {
        roster = selectedClient->getCachedRoster();
        emit rosterChanged();
    }
    void updateContact(int m_accountId,QString bareJid,QString property,int count) {
        dbWorker->executeQuery(QStringList() << "updateContact" << QString::number(m_accountId) << bareJid << property << QString::number(count));
    }
    void updateMessages() { dbWorker->updateMessages(currentClient,currentJid,page); }
    void insertMessage(int m_accountId,QString bareJid,QString body,QString date,int mine);

    Q_INVOKABLE QString getAvatarByJid(QString bareJid) { return lCache->getAvatarCache(bareJid); }

    // handling chats list
    void chatOpened(int accountId,QString bareJid);
    void chatClosed(QString bareJid);
    Q_INVOKABLE QString getPropertyByJid(int account,QString property,QString jid);
    Q_INVOKABLE QString getPreservedMsg(QString jid);
    Q_INVOKABLE void preserveMsg(QString jid,QString message);

    Q_INVOKABLE void emitQmlChat() {
      emit qmlChatChanged();
      emit sqlMessagesChanged();
    }

    // handling clients
    void accountAdded();
    void accountRemoved(QString bareJid);
    void accountModified(QString bareJid);
    Q_INVOKABLE int getStatusByIndex(int index);
    void renameChatContact(QString bareJid,QString name) {
      ChatsItemModel* item = (ChatsItemModel*)chats->find(bareJid);
      item->setContactName(name);
      item = 0; delete item;
    }

private:
    int currentClient;
    QMap<int,MyXmppClient*> *clients;
    MyXmppClient* selectedClient;
    MyXmppClient* getClient() { return selectedClient; }

    QMap<QString,MsgListModel*> *cachedMessages;

    RosterListModel* roster;
    RosterListModel* getRoster() { return roster; }

    QString getCurrentAccountName();

    SqlQueryModel* getSqlMessagesByPage() { return dbWorker->getSqlMessages(); }
    MsgListModel* getMessages() {
      return cachedMessages->value(currentJid);
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
};

#endif // XMPPCONNECTIVITY_H
