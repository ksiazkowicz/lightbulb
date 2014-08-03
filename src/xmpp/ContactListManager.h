#ifndef CONTACTLISTMANAGER_H
#define CONTACTLISTMANAGER_H

#include <QObject>

#include "src/models/RosterListModel.h"
#include "src/models/RosterItemModel.h"

class ContactListManager : public QObject
{
  Q_OBJECT

public:
  explicit ContactListManager(QObject *parent = 0);
  RosterListModel* getRoster();

   Q_INVOKABLE QString getPropertyByOrderID(int id,QString property);
   Q_INVOKABLE QString getPropertyByJid(QString accountId,QString bareJid,QString property);

  void clearPresenceForAccount(QString accountId);
  
signals:
  void rosterChanged();
  void contactNameChanged(QString accountId, QString jid, QString name);
  
public slots:
  void addContact(QString acc,QString jid, QString name);
  void changePresence(QString m_accountId,QString bareJid,QString resource,QString picStatus,QString txtStatus);
  void changeName(QString m_accountId,QString bareJid,QString name);
  void removeContact(QString acc,QString bareJid);

  void setOfflineContactsState(bool state) { showOfflineContacts = state; }
  bool getOfflineContactsState()           { return showOfflineContacts;  }

private:
  RosterListModel* roster;
  RosterListModel* rosterOffline;

  bool showOfflineContacts;
  
};

#endif // CONTACTLISTMANAGER_H
