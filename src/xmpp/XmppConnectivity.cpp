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
    connect(contacts,SIGNAL(contactNameChanged(QString,QString,QString)),this,SLOT(updateChatName(QString,QString,QString)));

    chats = new ChatsListModel();
    events = new EventsManager();

    for (int i=0; i<lSettings->accountsCount(); i++) {
        initializeAccount(lSettings->getAccount(i)->grid(),lSettings->getAccount(i));
    }
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

    clients->value(index)->setKeepAlive(lSettings->gInt("behavior","keepAliveInterval"));

    connect(clients->value(index),SIGNAL(iFoundYourParentsGoddamit(QString)),this,SLOT(updateMyData(QString)),Qt::UniqueConnection);

    connect(clients->value(index),SIGNAL(insertMessage(QString,QString,QString,QString,int,int,QString)),this,SLOT(insertMessage(QString,QString,QString,QString,int,int,QString)),Qt::UniqueConnection);
    connect(clients->value(index),SIGNAL(attentionRequested(QString,QString)),this,SLOT(pushAttention(QString,QString)),Qt::UniqueConnection);

    connect(clients->value(index),SIGNAL(connectingChanged(QString)),this,SIGNAL(xmppConnectingChanged(QString)),Qt::UniqueConnection);
    connect(clients->value(index),SIGNAL(statusChanged(QString)),this,SLOT(handleXmppStatusChange(QString)),Qt::UniqueConnection);
    connect(clients->value(index),SIGNAL(errorHappened(QString,QString)),this,SIGNAL(xmppErrorHappened(QString,QString)),Qt::UniqueConnection);
    connect(clients->value(index),SIGNAL(errorHappened(QString,QString)),this,SLOT(pushError(QString,QString)),Qt::UniqueConnection);
    connect(clients->value(index),SIGNAL(subscriptionReceived(QString,QString)),this,SIGNAL(xmppSubscriptionReceived(QString,QString)),Qt::UniqueConnection);
    connect(clients->value(index),SIGNAL(subscriptionReceived(QString,QString)),events,SLOT(appendSubscription(QString,QString)),Qt::UniqueConnection);
    connect(clients->value(index),SIGNAL(typingChanged(QString,QString,bool)),this,SIGNAL(xmppTypingChanged(QString,QString,bool)),Qt::UniqueConnection);

    connect(clients->value(index),SIGNAL(avatarUpdatedForJid(QString)),this,SIGNAL(avatarUpdatedForJid(QString)),Qt::UniqueConnection);

    // connect file transfer signals
    connect(clients->value(index),SIGNAL(incomingTransferReceived(QString,QString,QString,QString,int,bool)),events,SLOT(appendTransferJob(QString,QString,QString,QString,int,bool)),Qt::UniqueConnection);

    // connect MUC signals
    connect(clients->value(index),SIGNAL(mucInvitationReceived(QString,QString,QString,QString)),this,SIGNAL(mucInvitationReceived(QString,QString,QString,QString)),Qt::UniqueConnection);
    connect(clients->value(index),SIGNAL(mucRoomJoined(QString,QString)),this,SLOT(openChat(QString,QString)),Qt::UniqueConnection);
    connect(clients->value(index),SIGNAL(mucNameChanged(QString,QString,QString)),this,SLOT(updateChatName(QString,QString,QString)),Qt::UniqueConnection);
	
    // connect ContactListManager
    connect(clients->value(index),SIGNAL(contactAdded(QString,QString,QString)),contacts,SLOT(addContact(QString,QString,QString)),Qt::UniqueConnection);
    connect(clients->value(index),SIGNAL(presenceChanged(QString,QString,QString,QString,QString)),contacts,SLOT(changePresence(QString,QString,QString,QString,QString)),Qt::UniqueConnection);
    connect(clients->value(index),SIGNAL(presenceChanged(QString,QString,QString,QString,QString)), this, SIGNAL(xmppPresenceChanged(QString,QString,QString,QString,QString)),Qt::UniqueConnection);
    connect(clients->value(index),SIGNAL(nameChanged(QString,QString,QString)),contacts,SLOT(changeName(QString,QString,QString)),Qt::UniqueConnection);
    connect(clients->value(index),SIGNAL(nameChanged(QString,QString,QString)),this,SLOT(updateChatName(QString,QString,QString)),Qt::UniqueConnection);
    connect(clients->value(index),SIGNAL(contactRemoved(QString,QString)),contacts,SLOT(removeContact(QString,QString)),Qt::UniqueConnection);

    qDebug().nospace() << "XmppConnectivity::initializeAccount(): initialized account " << qPrintable(clients->value(index)->getMyJid()) << "/" << qPrintable(clients->value(index)->getResource());

    if (lSettings->gBool(index,"connectOnStart")) {
        clients->value(index)->setPresence(MyXmppClient::Online,lSettings->get("behavior","lastStatus").toString());
    }

    clients->value(index)->disableAvatarCaching = lSettings->get("behavior","disableAvatarCaching").toBool();

    delete account;
    return true;
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
void XmppConnectivity::insertMessage(QString m_accountId,QString bareJid,QString body,QString date,int mine, int type, QString resource) {
    QString name;
    if (type != 3)
      name = this->getPropertyByJid(m_accountId,"name",bareJid);
    else
      name = resource + "@" + bareJid.split('@')[0];

    if (mine == 0 && type != 4) {
      emit notifyMsgReceived(name,bareJid,body.left(30),m_accountId);
      if (body.length() > 30)
        events->appendUnreadMessage(bareJid,m_accountId,name,body.left(30) + "...");
      else
        events->appendUnreadMessage(bareJid,m_accountId,name,body);
    }

    body = body.replace(">", "&gt;");  //fix for > stuff
    body = body.replace("<", "&lt;");  //and < stuff too ^^
    body = msgWrapper->parseMsgOnLink(body);

    this->openChat(m_accountId,bareJid);

    bool msgUnreadState;
    if (type != 4 && mine == 0)
      msgUnreadState = true;

    if (!cachedMessages->contains(bareJid)) cachedMessages->insert(bareJid,new MsgListModel());
    MsgItemModel* message = new MsgItemModel(body,date,mine,type,resource,msgUnreadState);
    cachedMessages->value(bareJid)->insertRow(cachedMessages->value(bareJid)->whereShouldIPutThisCrapAnyway(date),message);

    qDebug() << date;

    if (type != 4 && type != 3)
      dbWorker->executeQuery(QStringList() << "insertMessage" << m_accountId << bareJid << body << date << QString::number(mine));

    if (type != 4)
      this->plusUnreadChatMsg(m_accountId,bareJid);
}

MsgListModel* XmppConnectivity::getMessages(QString jid) {
  MsgListModel* messages = cachedMessages->value(jid);
  if (msgLimit > 0) {
     while (messages->count() > msgLimit) {
         messages->remove(0);
       }
    }
  return messages;
}

SqlQueryModel* XmppConnectivity::getSqlMessagesByPage(QString accountId, QString bareJid, int page) {
  dbWorker->updateMessages(accountId,bareJid,page);
  return dbWorker->getSqlMessages();
}

// handling chats list
void XmppConnectivity::openChat(QString accountId, QString bareJid) {
  if (!chats->checkIfExists(accountId + ";" + bareJid)) {
    ChatsItemModel* chat;
    QString message;
    if (clients->value(accountId)->isMucRoom(bareJid)) {
        chat = new ChatsItemModel(bareJid,bareJid,accountId,3);
        chat->setUnreadMsg(0);
        // change it to MUC room name one day
        message = "[[INFO]] Joined chatroom\n[[bold]][[name]][[/bold]] @[[date]]";
      } else {
        // add contact if it doesn't exist on roster yet. If you receive messages before roster it would simply updates their names
        if (!contacts->doesContactExists(accountId,bareJid))
            contacts->addContact(accountId,bareJid,bareJid);

        chat = new ChatsItemModel(contacts->getPropertyByJid(accountId,bareJid,"name"),bareJid,accountId,0);
        message = "[[INFO]] Chat started with [[bold]][[name]][[/bold]] @[[date]]";
      }

    chats->append(chat);
    emit insertMessage(accountId,bareJid,message,QDateTime::currentDateTime().toString("dd-MM-yy hh:mm:ss"),0,4,"");
    qDebug() << "XmppConnectivity::openChat(): appending"<< qPrintable(bareJid) << "from account" << accountId << "to chats list.";
    emit chatsChanged();
  }

  // send "Active" chat state
  clients->value(accountId)->sendMessage(bareJid,"","",1,2);

  if (!cachedMessages->contains(bareJid))
    cachedMessages->insert(bareJid,new MsgListModel());
}

void XmppConnectivity::closeChat(QString accountId, QString bareJid) {
  int rowId;
  ChatsItemModel *itemExists = (ChatsItemModel*)chats->find(accountId + ";" + bareJid,rowId);
  int type;
  if (itemExists != NULL) {
    type = itemExists->type();
    // ok, so the item exists and stuff, so I can actually run resetUnreadMessages before the object is removed
    this->resetUnreadMessages(accountId, bareJid);

    if (!cachedMessages->contains(bareJid))
      cachedMessages->insert(bareJid,new MsgListModel());

    MsgItemModel* message = new MsgItemModel("[[INFO]] Chat closed @[[date]]",QDateTime::currentDateTime().toString("dd-MM-yy hh:mm:ss"),0,4,"",false);
    cachedMessages->value(bareJid)->append(message);
  } else return;

  // send "Gone" chat state
  if (type != 3) // don't emit Gone if in MUC
    clients->value(accountId)->sendMessage(bareJid,"","",3,2);
  else
    clients->value(accountId)->leaveMUCRoom(bareJid); // just leave the room

  if (itemExists != NULL)
    chats->takeRow(rowId);

  qDebug() << "XmppConnectivity::closeChat(): chat closed";
}

void XmppConnectivity::plusUnreadChatMsg(QString accountId,QString bareJid) {
  ChatsItemModel *itemExists = (ChatsItemModel*)chats->find(accountId + ";" + bareJid);
  if (itemExists != NULL)
    itemExists->setUnreadMsg(itemExists->unread() + 1);

  emit unreadCountChanged(1);
}

void XmppConnectivity::resetUnreadMessages(QString accountId, QString bareJid) {
  qDebug() << "XmppConnectivity::resetUnreadMessages() for"<<accountId<<bareJid<<
              "called";
  ChatsItemModel *itemExists = (ChatsItemModel*)chats->find(accountId + ";" + bareJid);
  int delta = 0;
  if (itemExists != NULL) {
    delta = itemExists->unread();
    itemExists->setUnreadMsg(0);
  }

  // dismiss Event
  events->removeEvent(bareJid,accountId,32);

  // update unread count
  emit unreadCountChanged(-delta);

  if (cachedMessages->contains(bareJid)) {
      MsgListModel* msgListModel = cachedMessages->value(bareJid);
      for (int i=0; i<=delta+1;i++) {
          if (msgListModel->count()-i <= 0)
            return;

          MsgItemModel* msgModel = (MsgItemModel*)msgListModel->getElementByID(msgListModel->count()-i);
          if (msgModel != NULL) {
              if (msgModel->gMsgUnreadState())
                msgModel->setMsgUnreadState(false);
              else delta++;
            }
        }
    }
}

int XmppConnectivity::getUnreadCount(QString accountId, QString bareJid) {
  ChatsItemModel *itemExists = (ChatsItemModel*)chats->find(accountId + ";" + bareJid);
  if (itemExists != NULL)
    return itemExists->unread();
  else return 0;
}

int XmppConnectivity::getChatType(QString accountId, QString bareJid) {
  ChatsItemModel *itemExists = (ChatsItemModel*)chats->find(accountId + ";" + bareJid);
  if (itemExists != NULL)
    return itemExists->type();
  else return 0;
}

QString XmppConnectivity::getPropertyByJid(QString account,QString property,QString jid) {
  return contacts->getPropertyByJid(account,jid,property);
}

QString XmppConnectivity::getPreservedMsg(QString jid) {  //this poorly written piece of shit should take care of account id one day
  ChatsItemModel* chat = (ChatsItemModel*)chats->find(jid);
  if (chat != 0) return chat->msg();
  return "";
}

void XmppConnectivity::preserveMsg(QString accountId,QString jid,QString message) { //this poorly written piece of shit should take care of account id one day
  ChatsItemModel* chat = (ChatsItemModel*)chats->find(accountId + ";" + jid);
  if (chat != 0) chat->setChatMsg(message);
  chat = 0; delete chat;
}

void XmppConnectivity::updateChatName(QString m_accountId, QString bareJid, QString name) {
  qDebug().nospace() << "XmppConnectivity::updateChatName(" +m_accountId+","+bareJid+","+name+") called";
  ChatsItemModel *itemExists = (ChatsItemModel*)chats->find(m_accountId+ ";" + bareJid);
  if (itemExists != NULL)
    itemExists->setContactName(name);
}

// handling adding and removing accounts
void XmppConnectivity::accountAdded(QString id) {
  qDebug().nospace() << "XmppConnectivity::accountAdded(): initializing account "
                     << qPrintable(id)<<"::"<<qPrintable(lSettings->getAccountByID(id)->jid());
  initializeAccount(id,lSettings->getAccountByID(id));
}
void XmppConnectivity::accountRemoved(QString id) {
  qDebug().nospace() << "XmppConnectivity::accountRemoved(): removing account "
           << qPrintable(id)<<"::"<<qPrintable(clients->value(id)->getMyJid());
  clients->remove(id);

  DatabaseManager* database = new DatabaseManager();
  SqlQueryModel* sqlQuery = new SqlQueryModel( 0 );
  sqlQuery->setQuery("DELETE FROM MESSAGES WHERE id_account='" +id + "'", database->db);
  database->deleteLater();
  sqlQuery->deleteLater();

  for (int i=0; i<chats->count(); i++) {
      int unreadDelta = 0;
      ChatsItemModel *itemExists = (ChatsItemModel*)chats->getElementByID(i);
      if (itemExists->accountID() == id) {
          unreadDelta += itemExists->unread();
          chats->takeRow(i);
      }
      emit unreadCountChanged(unreadDelta);
  }
}
void XmppConnectivity::accountModified(QString id) {
 qDebug().nospace() << "XmppConnectivity::accountModified(): reinitializing account "
           << qPrintable(id)<<"::"<<qPrintable(lSettings->getAccountByID(id)->jid());
  initializeAccount(id,lSettings->getAccountByID(id));
}

int XmppConnectivity::getStatusByIndex(QString accountId) {
  if (accountId > "")
    if (clients->value(accountId) != 0)
      return clients->value(accountId)->getStatus();
  else return 0;
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
      count = count+ currentChat->unread();
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

void XmppConnectivity::updateKeepAliveSetting(int keepAlive) {
  QMap<QString,MyXmppClient*>::iterator i;
  for (i = clients->begin(); i != clients->end(); i++) {
      if (clients->value(i.key()) != 0)
          clients->value(i.key())->setKeepAlive(keepAlive);
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

  QString status;

  if (clients->value(accountId)->getStatus() == MyXmppClient::Offline) {
    contacts->clearPresenceForAccount(accountId);
    status = "offline";
  }

  switch (clients->value(accountId)->getStatus()) {
     case MyXmppClient::Online: status = "online"; break;
     case MyXmppClient::Chat: status = "chatty"; break;
     case MyXmppClient::Away: status = "away"; break;
     case MyXmppClient::XA: status = "xa"; break;
     case MyXmppClient::DND: status = "busy"; break;
  }

  switch (clients->value(accountId)->getStateConnect()) {
    case MyXmppClient::Connecting: events->appendStatusChange(accountId,getAccountName(accountId),"Connecting..."); break;
    case MyXmppClient::Connected: events->appendStatusChange(accountId,getAccountName(accountId),"Current status is "+status); break;
    case MyXmppClient::Disconnect: events->appendStatusChange(accountId,getAccountName(accountId),"Disconected :c"); break;
    }

  emit xmppStatusChanged(accountId);
}
