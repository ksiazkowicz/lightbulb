#ifndef EVENTSMANAGER_H
#define EVENTSMANAGER_H

#include <QObject>
#include "../models/EventListModel.h"
#include "../models/EventItemModel.h"

class EventsManager : public QObject
{
  Q_OBJECT
  Q_PROPERTY(EventListModel* list READ getEvents NOTIFY eventsChanged)
public:
  explicit EventsManager(QObject *parent = 0);
  
signals:
  void eventsChanged();
  
public slots:
  void appendUnreadMessage(QString bareJid, QString accountId, QString name, QString description);
  void appendAttention(QString accountId, QString bareJid, QString name);
  void appendMUCInvitation(QString accountId, QString bareJid, QString sender);
  void appendSubscription(QString accountId, QString bareJid);
  void appendStatusChange(QString accountId, QString name, QString description);
  void appendError(QString accountId, QString name, QString errorString);
  void appendUpdate(bool updateAvailable = true, QString version = "", QString date = "");
  void appendTransferJob(QString accountId, QString bareJid, QString name, QString description, int transferJob, bool isIncoming);

  Q_INVOKABLE void removeEvent(int id);
  Q_INVOKABLE void removeEvent(QString bareJid, QString accountId,int type);
  Q_INVOKABLE void clearList();

private:
  EventListModel *events;
  EventListModel* getEvents() { return events; }
};

#endif // EVENTSMANAGER_H
