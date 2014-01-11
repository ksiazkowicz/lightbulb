/********************************************************************

src/MsgListModel.h
-- implements list model for messages

Copyright (c) 2014 Maciej Janiszewski

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


#ifndef MSGLISTMODEL_H
#define MSGLISTMODEL_H

#include "listmodel.h"
#include "msgitemmodel.h"

class MsgListModel : public ListModel
{
    Q_OBJECT
    
public:
    explicit MsgListModel( QObject *parent = 0) :ListModel( new MsgItemModel, parent ) {}

    Q_INVOKABLE void append( MsgItemModel *item ) { this->appendRow( item ); }
    Q_INVOKABLE void remove( int index ) { this->removeRow( index ); }
    Q_INVOKABLE int count() { return this->rowCount(); }

    Q_INVOKABLE void clearList() { this->clear(); }

signals:
    void messagesChanged();
};

#endif // MSGLISTMODEL_H

