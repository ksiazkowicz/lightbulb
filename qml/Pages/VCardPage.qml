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


            Text {
                id: txtNickname
                anchors { left: parent.left; leftMargin: 10 }
                text: vCardNickName != "" ? "<b>" + qsTr("Nickname") + "</b><br />" + vCardNickName : ""
                font.pixelSize: 18
                color: vars.textColor
                visible: text != ""
            }
            Rectangle {
                color: "gray"
                height: 1
                opacity: 0.5
                width: parent.width
                visible: txtNickname.visible
            }

            Text {
                id: txtName
                anchors { left: parent.left; leftMargin: 10 }
                text: vCardName != "" ? "<b>" + qsTr("Name") + "</b><br />" + vCardName : ""
                font.pixelSize: 18
                color: vars.textColor
                visible: text != ""
            }
            Rectangle {
                color: "gray"
                height: 1
                opacity: 0.5
                width: parent.width
                visible: txtName.visible
            }

            Text {
                id: txtMiddleName
                text: vCardMiddleName != "" ? "<b>" + qsTr("Middle name") + "</b><br />" + vCardMiddleName : ""
                anchors { left: parent.left; leftMargin: 10 }
                font.pixelSize: 18
                color: vars.textColor
                visible: text != ""
            }
            Rectangle {
                color: "gray"
                height: 1
                opacity: 0.5
                width: parent.width
                visible: txtMiddleName.visible
            }

            Text {
                id: txtLastName
                anchors { left: parent.left; leftMargin: 10 }
                text: vCardLastName != "" ? "<b>" + qsTr("Lastname") + "</b><br />" + vCardLastName : ""
                font.pixelSize: 18
                color: vars.textColor
                visible: text != ""
            }
            Rectangle {
                color: "gray"
                height: 1
                opacity: 0.5
                width: parent.width
                visible: txtLastName.visible
            }

            Text {
                id: txtFullName
                anchors { left: parent.left; leftMargin: 10 }
                text: vCardFullName != "" ? "<b>" + qsTr("Full name") + "</b><br />" + vCardFullName : ""
                font.pixelSize: 18
                color: vars.textColor
                visible: text != ""
            }
            Rectangle {
                color: "gray"
                height: 1
                opacity: 0.5
                width: parent.width
                visible: txtFullName.visible
            }

            Text {
                id: txtBareJid
                anchors { left: parent.left; leftMargin: 10; right: parent.right; rightMargin: 10 }
                text: "<b>" + qsTr("Jabber ID") + "</b><br />" + bareJid
                font.pixelSize: 18
                color: vars.textColor
                width: parent.width
                wrapMode: Text.WrapAnywhere
            }
            Rectangle {
                color: "gray"
                height: 1
                opacity: 0.5
                width: parent.width
            }

            Text {
                id: txtEmail
                anchors { left: parent.left; leftMargin: 10 }
                text: vCardEmail != "" ? "<b>" + qsTr("E-mail") + "</b><br />" + vCardEmail : ""
                font.pixelSize: 18
                color: vars.textColor
                visible: text != ""
            }
            Rectangle {
                color: "gray"
                height: 1
                opacity: 0.5
                width: parent.width
                visible: txtEmail.visible
            }

            Text {
                id: txtBirthday
                anchors { left: parent.left; leftMargin: 10 }
                text: vCardBirthday != "" ? "<b>" + qsTr("Birthday") + "</b><br />" + vCardBirthday : ""
                font.pixelSize: 18
                color: vars.textColor
                visible: text != ""
            }
            Rectangle {
                color: "gray"
                height: 1
                opacity: 0.5
                width: parent.width
                visible: txtBirthday.visible
            }

            Text {
                id: txtUrl
                anchors { left: parent.left; leftMargin: 10; right: parent.right; rightMargin: 10 }
                text: vCardUrl != "" ? "<b>" + qsTr("Website") + "</b><br /><a href=\"" + vCardUrl + "\">" + vCardUrl + "</a>" : ""
                font.pixelSize: 18
                color: vars.textColor
                wrapMode: Text.WrapAnywhere
                width: parent.width
                visible: text != ""
                onLinkActivated: { vars.url=link; dialog.create("qrc:/menus/UrlContext")}
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
