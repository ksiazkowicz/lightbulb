#include "DatabaseWorker.h"
#include "DatabaseManager.h"
#include <QDebug>

DatabaseWorker::DatabaseWorker(QObject *parent) :
    QObject(parent)
{
    database = new DatabaseManager(this);
    connect(database,SIGNAL(finished()), this, SIGNAL(finished()));
    connect(database,SIGNAL(messagesChanged()), this, SIGNAL(messagesChanged()));
    connect(database,SIGNAL(rosterChanged()), this, SIGNAL(rosterChanged()));
}

void DatabaseWorker::executeQuery(QStringList* query) {
    QStringList parameters;
    for (int j=1;j<query->count();j++) parameters.append(query->at(j));
    database->parameters.clear();
    database->parameters = parameters;
    if (query->at(0) == "insertMessage") database->insertMessage();
    if (query->at(0) == "insertContact") database->insertContact();
    if (query->at(0) == "deleteContact") database->deleteContact();
    if (query->at(0) == "updateContact") database->updateContact();
    if (query->at(0) == "updatePresence") database->updatePresence();
    if (query->at(0) == "incUnreadMessage") database->incUnreadMessage();
    if (query->at(0) == "setChatInProgress") database->setChatInProgress();
    if (query->at(0) == "clearPresence") database->clearPresence();
}
