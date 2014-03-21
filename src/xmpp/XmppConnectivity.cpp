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
    msgWrapper = new MessageWrapper(this);

    selectedClient = new MyXmppClient();
    currentClient = "";
    clients = new QMap<QString,MyXmppClient*>;
    cachedMessages = new QMap<QString,MsgListModel*>;
    lSettings = new Settings();
    lCache = new MyCache();
    lCache->createHomeDir();

    dbWorker = new DatabaseWorker;
    dbThread = new QThread(this);
    dbWorker->moveToThread(dbThread);
    dbThread->start();

    chats = new ChatsListModel();

    for (int i=0; i<lSettings->accountsCount(); i++) {
        initializeAccount(lSettings->getAccount(i)->grid(),lSettings->getAccount(i));
        if (currentClient == "") this->changeAccount(lSettings->getAccount(i)->grid());
    }

    connect(dbWorker, SIGNAL(messagesChanged()), this, SLOT(updateMessages()), Qt::UniqueConnection);
    connect(dbWorker, SIGNAL(sqlMessagesUpdated()), this, SIGNAL(sqlMessagesChanged()), Qt::UniqueConnection);

    connect(lSettings,SIGNAL(accountAdded(QString)),this,SLOT(accountAdded(QString)),Qt::UniqueConnection);
    connect(lSettings,SIGNAL(accountEdited(QString)),this,SLOT(accountModified(QString)),Qt::UniqueConnection);
    connect(lSettings,SIGNAL(accountRemoved(QString)),this,SLOT(accountRemoved(QString)),Qt::UniqueConnection);
}

XmppConnectivity::~XmppConnectivity() {
    if (msgWrapper != NULL) delete msgWrapper;
    if (clients != NULL) delete clients;
    if (cachedMessages != NULL) delete cachedMessages;
    if (roster != NULL) delete roster;
    if (chats != NULL) delete chats;
    if (lCache != NULL) delete lCache;

    if (dbThread != NULL) delete dbThread;
    if (dbWorker != NULL) delete dbWorker;
}

bool XmppConnectivity::initializeAccount(QString index, AccountsItemModel* account) {
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
    connect(clients->value(index),SIGNAL(updateContact(QString,QString,QString,int)),this,SLOT(updateContact(QString,QString,QString,int)));
    connect(clients->value(index),SIGNAL(insertMessage(QString,QString,QString,QString,int)),this,SLOT(insertMessage(QString,QString,QString,QString,int)));
    connect(clients->value(index),SIGNAL(chatOpened(QString,QString)),this,SLOT(chatOpened(QString,QString)));
    connect(clients->value(index),SIGNAL(chatClosed(QString,QString)),this,SLOT(chatClosed(QString,QString)));
    connect(clients->value(index),SIGNAL(contactRenamed(QString,QString)),this,SLOT(renameChatContact(QString,QString)));
    qDebug().nospace() << "XmppConnectivity::initializeAccount(): initialized account " << qPrintable(clients->value(index)->getMyJid()) << "/" << qPrintable(clients->value(index)->getResource());

    if (lSettings->gBool(index,"connectOnStart")) {
        clients->value(index)->goOnline(lSettings->gStr("behavior","lastStatus"));
    }

    delete account;
    return true;
}

void XmppConnectivity::changeAccount(QString accountId) {
    if (accountId != currentClient && clients->contains(accountId) && clients->value(accountId) != 0) {
        if (currentClient == "") delete selectedClient;
        currentClient = accountId;
        selectedClient = clients->value(accountId);
        emit accountChanged();
        changeRoster();
        qDebug() << "XmppConnectivity::changeAccount(): selected account is" << qPrintable(clients->value(accountId)->getMyJid());
    }
    if (accountId == "null") {
        currentClient  = "";
        selectedClient = new MyXmppClient();
        emit accountChanged();
        changeRoster();
        qDebug() << "XmppConnectivity::changeAccount(): no selected account";
    }
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
    sqlQuery->setQuery("DROP MESSAGES", database->db);
    database->initDB();
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
void XmppConnectivity::insertMessage(QString m_accountId,QString bareJid,QString body,QString date,int mine) {
    if (mine == 0) emit notifyMsgReceived(clients->value(m_accountId)->getPropertyByJid(bareJid,"name"),bareJid,body.left(30));

    body = body.replace(">", "&gt;");  //fix for > stuff
    body = body.replace("<", "&lt;");  //and < stuff too ^^
    body = msgWrapper->parseMsgOnLink(body);

    if (!cachedMessages->contains(bareJid)) cachedMessages->insert(bareJid,new MsgListModel());
    MsgItemModel* message = new MsgItemModel(body,date,mine);
    cachedMessages->value(bareJid)->append(message);
    dbWorker->executeQuery(QStringList() << "insertMessage" << m_accountId << bareJid << body << date << QString::number(mine));

    addChat(m_accountId,bareJid);
}

// handling chats list
void XmppConnectivity::chatOpened(QString accountId, QString bareJid) {
  if (!chats->checkIfExists(bareJid)) {
    ChatsItemModel* chat = new ChatsItemModel(clients->value(accountId)->getPropertyByJid(bareJid,"name"),bareJid,accountId);
    chats->append(chat);
    qDebug() << "XmppConnectivity::chatOpened(): appending"<< qPrintable(bareJid) << "from account" << accountId << "to chats list.";
    emit chatsChanged();
  }
  if (!cachedMessages->contains(bareJid)) cachedMessages->insert(bareJid,new MsgListModel());
  addChat(accountId,bareJid);
}

void XmppConnectivity::chatClosed(QString accId, QString bareJid) { //this poorly written piece of shit should take care of account id one day
  for (int i=0; i<chats->count(); i++) {
      ChatsItemModel *itemExists = (ChatsItemModel*)chats->getElementByID(i);
      if (itemExists->jid() == bareJid && itemExists->accountID() == accId)
          chats->takeRow(i);
  }
  qDebug() << "XmppConnectivity::chatClosed(): chat closed";
  removeChat(accId,bareJid);
}

QString XmppConnectivity::getPropertyByJid(QString account,QString property,QString jid) {
  if (clients->value(account) != 0)
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
  chat = 0; delete chat;
}

// handling adding and removing accounts
void XmppConnectivity::accountAdded(QString id) {
  qDebug().nospace() << "XmppConnectivity::accountAdded(): initializing account "
                     << qPrintable(id)<<"::"<<qPrintable(lSettings->getAccount(lSettings->getAccountId(id))->jid());
  initializeAccount(id,lSettings->getAccount(lSettings->getAccountId(id)));
}


void XmppConnectivity::accountRemoved(QString id) {
  qDebug().nospace() << "XmppConnectivity::accountRemoved(): removing account "
           << qPrintable(id)<<"::"<<qPrintable(clients->value(id)->getMyJid());
  if (currentClient == id) {
      qDebug() << "czemu to sie sypie";
      if (lSettings->getAccount(1) != 0) {
          qDebug() << lSettings->getAccount(1)->grid();
        changeAccount(lSettings->getAccount(1)->grid());
      } else {
          qDebug() << "nie ogarniam";
          changeAccount("null");
      }
  }
  clients->remove(id);

  DatabaseManager* database = new DatabaseManager();
  SqlQueryModel* sqlQuery = new SqlQueryModel( 0 );
  sqlQuery->setQuery("DELETE FROM MESSAGES WHERE id_account='" +id + "'", database->db);
  database->deleteLater();
  sqlQuery->deleteLater();

  for (int i=0; i<chats->count(); i++) {
      ChatsItemModel *itemExists = (ChatsItemModel*)chats->getElementByID(i);
      if (itemExists->accountID() == id)
          chats->takeRow(i);
  }
}

void XmppConnectivity::accountModified(QString id) {
 qDebug().nospace() << "XmppConnectivity::accountModified(): reinitializing account "
           << qPrintable(id)<<"::"<<qPrintable(lSettings->getAccount(lSettings->getAccountId(id))->jid());
  initializeAccount(id,lSettings->getAccount(lSettings->getAccountId(id)));
  if (id == currentClient) emit accountChanged();
}

int XmppConnectivity::getStatusByIndex(QString accountId) {
  if (accountId > "")
    if (clients->value(accountId) != 0)
      return clients->value(accountId)->getStatus();
  else return 0;
}

QString XmppConnectivity::getCurrentAccountName() {
  if (selectedClient != 0) {
      return getAccountName(currentClient);
   } else return "No accounts available";
}

QString XmppConnectivity::getAccountName(QString grid) {
  if (grid != "") {
      QString name = lSettings->gStr(grid,"name");
      if (name !="false" && name !="") return name;
      else return generateAccountName(lSettings->gStr(grid,"host"),lSettings->gStr(grid,"jid"));
  } else return "N/A";
}

QString XmppConnectivity::getAccountIcon(QString grid) {
  return lSettings->gStr(grid,"icon");
}

QString XmppConnectivity::generateAccountName(QString host, QString jid) {
  if (host == "talk.google.com") return "Hangouts";
  if (host == "chat.facebook.com") return "Facebook Chat";
  if (host != "") return host;
  return jid;
}
