#include "XmppConnectivity.h"
#include "MyXmppClient.h"
#include "Settings.h"

XmppConnectivity::XmppConnectivity(QObject *parent) :
    QObject(parent)
{
    clients = new QMap<int,MyXmppClient*>;
    Settings lightbulbConf;

    for (int i=0; i<lightbulbConf.accountsCount(); i++)
        initializeAccount(i,lightbulbConf.getAccount(i));
}

bool XmppConnectivity::initializeAccount(int index, AccountsItemModel* account) {
    // check if client with specified index exists. If not, add one
    if (!clients->contains(index))
        clients->insert(index,new MyXmppClient());

    // initialize account
    clients->value(index)->setMyJid(account->jid());
    clients->value(index)->setPassword(account->passwd());
    clients->value(index)->setResource(account->resource());
    if (account->isManuallyHostPort()) {
        clients->value(index)->setHost(account->host());
        clients->value(index)->setPort(account->port());
    } else {
        clients->value(index)->setHost("");
        clients->value(index)->setPort(5222);
    }
    qDebug() << "XmppConnectivity::initializeAccount(): initialized account " + clients->value(index)->getMyJid() + "/" + clients->value(index)->getResource();
    return true;
}

