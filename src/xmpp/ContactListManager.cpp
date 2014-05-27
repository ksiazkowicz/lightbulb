#include "ContactListManager.h"
#include <QDebug>

ContactListManager::ContactListManager(QObject *parent) :
  QObject(parent)
{
  roster = new RosterListModel();
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
  }

  contact->setUnreadMsg(contact->unreadMsg()+1);
}
void ContactListManager::changePresence(QString accountId,QString bareJid,QString resource,QString picStatus,QString txtStatus) {
  RosterItemModel *contact = (RosterItemModel*)roster->find( accountId + ";" + bareJid );
  if (contact != 0) {
      contact->setResource(resource);
      contact->setPresence(picStatus);
      contact->setStatusText(txtStatus);
    }
}
void ContactListManager::resetUnreadMessages(QString accountId, QString bareJid) {
  RosterItemModel *contact = (RosterItemModel*)roster->find( accountId + ";" + bareJid );
  if (contact != 0)
    contact->setUnreadMsg(0);
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
