/********************************************************************

qml/Pages/VCardPage.qml
-- displays contacts VCard

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
import com.nokia.symbian 1.1
import lightbulb 1.0
import "../Components"

Page {
    id: vCardPage
    tools: ToolBarLayout {
        ToolButton {
            iconSource: main.platformInverted ? "toolbar-back_inverse" : "toolbar-back"
            onClicked: {
                pageStack.pop()
                xmppConnectivity.chatJid = ""
            }
        }
    }

    property string pageName:          "VCard"

    property string accountId:         ""

    property string contactJid:        ""
    property string contactName:       ""
    property string contactPresence:   xmppConnectivity.getPropertyByJid(accountId,"presence",contactJid)
    property string contactStatusText: xmppConnectivity.getPropertyByJid(accountId,"statusText",contactJid)


    // Code for destroying the page after pop
    onStatusChanged: if (vCardPage.status === PageStatus.Inactive) vCardPage.destroy()

    Component.onCompleted: vCard.loadVCard(contactJid)

    XmppVCard { id: vCard }

    Flickable {
        id: flickArea
        anchors { top: parent.top; topMargin: 12; bottom: parent.bottom; bottomMargin: 12; left: parent.left; leftMargin: 20; right: parent.right; rightMargin: 20 }
        contentHeight: columnContent.height
        contentWidth: columnContent.width

        flickableDirection: Flickable.VerticalFlick

        Column {
            id: columnContent
            width: vCardPage.width - flickArea.anchors.rightMargin - flickArea.anchors.leftMargin
            spacing: 5

            Row {
                id: rowAvatarAndJid
                height: avatar.height < container.height ? avatar.height + (container.height-avatar.height) : avatar.height
                width: columnContent.width
                spacing: 15
                Image {
                    id: avatar
                    smooth: true
                    width: 128
                    height: width
                    source: xmppConnectivity.getAvatarByJid(contactJid)
                    sourceSize { height: height; width: width }
                    anchors.verticalCenter: parent.verticalCenter
                }
                Item {
                    id: container
                    width: parent.width - 143
                    anchors { right: parent.right; rightMargin: 10; }
                    height: txtJid.height + 5 + statusText.height
                    Text {
                        id: txtJid
                        width: container.width
                        text: contactName
                        wrapMode: Text.Wrap
                        color: vars.textColor
                    }
                    Row {
                        spacing: 5
                        anchors { top: txtJid.bottom }
                        height: statusText.height
                        Image {
                            width: 24
                            source: contactPresence
                            sourceSize { height: width; width: width }
                        }
                        Text {
                            id: statusText
                            width: columnContent.width - 162
                            font.pixelSize: 18
                            text: contactStatusText == "" ? contactPresence.slice(14) : contactStatusText
                            color: "gray"
                            wrapMode: Text.Wrap
                        }
                    }
                }
            }

            DetailsItem {
                title: qsTr("Nickname")
                value: vCard.nickname
                valueFont.bold: true
                visible: value != ""
            }
            LineItem {visible: vCard.nickname != ""}

            DetailsItem {
                title: qsTr("Name")
                value: vCard.name
                valueFont.bold: true
                visible: value != ""
            }
            LineItem {visible: vCard.name != ""}

            DetailsItem {
                title: qsTr("Middle name")
                value: vCard.middlename
                valueFont.bold: true
                visible: value != ""
            }
            LineItem {visible: vCard.middlename != ""}

            DetailsItem {
                title: qsTr("Lastname")
                value: vCard.lastname
                valueFont.bold: true
                visible: value != ""
            }
            LineItem {visible: vCard.lastname != ""}

            DetailsItem {
                title: qsTr("Full name")
                value: vCard.fullname
                valueFont.bold: true
                visible: value != ""
            }
            LineItem {visible: vCard.fullname != ""}

            DetailsItem {
                title: qsTr("Jabber ID")
                value: contactJid
                valueFont.bold: true
            }
            LineItem {}

            DetailsItem {
                title: qsTr("E-mail")
                value: vCard.email
                valueFont.bold: true
                visible: value != ""
            }
            LineItem { visible: vCard.email != ""}

            DetailsItem {
                title: qsTr("Website")
                value: "<a href=\"" + vCard.url + "\">" + vCard.url + "</a>"
                valueFont.bold: true
                wrapMode: Text.WrapAnywhere
                visible: vCard.url != ""
            }
        }

    }
}
