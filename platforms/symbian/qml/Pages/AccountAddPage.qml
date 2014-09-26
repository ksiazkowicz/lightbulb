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
import "../Components"

Page {
    id: accAddPage

    property string accGRID: ""
    property string pageName: accGRID !== "" ? qsTr("Editing ") + xmppConnectivity.getAccountName(accGRID) : "New account"

    function unhighlightFields(exception) {
        if (exception !== "name") name.highlighted = false;
        if (exception !== "password") password.highlighted = false;
        if (exception !== "resource") resource.highlighted = false;
        if (exception !== "login") login.highlighted = false;
        if (exception !== "serverDetails") serverDetails.highlighted = false;
    }

    Component.onCompleted: {
        if (accGRID != "") {
            if (settings.gStr(accGRID,'host') == "chat.facebook.com")
                selectionDialog.selectedIndex = 0;
            else if (settings.gStr(accGRID,'host') == "talk.google.com")
                selectionDialog.selectedIndex = 1;
            else
                selectionDialog.selectedIndex = 2;

            name.value = settings.gStr(accGRID,'name')
            login.value = settings.gStr(accGRID,'jid')
            password.value = settings.gStr(accGRID,'passwd')
            serverDetails.value = settings.gStr(accGRID,'host') + ":" + settings.gStr(accGRID,'port')
            resource.value = settings.gStr(accGRID,'resource')
            if (name.value == "false")
                name.value = "";
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

                onClicked: { unhighlightFields(""); selectionDialog.open() }

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
                        password.value = ""
                        switch (selectionDialog.selectedIndex) {
                            case 0: {
                                login.value = "@chat.facebook.com";
                                serverDetails.value = "chat.facebook.com:5222";
                                break;
                            }
                            case 1: {
                                login.value = "@gmail.com";
                                serverDetails.value = "talk.google.com:5222";
                                break;
                            }
                            case 2: {
                                login.value = "";
                                serverDetails.value = "";
                                break;
                            }
                        }
                    }
                }
            }

            SettingField {
                id: name
                settingLabel: "Name (optional)"
                width: parent.width
                onHighlightedChanged: if (highlighted) unhighlightFields("name");
            }

            SettingField {
                id: login
                settingLabel: "Login"
                placeholder: "login@server.com"
                enabled: selectionDialog.selectedIndex != -1
                width: parent.width

                onHighlightedChanged: if (highlighted) unhighlightFields("login");
            }

            SettingField {
                id: password
                settingLabel: "Password"
                enabled: selectionDialog.selectedIndex != -1
                width: parent.width
                echoMode: TextInput.Password

                onHighlightedChanged: if (highlighted) unhighlightFields("password");
            }

            SettingField {
                id: resource
                settingLabel: "Resource (optional)"
                placeholder: "(default: Lightbulb)"
                enabled: selectionDialog.selectedIndex != -1
                width: parent.width

                onHighlightedChanged: if (highlighted) unhighlightFields("resource");
            }

            SettingField {
                id: serverDetails
                settingLabel: "Server details"
                placeholder: "talk.google.com:5222"
                enabled: selectionDialog.selectedIndex == 2
                visible: enabled
                width: parent.width
                height: visible ? 66 : 0

                // need support for input validation

                onHighlightedChanged: if (highlighted) unhighlightFields("serverDetails");
            }

            CheckBox {
               id: goOnline
               text: qsTr("Go online on startup")
               enabled: selectionDialog.selectedIndex != -1
               checked: settings.gBool(accGRID,'connectOnStart')
               platformInverted: main.platformInverted
            }
        }

    }


    /******************************************/

    tools: ToolBarLayout {
        ToolButton {
            platformInverted: main.platformInverted
            iconSource: "toolbar-back"
            onClicked: {
                pageStack.replace( "qrc:/pages/Accounts" )
                main.splitscreenY = 0
            }
        }
        ToolButton {
            iconSource: main.platformInverted ? "qrc:/toolbar/ok_inverse" : "qrc:/toolbar/ok"
            enabled: login.value !== "" && password.value !== "" && selectionDialog.selectedIndex != -1
            onClicked: {
                var grid,vName,icon;
                grid = accGRID != "" ? accGRID : settings.generateGRID();
                vName = name.value == "" ? xmppConnectivity.generateAccountName(host,jid) : name.value
                switch (selectionDialog.selectedIndex) {
                    case 0: icon = "Facebook"; break;
                    case 1: icon = "Hangouts"; break;
                    case 2: icon = "XMPP"; break;
                }

                settings.setAccount(grid,vName,icon,login.value, password.value,goOnline.checked,resource.value,serverDetails.value.split(":")[0],serverDetails.value.split(":")[1],true)
                pageStack.pop()
            }
        }
    }
}
