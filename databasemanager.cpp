#include "DatabaseManager.h"
#include <QFile>
#include <QSqlRecord>
#include <QSqlField>
#include <QDebug>
#include <QSqlDatabase>


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
    if (db.isOpen())
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
    if ( !QSqlDatabase::contains("Database")) {
        db = QSqlDatabase::addDatabase("QSQLITE","Database");
        db.setDatabaseName("com.lightbulb.db");
    } else {
        db = QSqlDatabase::database("Database");
        db.setDatabaseName("com.lightbulb.db");
    }

    if ( !db.isOpen() )
    {
        if (!db.open()) {
            qWarning() << "Unable to connect to database, giving up:" << db.lastError().text();
            databaseOpen = false;
            return;
        }
    }
    databaseOpen = true;
}

DatabaseManager::~DatabaseManager() {
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
    mkMessagesTable();

    emit finished();

    return true;
}

bool DatabaseManager::mkAccTable()
{
    bool ret = false;
    if (db.isOpen()) {
        QSqlQuery query(db);
        ret = query.exec("create table accounts "
                         "(id integer primary key, "
                         "jid varchar(50), "
                         "pass varchar(30), "
                         "resource varchar(30), "
                         "manualHostPort integer, "
                         "enabled integer, "
                         "host varchar(50), "
                         "port integer)");
    }
    emit finished();
    return ret;
}

bool DatabaseManager::mkRosterTable()
{
    bool ret = false;
    if (db.isOpen()) {
        QSqlQuery query(db);
        ret = query.exec("create table roster "
                         "(id integer primary key, "
                         "id_account integer, "
                         "name varchar(80), "
                         "jid varchar(80), "
                         "resource varchar(30), "
                         "presence varchar(12), "
                         "statusText varchar(255), "
                         "avatarPath varchar(255), "
                         "isChatInProgress int, "
                         "unreadMsg integer)");
    }
    emit finished();
    return ret;
}

bool DatabaseManager::setChatInProgress()
{
    QStringList params = parameters;
    bool ret = false;
    QSqlQuery query(db);
    QString queryStr;
    queryStr = "UPDATE roster SET isChatInProgress='";
    queryStr += params.at(2);
    queryStr += "' where jid='";
    queryStr += params.at(1);
    queryStr += "'";
    ret = query.exec(queryStr);
    emit finished();
    return ret;

}

bool DatabaseManager::mkMessagesTable()
{
    bool ret = false;
    if (db.isOpen()) {
        QSqlQuery query(db);
        ret = query.exec("create table messages "
                         "(id integer primary key, "
                         "id_account integer, "
                         "bareJid varchar(80), "
                         "msgText varchar(8096), "
                         "dateTime varchar(30), "
                         "isMine integer)");
    }
    emit finished();
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
    QSqlQuery query(db);
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
    emit finished();
    return ret;
}

bool DatabaseManager::insertMessage()
{
    QStringList params = parameters;
    bool ret = false;
    QSqlQuery query(db);
    ret = query.prepare("INSERT INTO messages (id_account, bareJid, msgText, dateTime, isMine) "
                        "VALUES (:acc, :jid, :msgText, :time, :mine)");
    if (ret) {
        query.bindValue(":acc", params.at(0).toInt());
        query.bindValue(":jid", params.at(1));
        query.bindValue(":msgText", params.at(2));
        query.bindValue(":time", params.at(3));
        query.bindValue(":mine", params.at(4).toInt());
        if (databaseOpen)
            ret = query.exec();
    }
    emit finished();
    return ret;
}


bool DatabaseManager::insertContact()
{
    QStringList params = parameters;
    bool ret = false;
    QSqlQuery query(db);
    ret = query.prepare("INSERT INTO roster (id_account, name, jid, resource, presence, statusText, avatarPath, isChatInProgress, unreadMsg) "
                        "VALUES (:acc, :name, :jid, :resource, :status, :statusText, :avatarPath, :isChatInProgress, :unreadMsg)");
    if (ret) {
        query.bindValue(":acc", params.at(0).toInt());
        query.bindValue(":jid", params.at(1));
        query.bindValue(":name", params.at(2));
        query.bindValue(":resource", "");
        query.bindValue(":status", params.at(3));
        query.bindValue(":statusText","");
        query.bindValue(":avatarPath",params.at(4));
        query.bindValue(":isChatInProgress",0);
        query.bindValue(":unreadMsg",0);
        if (databaseOpen) {
            ret = query.exec();
        }
    }
    emit finished();
    return ret;
}

bool DatabaseManager::updateContact()
{
    QStringList params = parameters;
    bool ret = false;
    QSqlQuery query(db);
    ret = query.prepare("UPDATE roster SET " + params.at(2) + "=:value where jid=:jid");
    query.bindValue(":value",params.at(3));
    query.bindValue(":jid",params.at(1));
    query.exec();
    emit finished();
    return ret;
}

bool DatabaseManager::updatePresence()
{
    QStringList params = parameters;
    bool ret = false;
    QSqlQuery query(db);
    ret = query.prepare("UPDATE roster SET presence=:presence, resource=:resource, statusText=:statusText where jid=:jid");
    query.bindValue(":presence",params.at(2));
    query.bindValue(":resource",params.at(3));
    query.bindValue(":statusText",params.at(4));
    query.bindValue(":jid",params.at(1));
    query.exec();
    emit finished();
    return ret;
}

bool DatabaseManager::deleteContact()
{
    QStringList params = parameters;
    bool ret = false;
    QSqlQuery query(db);
    if (databaseOpen)
        ret = query.exec("DELETE FROM roster WHERE jid='" + params.at(1) + "'");

    emit finished();
    return ret;
}

bool DatabaseManager::incUnreadMessage()
{
    QStringList params = parameters;
    bool ret = false;
    QSqlQuery query(db);
    if (databaseOpen) {
        query.exec("select unreadMsg from roster where jid = '" + params.at(1) + "'");
        SqlQueryModel unreadMsgCount;
        unreadMsgCount.setQuery(query);

        int nCount = unreadMsgCount.record(0).value("unreadMsg").toInt()+1;

        ret = query.exec("UPDATE roster SET unreadMsg='" + QString::number(nCount) + "' where jid='" + params.at(1) + "'" );
    }
    emit finished();
    return ret;
}
