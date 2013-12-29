/********************************************************************

src/ChatsItemModel.h
-- implements item model for chats

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

#ifndef CHATSITEMMODEL_H
#define CHATSITEMMODEL_H
#include "listmodel.h"

class ChatsItemModel : public ListItem
{
    Q_OBJECT

public:
    enum Roles {
        roleAccount = Qt::UserRole+1,
        roleName,
        roleJid
      };

public:
      ChatsItemModel(QObject *parent = 0): ListItem(parent) {
          contactName = "";
          contactJid = "";
          contactAccountID = 0;
      }
      explicit ChatsItemModel( const QString &_contactName,
                                       const QString &_contactJid,
                                       const int _accountID,
                                       QObject *parent = 0 ) : ListItem(parent),
          contactAccountID(_accountID),
          contactName(_contactName),
          contactJid(_contactJid)
      {
      }

      virtual QVariant data(int role) const {
        switch(role) {
        case roleAccount:
            return accountID();
        case roleName:
          return name();
        case roleJid:
          return jid();
        default:
          return QVariant();
        }
      }
      virtual QHash<int, QByteArray> roleNames() const {
          QHash<int, QByteArray> names;
          names[roleAccount] = "account";
          names[roleName] = "name";
          names[roleJid] = "jid";
          return names;
      }

      virtual QString id() const { return contactJid; }

      void setAccountID(const int &_accountID) {
        if (contactAccountID != _accountID) {
            contactAccountID = _accountID;
            emit dataChanged();
          }
      }

      void setContactName( const QString &_contactName ) {
          if(contactName != _contactName) {
            contactName = _contactName;
            emit dataChanged();
          }
      }

      void setJid( const QString &_contactJid ) {
          if(contactJid != _contactJid) {
            contactJid = _contactJid;
            emit dataChanged();
          }
      }

      inline int accountID() const { return contactAccountID; }
      inline QString name() const { return contactName; }
      inline QString jid() const { return contactJid; }

      void copy( const ChatsItemModel* item ) {
          contactName = item->name();
          contactJid = item->jid();
          contactAccountID = item->accountID();
      }

    private:
      int contactAccountID;
      QString contactName;
      QString contactJid;
};

#endif // CHATSITEMMODEL_H