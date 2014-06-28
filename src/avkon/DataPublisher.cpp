#include "DataPublisher.h"
#include <qvaluespacepublisher.h>
#include <QVariant>

DataPublisher::DataPublisher(QString path, QObject *parent) :
  QObject(parent) {
  publish = new QValueSpacePublisher("/api/fluorescent/" + path);
}

void DataPublisher::dataChanged(QString key, QVariant &value) {
  publish->setValue(key, value);
}
