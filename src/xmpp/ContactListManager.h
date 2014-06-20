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
  RosterListModel* getRoster() { return roster; }

   Q_INVOKABLE QString getPropertyByOrderID(int id,QString property);
   Q_INVOKABLE QString getPropertyByJid(QString accountId,QString bareJid,QString property);

   Q_INVOKABLE void resetUnreadMessages(QString accountId,QString bareJid);

  void clearPresenceForAccount(QString accountId);
  
signals:
  void rosterChanged();

  
public slots:
  void addContact(QString acc,QString jid, QString name);
  void plusUnreadMessage(QString acc,QString jid);
  void changePresence(QString m_accountId,QString bareJid,QString resource,QString picStatus,QString txtStatus);
  void changeName(QString m_accountId,QString bareJid,QString name);
  void removeContact(QString acc,QString bareJid);

private:
  RosterListModel* roster;
  RosterListModel* rosterOffline;
  
};

#endif // CONTACTLISTMANAGER_H
