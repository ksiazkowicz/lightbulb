/********************************************************************

qml/Components/ConvoIncomingMsgDelegate.qml
-- delegate for incoming messages

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

    MouseArea {
        anchors.fill: parent
        onPressAndHold: dialog.createWithProperties(":/menus/MessageContext", {"msg": _msgText})
    }

    height: triangleTop.height + bubbleTop.height/2 + message.paintedHeight + bubbleBottom.height/2

    property int marginRight: platformStyle.paddingSmall + 10
    property int marginLeft: platformStyle.paddingLarge*3 + 10

    anchors { left: parent.left; right: parent.right; rightMargin: marginRight; leftMargin: marginLeft }
    Image {
        id: triangleTop
        anchors { top: parent.top; right: parent.right; rightMargin: platformStyle.paddingMedium*2 }
        source: "qrc:/images/bubble_incTriangle.png"
        width: platformStyle.paddingLarge
        height: platformStyle.paddingLarge
    }
    Rectangle {
        id: bubbleTop
        anchors {
            top: triangleTop.bottom;
            left: parent.left;
            right: parent.right;
        }
        height: 20
        smooth: true
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#f2f1f4" }
            GradientStop { position: 0.5; color: "#eae9ed" }
            GradientStop { position: 1.0; color: "#eae9ed" }
        }

        radius: 8
    }
    Rectangle {
        id: bubbleBottom
        anchors {
            bottom: parent.bottom
            left: parent.left;
            right: parent.right;
        }
        height: 20
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#e6e6eb" }
            GradientStop { position: 0.5; color: "#e6e6eb" }
            GradientStop { position: 1.0; color: "#b9b8bd" }
        }

        radius: 8
        smooth: true
    }
    Rectangle {
        id: bubbleCenter
        anchors {
            top: bubbleTop.top;
            topMargin: 10;
            left: wrapper.left;
            right: wrapper.right;
            bottom: bubbleBottom.bottom;
            bottomMargin: 10
        }
        color: "#e6e6eb"
        Text {
              id: message
              anchors { top: parent.top; left: parent.left; leftMargin: platformStyle.paddingSmall; right: parent.right; rightMargin: platformStyle.paddingSmall }
              property string messageText: vars.areEmoticonsDisabled ? _msgText : emoticon.parseEmoticons(_msgText)
              property string date: _dateTime.substr(0,8) == Qt.formatDateTime(new Date(), "dd-MM-yy") ? _dateTime.substr(9,5) : _dateTime
              property string name: _msgType !== 3 ? (_contactName === "" ? _contactJid : _contactName) : _msgResource

              text: "<font color='#009FEB'>" + name + ":</font> " + messageText + "<div align='right' style='color: \"#999999\"'>"+ date + "</div>"
              color: platformStyle.colorNormalDark
              font.pixelSize: platformStyle.fontSizeSmall
              wrapMode: Text.WordWrap
              onLinkActivated: dialog.createWithProperties("qrc:/menus/UrlContext", {"url": link})
        }
    }
}
