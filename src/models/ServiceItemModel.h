/********************************************************************

src/ServiceItemModel.h
-- implements item model for service discovery

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

#ifndef SERVICEITEMMODEL_H
#define SERVICEITEMMODEL_H

#include "QStandardItem"

class ServiceItemModel : public QStandardItem
{

public:
    enum userRoles {
        Name = Qt::UserRole+1,
        Jid,
        Features,
        Type
    };

public:
      ServiceItemModel();

      explicit ServiceItemModel( const QString &_nodeName,
                                             const QString &_nodeJid,
                                             const QString &_nodeFeatures,
                                             QObject *parent = 0 ) {
        setData(QVariant(_nodeName),Name);
        setData(QVariant(_nodeJid),Jid);
        setData(QVariant(_nodeFeatures),Features);
      }

      void set(const QString &data,userRoles role) {
        // if data is different, set it
        if (this->data(role).toString() != data)
          setData(QVariant(data),role);
        else return;
      }
};

#endif // SERVICEITEMMODEL_H
