#ifndef XMPPCONNECTIVITY_H
#define XMPPCONNECTIVITY_H

#include <QObject>
#include "AccountsItemModel.h"
#include "MyXmppClient.h"
#include "DatabaseWorker.h"
#include "QAvkonHelper.h"
#include "MyCache.h"
#include "Settings.h"

class XmppConnectivity : public QObject
{
    Q_OBJECT

    Q_PROPERTY(MyXmppClient* client READ getClient NOTIFY accountChanged)
    Q_PROPERTY(RosterListModel* roster READ getRoster NOTIFY rosterChanged)
    Q_PROPERTY(int page READ getPage WRITE gotoPage NOTIFY pageChanged)
    Q_PROPERTY(SqlQueryModel* messagesByPage READ getSqlMessagesByPage NOTIFY pageChanged)
    Q_PROPERTY(SqlQueryModel* messages READ getSqlMessagesByPage NOTIFY sqlMessagesChanged)
    Q_PROPERTY(QString chatJid READ getChatJid WRITE setChatJid NOTIFY chatJidChanged)
public:
    explicit XmppConnectivity(QObject *parent = 0);
    bool initializeAccount(int index, AccountsItemModel* account);
    Q_INVOKABLE void changeAccount(int index);

    // well, this stuff is needed
    int getPage() const { return page; }
    void gotoPage(int nPage);

    QString getChatJid() const { return currentJid; }
    void setChatJid( const QString & value ) {
        if(value!=currentJid) {
            currentJid=value;
            emit chatJidChanged();
        }
    }

    /* --- diagnostics --- */
    Q_INVOKABLE bool dbRemoveDb();
    Q_INVOKABLE bool cleanCache();
    Q_INVOKABLE bool resetSettings();

    Q_INVOKABLE QString getAvatarByJid(QString bareJid) { return lCache->getAvatarCache(bareJid); }

signals:
    void accountChanged();
    void rosterChanged();

    void pageChanged();
    void sqlMessagesChanged();
    void chatJidChanged();

    void notifyMsgReceived(QString name,QString jid,QString body);
    
public slots:
    void changeRoster() {
        roster = selectedClient->getCachedRoster();
        emit rosterChanged();
    }
    void updateContact(int m_accountId,QString bareJid,QString property,int count) {
        dbWorker->executeQuery(QStringList() << "updateContact" << QString::number(m_accountId) << bareJid << property << QString::number(count));
    }
    void updateMessages() { dbWorker->updateMessages(currentClient,currentJid,page); }
    void insertMessage(int m_accountId,QString bareJid,QString body,QString date,int mine);

private:
    int currentClient;
    QMap<int,MyXmppClient*> *clients;
    MyXmppClient* getClient() { return selectedClient; }

    RosterListModel* getRoster() { return roster; }
    SqlQueryModel* getSqlMessagesByPage() { return dbWorker->getSqlMessages(); }

    MyXmppClient* selectedClient;
    RosterListModel* roster;

    MyCache* lCache;
    Settings* lSettings;

    DatabaseWorker *dbWorker;
    QThread *dbThread;

    int page; //required for archive view
    QString currentJid;

    static bool removeDir(const QString &dirName); //workaround for qt not able to remove directory recursively
    // http://john.nachtimwald.com/2010/06/08/qt-remove-directory-and-its-contents/

    int globalUnreadCount;
};

#endif // XMPPCONNECTIVITY_H
