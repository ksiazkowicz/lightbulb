#ifndef XMPPCONNECTIVITY_H
#define XMPPCONNECTIVITY_H

#include <QObject>
#include "AccountsItemModel.h"
#include "MyXmppClient.h"

class XmppConnectivity : public QObject
{
    Q_OBJECT

    Q_PROPERTY( MyXmppClient* client READ getClient NOTIFY accountChanged )
    Q_PROPERTY( RosterListModel* roster READ getRoster NOTIFY rosterChanged )
public:
    explicit XmppConnectivity(QObject *parent = 0);
    bool initializeAccount(int index, AccountsItemModel* account);
    Q_INVOKABLE void changeAccount(int index) {
        if (index != currentClient) {
            currentClient = index;
            selectedClient = clients->value(index);
            connect( selectedClient, SIGNAL(rosterChanged()), this, SLOT(changeRoster()), Qt::UniqueConnection);
            emit accountChanged();
            changeRoster();
        }
    }
    
signals:
    void accountChanged();
    void rosterChanged();
    
public slots:
    void changeRoster() {
        roster = selectedClient->getCachedRoster();
        emit rosterChanged();
    }

private:
    int currentClient;
    QMap<int,MyXmppClient*> *clients;
    MyXmppClient* getClient() { return selectedClient; }
    RosterListModel* getRoster() { return roster; }

    MyXmppClient* selectedClient;
    RosterListModel* roster;
    
};

#endif // XMPPCONNECTIVITY_H
