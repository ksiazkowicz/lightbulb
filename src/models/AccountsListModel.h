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
    AccountsListModel( QObject *parent ) :ListModel( new AccountsItemModel, parent )
    {
    }

    Q_INVOKABLE void append( AccountsItemModel *item ) { this->appendRow(item); }
    Q_INVOKABLE void remove( int index ) { this->removeRow( index ); }
    Q_INVOKABLE int count() { return this->rowCount(); }
    Q_INVOKABLE void clearList() { this->clear(); }
};

#endif // ACCOUNTSLISTMODEL_H
