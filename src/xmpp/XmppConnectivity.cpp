#include "XmppConnectivity.h"

XmppConnectivity::XmppConnectivity(QObject *parent) :
    QObject(parent)
{
    selectedClient = new MyXmppClient();
    currentClient = -1;
    clients = new QMap<int,MyXmppClient*>;
    lSettings = new Settings();
    lCache = new MyCache();
    lCache->createHomeDir();

    dbWorker = new DatabaseWorker;
    dbThread = new QThread(this);
    dbWorker->moveToThread(dbThread);
    dbThread->start();

    for (int i=0; i<lSettings->accountsCount(); i++)
        initializeAccount(i,lSettings->getAccount(i));
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
    clients->value(index)->setAccountId(index);
    connect(clients->value(index),SIGNAL(rosterChanged()),this,SLOT(changeRoster()));
    connect(clients->value(index),SIGNAL(updateContact(int,QString,QString,int)),this,SLOT(updateContact(int,QString,QString,int)));
    connect(clients->value(index),SIGNAL(insertMessage(int,QString,QString,QString,int)),this,SLOT(insertMessage(int,QString,QString,QString,int)));
    qDebug() << "XmppConnectivity::initializeAccount(): initialized account " + clients->value(index)->getMyJid() + "/" + clients->value(index)->getResource();
    return true;
}

void XmppConnectivity::changeAccount(int index) {
    if (index != currentClient) {
        currentClient = index;
        selectedClient = clients->value(index);
        connect(dbWorker, SIGNAL(messagesChanged()), this, SLOT(updateMessages()), Qt::UniqueConnection);
        connect(dbWorker, SIGNAL(sqlMessagesUpdated()), this, SIGNAL(sqlMessagesChanged()), Qt::UniqueConnection);
        emit accountChanged();
        changeRoster();
    }
}

void XmppConnectivity::gotoPage(int nPage) {
    page = nPage;
    updateMessages();
    emit pageChanged();
}

/* --- diagnostics --- */
bool XmppConnectivity::dbRemoveDb() {
    bool ret = false;
    DatabaseManager* database = new DatabaseManager();
    SqlQueryModel* sqlQuery = new SqlQueryModel( 0 );
    sqlQuery->setQuery("DELETE FROM MESSAGES", database->db);
    database->deleteLater();
    if (sqlQuery->lastError().text() == " ") ret = true;
    sqlQuery->deleteLater();
    return ret;
}
bool XmppConnectivity::cleanCache() { return this->removeDir(lCache->getMeegIMCachePath()); }
bool XmppConnectivity::removeDir(const QString &dirName) {
    bool result = true;
    QDir dir(dirName);

    if (dir.exists(dirName)) {
        Q_FOREACH(QFileInfo info, dir.entryInfoList(QDir::NoDotAndDotDot | QDir::System | QDir::Hidden  | QDir::AllDirs | QDir::Files, QDir::DirsFirst)) {
            if (info.isDir()) result = removeDir(info.absoluteFilePath());
            else result = QFile::remove(info.absoluteFilePath());

            if (!result) return result;
        }
        result = dir.rmdir(dirName);
    }

    return result;
}
bool XmppConnectivity::resetSettings() { return QFile::remove(lSettings->confFile); }

// handling stuff from MyXmppClient
void XmppConnectivity::insertMessage(int m_accountId,QString bareJid,QString body,QString date,int mine) {
    dbWorker->executeQuery(QStringList() << "insertMessage" << QString::number(m_accountId) << bareJid << body << date << QString::number(mine));
    if (mine == 0) emit notifyMsgReceived(clients->value(m_accountId)->getPropertyByJid(bareJid,"name"),bareJid,body.left(30));
}
