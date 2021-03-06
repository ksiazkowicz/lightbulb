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
#include <QtCore/QModelIndexList>
#include <QtGui/QStandardItemModel>
#include <QDebug>

class RosterListModel : public QStandardItemModel
{
  Q_OBJECT

public:
  explicit RosterListModel( QObject *parent = 0) :QStandardItemModel(parent) {
  #if QT_VERSION >= 0x050000
    }
    QHash<int,QByteArray> roleNames() {
  #endif

    QHash<int, QByteArray> names;
    names[RosterItemModel::Name] = "name";
    names[RosterItemModel::Jid] = "jid";
    names[RosterItemModel::Resource] = "resource";
    names[RosterItemModel::Presence] = "presence";
    names[RosterItemModel::StatusText] = "statusText";
    names[RosterItemModel::Avatar] = "avatar";
    names[RosterItemModel::AccountId] = "accountId";
    names[RosterItemModel::ItemId] = "itemId";
    names[RosterItemModel::IsFavorite] = "favorite";
    names[RosterItemModel::Groups] = "groups";
    names[RosterItemModel::SubscriptionType] = "subscriptionType";

    #if QT_VERSION < 0x050000
    this->setRoleNames(names);
    #else
    return names;
    #endif
  }

  Q_INVOKABLE void append( RosterItemModel *item ) { item->groupContacts = contactGrouping; this->appendRow((QStandardItem*)item); }
  Q_INVOKABLE int count() { return this->rowCount(); }

  RosterItemModel* find(const QString &id) const {
    int row;
    return this->find(id,row);
  }

  RosterItemModel* find(const QString &id, int &row) const {
    RosterItemModel* result;
    for (row=0; row < this->rowCount(); row++) {
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

  void setContactGrouping(bool state) {
    // set contact grouping to state
    contactGrouping = state;

    // update every object with this data
    RosterItemModel* tmp;
    for (int row=0; row < this->rowCount(); row++) {
        tmp = (RosterItemModel*)this->itemFromIndex(this->index(row,0));
        if (tmp) {
          tmp->groupContacts = state;
          tmp->updateSortData();
        }
      }
  }

  bool contactGrouping;


signals:
  void rosterChanged();

};

#endif // ROSTERLISTMODEL_H

