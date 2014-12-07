#ifndef CONTACTLISTMANAGER_H
#define CONTACTLISTMANAGER_H

#include <QObject>

#include "../models/RosterListModel.h"
#include "../models/RosterItemModel.h"
#include "../models/RosterItemFilter.h"

#include "../database/DatabaseWorker.h"
#include "../database/Settings.h"

class ContactListManager : public QObject
{
  Q_OBJECT

public:
  explicit ContactListManager(DatabaseWorker* db,Settings* st,QObject *parent = 0);
  RosterItemFilter* getRoster();

  Q_INVOKABLE QString getPropertyByJid(QString accountId,QString bareJid,QString property);

  void clearPresenceForAccount(QString accountId);

  bool doesContactExists(QString accountId, QString bareJid);
  
signals:
  void rosterChanged();
  void contactNameChanged(QString accountId, QString jid, QString name);
  void forceXmppPresenceChanged(QString m_accountId, QString bareJid, QString resources, QString picStatus, QString txtStatus);
  void favUserStatusChanged(QString accountId, QString bareJid, QString name, QString description);
  
public slots:
  void addContact(QString acc, QString jid, QString name, bool updateDatabase = true, bool isFavorite = false, QString groups = "");
  void changePresence(QString m_accountId,QString bareJid,QString resource,QString picStatus,QString txtStatus, bool initializationState);
  void changeName(QString m_accountId,QString bareJid,QString name);
  void rememberResource(QString m_accountId, QString bareJid, QString resource);
  Q_INVOKABLE QString restoreResource(QString m_accountId, QString bareJid);
  void removeContact(QString acc,QString bareJid);
  void removeContact(QString acc);
  bool setContactFavState(QString acc, QString bareJid, bool favState);

  void cleanupCache(QString acc, QStringList bareJids);
  bool removeCache();

  void changeFilter(QString regexp) { filter->setFilterRegExp(regexp); }

  void setOfflineContactsState(bool state) { filter->setShowOfflineContacts(state); showOfflineContacts = state; }
  bool getOfflineContactsState()           { return showOfflineContacts;  }

private slots:
  void restoreCache();

private:
  RosterListModel* roster;
  RosterItemFilter* filter;

  DatabaseWorker* database;
  Settings* settings;

  bool showOfflineContacts;
  
};

#endif // CONTACTLISTMANAGER_H
