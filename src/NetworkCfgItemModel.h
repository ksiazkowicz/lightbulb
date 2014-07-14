/********************************************************************

src/models/NetworkCfgItemModel.h
-- implements item model for network configurations

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

#ifndef NETWORKCFGITEMMODEL_H
#define NETWORKCFGITEMMODEL_H

class NetworkCfgItemModel : public ListItem
{
    Q_OBJECT

public:
    enum Roles {
        roleID = Qt::UserRole+1,
        roleName,
        roleBearer,
        roleType
      };

public:
      NetworkCfgItemModel(QObject *parent = 0): ListItem(parent) {
          roleID = 0;
          roleName = "";
          roleBearerType = "";
          roleType = 0;
      }
      explicit NetworkCfgItemModel( const QString &_cfgName,
                                       const QString &_cfgBearerType,
                                       const int _cfgType,
                                       const int _cfgID,
                                       QObject *parent = 0 ) : ListItem(parent),
          cfgID(_cfgID),
          cfgName(_cfgName),
          cfgBearerType(_cfgBearerType),
          cfgType(_cfgType)
      {
      }

      virtual QVariant data(int role) const {
        switch(role) {
        case roleID:
            return cfgID;
        case roleName:
          return cfgName;
        case roleBearer:
          return cfgBearerType();
        case roleType:
          return cfgType;
        default:
          return QVariant();
        }
      }
      virtual QHash<int, QByteArray> roleNames() const {
          QHash<int, QByteArray> names;
          names[roleID] = "id";
          names[roleName] = "name";
          names[roleType] = "type";
          names[roleBearer] = "bearer";
          return names;
      }

      virtual QString id() const { return cfgId; }

    private:
      QString cfgName;
      QString cfgBearerType;
      QString cfgType;
      QString cfgID;
};

#endif // NETWORKCFGITEMMODEL_H
