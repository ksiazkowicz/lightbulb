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

import QtQuick 2.0
import QtQuick.Controls 2.0
import ".."

Item {
    id: wrapper
    height: time.height + message.paintedHeight + 10
    anchors.horizontalCenter: parent.horizontalCenter

    property bool isLogBeginning: stack.currentPage.beginID == _id
    property bool isLogEnd: stack.currentPage.endID == _id

    MouseArea {
        anchors.fill: parent
        onPressAndHold: dialog.createWithProperties("qrc:/menus/MessageContext", {"msg": _msgText})
        onClicked: {
            if (stack.currentPage.logGenerationMode) {
                // set beginning to current ID if not set
                if (pageStack.currentPage.beginID == -1) {
                    pageStack.currentPage.beginID = _id
                    return;
                }
                // set end to current ID if not set and bigger than beginID
                if (pageStack.currentPage.endID == -1 && _id > pageStack.currentPage.beginID) {
                    pageStack.currentPage.endID = _id
                    return;
                }
                // set begin to current ID if smaller than beginID
                if (_id < pageStack.currentPage.beginID) {
                    pageStack.currentPage.beginID = _id
                    return;
                }
                // set end to current ID if bigger than endID
                if (_id > pageStack.currentPage.endID) {
                    pageStack.currentPage.endID = _id
                    return;
                }
                /*if (avkon.displayAvkonQueryDialog("Archive view","Shall I mark it as end of log? (if 'no' replied, it will be treated as beginning)")) {
                      pageStack.currentPage.endID = _id
                } else pageStack.currentPage.beginID = _id;*/
            }
        }
    }

    Image {
        id: logOverlayBegin
        source: isLogBeginning ? "qrc:/convo/defaultSkin/logBeginOverlay" : ""
        sourceSize { height: 32; width: 320 }
        anchors { top: parent.top; left: parent.left }
        z: 1
    }
    Image {
        id: logOverlayEnd
        source: isLogEnd ? "qrc:/convo/defaultSkin/logEndOverlay" : ""
        sourceSize { height: 32; width: 320 }
        anchors { bottom: parent.bottom; right: parent.right }
        z: 1
    }

    Text {
          id: message
          anchors { top: parent.top; left: parent.left; right: parent.right }
          property string messageText: vars.areEmoticonsDisabled ? _msgText : emoticon.parseEmoticons(_msgText)
          text: "<font color='#009FEB'>" + ( _isMine == true ? qsTr("Me") : (_contactName === "" ? _contactJid : _contactName) ) + ":</font> " + messageText
          color: main.textColor
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
