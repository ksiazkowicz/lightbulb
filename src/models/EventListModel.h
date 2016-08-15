/********************************************************************

src/EventsListModel.h
-- implements list model for events

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

#ifndef EVENTLISTMODEL_H
#define EVENTLISTMODEL_H

#include "listmodel.h"
#include "EventItemModel.h"

class EventListModel : public ListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ getCount NOTIFY countChanged)

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
      Filename,
      Filetype,
      Count
    };

    explicit EventListModel( QObject *parent = 0) :ListModel( new EventItemModel, parent ) { }

    void append(EventItemModel *item) { this->appendRow(item); }
    void countWasChanged() { emit countChanged(); }

    Q_INVOKABLE int getCount() { return this->rowCount(); }

    QVariant EventListModel::data(const QModelIndex & index, int role) const {
        if (index.row() < 0 || index.row() >= m_list.count())
            return QVariant();

        return ((EventItemModel*)m_list[index.row()])->data(role);
    }

protected:
    QHash<int, QByteArray> roleNames() const {
        QHash<int, QByteArray> names;
        names[Jid] = "bareJid";
        names[Text] = "text";
        names[Name] = "name";
        names[Type] = "type";
        names[Description] = "description";
        names[Account] = "accountID";
        names[Date] = "date";
        names[TransferJob] = "transferJob";
        names[Filename] = "filename";
        names[Filetype] = "filetype";
        names[Count] = "count";
        return names;
    }

signals:
    void countChanged();
};

#endif // EVENTLISTMODEL_H
