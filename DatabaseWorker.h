#ifndef DATABASEWORKER_H
#define DATABASEWORKER_H

#include <QObject>
#include <QStringList>
#include "DatabaseManager.h"

class DatabaseWorker : public QObject
{
    Q_OBJECT
public:
    explicit DatabaseWorker(QObject *parent = 0);
    
signals:
    void finished();
    void messagesChanged();
    void rosterChanged();
    
public slots:
    void executeQuery(QStringList* query);

private:
    DatabaseManager* database;

    
};

#endif // DATABASEWORKER_H
