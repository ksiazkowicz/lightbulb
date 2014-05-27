#include "ContactListManager.h"
#include <QDebug>

ContactListManager::ContactListManager(QObject *parent) :
  QObject(parent)
{
  roster = new RosterListModel();
}

void ContactListManager::addContact(QString acc, QString jid, QString name) {
  RosterItemModel* contact = new RosterItemModel(name,jid,"","","",0,acc);
  qDebug() << "contact" << acc << jid << name << "appended";
  roster->append(contact);
  //emit rosterChanged();
}

void ContactListManager::plusUnreadMessage(QString acc, QString jid) {
  RosterItemModel *contact = (RosterItemModel*)roster->find( jid );
  if (contact != 0)
    contact->setUnreadMsg(contact->unreadMsg()+1);
}

void ContactListManager::resetUnreadMessages(QString accountId, QString bareJid) {
  RosterItemModel *contact = (RosterItemModel*)roster->find( bareJid );
  if (contact != 0)
    contact->setUnreadMsg(0);
}

QString ContactListManager::getPropertyByJid( QString bareJid, QString property ) {
    RosterItemModel *item = (RosterItemModel*)roster->find( bareJid );
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
            if (iterations == 0) return getPropertyByJid(item->jid(),property);
            else iterations--;
        }
        id++;
    } else break;
  }
  return "";
}
