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

import bb.cascades 1.4
import lightbulb 1.0

Page {
    id: accountsPage
    /*Component {
        id: componentAccountItem

        ListItem {
            AccountItem {
                text: xmppConnectivity.getAccountName(accGRID)
                icon: "qrc:/accounts/" + xmppConnectivity.getAccountIcon(accGRID)

                onEditButtonClick: pageStack.replace( "qrc:/pages/AccountsAdd", {"accGRID":accGRID})
                onRemoveButtonClick: {
                    if (avkon.displayAvkonQueryDialog("Remove","Are you sure you want to remove account " + accJid + "?"))
                        settings.removeAccount(accGRID)
                }
            }

            onClicked: dialog.createWithProperties("qrc:/dialogs/AccountDetails", {"accountGRID": accGRID})
        }
    }*/

    content: ListView {
        dataModel: AbstractItemModel { sourceModel: settings.accounts }
        onTriggered: {
            var selectedItem = dataModel.data(indexPath);
            xmppConnectivity.useClient(selectedItem.accGRID).setPresence(XmppClient.Online, "@Fluorescent for BlackBerry Alpha")
        }

        listItemComponents: [
            ListItemComponent {
                type: ""
                content: StandardListItem {
                    //imageSource: "assets://images/accounts/" + ListItemData.accIcon + ".svg"
                    title: ListItemData.accName
                    description: ListItemData.accJid
                }
            }
        ]

    }

    actions: [
        ActionItem {
            title: "Edit"
            ActionBar.placement: ActionBarPlacement.OnBar

            //onTriggered: navigationPane.push(addAccountPage);
        },
        ActionItem {
            title: "Add"
            ActionBar.placement: ActionBarPlacement.Signature

            onTriggered: {
                navigationPane.setBackButtonsVisible(false)
                navigationPane.push(addAccountPage);
            }
        },
        ActionItem {
            title: "Remove"
            ActionBar.placement: ActionBarPlacement.OnBar
            //onTriggered: navigationPane.push(addAccountPage);
        }
    ]
}
