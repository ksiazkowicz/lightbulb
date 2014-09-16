/********************************************************************

qml/Pages/AccountAddPage.qml
-- contains a form for adding accounts

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

Page {
    id: accAddPage

    tools: toolBarLayout
    property string accGRID: ""
    property string pageName: accGRID !== "" ? qsTr("Editing ") + xmppConnectivity.getAccountName(accGRID) : "New account"

    Component.onCompleted: {
        if (accGRID != "") {
            if (settings.gStr(accGRID,'host') == "chat.facebook.com")
                selectionDialog.selectedIndex = 0;
            else if (settings.gStr(accGRID,'host') == "talk.google.com")
                selectionDialog.selectedIndex = 1;
            else
                selectionDialog.selectedIndex = 2;

            tiName.text = settings.gStr(accGRID,'name')
            tiJid.text  = settings.gStr(accGRID,'jid')
            tiPass.text = settings.gStr(accGRID,'passwd')
            tiHost.text = settings.gStr(accGRID,'host')
            tiPort.text = settings.gStr(accGRID,'port')
            tiResource.text = settings.gStr(accGRID,'resource')
            if (tiName.text == "false")
                tiName.text = "";
        }
    }

    // Code for destroying the page after pop
    onStatusChanged: if (accAddPage.status === PageStatus.Inactive) accAddPage.destroy()

    Flickable {
        id: flickArea
        anchors { left: parent.left; leftMargin: 5; right: parent.right; rightMargin: 5; top: parent.top; topMargin: 5; bottom: parent.bottom; }

        contentHeight: contentPage.height
        contentWidth: contentPage.width

        flickableDirection: Flickable.VerticalFlick

        Column {
            id: contentPage
            width: accAddPage.width - flickArea.anchors.rightMargin - flickArea.anchors.leftMargin
            spacing: 5
            SelectionListItem {
                id: serverSelection
                platformInverted: main.platformInverted
                subTitle: selectionDialog.selectedIndex >= 0
                          ? selectionDialog.model.get(selectionDialog.selectedIndex).name
                          : "FB Chat, GTalk or manual"
                anchors { left: parent.left; right: parent.right }
                title: "Server"

                onClicked: selectionDialog.open()

                SelectionDialog {
                    id: selectionDialog
                    titleText: "Available options"
                    selectedIndex: -1
                    platformInverted: main.platformInverted
                    model: ListModel {
                        ListElement { name: "Facebook Chat" }
                        ListElement { name: "Google Talk" }
                        ListElement { name: "Generic XMPP server" }
                    }
                    onSelectedIndexChanged: {
                        tiPass.text = ""
                        tiPort.text = "5222"
                        switch (selectionDialog.selectedIndex) {
                            case 0: {
                                tiJid.text = "@chat.facebook.com";
                                tiHost.text = "chat.facebook.com";
                                break;
                            }
                            case 1: {
                                tiJid.text = "@gmail.com";
                                tiHost.text = "talk.google.com";
                                break;
                            }
                            case 2: {
                                tiJid.text = "";
                                tiHost.text = "";
                                break;
                            }
                        }
                    }
                }
            }

            Text {
                text: "Name (optional)"
                color: main.textColor
            }
            TextField {
                id: tiName
                height: 50
                enabled: selectionDialog.selectedIndex != -1
                anchors.horizontalCenter: parent.horizontalCenter
                width: accAddPage.width - 10
                onActiveFocusChanged: main.splitscreenY = 0
            }

            Text {
                text: "Login"
                color: main.textColor
            }
            TextField {
                id: tiJid
                height: 50
                enabled: selectionDialog.selectedIndex != -1
                anchors.horizontalCenter: parent.horizontalCenter
                width: accAddPage.width - 10
                placeholderText: qsTr("login@server.com")
                onActiveFocusChanged: main.splitscreenY = 0
            }

            Item {
                height: 5
                width: accAddPage.width
            }

            Text {
                text: "Password"
                color: main.textColor
            }

            TextField {
                id: tiPass
                anchors.horizontalCenter: parent.horizontalCenter
                enabled: selectionDialog.selectedIndex != -1
                width: accAddPage.width-10
                height: 50
                echoMode: TextInput.Password
                placeholderText: qsTr("Password")
                onActiveFocusChanged: main.splitscreenY = inputContext.height - (main.height - y) + 1.5*height
            }

            Item { height: 5; width: accAddPage.width}

            Item {
                height: 5
                width: accAddPage.width
            }

            Text {
                text: "Resource (optional)"
                color: main.textColor
            }

            TextField {
                id: tiResource
                height: 50
                anchors.horizontalCenter: parent.horizontalCenter
                enabled: selectionDialog.selectedIndex != -1
                width: accAddPage.width-10
                placeholderText: qsTr("(default: Lightbulb)")

                onActiveFocusChanged: main.splitscreenY = inputContext.height - (main.height - y) + 1.5*height
            }

            Item {
                height: 5
                width: accAddPage.width
            }

            CheckBox {
               id: goOnline
               text: qsTr("Go online on startup")
               enabled: selectionDialog.selectedIndex != -1
               checked: settings.gBool(accGRID,'connectOnStart')
               platformInverted: main.platformInverted
            }

            Item {
                height: 5
                width: accAddPage.width
            }

            Text {
                text: "Server details"
                color: main.textColor
                visible: selectionDialog.selectedIndex == 2
            }

            Rectangle {
                id: somethingInteresting
                height: 50
                width: accAddPage.width-20
                anchors.horizontalCenter: parent.horizontalCenter
                visible: selectionDialog.selectedIndex == 2
                color: "transparent"
                TextField {
                    id: tiHost
                    width: parent.width-10-tiPort.width
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    readOnly: !somethingInteresting.visible
                    placeholderText: "talk.google.com"

                    onActiveFocusChanged: main.splitscreenY = inputContext.height - (main.height - somethingInteresting.y) + 1.5*somethingInteresting.height
                }
                TextField {
                   id: tiPort
                   anchors.right: parent.right
                   anchors.top: parent.top
                   anchors.bottom: parent.bottom
                   width: 60
                   readOnly: !somethingInteresting.visible
                   placeholderText: "5222"

                   onActiveFocusChanged: main.splitscreenY = inputContext.height - (main.height - somethingInteresting.y) + 1.5*somethingInteresting.height
                }
            }

        }

    }


    /******************************************/

    ToolBarLayout {
        id: toolBarLayout
        ToolButton {
            iconSource: main.platformInverted ? "toolbar-back_inverse" : "toolbar-back"
            onClicked: {
                pageStack.replace( "qrc:/pages/Accounts" )
                main.splitscreenY = 0
            }
        }

        ToolButton {
            iconSource: main.platformInverted ? "qrc:/toolbar/ok_inverse" : "qrc:/toolbar/ok"
            enabled: tiJid.text !== "" && tiPass.text !== "" && selectionDialog.selectedIndex != -1
            onClicked: {
                var grid,name,icon,jid,pass,goonline,resource,host,port;
                if (accGRID != "") grid = accGRID;
                    else grid = settings.generateGRID()
                name = tiName.text
                if (tiName.text == "") {
                    name = xmppConnectivity.generateAccountName(host,jid);
                }
                switch (selectionDialog.selectedIndex) {
                    case 0:
                        icon = "Facebook";
                        break;
                    case 1:
                        icon = "Hangouts";
                        break;
                    case 2:
                        icon = "XMPP";
                        break;
                }
                jid = tiJid.text
                pass = tiPass.text
                goonline = goOnline.checked
                resource = tiResource.text
                host = tiHost.text
                port = tiPort.text

                settings.setAccount( grid, name, icon, jid, pass, goonline, resource, host, port,  true )
                pageStack.pop()
            }
        }
    }
}
