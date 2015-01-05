#include "ContactListManager.h"
#include <QDebug>
#include <QXmppMessage.h>
#include <QSqlRecord>

ContactListManager::ContactListManager(DatabaseWorker *db, Settings *st, QObject *parent) :
  QObject(parent)
{
  roster = new RosterListModel();
  roster->setSortRole(RosterItemModel::SortData);

  // get database code to work
  database = db;

  //
  settings = st;

  // pull data from cache
  connect(database,SIGNAL(sqlRosterUpdated()),this,SLOT(restoreCache()),Qt::UniqueConnection);
  database->updateRoster();

  // initialize filter
  filter = new RosterItemFilter;
  filter->setSourceModel(roster);
}

// caching code

void ContactListManager::restoreCache() {
    for (int i=0;i<database->sqlRoster->rowCount();i++) {
        // if contact found, add it to list
        QSqlRecord record = database->sqlRoster->record(i);
        this->addContact(record.value("id_account").toString(),record.value("jid").toString(),record.value("name").toString(),false,record.value("isFavorite").toBool());
    }

    // disconnect the signal, we want it to be done just once in a lifetime~!
    disconnect(database,SIGNAL(sqlRosterUpdated()));

    // debug the amount of contact which were restored from the cache, it might get handy if something breaks
    qDebug() << "Restored" << database->sqlRoster->rowCount() << "contacts from cache.";
}

void ContactListManager::cleanupCache(QString acc, QStringList bareJids) {
    for (int i=0;i<database->sqlRoster->rowCount();i++) {
        // if contact found, check if it's a valid one
        QSqlRecord record = database->sqlRoster->record(i);
        if (record.value("id_account").toString() == acc) {
            // account ID is right, we care, let's check if it should be here
            if (!bareJids.contains(record.value("jid").toString())) {
                // it shouldn't, lets remove it
                database->executeQuery(QStringList() << "deleteContact" << acc << record.value("jid").toString());
            }
        }
    }

    // well... that's it
    database->updateRoster();
}

bool ContactListManager::removeCache() {
  database->executeQuery(QStringList() << "removeContactCache");
  return true;
}

// contact list management code

void ContactListManager::addContact(QString acc, QString jid, QString name, bool updateDatabase,bool isFavorite, QString groups) {
  // don't debug it while pulling data from cache, it's a mess T_T
  if (updateDatabase)
    qDebug() << "ContactListManager::addContact() called for" << qPrintable(jid) << "at" << qPrintable(acc);

  // first, check if contact isn't already on the contact list
  RosterItemModel *item = roster->find( acc + ";" + jid );
  if (item != 0) {
      // yup, it is, update the name if required, then
      if (item->data(RosterItemModel::Name).toString() != name) {
          item->set(name,RosterItemModel::Name);
        emit contactNameChanged(acc,jid,name);
      }
      if (item->data(RosterItemModel::Groups).toString() != groups && groups != "") { // retarded hackfix for that stupid bug
          item->set(groups,RosterItemModel::Groups);
        }
      return;
  }
  // nope, append it
  RosterItemModel* contact = new RosterItemModel(name,jid,"","qrc:/presence/offline","",acc);
  contact->set(groups,RosterItemModel::Groups);

  contact->set(QString::number(isFavorite),RosterItemModel::IsFavorite);
  roster->append(contact);
  roster->sort(0);

  // add contact to database unless said otherwise
  if (updateDatabase)
      database->executeQuery(QStringList() << "insertContact" << acc << jid << name);
}

void ContactListManager::changePresence(QString accountId,QString bareJid,QString resource,QString picStatus,QString txtStatus, bool initializationState) {
  qDebug() << "ContactListManager::changePresence() called" << bareJid << resource << picStatus << txtStatus;
  RosterItemModel *contact = roster->find( accountId + ";" + bareJid );

  if (contact != 0) {
      bool isStatusDifferent = (contact->data(RosterItemModel::Presence) != picStatus);

      qDebug() << "presence changed";
      // set data
      contact->set(resource,RosterItemModel::Resource);
      contact->set(picStatus,RosterItemModel::Presence);
      contact->set(txtStatus,RosterItemModel::StatusText);

      // if user is someone cool, push the status change notification
      if (contact->data(RosterItemModel::IsFavorite).toBool() && isStatusDifferent && !initializationState) {
          QString description = "";
          if (picStatus == "qrc:/presence/online" || picStatus == "qrc:/presence/chatty") description = "I'm online. ^^";
          if (picStatus == "qrc:/presence/offline") description = "I just went offline. :c";
          if (picStatus == "qrc:/presence/away" || picStatus == "qrc:/presence/xa") description = "I'm away.";
          if (picStatus == "qrc:/presence/busy") description = "I'm busy.";

          if (description != "" && settings->gBool("notifications","notifyStatusChange"))
            emit favUserStatusChanged(accountId,bareJid,contact->data(RosterItemModel::Name).toString(),description);
        }

      // sort the roster again
      roster->sort(0);
    } else return;
}

void ContactListManager::changeName(QString accountId,QString bareJid,QString name) {
  RosterItemModel *contact = roster->find( accountId + ";" + bareJid );
  if (contact != 0)
    contact->set(name,RosterItemModel::Name);

  // update contact name in database
  database->executeQuery(QStringList() << "updateContact" << accountId << bareJid << "name" << name);

  roster->sort(0);
  emit contactNameChanged(accountId,bareJid,name);
}

void ContactListManager::rememberResource(QString accountId, QString bareJid, QString resource) {
  // try to find a roster element
  RosterItemModel *contact = roster->find(accountId + ";" + bareJid);

  // if exists, set resource
  if (contact != 0)
    contact->set(resource,RosterItemModel::Resource);
}

QString ContactListManager::restoreResource(QString accountId, QString bareJid) {
  // try to find a roster element
  RosterItemModel *contact = roster->find(accountId + ";" + bareJid);

  // if exists, return resource
  return (contact != 0) ? contact->data(RosterItemModel::Resource).toString() : QString();
}

void ContactListManager::removeContact(QString acc,QString bareJid) {
  int row;
  RosterItemModel *contact = roster->find(acc+";"+bareJid,row);
  if (contact != NULL)
    roster->takeRow(row);

  // remove contact from database
  database->executeQuery(QStringList() << "deleteContact" << acc << bareJid);

  roster->sort(0);
}

void ContactListManager::removeContact(QString acc) {
    // iterate through contact list to remove all contacts from specified account
    RosterItemModel* result;
    QList<int> itemsToRemove;
    for (int row=0; row < roster->rowCount(); row++) {
        result = (RosterItemModel*)roster->itemFromIndex(roster->index(row,0));
        if (result->data(RosterItemModel::AccountId).toString() == acc)
            itemsToRemove.append(row);
    }

    // found all contacts that need to be removed, reset RosterItemModel* pointer and remove contacts
    result = 0;
    for (int row=0; row<itemsToRemove.count(); row++) {
        roster->removeRow(itemsToRemove.at(itemsToRemove.count()-1-row));
    }

    // remove contacts from database
    database->executeQuery(QStringList() << "deleteContact" << acc);

    roster->sort(0);
}

QString ContactListManager::getPropertyByJid( QString accountId, QString bareJid, QString property ) {
    RosterItemModel *item = roster->find( accountId + ";" + bareJid );
    if (item == 0 && property== "name") return bareJid;
    if (item != 0) {
      if (property == "name") {
          return item->data(RosterItemModel::Name).toString() == "" ? bareJid : item->data(RosterItemModel::Name).toString();
      } else if (property == "presence") return item->data(RosterItemModel::Presence).toString();
      else if (property == "resource") return item->data(RosterItemModel::Resource).toString();
      else if (property == "statusText") return item->data(RosterItemModel::StatusText).toString();
      } else return "(unknown)";
}

void ContactListManager::clearPresenceForAccount(QString accountId) {
  RosterItemModel* element;
  for (int i=0;i<roster->count();i++) {
      element = (RosterItemModel*)roster->itemFromIndex(roster->index(i,0));
      if (element != 0 && element->data(RosterItemModel::AccountId).toString() == accountId) {
        element->set("qrc:/presence/offline",RosterItemModel::Presence);
        emit forceXmppPresenceChanged(accountId,element->data(RosterItemModel::Jid).toString(),element->data(RosterItemModel::Resource).toString(),"qrc:/presence/offline",element->data(RosterItemModel::StatusText).toString());
      }
    }
  roster->sort(0);
}

bool ContactListManager::setContactFavState(QString accountId, QString bareJid, bool favState) {
  RosterItemModel *contact = roster->find(accountId + ";" + bareJid);
  if (contact != 0)
    contact->set(QString::number(favState),RosterItemModel::IsFavorite);

  // update contact name in database
  database->executeQuery(QStringList() << "updateContact" << accountId << bareJid << "isFavorite" << QString::number(favState));

  roster->sort(0);

  return contact != 0;
}

// some other stuff

RosterItemFilter* ContactListManager::getRoster() {
  return filter;
}

bool ContactListManager::doesContactExists(QString accountId, QString bareJid) {
  return roster->checkIfExists(accountId + ";" + bareJid);
}
