#include "DatabaseManager.h"
#include <QFile>
#include <QSqlRecord>
#include <QSqlField>
#include <QDebug>


//--------------------------------
// SQL QUERY MODEL
//
// DOES SOME FUN STUFF TO DISPLAY STUFF IN QML
//--------------------------------

SqlQueryModel::SqlQueryModel(QObject *parent) :
    QSqlQueryModel(parent)
{

}

void SqlQueryModel::setQuery(const QString &query, const QSqlDatabase &db)
{
    QSqlQueryModel::setQuery(query,db);
    generateRoleNames();
}

void SqlQueryModel::setQuery(const QSqlQuery & query)
{
    QSqlQueryModel::setQuery(query);
    generateRoleNames();
}

void SqlQueryModel::generateRoleNames()
{
    QHash<int, QByteArray> roleNames;
    for( int i = 0; i < record().count(); i++) {
        roleNames[Qt::UserRole + i + 1] = record().fieldName(i).toAscii();
    }
    setRoleNames(roleNames);
}

QVariant SqlQueryModel::data(const QModelIndex &index, int role) const
{
    QVariant value = QSqlQueryModel::data(index, role);
    if(role < Qt::UserRole)
    {
        value = QSqlQueryModel::data(index, role);
    }
    else
    {
        int columnIdx = role - Qt::UserRole - 1;
        QModelIndex modelIndex = this->index(index.row(), columnIdx);
        value = QSqlQueryModel::data(modelIndex, Qt::DisplayRole);
    }
    return value;
}

//--------------------------------
// DATABASE
// MANAGER
//
// APPENDS DATA TO TEH DATABSE AND DOES OTHER USEFUL STUFF
//--------------------------------

DatabaseManager::DatabaseManager(QObject *parent) :
    QObject(parent)
{
}

bool DatabaseManager::openDB()
{
    // Find QSLite driver
    db = QSqlDatabase::addDatabase("QSQLITE");

    // NOTE: File exists in the application private folder, in Symbian Qt implementation
    db.setDatabaseName("com.lightbulb.db");

    // Open databasee
    return db.open();
}

QSqlError DatabaseManager::lastError()
{
    return db.lastError();
}

bool DatabaseManager::deleteDB()
{
    // Close database
    db.close();

    // Remove created database binary file
    return QFile::remove("com.lightbulb.db");
}

bool DatabaseManager::initDB()
{
    mkAccTable();
    mkRosterTable();

    return true;
}

bool DatabaseManager::mkAccTable()
{
    bool ret = false;
    if (db.isOpen()) {
        QSqlQuery query;
        ret = query.exec("create table accounts "
                         "(id integer primary key, "
                         "jid varchar(30), "
                         "pass varchar(30), "
                         "resource varchar(30), "
                         "manualHostPort integer, "
                         "enabled integer, "
                         "host varchar(30), "
                         "port integer)");
    }
    return ret;
}

bool DatabaseManager::mkRosterTable()
{
    bool ret = false;
    if (db.isOpen()) {
        QSqlQuery query;
        ret = query.exec("create table roster "
                         "(id integer primary key, "
                         "id_account integer, "
                         "name varchar(30), "
                         "jid varchar(30), "
                         "resource varchar(30), "
                         "status varchar(12), "
                         "statusText varchar(255), "
                         "avatarPath varchar(255), "
                         "isChatInProgress int, "
                         "unreadMsg integer)");
    }
    return ret;
}

bool DatabaseManager::checkIfChatInProgress( QString bareJid )
{
    bool ret = false;
    QSqlQuery query;
    query.prepare("select isChatInProgress from roster where jid = " + bareJid);
    SqlQueryModel isChatInProgress;
    isChatInProgress.setQuery(query);

    ret = isChatInProgress.record(0).value("isChatInProgress").toBool();
    return ret;
}

bool DatabaseManager::setChatInProgress( QString bareJid, bool chat )
{
    bool ret = false;
    QSqlQuery query;
    QString queryStr;
    queryStr = "UPDATE roster SET isChatInProgress=";
    queryStr += chat;
    queryStr += " where jid=";
    queryStr += bareJid;
    ret = query.exec(queryStr);
    return ret;

}

bool DatabaseManager::mkMessagesTable()
{
    bool ret = false;
    if (db.isOpen()) {
        QSqlQuery query;
        ret = query.exec("create table messages "
                         "(id integer primary key, "
                         "id_account integer, "
                         "bareJid varchar(30), "
                         "msgText varchar(2048), "
                         "dateTime varchar(30), "
                         "isMine integer)");
    }
    return ret;
}

bool DatabaseManager::insertAccount(QString jid,
                                    QString pass,
                                    QString resource,
                                    int manualHostPort,
                                    int enabled,
                                    QString host,
                                    int port)
{
    bool ret = false;
    QSqlQuery query;
    ret = query.prepare("INSERT INTO accounts (jid, pass, resource, manualHostPort, enabled, host, port) "
                        "VALUES (:jid, :pass, :resource, :manualHostPort, :enabled, :host, :port)");
    if (ret) {
        query.bindValue(":jid", jid);
        query.bindValue(":pass", pass);
        query.bindValue(":resource", resource);
        query.bindValue(":manualHostPort", manualHostPort);
        query.bindValue(":enabled", enabled);
        query.bindValue(":host", host);
        query.bindValue(":port", port);
        ret = query.exec();
    }
    return ret;
}

bool DatabaseManager::doGenericQuery(QString genericQuery)
{
    bool ret = false;
    QSqlQuery query;
    ret = query.prepare(genericQuery);
    if (ret) {
        ret = query.exec();
    }
    return ret;
}


bool DatabaseManager::insertMessage(int acc,
                                    QString bareJid,
                                    QString text,
                                    QString time,
                                    int mine)
{
    bool ret = false;
    QSqlQuery query;
    ret = query.prepare("INSERT INTO messages (id_account, bareJid, msgText, dateTime, isMine) "
                        "VALUES (:acc, :jid, :msgText, :time, :mine)");
    if (ret) {
        query.bindValue(":acc", acc);
        query.bindValue(":jid", bareJid);
        query.bindValue(":msgText", text);
        query.bindValue(":time", time);
        query.bindValue(":mine", mine);
        ret = query.exec();
    }
    return ret;
}


bool DatabaseManager::insertContact( int acc,
                                     QString bareJid,
                                     QString name,
                                     QString presence,
                                     QString avatarPath)
{
    bool ret = false;
    QSqlQuery query;
    ret = query.prepare("INSERT INTO roster (id, id_account, name, jid, resource, status, statusText, avatarPath, isChatInProgress, unreadMsg) "
                        "VALUES (:acc, :name, :jid, :resource, :status, :statusText, :avatarPath, :isChatInProgress, :unreadMsg)");
    if (ret) {
        query.bindValue(":acc", acc);
        query.bindValue(":jid", bareJid);
        query.bindValue(":name", name);
        query.bindValue(":resource", "");
        query.bindValue(":status", presence);
        query.bindValue(":statusText","");
        query.bindValue(":avatarPath",avatarPath);
        query.bindValue(":isChatInProgress",0);
        query.bindValue(":unreadMsg",0);
        ret = query.exec();
    }

    return ret;
}
