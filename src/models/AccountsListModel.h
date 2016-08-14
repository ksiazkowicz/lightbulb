/********************************************************************

src/AccountsListModel.h
-- implements list model for accounts

Copyright (c) 2012 Anatoliy Kozlov,
                   Maciej Janiszewski

This file is part of Lightbulb and was derived from MeegIM.

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

#ifndef ACCOUNTSLISTMODEL_H
#define ACCOUNTSLISTMODEL_H

#include "ListModel.h"
#include "AccountsItemModel.h"

class AccountsListModel : public ListModel
{
    Q_OBJECT
public:
    enum Roles {
        accGRID = Qt::UserRole+1, //Globally Recognizable ID (sounds awesome :D)
        accName,
        accIcon,
        accJid,
        accPasswd,
        accResource,
        accHost,
        accPort,
        accManualHostPort
      };

    AccountsListModel( QObject *parent ) :ListModel( new AccountsItemModel, parent )
    {
    }

    Q_INVOKABLE void append( AccountsItemModel *item ) { this->appendRow(item); }
    Q_INVOKABLE void remove( int index ) { this->removeRow( index ); }
    Q_INVOKABLE int count() { return this->rowCount(); }
    Q_INVOKABLE void clearList() { this->clear(); }

    QVariant AccountsListModel::data(const QModelIndex & index, int role) const {
        if (index.row() < 0 || index.row() >= m_list.count())
            return QVariant();

        return ((AccountsItemModel*)m_list[index.row()])->data(role);
    }

protected:
    QHash<int, QByteArray> roleNames() const {
        QHash<int, QByteArray> names;
        names[accGRID] = "accGRID";
        names[accName] = "accName";
        names[accIcon] = "accIcon";
        names[accJid] = "accJid";
        names[accPasswd] = "accPasswd";
        names[accResource] = "accResource";
        names[accHost] = "accHost";
        names[accPort] = "accPort";
        names[accManualHostPort] = "accManualHostPort";
        return names;
      }
};

#endif // ACCOUNTSLISTMODEL_H
