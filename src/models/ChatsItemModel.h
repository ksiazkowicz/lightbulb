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
        roleResource,
        roleJid,
        roleMsg,
        roleType,
        roleUnreadMsg
      };

public:
      ChatsItemModel(QObject *parent = 0): ListItem(parent) {
          contactName = "";
          contactResource = "";
          contactJid = "";
          contactAccountID = "";
          chatMsg = "";
          chatType = 0;
          chatUnreadMsg = 0;
      }
      explicit ChatsItemModel( const QString &_contactName,
                                       const QString &_contactJid,
                                       const QString &_contactResource,
                                       const QString _accountID,
                                       const int _chatType,
                                       QObject *parent = 0 ) : ListItem(parent),
          contactAccountID(_accountID),
          contactName(_contactName),
          contactJid(_contactJid),
          contactResource(_contactResource),
          chatType(_chatType),
          chatUnreadMsg(0)
      {
      }

      virtual QVariant data(int role) const {
        switch(role) {
        case roleAccount:
            return accountID();
        case roleName:
          return name();
        case roleResource:
          return resource();
        case roleJid:
          return jid();
        case roleMsg:
          return msg();
        case roleType:
          return type();
        case roleUnreadMsg:
          return unread();
        default:
          return QVariant();
        }
      }
      virtual QHash<int, QByteArray> roleNames() const {
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

      virtual QString id() const { return QString(contactAccountID + ";" + contactJid); }

      void setAccountID(const QString &_accountID) {
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

      void setResource( const QString &_contactResource ) {
          if(contactResource != _contactResource) {
            contactResource = _contactResource;
            emit dataChanged();
          }
      }

      void setJid( const QString &_contactJid ) {
          if(contactJid != _contactJid) {
            contactJid = _contactJid;
            emit dataChanged();
          }
      }

      void setUnreadMsg( const int _chatUnreadMsg ) {
          if(chatUnreadMsg != _chatUnreadMsg) {
            chatUnreadMsg = _chatUnreadMsg;
            emit dataChanged();
          }
      }

      void setChatMsg(const QString &_chatMsg) { chatMsg = _chatMsg; }
      void setChatType(const int &_chatType) { chatType = _chatType; }

      inline QString accountID() const { return contactAccountID; }
      inline QString name() const { return contactName; }
      inline QString resource() const { return contactResource; }
      inline QString jid() const { return contactJid; }
      inline QString msg() const { return chatMsg; }
      inline int type() const { return chatType; }
      inline int unread() const { return chatUnreadMsg; }

    private:
      QString contactAccountID;
      QString contactName;
      QString contactResource;
      QString contactJid;
      QString chatMsg;
      int chatType;
      int chatUnreadMsg;
};

#endif // CHATSITEMMODEL_H
