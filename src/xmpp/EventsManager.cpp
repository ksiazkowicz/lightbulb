#include "EventsManager.h"
#include <QDebug>
#include <QDateTime>

EventsManager::EventsManager(QObject *parent) :
  QObject(parent)
{
  // initialize EventListModel which will hold all the events
  events = new EventListModel();
}

void EventsManager::appendUnreadMessage(QString bareJid, QString accountId, QString name, QString description) {
  // appends or updates an information about unread message
  int rowId; // holds the row ID, might be used for moving items to the top of the list
  EventItemModel *item = (EventItemModel*)events->find(bareJid + ";" + accountId + ";" + QString::number((int)EventItemModel::UnreadMessage),rowId);

  // check if item exists, if yes, remove it
  if (item != NULL) {
      events->takeRow(rowId);
  }

  // create a new EventItemModel
  item = new EventItemModel();
  item->setData(QVariant(bareJid),EventItemModel::Jid);
  item->setData(QVariant(accountId),EventItemModel::Account);
  item->setData(QVariant(name),EventItemModel::Name);
  item->setData(QVariant(description),EventItemModel::Description);
  item->setData(QVariant((int)EventItemModel::UnreadMessage),EventItemModel::Type);
  item->setData(QVariant(QDateTime::currentDateTime()),EventItemModel::Date);

  // and append it at the top of the list
  events->insertRow(0,item);
  events->countWasChanged();
}

void EventsManager::appendAttention(QString accountId, QString bareJid, QString name) {
  // appends or updates an information about unread message
  int rowId; // holds the row ID, might be used for moving items to the top of the list
  EventItemModel *item = (EventItemModel*)events->find(bareJid + ";" + accountId + ";" + QString::number((int)EventItemModel::UnreadMessage),rowId);

  // check if item exists, if yes, remove it
  if (item != NULL) {
      events->takeRow(rowId);
  }

  // create a new EventItemModel
  item = new EventItemModel();
  item->setData(QVariant(bareJid),EventItemModel::Jid);
  item->setData(QVariant(accountId),EventItemModel::Account);
  item->setData(QVariant(name),EventItemModel::Name);
  item->setData(QVariant("You received attention request."),EventItemModel::Description);
  item->setData(QVariant((int)EventItemModel::AttentionRequest),EventItemModel::Type);
  item->setData(QVariant(QDateTime::currentDateTime()),EventItemModel::Date);

  // and append it at the top of the list
  events->insertRow(0,item);
  events->countWasChanged();
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
  item->setData(QVariant("Tap to subscribe contact"),EventItemModel::Description);
  item->setData(QVariant((int)EventItemModel::SubscriptionRequest),EventItemModel::Type);
  item->setData(QVariant(QDateTime::currentDateTime()),EventItemModel::Date);

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
      qDebug() << "update available";
    item->setData(QVariant("Update to <b>"+version+"</b> is available (" + date + "). <b>Tap to open</b>."),EventItemModel::Description);
  } else {
    item->setData(QVariant("Version is up to date. ^^"),EventItemModel::Description);
  }

  item->setData(QVariant((int)EventItemModel::AppUpdate),EventItemModel::Type);
  item->setData(QVariant(QDateTime::currentDateTime()),EventItemModel::Date);

  // and append it at the top of the list
  events->insertRow(0,item);
  events->countWasChanged();
}

void EventsManager::removeEvent(int id) {
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

void EventsManager::clearList() {
  // clear the list
  qDebug() << "EventsManager::clearList() called";

  while (events->getCount() > 0)
    events->takeRow(0);

  events->countWasChanged();
}
