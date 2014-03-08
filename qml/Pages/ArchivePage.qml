/********************************************************************

qml/Pages/ArchivePage.qml
-- message archive page, loads and displays old messages

Copyright (c) 2013-2014 Maciej Janiszewski

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
import lightbulb 1.0
import com.nokia.symbian 1.1

Page {
    property bool emoticonsDisabled: settings.gBool("behavior","disableEmoticons")
    tools: ToolBarLayout {
            ToolButton {
                iconSource: main.platformInverted ? "toolbar-back_inverse" : "toolbar-back"
                onClicked: {
                    pageStack.replace("qrc:/pages/Messages")
                    xmppConnectivity.page = 1
                }
            }
            ButtonRow {
                ToolButton {
                    iconSource: main.platformInverted ? "toolbar-previous_inverse" : "toolbar-previous"
                    enabled: xmppConnectivity.messagesCount - xmppConnectivity.page> 0
                    opacity: enabled ? 1 : 0.2
                    onClicked: xmppConnectivity.page++;
                }
                ToolButton {
                    iconSource: main.platformInverted ? "toolbar-next_inverse" : "toolbar-next"
                    enabled: xmppConnectivity.page > 1
                    opacity: enabled ? 1 : 0.2
                    onClicked: {
                        xmppConnectivity.page--;
                        flickable.contentY = flickable.contentHeight-flickable.height;
                    }
                }
            }
            ToolButton {
                iconSource: main.platformInverted ? "qrc:/toolbar/chats_inverse" : "qrc:/toolbar/chats"
                onClicked: dialog.create("qrc:/dialogs/Chats")
                Image {
                    source: main.platformInverted ? "qrc:/unread-mark_inverse" : "qrc:/unread-mark"
                    smooth: true
                    sourceSize.width: parent.width
                    sourceSize.height: parent.width
                    width: parent.width
                    height: parent.width
                    visible: vars.globalUnreadCount != 0
                    anchors.centerIn: parent
                 }
                 Text {
                    text: vars.globalUnreadCount
                    font.pixelSize: 16
                    anchors.centerIn: parent
                    visible: vars.globalUnreadCount != 0
                    z: 1
                    color: main.platformInverted ? "white" : "black"
                 }
            }
           }

    Component.onCompleted: statusBarText.text = vars.contactName
    /**-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**/
    Component {
        id: componentWrapperItem

        Rectangle {
            id: wrapper
            color: "transparent"
            clip: true

            height: time.height + message.height + 10

            anchors.horizontalCenter: parent.horizontalCenter
            Text {
                  id: message
                  anchors { top: parent.top; left: parent.left; right: parent.right }
                  text: "<font color='#009FEB'>" + ( isMine == true ? qsTr("Me") : (vars.contactName === "" ? xmppConnectivity.chatJid : vars.contactName) ) + ":</font> " + (emoticonsDisabled ? msgText : emoticon.parseEmoticons(msgText))
                  color: vars.textColor
                  font.pixelSize: 16
                  wrapMode: Text.Wrap
                  onLinkActivated: { vars.url=link; dialog.create("qrc:/menus/UrlContext")}
            }
            Text {
                  id: time
                  anchors { top: message.bottom; right: parent.right }
                  text: dateTime.substr(0,8) == Qt.formatDateTime(new Date(), "dd-MM-yy") ? dateTime.substr(9,5) : dateTime
                  font.pixelSize: 16
                  color: "#999999"
            }

            width: listViewMessages.width - 10
        }
    } //Component
    /* --------------------( Messages view )-------------------- */
    Flickable {
        id: flickable
        boundsBehavior: Flickable.DragAndOvershootBounds

        anchors { fill: parent }

        contentHeight: listViewMessages.contentHeight+10

        ListView {
            id: listViewMessages
            interactive: false
            anchors { top: parent.top; topMargin: 5; bottom: parent.bottom; bottomMargin: 5; left: parent.left; right: parent.right }
            clip: true
            model: xmppConnectivity.messagesByPage
            delegate: componentWrapperItem
            spacing: 2
        }

        Component.onCompleted: contentY = contentHeight-height;
    }
}
