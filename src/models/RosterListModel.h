/********************************************************************

src/RosterListModel.h
-- implements list model for roster

Copyright (c) 2012 Anatoliy Kozlov

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


#ifndef ROSTERLISTMODEL_H
#define ROSTERLISTMODEL_H

#include "listmodel.h"
#include "rosteritemmodel.h"

class RosterListModel : public ListModel
{
    Q_OBJECT
    
public:
    explicit RosterListModel( QObject *parent = 0) :ListModel( new RosterItemModel, parent ) {}

    Q_INVOKABLE void append( RosterItemModel *item ) { this->appendRow( item ); }
    Q_INVOKABLE void remove( int index ) { this->removeRow( index ); }
    Q_INVOKABLE int count() { return this->rowCount(); }

    Q_INVOKABLE void clearList() { this->clear(); }
    void cleanList() {
      if (this->rowCount() == 0)
        return;

      RosterItemModel* item;
      for (int i=0; i<this->rowCount();i++) {
          item = (RosterItemModel*)this->getElementByID(i);
          if (item->unreadMsg() == 0) this->remove(i);
          item = 0;
        }
      delete item;
    }

signals:
    void rosterChanged();
};

#endif // ROSTERLISTMODEL_H

