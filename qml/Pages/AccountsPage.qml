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
import "../Components"

Page {
    id: accountsPage
    tools: toolBarAccounts

    Component {
        id: componentAccountItem

        ListItem {
            AccountItem {
                text: xmppConnectivity.getAccountName(accGRID)
                icon: "qrc:/accounts/" + xmppConnectivity.getAccountIcon(accGRID)

                onEditButtonClick: pageStack.replace( "qrc:/pages/AccountsAdd", {"accGRID":accGRID})
                onRemoveButtonClick: {
                    if (avkon.displayAvkonQueryDialog("Remove","Are you sure you want to remove account " + accJid + "?")) {
                        xmppConnectivity.accountRemoved(accGRID)
                        settings.removeAccount(accGRID)
                    }
                }
            }

            onClicked: dialog.createWithProperties("qrc:/dialogs/AccountDetails", {"accountGRID": accGRID})
        }
    }

    ListView {
        id: listViewAccounts
        anchors { fill: parent }
        clip: true
        delegate: componentAccountItem
        model: settings.accounts
    }

    ScrollBar {
        id: scrollBar

        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
            margins: platformStyle.paddingSmall
        }

        flickableItem: listViewAccounts
        interactive: false
        orientation: Qt.Vertical
        platformInverted: main.platformInverted
    }

    Component.onCompleted: {
        statusBarText.text = qsTr("Accounts")
    }

    // Code for destroying the page after pop
    onStatusChanged: if (status === PageStatus.Inactive) destroy()


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
            iconSource: main.platformInverted ? "toolbar-add_inverse" : "toolbar-add"
            onClicked: {
                pageStack.replace( "qrc:/pages/AccountsAdd" )
            }
        }
    }
}
