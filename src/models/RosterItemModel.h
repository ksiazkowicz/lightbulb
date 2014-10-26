/********************************************************************

src/RosterItemModel.h
-- implements item model for roster

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

#ifndef ROSTERITEMMODEL_H
#define ROSTERITEMMODEL_H

#include "QStandardItem"
#include <QDebug>

class RosterItemModel : public QStandardItem
{

public:
    enum userRoles {
        Name = Qt::UserRole+1,
        Jid,
        Resource,
        Presence,
        StatusText,
        Avatar,
        AccountId,
        ItemId,
        SortData,
        IsFavorite
      };

public:
      RosterItemModel();

      explicit RosterItemModel( const QString &_contactName,
                                             const QString &_contactJid,
                                             const QString &_contactResource,
                                             const QString &_contactPresence,
                                             const QString &_contactStatusText,
                                             const QString &_contactAccountID,
                                             QObject *parent = 0 ) {
        setData(QVariant(_contactName),Name);
        setData(QVariant(_contactJid),Jid);
        setData(QVariant(_contactResource),Resource);
        setData(QVariant(_contactPresence),Presence);
        setData(QVariant(_contactStatusText),StatusText);
        setData(QVariant(_contactAccountID),AccountId);
        setData(QVariant(QString(_contactAccountID + ";" + _contactJid)),ItemId);
        updateSortData();
      }

      void set(const QString &data,userRoles role) {
        // if data is different, set it
        if (this->data(role).toString() != data)
          setData(QVariant(data),role);
        else return;

        // if changed data which affects sort data
        if (role == Name || role == Jid || role == Presence || role == IsFavorite)
          updateSortData();
      }

      void updateSortData() {
        QString newSortData;

        // append 0 if contact is favorite
        if (data(IsFavorite).toBool() == true)
          newSortData += "0";
        else newSortData += "1";

        // append presence priority, name and jid
        newSortData += QString::number(presencePriority(data(Presence).toString()));
        newSortData += data(Name).toString();
        newSortData += data(Jid).toString();

        setData(QVariant(newSortData),SortData);
      }

      int presencePriority(QString presence) const {
        if (presence == "qrc:/presence/chatty") return 0;
        if (presence == "qrc:/presence/online") return 1;
        if (presence == "qrc:/presence/away") return 2;
        if (presence == "qrc:/presence/xa") return 3;
        if (presence == "qrc:/presence/busy") return 4;
        if (presence == "qrc:/presence/offline") return 5;
      }
};

#endif // ROSTERITEMMODEL_H

