#ifndef DATABASEMANAGER_H
#define DATABASEMANAGER_H

#include <QObject>
#include <QSqlDatabase>
#include <QSqlError>
#include <QSqlQuery>
#include <QSqlQueryModel>
#include <QVariant>
#include <QStringList>

class SqlQueryModel : public QSqlQueryModel
{
    Q_OBJECT

    void generateRoleNames();

public:
    explicit SqlQueryModel(QObject *parent = 0);

    void setQuery(const QString &query, const QSqlDatabase &db = QSqlDatabase());
    void setQuery(const QSqlQuery &query);
    QVariant data(const QModelIndex &index, int role) const;

signals:

public slots:

};

class DatabaseManager: public QObject
{
    Q_OBJECT

public:
    DatabaseManager(QObject *parent = 0);
    ~DatabaseManager();

    signals:
        void finished();

    public:
        bool deleteDB();

        // create database structure
        bool mkAccTable();
        bool mkRosterTable();
        bool mkMessagesTable();
        QSqlError lastError();
        QSqlDatabase db;
        QStringList parameters;
        bool databaseOpen;
    public slots:
        Q_INVOKABLE bool initDB();
        bool insertMessage();

        bool insertContact();
        bool deleteContact();
        bool setChatInProgress();
        bool updateContact();
        bool updatePresence();
        bool incUnreadMessage();
        int getUnreadCount();

        void getLastError();

        bool insertAccount(QString jid, QString pass, QString resource, int manualHostPort, int enabled, QString host, int port);

    };

#endif // DATABASEMANAGER_H
