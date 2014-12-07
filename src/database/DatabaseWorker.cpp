/********************************************************************

src/database/DatabaseWorker.cpp
-- class designed to enable access DatabaseManager in a threaded way

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

#include "DatabaseWorker.h"
#include "DatabaseManager.h"

#include <QDebug>

#include <QSqlQuery>
#include <QSqlRecord>
#include <QtCore/qmath.h>

DatabaseWorker::DatabaseWorker(QObject *parent) :
    QObject(parent)
{
    // initialize DatabaseManager
    database = new DatabaseManager(this);
    database->initDB();

    // make stuff threaded, because why not?
    connect(database,SIGNAL(finished()), this, SIGNAL(finished()));
    connect(database,SIGNAL(messagesChanged()), this, SIGNAL(messagesChanged()));

    //initialize SqlQueryModel
    sqlMessages = new SqlQueryModel( 0 );
    sqlRoster = new SqlQueryModel( 0 );

    // populates queryType list so I could use switch with QStrings. I like switches.
    queryType << "begin" << "end" << "insertMessage" << "insertContact" << "deleteContact" <<
                 "updateContact" << "removeContactCache";
}

void DatabaseWorker::executeQuery(QStringList& query) {
    // Pass the parameters to DatabaseManager
    database->parameters.clear();
    for (int j=1;j<query.count();j++) {
        QString parameter = query.at(j);
        database->parameters.append(parameter.replace("'","''"));
    }

    // Used for debugging. I like debugging. Debugging is nice.
    qDebug() << "DatabaseWorker::executeQuery(): executing query with parameters:" << database->parameters;


    // Check the type of query and execute
    switch (queryType.indexOf(query.at(0))) {
        case 0:
            qDebug() << "DatabaseWorker::executeQuery(): beginning transaction";
            QSqlQuery("begin",database->db);
            break;
        case 1:
            qDebug() << "DatabaseWorker::executeQuery(): ending transaction";
            QSqlQuery("end",database->db);
            break;
        case 2: database->insertMessage(); break;
        case 3: database->insertContact(); break;
        case 4: database->deleteContact(); break;
        case 5: database->updateContact(); break;
        case 6: database->removeContactCache(); break;
        default:
            #ifdef QT_DEBUG
            qDebug() << "DatabaseWorker::executeQuery(): query " + query.at(0) + " not recognized.";
            #endif
            break;
    }
}

void DatabaseWorker::updateMessages(QString m_accountId, QString bareJid, int page) {
    if (accountId != m_accountId) accountId = m_accountId;
    #ifdef QT_DEBUG
    qDebug().nospace() << "DatabaseWorker::updateMessages(): updating messages query model for " << m_accountId << ":"<< qPrintable(bareJid) << " from page "<<page;
    #endif
    int border = page*20;
    sqlMessages = new SqlQueryModel( 0 );
    if (bareJid != "") sqlMessages->setQuery("SELECT * FROM (SELECT * FROM messages WHERE bareJid='" + bareJid + "' and id_account='"+m_accountId + "' ORDER BY id DESC limit " + QString::number(border) + ") ORDER BY id ASC limit 20",database->db);
    emit sqlMessagesUpdated();
}

void DatabaseWorker::updateRoster(QString m_accountId) {
    if (accountId != m_accountId) accountId = m_accountId;
    qDebug() << "DatabaseWorker::updateRoster(): updating contact list.";
    if (m_accountId.isEmpty()) {
        sqlRoster->setQuery("select * from roster", database->db);
    } else {
        sqlRoster->setQuery("select * from roster where id_account="+m_accountId, database->db);
    }
    emit sqlRosterUpdated();
}

int DatabaseWorker::getPageCount(QString m_accountId, QString bareJid) {
  SqlQueryModel getMeSomeNumbersCauseNumbersAreAwesome;
  if (bareJid != "") getMeSomeNumbersCauseNumbersAreAwesome.setQuery("SELECT id FROM messages WHERE bareJid='" + bareJid + "' and id_account='"+m_accountId+"'",database->db);
  double pagesCount = getMeSomeNumbersCauseNumbersAreAwesome.rowCount()/20;
  return qCeil(pagesCount);
}

QString DatabaseWorker::generateLog(QString m_accountId, QString bareJid, QString contactName, int beginID, int endID) {
  qDebug() << "DatabaseWorker::generateLog("<<m_accountId<<","<<bareJid<<","<<beginID<<","<<endID<<") called";
  sqlMessages = new SqlQueryModel( 0 );
  if (bareJid != "")
    sqlMessages->setQuery("SELECT * FROM messages WHERE bareJid='"
                          + bareJid + "' and id_account='"+m_accountId
                          + "' and id>=" + QString::number(beginID) +" and id<="+ QString::number(endID)
                          + " ORDER BY id ASC",database->db);

  int rowCount = sqlMessages->rowCount();

  QString log;

  for (int i=0; i<rowCount; i++) {
      QString tempStr;
      if (sqlMessages->data(sqlMessages->index(i,5),Qt::DisplayRole).toInt() == 0)
        tempStr = contactName;
      else tempStr = "Me";

      tempStr += " " + sqlMessages->data(sqlMessages->index(i,4),Qt::DisplayRole).toString();
      tempStr += ": " + sqlMessages->data(sqlMessages->index(i,3),Qt::DisplayRole).toString() + "\n";

      log += tempStr;
    }

  return log;
}
