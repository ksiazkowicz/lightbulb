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

    // populates queryType list so I could use switch with QStrings. I like switches.
    queryType << "begin" << "end" << "insertMessage";
}

void DatabaseWorker::executeQuery(QStringList& query) {
    // Pass the parameters to DatabaseManager
    database->parameters.clear();
    for (int j=1;j<query.count();j++) database->parameters.append(query.at(j));

    // Used for debugging. I like debugging. Debugging is nice.

    qDebug() << "DatabaseWorker::executeQuery(): executing query with parameters: " << database->parameters;


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
        default:
            #ifdef QT_DEBUG
            qDebug() << "DatabaseWorker::executeQuery(): query " + query.at(0) + " not recognized.";
            #endif
            break;
    }
}

void DatabaseWorker::updateMessages(int m_accountId, QString bareJid, int page) {
    if (accountId != m_accountId) accountId = m_accountId;
    #ifdef QT_DEBUG
    qDebug() << "DatabaseWorker::updateMessages(): updating messages query model.";
    #endif
    int border = page*20;
    sqlMessages = new SqlQueryModel( 0 );
    if (bareJid != "") sqlMessages->setQuery("SELECT * FROM (SELECT * FROM messages WHERE bareJid='" + bareJid + "' and id_account="+QString::number(m_accountId) + " ORDER BY id DESC limit " + QString::number(border) + ") ORDER BY id ASC limit 20",database->db);
    emit sqlMessagesUpdated();
}
