/********************************************************************

src/WidgetItemModel.h
-- implements item model for widget data

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

#ifndef WIDGETITEMMODEL_H
#define WIDGETITEMMODEL_H

#include "listmodel.h"

class WidgetItemModel : public ListItem
{
    Q_OBJECT

public:
    enum Roles {
        roleName = Qt::UserRole+1,
        roleAccountIcon,
        rolePresence,
        roleUnreadMsg
      };

public:
      WidgetItemModel(QObject *parent = 0): ListItem(parent) {
      }
      explicit WidgetItemModel( const QString &_contactName,
                                       const QString &_contactAccountIcon,
                                       const int &_contactPresence,
                                       const int _contactUnreadMsg,
                                       QObject *parent = 0 ) : ListItem(parent),
          contactName(_contactName),
          contactAccountIcon(_contactAccountIcon),
          contactPresence(_contactPresence),
          contactUnreadMsg(_contactUnreadMsg)
      {
      }

      virtual QVariant data(int role) const {
        switch(role) {
        case roleName:
          return contactName;
        case roleAccountIcon:
          return contactAccountIcon;
        case rolePresence:
          return contactPresence;
        case roleUnreadMsg:
          return contactUnreadMsg;
        default:
          return QVariant();
        }
      }
      virtual QHash<int, QByteArray> roleNames() const {
          QHash<int, QByteArray> names;
          names[roleName] = "name";
          names[roleAccountIcon] = "icon";
          names[rolePresence] = "presence";
          names[roleUnreadMsg] = "unreadMsg";
          return names;
        }

      virtual QString id() const { return ""; }

      void setPresence( const int &_contactPresence ) {
          if(contactPresence != _contactPresence) {
            contactPresence = _contactPresence;
            emit dataChanged();
          }
      }

      void setContactName( const QString &_contactName ) {
          if(contactName != _contactName) {
            contactName = _contactName;
            emit dataChanged();
          }
      }

      void setAccountIcon( const QString &_contactAccountIcon ) {
          if(contactAccountIcon != _contactAccountIcon) {
            contactAccountIcon = _contactAccountIcon;
            emit dataChanged();
          }
      }

      void setUnreadMsg( const int _contactUnreadMsg )  {
          if(contactUnreadMsg != _contactUnreadMsg) {
            contactUnreadMsg = _contactUnreadMsg;
            emit dataChanged();
          }
      }

      inline int presence() { return contactPresence; }
      inline QString name() { return contactName; }
      inline QString accountIcon() { return contactAccountIcon; }
      inline int unreadMsg() { return contactUnreadMsg; }


    private:
      QString contactName;
      QString contactAccountIcon;
      int contactPresence;
      int contactUnreadMsg;
};

#endif // WIDGETITEMMODEL_H

