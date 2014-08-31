/********************************************************************

src/RosterListModel.h
-- implements list model for roster

Copyright (c) 2014 Maciej Janiszewski

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


#ifndef ROSTERLISTMODEL_H
#define ROSTERLISTMODEL_H

#include "rosteritemmodel.h"
#include "QModelIndexList"
#include "QStandardItemModel"
#include <QDebug>

class RosterListModel : public QStandardItemModel
{
  Q_OBJECT

public:
  explicit RosterListModel( QObject *parent = 0) :QStandardItemModel(parent) {
    QHash<int, QByteArray> names;
    names[RosterItemModel::Name] = "name";
    names[RosterItemModel::Jid] = "jid";
    names[RosterItemModel::Resource] = "resource";
    names[RosterItemModel::Presence] = "presence";
    names[RosterItemModel::StatusText] = "statusText";
    names[RosterItemModel::Avatar] = "avatar";
    names[RosterItemModel::AccountId] = "accountId";
    names[RosterItemModel::ItemId] = "itemId";

    this->setRoleNames(names);
  }

  Q_INVOKABLE void append( RosterItemModel *item ) { qDebug() << this->columnCount(); this->appendRow((QStandardItem*)item); }
  Q_INVOKABLE int count() { return this->rowCount(); }

  RosterItemModel* find(const QString &id) const {
    int row;
    return this->find(id,row);
  }

  RosterItemModel* find(const QString &id, int &row) const {
    RosterItemModel* result;
    for (int row=0; row < this->rowCount(); row++) {
        result = (RosterItemModel*)this->itemFromIndex(this->index(row,0));
        if (result->data(RosterItemModel::ItemId).toString() == id)
          return result;
      }
    row = -1;
    return 0;
  }

  bool checkIfExists(const QString &id) const {
    return this->find(id) != NULL;
  }


signals:
  void rosterChanged();

};

#endif // ROSTERLISTMODEL_H

