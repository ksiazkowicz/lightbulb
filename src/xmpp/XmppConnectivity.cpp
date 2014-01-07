/********************************************************************

src/xmpp/XmppConnectivity.cpp
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

#include "XmppConnectivity.h"

XmppConnectivity::XmppConnectivity(QObject *parent) :
    QObject(parent)
{
    selectedClient = new MyXmppClient();
    currentClient = -1;
    clients = new QMap<int,MyXmppClient*>;
    lSettings = new Settings();
    lCache = new MyCache();
    lCache->createHomeDir();

    dbWorker = new DatabaseWorker;
    dbThread = new QThread(this);
    dbWorker->moveToThread(dbThread);
    dbThread->start();

    chats = new ChatsListModel();

    for (int i=0; i<lSettings->accountsCount(); i++)
        initializeAccount(i,lSettings->getAccount(i));

    connect(dbWorker, SIGNAL(messagesChanged()), this, SLOT(updateMessages()), Qt::UniqueConnection);
    connect(dbWorker, SIGNAL(sqlMessagesUpdated()), this, SIGNAL(sqlMessagesChanged()), Qt::UniqueConnection);
}

bool XmppConnectivity::initializeAccount(int index, AccountsItemModel* account) {
    // check if client with specified index exists. If not, add one
    if (!clients->contains(index))
        clients->insert(index,new MyXmppClient());

    // initialize account
    clients->value(index)->setMyJid(account->jid());
    clients->value(index)->setPassword(account->passwd());
    clients->value(index)->setResource(account->resource());
    if (account->isManuallyHostPort()) {
        clients->value(index)->setHost(account->host());
        clients->value(index)->setPort(account->port());
    } else {
        clients->value(index)->setHost("");
        clients->value(index)->setPort(5222);
    }
    clients->value(index)->setAccountId(index);
    connect(clients->value(index),SIGNAL(rosterChanged()),this,SLOT(changeRoster()));
    connect(clients->value(index),SIGNAL(updateContact(int,QString,QString,int)),this,SLOT(updateContact(int,QString,QString,int)));
    connect(clients->value(index),SIGNAL(insertMessage(int,QString,QString,QString,int)),this,SLOT(insertMessage(int,QString,QString,QString,int)));
    connect(clients->value(index),SIGNAL(chatOpened(int,QString)),this,SLOT(chatOpened(int,QString)));
    connect(clients->value(index),SIGNAL(chatClosed(QString)),this,SLOT(chatClosed(QString)));
    qDebug().nospace() << "XmppConnectivity::initializeAccount(): initialized account " << qPrintable(clients->value(index)->getMyJid()) << "/" << qPrintable(clients->value(index)->getResource());
    return true;
}

void XmppConnectivity::changeAccount(int index) {
    if (currentClient == -1) delete selectedClient;
    if (index != currentClient) {
        currentClient = index;
        selectedClient = clients->value(index);
        emit accountChanged();
        changeRoster();
    }
    qDebug() << "XmppConnectivity::changeAccount(): selected account is" << qPrintable(clients->value(index)->getMyJid());
}

void XmppConnectivity::gotoPage(int nPage) {
    page = nPage;
    updateMessages();
    emit pageChanged();
}

/* --- diagnostics --- */
bool XmppConnectivity::dbRemoveDb() {
    bool ret = false;
    DatabaseManager* database = new DatabaseManager();
    SqlQueryModel* sqlQuery = new SqlQueryModel( 0 );
    sqlQuery->setQuery("DELETE FROM MESSAGES", database->db);
    database->deleteLater();
    if (sqlQuery->lastError().text() == " ") ret = true;
    sqlQuery->deleteLater();
    return ret;
}
bool XmppConnectivity::cleanCache() { return this->removeDir(lCache->getMeegIMCachePath()); }
bool XmppConnectivity::removeDir(const QString &dirName) {
    bool result = true;
    QDir dir(dirName);

    if (dir.exists(dirName)) {
        Q_FOREACH(QFileInfo info, dir.entryInfoList(QDir::NoDotAndDotDot | QDir::System | QDir::Hidden  | QDir::AllDirs | QDir::Files, QDir::DirsFirst)) {
            if (info.isDir()) result = removeDir(info.absoluteFilePath());
            else result = QFile::remove(info.absoluteFilePath());

            if (!result) return result;
        }
        result = dir.rmdir(dirName);
    }

    return result;
}
bool XmppConnectivity::resetSettings() { return QFile::remove(lSettings->confFile); }

// handling stuff from MyXmppClient
void XmppConnectivity::insertMessage(int m_accountId,QString bareJid,QString body,QString date,int mine) {
    dbWorker->executeQuery(QStringList() << "insertMessage" << QString::number(m_accountId) << bareJid << body << date << QString::number(mine));
    if (mine == 0) emit notifyMsgReceived(clients->value(m_accountId)->getPropertyByJid(bareJid,"name"),bareJid,body.left(30));
}

// handling chats list
void XmppConnectivity::chatOpened(int accountId, QString bareJid) {
  if (!chats->checkIfExists(bareJid)) {
    ChatsItemModel* chat = new ChatsItemModel(clients->value(accountId)->getPropertyByJid(bareJid,"name"),bareJid,accountId);
    chats->append(chat);
    qDebug() << "XmppConnectivity::chatOpened(): appending"<< qPrintable(bareJid) << "from account" << accountId << "to chats list.";
    emit chatsChanged();
  }
}

void XmppConnectivity::chatClosed(QString bareJid) { //this poorly written piece of shit should take care of account id one day
  int indxItem = -1;
  ChatsItemModel *itemExists = (ChatsItemModel*)chats->find( bareJid, indxItem );
  if( itemExists ) if( indxItem >= 0 ) chats->takeRow( indxItem );
  qDebug() << "XmppConnectivity::chatClosed(): chat closed";
}

QString XmppConnectivity::getPropertyByJid(int account,QString property,QString jid) {
  if (account <= clients->count() && account >= 0)
    return clients->value(account)->getPropertyByJid(jid,property);
  else return "(unknown)";
}

QString XmppConnectivity::getPreservedMsg(QString jid) {  //this poorly written piece of shit should take care of account id one day
  ChatsItemModel* chat = (ChatsItemModel*)chats->find(jid);
  if (chat != 0) return chat->msg();
  return "";
}

void XmppConnectivity::preserveMsg(QString jid,QString message) { //this poorly written piece of shit should take care of account id one day
  ChatsItemModel* chat = (ChatsItemModel*)chats->find(jid);
  if (chat != 0) chat->setChatMsg(message);
}

// handling adding and removing accounts
void XmppConnectivity::accountAdded() {
  qDebug() << "XmppConnectivity::accountAdded(): this is not being handled right now #yolo";
}


void XmppConnectivity::accountRemoved(QString bareJid) {
  qDebug() << "XmppConnectivity::accountRemoved(): this is not being handled right now #yolo";
}

void XmppConnectivity::accountModified(QString bareJid) {
  qDebug() << "XmppConnectivity::accountModified(): this is not being handled right now #yolo";
}

int XmppConnectivity::getStatusByIndex(int index) {
  if (index <= clients->count() && index > -1)
    return clients->value(index)->getStatus();
  else return 0;
}

// stub stub stub stub stub hardcoded doesnt matter lol
QString XmppConnectivity::getCurrentAccountName() {
  if (selectedClient != 0) {
    if (selectedClient->getHost() == "talk.google.com") return "Hangouts";
    if (selectedClient->getHost() == "chat.facebook.com") return "Facebook Chat";
    if (selectedClient->getHost() != "") return selectedClient->getHost();
    return selectedClient->getMyJid();
  } return "No account available";
}
