#include "DataPublisher.h"
#include <qvaluespacepublisher.h>
#include <QVariant>
#include <QDebug>

DataPublisher::DataPublisher(QString path, QObject *parent) :
  QObject(parent) {
  publish = new QValueSpacePublisher("/Fluorescent/widget/" + path);

  // reset unread count and update the value
  unreadCount = 0;
  this->unreadCountChanged(0);
}

void DataPublisher::dataChanged(QString key, QVariant value) {
  publish->setValue(key, value);
}

void DataPublisher::unreadCountChanged(int count) {
  unreadCount += count;
  publish->setValue("unreadCount",QVariant(unreadCount));
}
