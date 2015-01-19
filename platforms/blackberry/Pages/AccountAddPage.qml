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

import bb.cascades 1.4

Page {
    id: accountAddPage

    titleBar: TitleBar {
                  kind: TitleBarKind.FreeForm
                  kindProperties: FreeFormTitleBarKindProperties {
                      Container {
                          layout: StackLayout { orientation: LayoutOrientation.LeftToRight }
                          leftPadding: 10
                          rightPadding: 10
                          Button {
                              text: "Cancel"
                              verticalAlignment: VerticalAlignment.Center
                              layoutProperties: StackLayoutProperties { spaceQuota: 1 }
                              onClicked: {
                                  navigationPane.setBackButtonsVisible(true)
                                  navigationPane.pop();
                              }
                          }
                          Label {
                              text: "Add account"
                              verticalAlignment: VerticalAlignment.Center
                              textStyle {
                                  fontWeight: FontWeight.Bold
                                  textAlign: TextAlign.Center
                              }
                              layoutProperties: StackLayoutProperties { spaceQuota: 3 }
                          }
                          Button {
                              text: "Next"
                              verticalAlignment: VerticalAlignment.Center
                              layoutProperties: StackLayoutProperties { spaceQuota: 1 }
                              onClicked: {
                                  navigationPane.setBackButtonsVisible(true)

                                  var grid,vName,icon;
                                  grid = /*accGRID != "" ? accGRID : */settings.generateGRID();
                                  vName = name.text == "" ? xmppConnectivity.generateAccountName(serverDetails.text.split(":")[0],login.text) : name.text
                                  /*switch (selectionDialog.selectedIndex) {
                                      case 0: icon = "Facebook"; break;
                                      case 1: icon = "Hangouts"; break;
                                      case 2: icon = "XMPP"; break;
                                  }*/

                                  settings.setAccount(grid,vName,icon,login.text, password.text,goOnline.checked,resource.text,serverDetails.text.split(":")[0],serverDetails.text.split(":")[1],true)
                                  navigationPane.pop();
                              }
                          }
                      }
                  }
              }

    content: Container {
        layout: StackLayout {}

        Label { text: "Name" }
        TextField {
            id: name
            horizontalAlignment: HorizontalAlignment.Center
            inputMode: TextFieldInputMode.Text
        }

        Label { text: "Login *" }
        TextField {
            id: login
            hintText: "Enter your Jabber ID (login@server.com)"
            horizontalAlignment: HorizontalAlignment.Center
            inputMode: TextFieldInputMode.EmailAddress
        }

        Label { text: "Password *" }
        TextField {
            id: password
            hintText: "Enter your password"
            horizontalAlignment: HorizontalAlignment.Center
            inputMode: TextFieldInputMode.Password
        }

        Label { text: "Resource" }
        TextField {
            id: resource
            horizontalAlignment: HorizontalAlignment.Center
            inputMode: TextFieldInputMode.Text
        }

        Label { text: "Server details" }
        TextField {
            id: serverDetails
            hintText: "talk.google.com:5222"
            horizontalAlignment: HorizontalAlignment.Center
            inputMode: TextFieldInputMode.Text
        }

        CheckBox {
           id: goOnline
           text: qsTr("Go online on startup")
           horizontalAlignment: HorizontalAlignment.Center
           checked: settings.gBool(accGRID,'connectOnStart')
        }
    }
}

/*Page {
    id: accAddPage

    property string accGRID: ""
    property string pageName: accGRID !== "" ? qsTr("Editing ") + xmppConnectivity.getAccountName(accGRID) : "New account"

    /*Component.onCompleted: {
        if (accGRID != "") {
            if (settings.gStr(accGRID,'host') == "chat.facebook.com")
                selectionDialog.selectedIndex = 0;
            else if (settings.gStr(accGRID,'host') == "talk.google.com")
                selectionDialog.selectedIndex = 1;
            else
                selectionDialog.selectedIndex = 2;

            name.text = settings.gStr(accGRID,'name')
            login.text = settings.gStr(accGRID,'jid')
            password.text = settings.gStr(accGRID,'passwd')
            serverDetails.text = settings.gStr(accGRID,'host') + ":" + settings.gStr(accGRID,'port')
            resource.text = settings.gStr(accGRID,'resource')
            if (name.text == "false")
                name.text = "";
        }
    }

    // Code for destroying the page after pop
    onStatusChanged: if (accAddPage.status === PageStatus.Inactive) accAddPage.destroy()

    Flickable {
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

                onClicked: { selectionDialog.open() }

                SelectionDialog {
                    id: selectionDialog
                    titleText: "Available options"
                    selectedIndex: -1
                    platformInverted: main.platformInverted
                    model: ListModel {
                        /*ListElement { name: "Facebook Chat" }
                        ListElement { name: "Google Talk" }
                        ListElement { name: "Generic XMPP server" }*/
                    /*}
                    onSelectedIndexChanged: {
                        password.text = ""
                        switch (selectionDialog.selectedIndex) {
                            case 0: {
                                login.text = "@chat.facebook.com";
                                serverDetails.text = "chat.facebook.com:5222";
                                break;
                            }
                            case 1: {
                                login.text = "@gmail.com";
                                serverDetails.text = "talk.google.com:5222";
                                break;
                            }
                            case 2: {
                                login.text = "";
                                serverDetails.text = "";
                                break;
                            }
                        }
                    }
                }
            }
        }
    }

    /******************************************/

    /*tools: ToolBarLayout {
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
            enabled: login.text !== "" && password.text !== "" && selectionDialog.selectedIndex != -1
            onClicked: {
                var grid,vName,icon;
                grid = accGRID != "" ? accGRID : settings.generateGRID();
                vName = name.text == "" ? xmppConnectivity.generateAccountName(serverDetails.text.split(":")[0],login.text) : name.text
                switch (selectionDialog.selectedIndex) {
                    case 0: icon = "Facebook"; break;
                    case 1: icon = "Hangouts"; break;
                    case 2: icon = "XMPP"; break;
                }

                settings.setAccount(grid,vName,icon,login.text, password.text,goOnline.checked,resource.text,serverDetails.text.split(":")[0],serverDetails.text.split(":")[1],true)
                pageStack.pop()
            }
        }
    }
}*/
