#include "DatabaseManager.h"
#include <QFile>

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
    // If opening database has failed user can ask
    // error description by QSqlError::text()
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
    mkChatsTable();

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
                         "manualHostPort integer, "
                         "unreadMsg integer)");
    }
    return ret;
}

bool DatabaseManager::mkChatsTable()
{
    bool ret = false;
    if (db.isOpen()) {
        QSqlQuery query;
        ret = query.exec("create table chats "
                         "(id integer primary key, "
                         "id_account integer, "
                         "id_contact integer)");
    }
    return ret;
}

bool DatabaseManager::mkMessagesTable(QString bareJid)
{
    bool ret = false;
    if (db.isOpen()) {
        QSqlQuery query;
        ret = query.exec("create table messages_" + bareJid + ""
                         "(id integer primary key, "
                         "id_account integer, "
                         "id_contact integer, "
                         "resource varchar(30), "
                         "dateTime varchar(30), "
                         "isDelivered integer, "
                         "isMine integer, "
                         "type integer)");
    }
    return ret;
}


