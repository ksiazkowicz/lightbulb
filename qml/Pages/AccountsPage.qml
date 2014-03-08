/********************************************************************

qml/Pages/AccountsPage.qml
-- account management page

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
    id: accountsPage
    tools: toolBarAccounts

    property int currentIndex: -1;

    Component {
        id: componentAccountItem
        Rectangle {
            id: wrapper
            clip: true
            width: listViewAccounts.width
            height: 64
            gradient: gr_free
            Gradient {
                id: gr_free
                GradientStop { id: gr1; position: 0; color: "transparent" }
                GradientStop { id: gr3; position: 1; color: "transparent" }
            }
            Gradient {
                id: gr_press
                GradientStop { position: 0; color: "#1C87DD" }
                GradientStop { position: 1; color: "#51A8FB" }
            }
            Text {
                id: txtAcc
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 5
                anchors.right: parent.right
                anchors.rightMargin: 10
                text: accJid
                font.pixelSize: 18
                clip: true
                color: vars.textColor
            }
            states: State {
                name: "Current"
                when: (wrapper.ListView.isCurrentItem && (vars.accJid != "") )
                PropertyChanges { target: wrapper; gradient: gr_press }
            }

            transitions: Transition {
                //NumberAnimation { properties: "position"; duration: 300 }
            }

            MouseArea {
                id: maAccItem
                anchors { left: parent.left; right: parent.right; top: parent.top; bottom: parent.bottom; }
                onDoubleClicked: {
                    vars.accGRID = accGRID
                    vars.accJid = accJid
                    pageStack.replace( "qrc:/pages/AccountsAdd" )
                }
                onClicked: {
                    wrapper.ListView.view.currentIndex = index
                    accountsPage.currentIndex = index
                    vars.accGRID = accGRID
                    vars.accJid = accJid
                }
            }

        }
    }

    ListView {
        id: listViewAccounts
        anchors { fill: parent }
        clip: true
        delegate: componentAccountItem
        model: settings.accounts
    }

    Component.onCompleted: {
        vars.accGRID = ""
        statusBarText.text = qsTr("Accounts")
    }


    /********************************( Toolbar )************************************/

    ToolBarLayout {
        id: toolBarAccounts

        ToolButton {
            iconSource: main.platformInverted ? "toolbar-back_inverse" : "toolbar-back"
            onClicked: {
                pageStack.pop()
                statusBarText.text = "Contacts"
            }
        }

        ToolButton {
            iconSource: main.platformInverted ? "toolbar-delete_inverse" : "toolbar-delete"
            onClicked: if( vars.accGRID != "" ) {
                           if (avkon.displayAvkonQueryDialog("Remove","Are you sure you want to remove account " + vars.accJid + "?")) {
                               xmppConnectivity.accountRemoved(vars.accGRID)
                               settings.removeAccount( vars.accGRID )
                           }
                       }
        }

        ToolButton {
            enabled: vars.accGRID != ""
            opacity: enabled ? 1 : 0.5
            iconSource: main.platformInverted ? "qrc:/toolbar/edit_inverse" : "qrc:/toolbar/edit"
            onClicked: if( vars.accGRID != "" ) pageStack.replace( "qrc:/pages/AccountsAdd" )
        }

        ToolButton {
            iconSource: main.platformInverted ? "toolbar-add_inverse" : "toolbar-add"
            onClicked: {
                vars.accGRID = "";
                pageStack.replace( "qrc:/pages/AccountsAdd" )
            }
        }
    }
}
