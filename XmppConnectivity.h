#ifndef XMPPCONNECTIVITY_H
#define XMPPCONNECTIVITY_H

#include <QObject>
#include <list>
#include "MyXmppClient.h"

class XmppConnectivity : public QObject
{
    Q_OBJECT
public:
    explicit XmppConnectivity(QObject *parent = 0);
    
signals:
    
public slots:

private:
    std::list<MyXmppClient> clients;
    
};

#endif // XMPPCONNECTIVITY_H
