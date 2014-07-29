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
    lCache = new MyCache(lSettings->gStr("paths","cache"));
    lCache->createHomeDir();

    dbWorker = new DatabaseWorker;
    dbThread = new QThread(this);
    dbWorker->moveToThread(dbThread);
    dbThread->start();

    contacts = new ContactListManager();
    chats = new ChatsListModel();

    for (int i=0; i<lSettings->accountsCount(); i++) {
        initializeAccount(lSettings->getAccount(i)->grid(),lSettings->getAccount(i));
        if (currentClient == "") this->changeAccount(lSettings->getAccount(i)->grid());
    }

    connect(dbWorker, SIGNAL(messagesChanged()), this, SLOT(updateMessages()), Qt::UniqueConnection);
    connect(dbWorker, SIGNAL(sqlMessagesUpdated()), this, SIGNAL(sqlMessagesChanged()), Qt::UniqueConnection);
}

XmppConnectivity::~XmppConnectivity() {
    if (msgWrapper != NULL) delete msgWrapper;
    if (clients != NULL) delete clients;
    if (cachedMessages != NULL) delete cachedMessages;
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
    connect(clients->value(index),SIGNAL(iFoundYourParentsGoddamit(QString)),this,SLOT(updateMyData(QString)),Qt::UniqueConnection);

    connect(clients->value(index),SIGNAL(updateContact(QString,QString,QString,int)),this,SLOT(updateContact(QString,QString,QString,int)),Qt::UniqueConnection);
    connect(clients->value(index),SIGNAL(insertMessage(QString,QString,QString,QString,int)),this,SLOT(insertMessage(QString,QString,QString,QString,int)),Qt::UniqueConnection);
    connect(clients->value(index),SIGNAL(contactStatusChanged(QString,QString)),this,SLOT(handleContactStatusChange(QString,QString)),Qt::UniqueConnection);

    connect(clients->value(index),SIGNAL(connectingChanged(QString)),this,SIGNAL(xmppConnectingChanged(QString)),Qt::UniqueConnection);
    connect(clients->value(index),SIGNAL(statusChanged(QString)),this,SLOT(handleXmppStatusChange(QString)),Qt::UniqueConnection);
    connect(clients->value(index),SIGNAL(errorHappened(QString,QString)),this,SIGNAL(xmppErrorHappened(QString,QString)),Qt::UniqueConnection);
    connect(clients->value(index),SIGNAL(subscriptionReceived(QString,QString)),this,SIGNAL(xmppSubscriptionReceived(QString,QString)),Qt::UniqueConnection);
    connect(clients->value(index),SIGNAL(typingChanged(QString,QString,bool)),this,SIGNAL(xmppTypingChanged(QString,QString,bool)),Qt::UniqueConnection);
	
    // connect ContactListManager
    connect(clients->value(index),SIGNAL(contactAdded(QString,QString,QString)),contacts,SLOT(addContact(QString,QString,QString)),Qt::UniqueConnection);
    connect(clients->value(index),SIGNAL(presenceChanged(QString,QString,QString,QString,QString)),contacts,SLOT(changePresence(QString,QString,QString,QString,QString)),Qt::UniqueConnection);
    connect(clients->value(index),SIGNAL(presenceChanged(QString,QString,QString,QString,QString)), this, SIGNAL(xmppPresenceChanged(QString,QString,QString,QString,QString)),Qt::UniqueConnection);
    connect(clients->value(index),SIGNAL(nameChanged(QString,QString,QString)),contacts,SLOT(changeName(QString,QString,QString)),Qt::UniqueConnection);
    connect(clients->value(index),SIGNAL(nameChanged(QString,QString,QString)),this,SLOT(updateChatName(QString,QString,QString)),Qt::UniqueConnection);
    connect(clients->value(index),SIGNAL(contactRemoved(QString,QString)),contacts,SLOT(removeContact(QString,QString)),Qt::UniqueConnection);

    qDebug().nospace() << "XmppConnectivity::initializeAccount(): initialized account " << qPrintable(clients->value(index)->getMyJid()) << "/" << qPrintable(clients->value(index)->getResource());

    if (lSettings->gBool(index,"connectOnStart")) {
        clients->value(index)->goOnline(lSettings->get("behavior","lastStatus").toString());
    }

    clients->value(index)->disableAvatarCaching = lSettings->get("behavior","disableAvatarCaching").toBool();

    delete account;
    return true;
}

void XmppConnectivity::changeAccount(QString accountId) {
    if (accountId != currentClient && clients->contains(accountId) && clients->value(accountId) != 0) {
        if (currentClient == "") delete selectedClient;
        currentClient = accountId;
        selectedClient = clients->value(accountId);
        emit accountChanged();
        qDebug() << "XmppConnectivity::changeAccount(): selected account is" << qPrintable(clients->value(accountId)->getMyJid());
    }
    if (accountId == "null") {
        currentClient  = "";
        selectedClient = new MyXmppClient();
        emit accountChanged();
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
bool XmppConnectivity::cleanCache() { return this->removeDir(lCache->getCachePath()); }
bool XmppConnectivity::cleanCache(QString path) { return this->removeDir(path); }
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
    if (mine == 0) emit notifyMsgReceived(this->getPropertyByJid(m_accountId,"name",bareJid),bareJid,body.left(30),m_accountId);

    body = body.replace(">", "&gt;");  //fix for > stuff
    body = body.replace("<", "&lt;");  //and < stuff too ^^
    body = msgWrapper->parseMsgOnLink(body);

    this->openChat(m_accountId,bareJid);

    if (!cachedMessages->contains(bareJid)) cachedMessages->insert(bareJid,new MsgListModel());
    MsgItemModel* message = new MsgItemModel(body,date,mine);
    cachedMessages->value(bareJid)->append(message);
    dbWorker->executeQuery(QStringList() << "insertMessage" << m_accountId << bareJid << body << date << QString::number(mine));

    addChat(m_accountId,bareJid);

    contacts->plusUnreadMessage(m_accountId,bareJid);
}

// handling chats list
void XmppConnectivity::openChat(QString accountId, QString bareJid) {
  if (!chats->checkIfExists(bareJid)) {
    ChatsItemModel* chat = new ChatsItemModel(contacts->getPropertyByJid(accountId,bareJid,"name"),bareJid,accountId);
    chats->append(chat);
    qDebug() << "XmppConnectivity::openChat(): appending"<< qPrintable(bareJid) << "from account" << accountId << "to chats list.";
    emit chatsChanged();
  }

  // send "Active" chat state
  clients->value(accountId)->sendMessage(bareJid,"","",1);

  if (!cachedMessages->contains(bareJid))
    cachedMessages->insert(bareJid,new MsgListModel());
  addChat(accountId,bareJid);
}

void XmppConnectivity::closeChat(QString accId, QString bareJid) {
  // send "Gone" chat state
  clients->value(accId)->sendMessage(bareJid,"","",3);

  for (int i=0; i<chats->count(); i++) {
      ChatsItemModel *itemExists = (ChatsItemModel*)chats->getElementByID(i);
      if (itemExists->jid() == bareJid && itemExists->accountID() == accId)
          chats->takeRow(i);
  }
  qDebug() << "XmppConnectivity::closeChat(): chat closed";
  removeChat(accId,bareJid);
}

QString XmppConnectivity::getPropertyByJid(QString account,QString property,QString jid) {
  return contacts->getPropertyByJid(account,jid,property);
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

void XmppConnectivity::updateChatName(QString m_accountId, QString bareJid, QString name) {
  qDebug().nospace() << "XmppConnectivity::updateChatName(" +m_accountId+","+bareJid+","+name+") called";
  for (int i=0; i<chats->count(); i++) {
      ChatsItemModel *itemExists = (ChatsItemModel*)chats->getElementByID(i);
      if (itemExists->jid() == bareJid && itemExists->accountID() == m_accountId) {
          itemExists->setContactName(name);
          qDebug() << "XmppConnectivity::updateChatName() name updated";
      }
  }
}

// handling adding and removing accounts
// handling adding and removing accounts
void XmppConnectivity::accountAdded(QString id) {
  qDebug().nospace() << "XmppConnectivity::accountAdded(): initializing account "
                     << qPrintable(id)<<"::"<<qPrintable(lSettings->getAccountByID(id)->jid());
  initializeAccount(id,lSettings->getAccountByID(id));
}
void XmppConnectivity::accountRemoved(QString id) {
  qDebug().nospace() << "XmppConnectivity::accountRemoved(): removing account "
           << qPrintable(id)<<"::"<<qPrintable(clients->value(id)->getMyJid());
  if (currentClient == id) {
      changeAccount("null");
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
           << qPrintable(id)<<"::"<<qPrintable(lSettings->getAccountByID(id)->jid());
  initializeAccount(id,lSettings->getAccountByID(id));
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
      QString name = lSettings->get(grid,"name").toString();
      if (name !="false" && name !="") return name;
      else return generateAccountName(lSettings->get(grid,"host").toString(),lSettings->get(grid,"jid").toString());
  } else return "N/A";
}

QString XmppConnectivity::getAccountIcon(QString grid) {
  return lSettings->get(grid,"icon").toString();
}

QString XmppConnectivity::generateAccountName(QString host, QString jid) {
  if (host == "talk.google.com") return "Hangouts";
  if (host == "chat.facebook.com") return "Facebook Chat";
  if (host != "") return host;
  return jid;
}

int XmppConnectivity::getGlobalUnreadCount() {
  int count = 0;
  ChatsItemModel* currentChat;
  for (int i=0;i<chats->rowCount();i++) {
      currentChat = (ChatsItemModel*)chats->getElementByID(i);
      count = count+ this->getPropertyByJid(currentChat->accountID(),"unreadMsg",currentChat->jid()).toInt();
    }
  currentChat = 0;
  return count;
}

RosterListModel* XmppConnectivity::getRoster() {
  return contacts->getRoster();
}

void XmppConnectivity::updateAvatarCachingSetting(bool setting) {
  QMap<QString,MyXmppClient*>::iterator i;
  for (i = clients->begin(); i != clients->end(); i++) {
      if (clients->value(i.key()) != 0)
          clients->value(i.key())->disableAvatarCaching = setting;
    }
}

void XmppConnectivity::updateMyData(QString jid) {
  QString currentPersonality = lSettings->gStr("behavior","personality");
  QString currentAvatar = lCache->getAvatarCache(currentPersonality);
  QString newAvatar = lCache->getAvatarCache(jid);

  if ((currentPersonality == "") || (currentPersonality != jid && currentAvatar == "qrc:/avatar" && newAvatar != "qrc:/avatar")) {
    lSettings->sStr(jid,"behavior","personality");
    emit personalityChanged();
  }
}

void XmppConnectivity::handleXmppStatusChange (const QString accountId) {
  if (clients->value(accountId) == 0)
    return;

  if (clients->value(accountId)->getStatus() == MyXmppClient::Offline)
    contacts->clearPresenceForAccount(accountId);

  emit xmppStatusChanged(accountId);
}

// handle messages and states
bool XmppConnectivity::sendAMessage(QString accountId, QString recipientJid, QString recipientResource, QString body, int state) {
  if (clients->value(accountId) == NULL)
    return false;

  return clients->value(accountId)->sendMessage(recipientJid,recipientResource,body,state);
}
