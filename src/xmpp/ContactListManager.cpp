#include "ContactListManager.h"
#include <QDebug>

ContactListManager::ContactListManager(QObject *parent) :
  QObject(parent)
{
  roster = new RosterListModel();
  rosterOffline = new RosterListModel();
}

void ContactListManager::addContact(QString acc, QString jid, QString name) {
  // first, check if contact isn't already on the contact list
  RosterItemModel *item = (RosterItemModel*)roster->find( acc + ";" + jid );
  if (item != 0) {
      // yup, it is, update the name if required, then
      if (item->name() != name)
        item->setContactName(name);
      return;
  }
  // nope, append it
  RosterItemModel* contact = new RosterItemModel(name,jid,"","qrc:/presence/offline","",0,acc);
  roster->append(contact);
}

void ContactListManager::plusUnreadMessage(QString acc, QString jid) {
  RosterItemModel *contact = (RosterItemModel*)roster->find( acc + ";" + jid );

  if (contact == 0) {
    this->addContact(acc,jid,jid);
    contact = (RosterItemModel*)roster->find( acc + ";" + jid );
    plusUnreadMessage(acc,jid);
  } else {
    contact->setUnreadMsg(contact->unreadMsg()+1);
  }

  if (contact->presence() != "qrc:/presence/offline") {
      RosterItemModel *contactOffline = (RosterItemModel*)rosterOffline->find( acc + ";" + jid);
      if (contactOffline != 0)
        contactOffline->setUnreadMsg(contact->unreadMsg());
    }
}
void ContactListManager::changePresence(QString accountId,QString bareJid,QString resource,QString picStatus,QString txtStatus) {
  qDebug() << "ContactListManager::changePresence() called";
  RosterItemModel *contact = (RosterItemModel*)roster->find( accountId + ";" + bareJid );
  if (contact != 0) {
      contact->setResource(resource);
      contact->setPresence(picStatus);
      contact->setStatusText(txtStatus);
    }

  RosterItemModel *contactOffline = (RosterItemModel*)rosterOffline->find(accountId+";"+bareJid);
  if (picStatus != "qrc:/presence/offline") {
      if (contactOffline!=0) {
          contactOffline->setResource(resource);
          contactOffline->setPresence(picStatus);
          contactOffline->setStatusText(txtStatus);
        } else {
          RosterItemModel *contactNew = new RosterItemModel(contact->name(),bareJid,resource,picStatus,txtStatus,contact->unreadMsg(),accountId);
          rosterOffline->append(contactNew);
        }
    } else if (contactOffline != 0)
        rosterOffline->removeId(accountId+";"+bareJid);
}
void ContactListManager::changeName(QString accountId,QString bareJid,QString name) {
  RosterItemModel *contact = (RosterItemModel*)roster->find( accountId + ";" + bareJid );
  if (contact != 0)
    contact->setContactName(name);
}
void ContactListManager::removeContact(QString acc,QString bareJid) {
  RosterItemModel *contact;
  for (int i=0;i<roster->count();i++) {
      contact = (RosterItemModel*)roster->getElementByID(i);
      if (contact->id() == acc+";"+bareJid)
        roster->remove(i);
    }
}
void ContactListManager::resetUnreadMessages(QString accountId, QString bareJid) {
  RosterItemModel *contact = (RosterItemModel*)roster->find( accountId + ";" + bareJid );
  if (contact != 0) {
    contact->setUnreadMsg(0);
    if (contact->presence() != "qrc:/presence/offline") {
        RosterItemModel *contactOffline = (RosterItemModel*)rosterOffline->find( accountId + ";" + bareJid );
        if (contactOffline != 0)
          contactOffline->setUnreadMsg(contact->unreadMsg());
      }
  }
}
QString ContactListManager::getPropertyByJid( QString accountId, QString bareJid, QString property ) {
    RosterItemModel *item = (RosterItemModel*)roster->find( accountId + ";" + bareJid );
    if (item != 0) {
      if (property == "name") return item->name();
      else if (property == "presence") return item->presence();
      else if (property == "resource") return item->resource();
      else if (property == "statusText") return item->statusText();
      else if (property == "unreadMsg") return QString::number(item->unreadMsg());
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
}

RosterListModel* ContactListManager::getRoster() {
  if (showOfflineContacts)
    return roster;
  else return rosterOffline;
}
