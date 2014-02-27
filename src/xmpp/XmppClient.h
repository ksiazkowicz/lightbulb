#ifndef XMPPCLIENT_H
#define XMPPCLIENT_H

#include <QObject>

class XmppClient : public QObject
{
  Q_OBJECT
public:
  explicit XmppClient(QObject *parent = 0);
  
signals:
  
public slots:
  
};

#endif // XMPPCLIENT_H
