/********************************************************************

src/EventItemModel.h
-- implements item model for events

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

#ifndef EVENTITEMMODEL_H
#define EVENTITEMMODEL_H

#include "ListModel.h"
#include <QList>
#include <QVariant>
#include <QDebug>

class EventItemModel : public ListItem
{
    Q_OBJECT

public:
    enum Roles {
      Jid = Qt::UserRole+1,
      Text,
      Name,
      Type,
      Description,
      Account,
      Date,
      TransferJob,
      State,
      Filename,
      Filetype,
      Progress,
      Count
    };

    enum EventTypes {
      UnreadMessage = 32, //i like that number, so what?
      ConnectionState,
      SubscriptionRequest,
      MUCinvite,
      AttentionRequest,
      FavUserStatusChange,
      AppUpdate,
      ConnectionError,
      IncomingTransfer,
      OutcomingTransfer
    };

public:
      EventItemModel(QObject *parent = 0): ListItem(parent) {
        itemData = new QList<QVariant>();
        for (int i=0; i<13;i++)
          itemData->append(QVariant());
      }

      virtual QVariant data(int role) const { return this->getData((Roles)role);  }
      virtual QHash<int, QByteArray> roleNames() const {
          QHash<int, QByteArray> names;
          names[Jid] = "bareJid";
          names[Text] = "text";
          names[Name] = "name";
          names[Type] = "type";
          names[Description] = "description";
          names[Account] = "accountID";
          names[Date] = "date";
          names[TransferJob] = "transferJob";
          names[State] = "state";
          names[Filename] = "filename";
          names[Filetype] = "filetype";
          names[Progress] = "progress";
          names[Count] = "count";
          return names;
        }

      virtual QString id() const {
        if (getData(Type).toInt() == (int)IncomingTransfer || getData(Type).toInt() == (int)OutcomingTransfer)
          return getData(Jid).toString() + ";" + getData(Account).toString() + ";" + getData(Type).toString() + ";" + getData(TransferJob).toString();
        else
          return getData(Jid).toString() + ";" + getData(Account).toString() + ";" + getData(Type).toString();
      }

      void setData(QVariant data,Roles id) {
        itemData->replace((int)id-Jid,data);
        emit dataChanged();
      }
      inline QVariant getData(Roles id) const { return itemData->value((int)id-Jid); }

    private:
      QList<QVariant> *itemData;
};

#endif // EVENTITEMMODEL_H
