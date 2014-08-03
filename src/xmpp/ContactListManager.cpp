#include "ContactListManager.h"
#include <QDebug>
#include <QXmppMessage.h>

ContactListManager::ContactListManager(QObject *parent) :
  QObject(parent)
{
  roster = new RosterListModel();
  rosterOffline = new RosterListModel();
}

void ContactListManager::addContact(QString acc, QString jid, QString name) {
  qDebug() << "ContactListManager::addContact() called";

  // first, check if contact isn't already on the contact list
  RosterItemModel *item = (RosterItemModel*)roster->find( acc + ";" + jid );
  if (item != 0) {
      // yup, it is, update the name if required, then
      if (item->name() != name) {
        item->setContactName(name);
        emit contactNameChanged(acc,jid,name);
      }
      return;
  }
  // nope, append it
  RosterItemModel* contact = new RosterItemModel(name,jid,"","qrc:/presence/offline","",acc);
  roster->append(contact);
  emit contactNameChanged(acc,jid,name);
}

void ContactListManager::changePresence(QString accountId,QString bareJid,QString resource,QString picStatus,QString txtStatus) {
  qDebug() << "ContactListManager::changePresence() called" << bareJid << resource << picStatus << txtStatus;
  RosterItemModel *contact = (RosterItemModel*)roster->find( accountId + ";" + bareJid );
  if (contact != 0) {
      contact->setResource(resource);
      contact->setPresence(picStatus);
      contact->setStatusText(txtStatus);
    } else return;

  RosterItemModel *contactOffline = (RosterItemModel*)rosterOffline->find(accountId+";"+bareJid);
  if (picStatus != "qrc:/presence/offline") {
      qDebug() << "isn't offline should do stuff";
      if (contactOffline!=0) {
          contactOffline->setResource(resource);
          contactOffline->setPresence(picStatus);
          contactOffline->setStatusText(txtStatus);
        } else {
          qDebug() << "appending crap";
          RosterItemModel *contactNew = new RosterItemModel(contact->name(),bareJid,resource,picStatus,txtStatus,accountId);
          rosterOffline->append(contactNew);
        }
    } else if (contactOffline != 0)
        rosterOffline->removeId(accountId+";"+bareJid);
  qDebug() << "presence changed";
}
void ContactListManager::changeName(QString accountId,QString bareJid,QString name) {
  RosterItemModel *contact = (RosterItemModel*)roster->find( accountId + ";" + bareJid );
  if (contact != 0)
    contact->setContactName(name);

  contact = (RosterItemModel*)rosterOffline->find( accountId + ";" + bareJid );
  if (contact != 0)
    contact->setContactName(name);

  emit contactNameChanged(accountId,bareJid,name);
}
void ContactListManager::removeContact(QString acc,QString bareJid) {
  RosterItemModel *contact;
  for (int i=0;i<roster->count();i++) {
      contact = (RosterItemModel*)roster->getElementByID(i);
      if (contact->id() == acc+";"+bareJid)
        roster->remove(i);
    }

  for (int i=0;i<rosterOffline->count();i++) {
      contact = (RosterItemModel*)rosterOffline->getElementByID(i);
      if (contact->id() == acc+";"+bareJid)
        roster->remove(i);
    }
}

QString ContactListManager::getPropertyByJid( QString accountId, QString bareJid, QString property ) {
    RosterItemModel *item = (RosterItemModel*)roster->find( accountId + ";" + bareJid );
    if (item != 0) {
      if (property == "name") return item->name();
      else if (property == "presence") return item->presence();
      else if (property == "resource") return item->resource();
      else if (property == "statusText") return item->statusText();
      } else return "(unknown)";
}

QString ContactListManager::getPropertyByOrderID(int id, QString property) {
  bool onlineContactFound;
  int  iterations = id;
  while (!onlineContactFound && roster->count() >= id+1) {
    RosterItemModel *item = (RosterItemModel*)roster->getElementByID(id);
    if (item != 0) {
        if (item->presence() != "qrc:/presence/offline") {
            if (iterations == 0) return getPropertyByJid(item->accountId(),item->jid(),property);
            else iterations--;
        }
        id++;
    } else break;
  }
  return "";
}

void ContactListManager::clearPresenceForAccount(QString accountId) {
  RosterItemModel* element;
  for (int i=0;i<roster->count();i++) {
      element = (RosterItemModel*)roster->getElementByID(i);
      if (element != 0 && element->accountId() == accountId)
        element->setPresence("qrc:/presence/offline");
    }

  for (int i=0;i<rosterOffline->count();i++) {
      element = (RosterItemModel*)rosterOffline->getElementByID(i);
      if (element != 0 && element->accountId() == accountId)
        rosterOffline->remove(i);
    }
}

RosterListModel* ContactListManager::getRoster() {
  if (showOfflineContacts)
    return roster;
  else return rosterOffline;
}
