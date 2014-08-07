#ifndef EVENTSMANAGER_H
#define EVENTSMANAGER_H

#include <QObject>
#include "EventListModel.h"
#include "EventItemModel.h"

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
  Q_INVOKABLE void removeEvent(int id);
  Q_INVOKABLE void removeEvent(QString bareJid, QString accountId,int type);
  Q_INVOKABLE void clearList();

private:
  EventListModel *events;
  EventListModel* getEvents() { return events; }
};

#endif // EVENTSMANAGER_H
