#include "EventsManager.h"
#include <QDebug>
#include <QDateTime>

EventsManager::EventsManager(QObject *parent) :
  QObject(parent)
{
  // initialize EventListModel which will hold all the events
  events = new EventListModel();
}

bool EventsManager::cleanEvent(QString id) {
    int rowId; // holds the row ID for row which is being removed
    EventItemModel *item = (EventItemModel*)events->find(id,rowId);

    // check if item exists, if yes, remove it
    if (item != NULL) {
        events->takeRow(rowId);
        return true;
    }

    // item doesn't exist, return false
    return false;
}

bool EventsManager::appendEvent(EventItemModel *item) {
    // check if item is valid
    if (item == NULL)
        return false;

    // try to push a system notification
    this->pushSystemNotification((EventItemModel::EventTypes)item->getData(EventItemModel::Type).toInt(),item->getData(EventItemModel::Name).toString(),item->getData(EventItemModel::Description).toString());

    // try to append it at the top of the list
    events->insertRow(0,item);
    events->countWasChanged();
    return true;
}

void EventsManager::pushSystemNotification(EventItemModel::EventTypes type, QString title, QString description) {
  switch (type) {
    case EventItemModel::UnreadMessage: emit pushedSystemNotification("MsgRecv",title,description); break;
    case EventItemModel::AttentionRequest: emit pushedSystemNotification("Attention",title,"requested your attention~!"); break;
    case EventItemModel::AppUpdate: emit pushedSystemNotification("AppUpdate",title,description); break;
    case EventItemModel::SubscriptionRequest: emit pushedSystemNotification("MsgSub",title,description); break;
    case EventItemModel::ConnectionState: emit pushedSystemNotification("NotifyConn",title,description); break;
    case EventItemModel::ConnectionError: emit pushedSystemNotification("NotifyError",title,description); break;
    case EventItemModel::FavUserStatusChange: emit pushedSystemNotification("FavStatus",title,description); break;
    case EventItemModel::IncomingTransfer: emit pushedSystemNotification("TransRecv",title,description); break;
    case EventItemModel::OutcomingTransfer: emit pushedSystemNotification("TransSent",title,description); break;
    case EventItemModel::MUCinvite: emit pushedSystemNotification("MUCInv",title,description); break;
    }
}

void EventsManager::appendUnreadMessage(QString bareJid, QString accountId, QString name, QString description) {
  // appends or updates an information about unread message

  // message might already be there, clean it up
  this->cleanEvent(bareJid + ";" + accountId + ";" + QString::number((int)EventItemModel::UnreadMessage));

  // create a new EventItemModel
  EventItemModel *item = new EventItemModel();
  item->setData(QVariant(bareJid),EventItemModel::Jid);
  item->setData(QVariant(accountId),EventItemModel::Account);
  item->setData(QVariant(name),EventItemModel::Name);
  item->setData(QVariant(description),EventItemModel::Description);
  item->setData(QVariant((int)EventItemModel::UnreadMessage),EventItemModel::Type);
  item->setData(QVariant(QDateTime::currentDateTime()),EventItemModel::Date);

  // and append it at the top of the list
  this->appendEvent(item);
}

void EventsManager::appendAttention(QString accountId, QString bareJid, QString name) {
  // appends attention request
  int count = 1;

  // check if there was already an attention request
  EventItemModel *item = (EventItemModel*)events->find(bareJid + ";" + accountId + ";" + QString::number((int)EventItemModel::AttentionRequest));

  // change count if there was
  if (item != NULL)
      count = item->getData(EventItemModel::Count).toInt()+1;

  // create a new EventItemModel
  item = new EventItemModel();
  item->setData(QVariant(bareJid),EventItemModel::Jid);
  item->setData(QVariant(accountId),EventItemModel::Account);
  item->setData(QVariant(name),EventItemModel::Name);
  item->setData(QVariant(count),EventItemModel::Count);
  // item->setData(QVariant("You received attention request."),EventItemModel::Description);
  item->setData(QVariant((int)EventItemModel::AttentionRequest),EventItemModel::Type);
  item->setData(QVariant(QDateTime::currentDateTime()),EventItemModel::Date);

  // and append it at the top of the list
  this->appendEvent(item);
}

void EventsManager::appendSubscription(QString accountId,QString bareJid) {
  // appends or updates an information about unread message
  int rowId; // holds the row ID, might be used for moving items to the top of the list
  EventItemModel *item = (EventItemModel*)events->find(bareJid + ";" + accountId + ";" + QString::number((int)EventItemModel::SubscriptionRequest),rowId);

  // check if item exists, if yes, remove it
  if (item != NULL) {
      events->takeRow(rowId);
  }

  // create a new EventItemModel
  item = new EventItemModel();
  item->setData(QVariant(bareJid),EventItemModel::Jid);
  item->setData(QVariant(accountId),EventItemModel::Account);
  item->setData(QVariant(bareJid),EventItemModel::Name);
  item->setData(QVariant((int)EventItemModel::SubscriptionRequest),EventItemModel::Type);
  item->setData(QVariant(QDateTime::currentDateTime()),EventItemModel::Date);

  // try to push a system notification
  this->pushSystemNotification((EventItemModel::EventTypes)item->getData(EventItemModel::Type).toInt(),item->getData(EventItemModel::Name).toString(),item->getData(EventItemModel::Description).toString());

  // and append it at the top of the list
  events->insertRow(0,item);
  events->countWasChanged();
}

void EventsManager::appendStatusChange(QString accountId, QString name, QString description) {
  // appends or updates an information about unread message
  int rowId; // holds the row ID, might be used for moving items to the top of the list
  EventItemModel *item = (EventItemModel*)events->find(";" +accountId + ";" + QString::number((int)EventItemModel::ConnectionState),rowId);

  // check if item exists, if yes, remove it
  if (item != NULL) {
      events->takeRow(rowId);
  }

  // create a new EventItemModel
  item = new EventItemModel();
  item->setData(QVariant(accountId),EventItemModel::Account);
  item->setData(QVariant(name),EventItemModel::Name);
  item->setData(QVariant(description),EventItemModel::Description);
  item->setData(QVariant((int)EventItemModel::ConnectionState),EventItemModel::Type);
  item->setData(QVariant(QDateTime::currentDateTime()),EventItemModel::Date);

  // try to push a system notification
  this->pushSystemNotification((EventItemModel::EventTypes)item->getData(EventItemModel::Type).toInt(),item->getData(EventItemModel::Name).toString(),item->getData(EventItemModel::Description).toString());

  // and append it at the top of the list
  events->insertRow(0,item);
  events->countWasChanged();
}

void EventsManager::appendUserStatusChange(QString accountId, QString bareJid, QString name, QString description) {
  // appends or updates an information about unread message
  int rowId; // holds the row ID, might be used for moving items to the top of the list
  EventItemModel *item = (EventItemModel*)events->find(";" +accountId + ";" + QString::number((int)EventItemModel::FavUserStatusChange),rowId);

  // check if item exists, if yes, remove it
  if (item != NULL)
      events->takeRow(rowId);

  // create a new EventItemModel
  item = new EventItemModel();
  item->setData(QVariant(accountId),EventItemModel::Account);
  item->setData(QVariant(name),EventItemModel::Name);
  item->setData(QVariant(bareJid),EventItemModel::Jid);
  item->setData(QVariant(description),EventItemModel::Description);
  item->setData(QVariant((int)EventItemModel::FavUserStatusChange),EventItemModel::Type);
  item->setData(QVariant(QDateTime::currentDateTime()),EventItemModel::Date);

  // and append it at the top of the list
  events->insertRow(0,item);
  events->countWasChanged();
}

void EventsManager::appendError(QString accountId, QString name, QString errorString) {
  // appends or updates an information about unread message
  int rowId; // holds the row ID, might be used for moving items to the top of the list
  EventItemModel *item = (EventItemModel*)events->find(";" +accountId + ";" + QString::number((int)EventItemModel::ConnectionError),rowId);

  // check if item exists, if yes, remove it
  if (item != NULL) {
      events->takeRow(rowId);
  }

  // create a new EventItemModel
  item = new EventItemModel();
  item->setData(QVariant(accountId),EventItemModel::Account);
  item->setData(QVariant(name),EventItemModel::Name);
  item->setData(QVariant(errorString),EventItemModel::Description);
  item->setData(QVariant((int)EventItemModel::ConnectionError),EventItemModel::Type);
  item->setData(QVariant(QDateTime::currentDateTime()),EventItemModel::Date);

  // try to push a system notification
  this->pushSystemNotification((EventItemModel::EventTypes)item->getData(EventItemModel::Type).toInt(),item->getData(EventItemModel::Name).toString(),item->getData(EventItemModel::Description).toString());


  // and append it at the top of the list
  events->insertRow(0,item);
  events->countWasChanged();
}

void EventsManager::appendUpdate(bool updateAvailable, QString version, QString date) {
  // appends or updates an information about unread message
  int rowId; // holds the row ID, might be used for moving items to the top of the list
  EventItemModel *item = (EventItemModel*)events->find(";{SYSTEM};" + QString::number((int)EventItemModel::AppUpdate),rowId);

  // check if item exists, if yes, don't do anything
  if (item != NULL)
    return;

  // create a new EventItemModel
  item = new EventItemModel();
  item->setData(QVariant("{SYSTEM}"),EventItemModel::Account);
  item->setData(QVariant("System"),EventItemModel::Name);

  if (updateAvailable) {
    item->setData(QVariant("Update to <b>"+version+"</b> is available (" + date + "). <b>Tap to open</b>."),EventItemModel::Description);
    this->pushSystemNotification(EventItemModel::AppUpdate,"Update for Lightbulb is available",version+" ("+date+")");
  } else {
    item->setData(QVariant("Lightbulb is up to date. ^^"),EventItemModel::Description);
    this->pushSystemNotification(EventItemModel::AppUpdate,"No updates for","Lightbulb are available");
  }

  item->setData(QVariant((int)EventItemModel::AppUpdate),EventItemModel::Type);
  item->setData(QVariant(QDateTime::currentDateTime()),EventItemModel::Date);

  // and append it at the top of the list
  events->insertRow(0,item);
  events->countWasChanged();
}

void EventsManager::appendTransferJob(QString accountId, QString bareJid, QString name, QString filename, int transferJob, bool isIncoming) {
  // create a new EventItemModel
  EventItemModel* item = new EventItemModel();
  item->setData(QVariant(bareJid),EventItemModel::Jid);
  item->setData(QVariant(accountId),EventItemModel::Account);
  item->setData(QVariant(name),EventItemModel::Name);
  item->setData(QVariant(filename),EventItemModel::Filename);
  item->setData(QVariant(transferJob),EventItemModel::TransferJob);

  if (isIncoming)
    item->setData(QVariant((int)EventItemModel::IncomingTransfer),EventItemModel::Type);
  else
    item->setData(QVariant((int)EventItemModel::OutcomingTransfer),EventItemModel::Type);

  item->setData(QVariant(QDateTime::currentDateTime()),EventItemModel::Date);

  // try to push a system notification
  this->pushSystemNotification((EventItemModel::EventTypes)item->getData(EventItemModel::Type).toInt(),item->getData(EventItemModel::Name).toString(),item->getData(EventItemModel::Description).toString());


  // and append it at the top of the list
  events->insertRow(0,item);
  events->countWasChanged();
}

void EventsManager::appendMUCInvitation(QString accountId, QString bareJid, QString sender) {
  // appends or updates an information about unread message
  int rowId; // holds the row ID, might be used for moving items to the top of the list
  EventItemModel *item = (EventItemModel*)events->find(bareJid + ";" + accountId + ";" + QString::number((int)EventItemModel::MUCinvite),rowId);

  // check if item exists, if yes, remove it
  if (item != NULL) {
      events->takeRow(rowId);
  }

  // create a new EventItemModel
  item = new EventItemModel();
  item->setData(QVariant(bareJid),EventItemModel::Jid);
  item->setData(QVariant(accountId),EventItemModel::Account);
  item->setData(QVariant(sender),EventItemModel::Name);
  item->setData(QVariant((int)EventItemModel::MUCinvite),EventItemModel::Type);
  item->setData(QVariant(QDateTime::currentDateTime()),EventItemModel::Date);

  // try to push a system notification
  this->pushSystemNotification((EventItemModel::EventTypes)item->getData(EventItemModel::Type).toInt(),item->getData(EventItemModel::Name).toString(),item->getData(EventItemModel::Description).toString());


  // and append it at the top of the list
  events->insertRow(0,item);
  events->countWasChanged();
}

void EventsManager::removeEvent(int id) {
  // check if id is valid (because it doesn't have to) and crash if not
  if (id > events->rowCount()-1 || id < 0)
    return;

  // assume that id is a row ID and remove it
  events->takeRow(id);
  events->countWasChanged();
}

void EventsManager::removeEvent(QString bareJid, QString accountId, int type) {
  // appends or updates an information about unread message
  int rowId; // holds the row ID
  EventItemModel *item = (EventItemModel*)events->find(bareJid + ";" + accountId + ";" + QString::number(type),rowId);

  if (item != NULL) {
    // if item exists, remove it
    events->takeRow(rowId);
    events->countWasChanged();
  }
}

void EventsManager::removeTransferJob(QString accountId, int transferJob) {
  int idToRemove = 0;

  for (int i=0; i < events->getCount();i++) {
      EventItemModel *event = (EventItemModel*)events->getElementByID(i);
      if (event->getData(EventItemModel::Account).toString() == accountId && event->getData(EventItemModel::TransferJob).toInt() == transferJob) {
        idToRemove = i;
        break;
      }
    }

  if (idToRemove != 0)
    events->takeRow(idToRemove);
}

void EventsManager::clearList() {
  // clear the list
  qDebug() << "EventsManager::clearList() called";
  int eventsToIgnore = 0;

  // iterate through all events
  while (events->getCount() > eventsToIgnore) {
      // variable to check if we shall ignore this event
      bool ignorePlz = false;

      // try to find the event on the events list and stuff
      EventItemModel *event = (EventItemModel*)events->getElementByID(eventsToIgnore);
      if (event != 0) {
          // event exists, that's great
        int eventType = event->data(EventItemModel::Type).toInt();

        // prevent removing the event if it's an unifinished transfer
        if (eventType == EventItemModel::IncomingTransfer || eventType == EventItemModel::OutcomingTransfer)
          ignorePlz = true;

        // if event shall be ignored, ignore it, otherwise remove
        if (ignorePlz)
          eventsToIgnore++;
        else events->takeRow(eventsToIgnore);

        } else eventsToIgnore++; // this should never be needed but I added it just in case
  }

  events->countWasChanged();
}
