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
   Q_INVOKABLE QString getPropertyByJid(QString bareJid,QString property);

   Q_INVOKABLE void resetUnreadMessages(QString accountId,QString bareJid);
  
signals:
  void rosterChanged();

  
public slots:
  void addContact(QString acc,QString jid, QString name);
  void plusUnreadMessage(QString acc,QString jid);

private:
  RosterListModel* roster;
  
};

#endif // CONTACTLISTMANAGER_H
