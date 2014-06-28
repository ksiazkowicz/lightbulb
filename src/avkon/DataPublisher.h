#ifndef DATAPUBLISHER_H
#define DATAPUBLISHER_H

#include <QObject>
#include <qmobilityglobal.h>
#include <QVariant>

QTM_BEGIN_NAMESPACE

class QValueSpacePublisher;
QTM_END_NAMESPACE

QTM_USE_NAMESPACE

class DataPublisher : public QObject
{
  Q_OBJECT
public:
  explicit DataPublisher(QString path, QObject *parent = 0);
  
signals:
  
public slots:
  void dataChanged(QString key, QVariant &value);

private:
  QValueSpacePublisher *publish;
  
};

#endif // DATAPUBLISHER_H
