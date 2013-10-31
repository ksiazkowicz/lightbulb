#ifndef DATABASEMANAGER_H
#define DATABASEMANAGER_H

#include <QObject>
#include <QSqlDatabase>
#include <QSqlError>
#include <QSqlQuery>
#include <QSqlQueryModel>
#include <QVariant>

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
    //~DatabaseManager();

    public:
        bool openDB();
        bool deleteDB();
        Q_INVOKABLE bool initDB();

        // create database structure
        bool mkAccTable();
        bool mkChatsTable();
        bool mkRosterTable();
        bool mkMessagesTable();
        bool insertMessage(int acc, QString bareJid, QString text, QString time, int mine);
        bool insertContact(int acc, QString bareJid, QString name, QString presence, QString avatarPath);

        bool checkIfChatInProgress( QString bareJid );
        bool setChatInProgress( QString bareJid, bool chat );

        bool insertAccount(QString jid, QString pass, QString resource, int manualHostPort, int enabled, QString host, int port);
        bool doGenericQuery(QString genericQuery);

        QSqlError lastError();
        QSqlDatabase db;
    };

#endif // DATABASEMANAGER_H
