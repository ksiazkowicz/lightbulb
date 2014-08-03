/********************************************************************

qml/Components/ConvoOutcomingMsgDelegate.qml
-- delegate for outcoming messages

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
    height: bubbleTop.height/2 + message.paintedHeight + bubbleBottom.height/2 + triangleBottom.height
    property int marginRight: platformStyle.paddingLarge*3+10
    property int marginLeft: platformStyle.paddingSmall+10

    anchors { left: parent.left; right: parent.right; rightMargin: marginRight; leftMargin: marginLeft }

    MouseArea {
        anchors.fill: parent
        onPressAndHold: dialog.createWithProperties("qrc:/menus/MessageContext", {"msg": _msgText})
    }

    Rectangle {
        id: bubbleTop
        anchors { top: parent.top;
            left: parent.left;
            right: parent.right;
        }
        height: 20
        smooth: true
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#6f6f74" }
            GradientStop { position: 0.5; color: "#56565b" }
            GradientStop { position: 1.0; color: "#56565b" }
        }

        radius: 8
    }
    Rectangle {
        id: bubbleBottom
        anchors { bottom: triangleBottom.top;
            left: parent.left;
            right: parent.right;
        }
        height: 20
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#56565b" }
            GradientStop { position: 0.5; color: "#56565b" }
            GradientStop { position: 1.0; color: "#46464b" }
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
        color: "#56565b"
        Text {
              id: message
              anchors { top: parent.top; left: parent.left; leftMargin: platformStyle.paddingSmall; right: parent.right; rightMargin: platformStyle.paddingSmall }
              property string messageText: vars.areEmoticonsDisabled ? _msgText : emoticon.parseEmoticons(_msgText)
              property string date: _dateTime.substr(0,8) == Qt.formatDateTime(new Date(), "dd-MM-yy") ? _dateTime.substr(9,5) : _dateTime
              property string name: qsTr("Me")

              text: "<font color='#009FEB'>" + name + ":</font> " + messageText + "<div align='right' style='color: \"#999999\"'>"+ date + "</div>"
              color: platformStyle.colorNormalLight
              font.pixelSize: platformStyle.fontSizeSmall
              wrapMode: Text.WordWrap
              onLinkActivated: dialog.createWithProperties("qrc:/menus/UrlContext", {"url": link})
        }
    }

    Image {
        id: triangleBottom
        anchors { bottom: parent.bottom;
            left: parent.left;
            leftMargin: platformStyle.paddingMedium*2
        }
        source: "qrc:/images/bubble_outTriangle.png"
        width: platformStyle.paddingLarge
        height: platformStyle.paddingLarge
    }
}
