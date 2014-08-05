/********************************************************************

qml/Components/ConvoArchiveDelegate.qml
-- delegate for archive

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

import QtQuick 1.1
import com.nokia.symbian 1.1

Item {
    id: wrapper
    height: time.height + message.paintedHeight + 10
    anchors.horizontalCenter: parent.horizontalCenter

    MouseArea {
        anchors.fill: parent
        onPressAndHold: dialog.createWithProperties("qrc:/menus/MessageContext", {"msg": _msgText})
    }

    Text {
          id: message
          anchors { top: parent.top; left: parent.left; right: parent.right }
          property string messageText: vars.areEmoticonsDisabled ? _msgText : emoticon.parseEmoticons(_msgText)
          text: "<font color='#009FEB'>" + ( _isMine == true ? qsTr("Me") : (_contactName === "" ? _contactJid : _contactName) ) + ":</font> " + messageText
          color: vars.textColor
          font.pixelSize: 16
          wrapMode: Text.Wrap
          onLinkActivated: dialog.createWithProperties("qrc:/menus/UrlContext", {"url": link})
    }
    Text {
          id: time
          anchors { top: message.bottom; right: parent.right }
          text: _dateTime.substr(0,8) == Qt.formatDateTime(new Date(), "dd-MM-yy") ? _dateTime.substr(9,5) : _dateTime
          font.pixelSize: 16
          color: "#999999"
    }
}
