/********************************************************************

src/MsgListModel.h
-- implements list model for messages

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


#ifndef MSGLISTMODEL_H
#define MSGLISTMODEL_H

#include "listmodel.h"
#include "msgitemmodel.h"
#include <QDateTime>

class MsgListModel : public ListModel
{
    Q_OBJECT
    
public:
    enum Roles {
        roleMsgText = Qt::UserRole+1,
        roleDateTime,
        roleIsMine,
        roleMsgType,
        roleMsgResource,
        roleUnreadState
      };

    explicit MsgListModel( QObject *parent = 0) :ListModel( new MsgItemModel, parent ) {}

    Q_INVOKABLE void append( MsgItemModel *item ) { this->appendRow( item ); }
    Q_INVOKABLE void remove( int index ) { this->removeRow( index ); }
    Q_INVOKABLE int count() { return this->rowCount(); }

    int whereShouldIPutThisCrapAnyway(QString date) {
      MsgItemModel* message;
      for (int i=0; i < this->rowCount(); i++) {
          message = (MsgItemModel*)this->getElementByID(i);
          if (message != NULL) {
              if (QDateTime::fromString(message->gDateTime(),"dd-MM-yy hh:mm:ss") > QDateTime::fromString(date,"dd-MM-yy hh:mm:ss"))
                return i;
            }
        }
      return this->rowCount();
    }

signals:
    void messagesChanged();

protected:
    QHash<int, QByteArray> roleNames() const {
        QHash<int, QByteArray> names;
        names[roleMsgText] = "msgText";
        names[roleDateTime] = "dateTime";
        names[roleIsMine] = "isMine";
        names[roleMsgType] = "msgType";
        names[roleMsgResource] = "msgResource";
        names[roleUnreadState] = "msgUnreadState";
        return names;
    }

};

#endif // MSGLISTMODEL_H

