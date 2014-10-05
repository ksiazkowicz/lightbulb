/********************************************************************

src/ServiceListModel.h
-- implements list model for Service

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

#ifndef SERVICELISTMODEL_H
#define SERVICELISTMODEL_H

#include "serviceitemmodel.h"
#include "QModelIndexList"
#include "QStandardItemModel"

class ServiceListModel : public QStandardItemModel
{
  Q_OBJECT

public:
  explicit ServiceListModel( QObject *parent = 0) :QStandardItemModel(parent) {
  #if QT_VERSION >= 0x050000
    }
    QHash<int,QByteArray> roleNames() {
  #endif

    QHash<int, QByteArray> names;
    names[ServiceItemModel::Name] = "name";
    names[ServiceItemModel::Jid] = "jid";
    names[ServiceItemModel::Features] = "features";
    names[ServiceItemModel::Type] = "type";

    #if QT_VERSION < 0x050000
    this->setRoleNames(names);
    #else
    return names;
    #endif
  }

  Q_INVOKABLE void append( ServiceItemModel *item ) { this->appendRow((QStandardItem*)item); }
  Q_INVOKABLE int count() { return this->rowCount(); }

  ServiceItemModel* find(const QString &id, int &row) const {
    ServiceItemModel* result;
    for (row=0; row < this->rowCount(); row++) {
        result = (ServiceItemModel*)this->itemFromIndex(this->index(row,0));
        if (result->data(ServiceItemModel::Jid).toString() == id)
          return result;
      }
    row = -1;
    return 0;
  }

  ServiceItemModel* find(const QString &id) const {
    int row;
    return this->find(id,row);
  }

  bool checkIfExists(const QString &id) const { return this->find(id) != NULL; }

signals:
  void nodesChanged();

};

#endif // SERVICELISTMODEL_H
