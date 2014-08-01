/********************************************************************

src/MsgItemModel.h
-- implements item model for messages

Copyright (c) 2014 Maciej Janiszewski

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

#ifndef MSGITEMMODEL_H
#define MSGITEMMODEL_H

#include "listmodel.h"

class MsgItemModel : public ListItem
{
    Q_OBJECT

public:
    enum Roles {
        roleMsgText = Qt::UserRole+1,
        roleDateTime,
        roleIsMine,
        roleMsgType,
        roleMsgResource
      };

public:
      MsgItemModel(QObject *parent = 0): ListItem(parent) {
          msgText= "";
          dateTime = "";
          isMine = 0;
          msgType = 0;
          msgResource = "";
      }
      explicit MsgItemModel( const QString &_msgText,
                                       const QString &_dateTime,
                                       const int _isMine,
                                       const int _msgType,
                                       const QString &_msgResource,
                                       QObject *parent = 0 ) : ListItem(parent),
          msgText(_msgText),
          dateTime(_dateTime),
          isMine(_isMine),
          msgType(_msgType),
          msgResource(_msgResource)
      {
      }

      virtual QVariant data(int role) const {
        switch(role) {
        case roleMsgText:
          return gMsgText();
        case roleDateTime:
          return gDateTime();
        case roleIsMine:
          return gIsMine();
        case roleMsgType:
         return gMsgType();
        case roleMsgResource:
         return gMsgResource();
        default:
          return QVariant();
        }
      }
      virtual QHash<int, QByteArray> roleNames() const {
          QHash<int, QByteArray> names;
          names[roleMsgText] = "msgText";
          names[roleDateTime] = "dateTime";
          names[roleIsMine] = "isMine";
          names[roleMsgType] = "msgType";
          names[roleMsgResource] = "msgResource";
          return names;
        }


      virtual QString id() const { return "doesnt matter had sex"; }

      void setMsgText( const QString &_msgText) {
        if (msgText != _msgText) {
            msgText = _msgText; emit dataChanged();
          }
      }

      void setDateTime( const QString &_dateTime) {
        if (dateTime != _dateTime) {
            dateTime = _dateTime; emit dataChanged();
          }
      }

      void setIsMine( const int _isMine )  {
          if(isMine != _isMine) {
            isMine = _isMine;
            emit dataChanged();
          }
      }

      void setMsgType(const int _msgType) {
        if(msgType != _msgType) {
          msgType = _msgType;
          emit dataChanged();
        }
      }

      void setMsgResource( const QString &_msgResource) {
        if (msgResource != _msgResource) {
            msgResource = _msgResource; emit dataChanged();
          }
      }

      inline QString gMsgText() const { return msgText; }
      inline QString gDateTime() const { return dateTime; }
      inline int gIsMine() const { return isMine; }
      inline int gMsgType() const { return msgType; }
      inline QString gMsgResource() const { return msgResource; }

    private:
      QString msgText;
      QString dateTime;
      int isMine;
      int msgType;
      QString msgResource;
};

#endif // MSGITEMMODEL_H

