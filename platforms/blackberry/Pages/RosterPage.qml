/********************************************************************

qml/Pages/RosterPage.qml
-- displays contact list and interfaces with XmppConnectivity

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
import bb.system 1.0
import lightbulb 1.0

Page {
    id: rosterPage

    /*******************************************************************************/

    content: ListView {
        id: rosterView

        dataModel: AbstractItemModel { sourceModel: xmppConnectivity.roster }

        listItemComponents: [
                        ListItemComponent {
                            type: ""

                            // Use a predefined StandardListItem
                            //  to represent "listItem" items
                            content: StandardListItem {
                                imageSource: xmppConnectivity.getAvatarByJid(jid)
                                title: ListItemData.name
                                description: ListItemData.statusText
                                status: ListItemData.presence
                            }
                        }
                    ]

        onTriggered: {
            var item = dataModel.data(indexPath);

            msgPrompt.title = qsTr("Enter message for ") + dataModel.data(indexPath).name
            msgPrompt.jid = item.jid
            msgPrompt.accountId = item.accountId
            msgPrompt.resource = item.resource

            msgPrompt.show()
        }

        //anchors { top: parent.top; left: parent.left; right: parent.right; bottom: rosterSearch.top; }
        //model: xmppConnectivity.roster
        //delegate: RosterItemDelegate {width: rosterView.width }
    }

    attachedObjects: [ SystemPrompt {
            id: msgPrompt

            property string jid;
            property string resource;
            property string accountId;

            title: qsTr("Enter message")
            modality: SystemUiModality.Application
            inputField.inputMode: SystemUiInputMode.Default
            confirmButton.label: qsTr("Send")
            confirmButton.enabled: true
            cancelButton.label: qsTr("Cancel")
            cancelButton.enabled: true

            onFinished: {
                if (result == SystemUiResult.ConfirmButtonSelection) {
                    var message = inputFieldTextEntry()
                    xmppConnectivity.useClient(accountId).sendMessage(jid,resource,message,1,1);
                }
            }
        } ]

    /*********************************************************************/

    /*TextField {
        id: rosterSearch
        height: enabled ? 50 : 0
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        placeholderText: qsTr("Tap to write")
        enabled: false

        Behavior on height { SmoothedAnimation { velocity: 200 } }
        onTextChanged: xmppConnectivity.setFilter(text);

        function switchEnabled() {
            enabled = !enabled;
            if (!enabled) text = "";
        }
    }

    tools: ToolBarLayout {
        ToolButton {
            iconSource: "toolbar-back"
            platformInverted: main.platformInverted
            onClicked: pageStack.pop()
        }
        ToolButton {
            iconSource: "toolbar-add"
            platformInverted: main.platformInverted
            onClicked: dialog.createWithContext("qrc:/dialogs/Contact/Add")
        }
        ToolButton {
            iconSource: "toolbar-search"
            platformInverted: main.platformInverted
            onClicked: rosterSearch.switchEnabled()
        }
    }*/
}
