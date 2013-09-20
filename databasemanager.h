#ifndef DATABASEMANAGER_H
#define DATABASEMANAGER_H

#include <QObject>
#include <QSqlDatabase>
#include <QSqlError>
#include <QSqlQuery>
#include <QVariant>

class DatabaseManager: public QObject
{
    Q_OBJECT

public:
    DatabaseManager(QObject *parent = 0);
    //~DatabaseManager();

    public:
        bool openDB();
        bool deleteDB();
        Q_INVOKABLE bool initDB();

        // create database structure
        bool mkAccTable();
        bool mkChatsTable();
        bool mkRosterTable();
        bool mkMessagesTable(QString bareJid);

        QSqlError lastError();
    private:
        QSqlDatabase db;
    };

#endif // DATABASEMANAGER_H
