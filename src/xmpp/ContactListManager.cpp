#include "ContactListManager.h"
#include <QDebug>
#include <QXmppMessage.h>

ContactListManager::ContactListManager(QObject *parent) :
  QObject(parent)
{
  roster = new RosterListModel();
  roster->setSortRole(RosterItemModel::SortData);

  // initialize filter
  filter = new RosterItemFilter;
  filter->setSourceModel(roster);
}

void ContactListManager::addContact(QString acc, QString jid, QString name) {
  qDebug() << "ContactListManager::addContact() called";

  // first, check if contact isn't already on the contact list
  RosterItemModel *item = roster->find( acc + ";" + jid );
  if (item != 0) {
      // yup, it is, update the name if required, then
      if (item->data(RosterItemModel::Name).toString() != name) {
          item->set(name,RosterItemModel::Name);
        emit contactNameChanged(acc,jid,name);
      }
      return;
  }
  // nope, append it
  RosterItemModel* contact = new RosterItemModel(name,jid,"","qrc:/presence/offline","",acc);
  roster->append(contact);
  roster->sort(0);
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

          if (description != "")
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

  roster->sort(0);
  emit contactNameChanged(accountId,bareJid,name);
}
void ContactListManager::removeContact(QString acc,QString bareJid) {
  int row;
  RosterItemModel *contact = roster->find(acc+";"+bareJid,row);
  if (contact != NULL)
    roster->takeRow(row);
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

RosterItemFilter* ContactListManager::getRoster() {
  return filter;
}

bool ContactListManager::doesContactExists(QString accountId, QString bareJid) {
  return roster->checkIfExists(accountId + ";" + bareJid);
}
