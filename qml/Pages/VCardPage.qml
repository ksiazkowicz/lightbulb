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
    tools: toolBar

    property string bareJid: ""
    property bool readOnly: true

    property alias vCardPhoto: avatar.source
    property string vCardNickName: ""
    property string vCardName: ""
    property string vCardMiddleName: ""
    property string vCardLastName: ""
    property string vCardFullName: ""
    property string vCardEmail: ""
    property string vCardBirthday: ""
    property string vCardUrl: ""

    Component.onCompleted: {
        console.log("QML::VCargPage: Request vCard for: " + xmppConnectivity.chatJid )
        xmppConnectivity.client.requestVCard( xmppConnectivity.chatJid )
        clearForm()
    }

    Connections {
        target: xmppVCard
        onVCardChanged: {
            //console.log( "QML: VCardPage: onVCardChanged: " + xmppVCard.nickname )
            if( xmppVCard.photo != "" ) {
                vCardPhoto = xmppVCard.photo
            }
            vCardNickName = xmppVCard.nickname
            vCardName = xmppVCard.name
            vCardMiddleName = xmppVCard.middlename
            vCardLastName = xmppVCard.lastname
            vCardFullName = xmppVCard.fullname
            vCardEmail = xmppVCard.email
            vCardBirthday = xmppVCard.birthday
            vCardUrl = xmppVCard.url
            bareJid = xmppVCard.jid

        }
    }
    function clearForm()
    {
        vCardPhoto = "qrc:/avatar"
        vCardNickName = ""
        vCardName = ""
        vCardMiddleName = ""
        vCardLastName = ""
        vCardFullName = ""
        vCardEmail = ""
        vCardBirthday = ""
        vCardUrl = ""
        bareJid = ""
    }

    function getPresence() {
        var presence = xmppConnectivity.getPropertyByJid(xmppConnectivity.currentAccount,"presence",xmppVCard.jid);
        if (presence != "(unknown)") {
            return presence.slice(14);
        } return presence;
    }

    Flickable {
        id: flickArea
        anchors.top: parent.top; anchors.topMargin: 12
        anchors.bottom: parent.bottom; anchors.bottomMargin: 12
        anchors.left: parent.left; anchors.leftMargin: 20
        anchors.right: parent.right; anchors.rightMargin: 20

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
                    height: 128
                    source: "qrc:/avatar"
                    sourceSize.height: height
                    sourceSize.width: width
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
                        text: vars.contactName
                        wrapMode: Text.Wrap
                        color: vars.textColor
                    }
                    Row {
                        spacing: 5
                        anchors { top: txtJid.bottom }
                        height: statusText.height
                        Image {
                            id: statusImg
                            width: 24
                            source: vars.selectedContactPresence
                            sourceSize.height: 24
                            sourceSize.width: 24
                        }
                        Text {
                            id: statusText
                            width: columnContent.width - 162
                            font.pixelSize: 18
                            text: vars.selectedContactStatusText == "" ? getPresence() : vars.selectedContactStatusText
                            color: "gray"
                            wrapMode: Text.Wrap
                        }
                    }
                }
            }

            DetailsItem {
                title: qsTr("Nickname")
                value: vCardNickName
                valueFont.bold: true
                visible: vCardNickName != ""
            }
            LineItem {visible: vCardNickName != ""}

            DetailsItem {
                title: qsTr("Name")
                value: vCardName
                valueFont.bold: true
                visible: vCardName != ""
            }
            LineItem {visible: vCardName != ""}

            DetailsItem {
                title: qsTr("Middle name")
                value: vCardMiddleName
                valueFont.bold: true
                visible: vCardMiddleName != ""
            }
            LineItem {visible: vCardMiddleName != ""}

            DetailsItem {
                title: qsTr("Lastname")
                value: vCardLastName
                valueFont.bold: true
                visible: vCardLastName != ""
            }
            LineItem {visible: vCardLastName != ""}

            DetailsItem {
                title: qsTr("Full name")
                value: vCardFullName
                valueFont.bold: true
                visible: vCardFullName != ""
            }
            LineItem {visible: vCardFullName != ""}

            DetailsItem {
                title: qsTr("Jabber ID")
                value: bareJid
                valueFont.bold: true
            }
            LineItem {}

            DetailsItem {
                title: qsTr("E-mail")
                value: vCardEmail
                valueFont.bold: true
                visible: vCardEmail != ""
            }
            LineItem { visible: vCardEmail != ""}

            DetailsItem {
                title: qsTr("Birthday")
                value: vCardBirthday
                valueFont.bold: true
                visible: vCardBirthday != ""
            }
            LineItem { visible: vCardBirthday != ""}

            DetailsItem {
                title: qsTr("Website")
                value: "<a href=\"" + vCardUrl + "\">" + vCardUrl + "</a>"
                valueFont.bold: true
                wrapMode: Text.WrapAnywhere
                visible: vCardUrl != ""
            }
        }

    }

    ToolBarLayout {
        id: toolBar
        ToolButton {
            iconSource: main.platformInverted ? "toolbar-back_inverse" : "toolbar-back"
            onClicked: {
                pageStack.pop()
                statusBarText.text = "Contacts"
                xmppConnectivity.chatJid = ""
            }
        }
    }

}
