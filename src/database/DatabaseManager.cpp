/********************************************************************

src/database/DatabaseManager.cpp
-- accesses and manages the SQLite database.

Copyright (c) 2013 Maciej Janiszewski

This file is part of Lightbulb.

Lightbulb is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

*********************************************************************/

#include "DatabaseManager.h"
#include <QFile>
#include <QSqlRecord>
#include <QSqlField>
#include <QDebug>
#include <QSqlDatabase>

DatabaseManager::DatabaseManager(QObject *parent) :
    QObject(parent)
{
    // threaded way to initialize the database
    if ( !QSqlDatabase::contains("Database")) {
        db = QSqlDatabase::addDatabase("QSQLITE","Database");
        db.setDatabaseName("com.lightbulb.db");
    } else {
        db = QSqlDatabase::database("Database");
        db.setDatabaseName("com.lightbulb.db");
    }

    if ( !db.isOpen() ) {
        if (!db.open()) {
            databaseOpen = false;
            return;
        }
    }
    databaseOpen = true;

    // set up some pragma parameters to get this thing working faster
    QSqlQuery("PRAGMA journal_mode = OFF",db);
    QSqlQuery("PRAGMA page_size = 16384",db);
    QSqlQuery("PRAGMA cache_size = 163840",db);
    QSqlQuery("PRAGMA temp_store = MEMORY",db);
    QSqlQuery("PRAGMA locking_mode = EXCLUSIVE",db);
    connect(this,SIGNAL(finished()), this, SLOT(getLastError()));
}

DatabaseManager::~DatabaseManager() {
}

QSqlError DatabaseManager::lastError() { return db.lastError(); }

void DatabaseManager::getLastError() { if (this->lastError().text() != " ") qDebug () << this->lastError(); }

bool DatabaseManager::deleteDB() {
    // Close database
    db.close();

    // Remove created database binary file
    return QFile::remove("com.lightbulb.db");
}

bool DatabaseManager::initDB() {
    mkRosterTable();
    mkMessagesTable();

    emit finished();
    return true;
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
                         "isChatInProgress int, "
                         "unreadMsg integer)");
    }
    emit finished();
    return ret;
}

bool DatabaseManager::setChatInProgress() {
    QStringList params = parameters;
    bool ret = false;
    QSqlQuery query(db);
    ret = query.exec("UPDATE roster SET isChatInProgress='" + params.at(2) +  "' where jid='" + params.at(1) + "' and id_account=" + params.at(0));
    emit finished();
    emit chatsChanged();
    return ret;
}

bool DatabaseManager::mkMessagesTable() {
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
    emit messagesChanged();
    return ret;
}


bool DatabaseManager::insertContact()
{
    QStringList params = parameters;
    bool ret = false;
    QSqlQuery query(db);
    ret = query.prepare("INSERT INTO roster (id_account, name, jid, resource, presence, statusText, isChatInProgress, unreadMsg) "
                        "VALUES (:acc, :name, :jid, :resource, :status, :statusText, :isChatInProgress, :unreadMsg)");
    if (ret) {
        query.bindValue(":acc", params.at(0).toInt());
        query.bindValue(":jid", params.at(1));
        query.bindValue(":name", params.at(2));
        query.bindValue(":resource", "");
        query.bindValue(":status", params.at(3));
        query.bindValue(":statusText","");
        query.bindValue(":isChatInProgress",0);
        query.bindValue(":unreadMsg",0);
        if (databaseOpen) {
            ret = query.exec();
        }
    }
    emit finished();
    emit rosterChanged();
    return ret;
}

bool DatabaseManager::updateContact()
{
    QStringList params = parameters;
    bool ret = false;
    QSqlQuery query(db);
    ret = query.prepare("UPDATE roster SET " + params.at(2) + "=:value where jid=:jid and id_account=:acc");
    query.bindValue(":acc", params.at(0).toInt());
    query.bindValue(":value",params.at(3));
    query.bindValue(":jid",params.at(1));
    query.exec();
    emit finished();
    emit rosterChanged();
    return ret;
}

bool DatabaseManager::updatePresence()
{
    QStringList params = parameters;
    bool ret = false;
    QSqlQuery query(db);
    ret = query.prepare("UPDATE roster SET presence=:presence, resource=:resource, statusText=:statusText where jid=:jid and id_account=:acc");
    query.bindValue(":acc", params.at(0).toInt());
    query.bindValue(":presence",params.at(2));
    query.bindValue(":resource",params.at(3));
    query.bindValue(":statusText",params.at(4));
    query.bindValue(":jid",params.at(1));
    query.exec();
    emit finished();
    emit rosterChanged();
    return ret;
}

bool DatabaseManager::clearPresence()
{
    QStringList params = parameters;
    bool ret = false;
    QSqlQuery query(db);
    ret = query.prepare("UPDATE roster SET presence=:presence, resource=:resource, statusText=:statusText where id_account=:acc");
    query.bindValue(":acc", params.at(0).toInt());
    query.bindValue(":presence",params.at(1));
    query.bindValue(":resource",params.at(2));
    query.bindValue(":statusText",params.at(3));
    query.exec();
    emit finished();
    emit rosterChanged();
    return ret;
}

bool DatabaseManager::deleteContact()
{
    QStringList params = parameters;
    bool ret = false;
    QSqlQuery query(db);
    if (databaseOpen)
        ret = query.exec("DELETE FROM roster WHERE jid='" + params.at(1) + "' and id_account =" + params.at(0));

    emit finished();
    emit rosterChanged();
    return ret;
}

bool DatabaseManager::incUnreadMessage()
{
    QStringList params = parameters;
    bool ret = false;
    QSqlQuery query(db);
    if (databaseOpen) {
        query.exec("select unreadMsg from roster where jid = '" + params.at(1) + "' and id_account =" + params.at(0));
        SqlQueryModel unreadMsgCount;
        unreadMsgCount.setQuery(query);

        int nCount = unreadMsgCount.record(0).value("unreadMsg").toInt()+1;

        ret = query.exec("UPDATE roster SET unreadMsg='" + QString::number(nCount) + "' where jid='" + params.at(1) + "' and id_account =" + params.at(0) );
    }
    emit finished();
    emit rosterChanged();
    return ret;
}

int DatabaseManager::getUnreadCount(int acc)
{
    QSqlQuery query(db);
    int count = 0;
    if (databaseOpen) {
        query.exec("select SUM(unreadMsg) from roster where id_account = " + QString::number(acc));
        SqlQueryModel unreadMsgCount;
        unreadMsgCount.setQuery(query);
        count = unreadMsgCount.record(0).value("SUM(unreadMsg)").toInt();
    }
    emit finished();
    return count;
}

/*******************************************************************************/

SqlQueryModel::SqlQueryModel(QObject *parent) :
    QSqlQueryModel(parent) { }

void SqlQueryModel::setQuery(const QString &query, const QSqlDatabase &db) {
    if (db.isOpen()) QSqlQueryModel::setQuery(query,db);
    generateRoleNames();
}

void SqlQueryModel::setQuery(const QSqlQuery & query) {
    QSqlQueryModel::setQuery(query);
    generateRoleNames();
}

void SqlQueryModel::generateRoleNames() {
    QHash<int, QByteArray> roleNames;
    for( int i = 0; i < record().count(); i++) roleNames[Qt::UserRole + i + 1] = record().fieldName(i).toAscii();
    setRoleNames(roleNames);
}

QVariant SqlQueryModel::data(const QModelIndex &index, int role) const {
    QVariant value = QSqlQueryModel::data(index, role);
    if(role < Qt::UserRole) value = QSqlQueryModel::data(index, role);
    else {
        int columnIdx = role - Qt::UserRole - 1;
        QModelIndex modelIndex = this->index(index.row(), columnIdx);
        value = QSqlQueryModel::data(modelIndex, Qt::DisplayRole);
    }
    return value;
}
