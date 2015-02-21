/********************************************************************

src/WidgetDataModel.h
-- implements list model for widget data

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

#ifndef WIDGETDATAMODEL_H
#define WIDGETDATAMODEL_H

#include "ListModel.h"
#include "WidgetItemModel.h"

class WidgetDataModel : public ListModel
{
    Q_OBJECT
public:
    WidgetDataModel( QObject *parent ) :ListModel( new WidgetItemModel, parent )
    {
    }

    Q_INVOKABLE void append( WidgetItemModel *item ) { this->appendRow(item); }
    Q_INVOKABLE void remove( int index ) { this->removeRow( index ); }
    Q_INVOKABLE int count() { return this->rowCount(); }
    Q_INVOKABLE void clearList() { this->clear(); }
};

#endif // WIDGETDATAMODEL_H
