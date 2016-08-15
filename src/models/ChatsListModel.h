/********************************************************************

src/ChatsListModel.h
-- implements list model for chats

Copyright (c) 2013 Maciej Janiszewski

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

#ifndef CHATSLISTMODEL_H
#define CHATSLISTMODEL_H

#include "ListModel.h"
#include "ChatsItemModel.h"

class ChatsListModel : public ListModel
{
    Q_OBJECT

public:
    enum Roles {
        roleAccount = Qt::UserRole+1,
        roleName,
        roleResource,
        roleJid,
        roleMsg,
        roleType,
        roleUnreadMsg
      };

    explicit ChatsListModel( QObject *parent = 0) :ListModel( new ChatsItemModel, parent ) {}

    Q_INVOKABLE void append( ChatsItemModel *item ) { this->appendRow( item ); }
    Q_INVOKABLE void remove( int index ) { this->removeRow( index ); }
    Q_INVOKABLE int count() { return this->rowCount(); }

    QVariant ChatsListModel::data(const QModelIndex & index, int role) const {
        if (index.row() < 0 || index.row() >= m_list.count())
            return QVariant();

        return ((ChatsItemModel*)m_list[index.row()])->data(role);
    }

protected:
    QHash<int, QByteArray> roleNames() const {
        QHash<int, QByteArray> names;
        names[roleAccount] = "account";
        names[roleName] = "name";
        names[roleResource] = "resource";
        names[roleJid] = "jid";
        names[roleMsg] = "chatMsg";
        names[roleType] = "chatType";
        names[roleUnreadMsg] = "unreadMsg";
        return names;
    }

signals:
    void chatsChanged();
};

#endif // CHATSLISTMODEL_H
