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

import QtQuick 1.1
import com.nokia.symbian 1.1
import lightbulb 1.0
import "../Components"

Page {
    id: rosterPage

    property string selectedJid

    Connections {
        target: vars
        onHideOfflineChanged: {
            if (rosterSearch.height == 0)
                xmppConnectivity.offlineContactsVisibility = !vars.hideOffline
        }
    }

    property string pageName: "Contacts"

    /*******************************************************************************/

    ListView {
        id: rosterView
        anchors { top: parent.top; left: parent.left; right: parent.right; bottom: rosterSearch.top; }
        model: xmppConnectivity.roster
        delegate: Loader {
            source: visible ? "qrc:/Components/RosterItemDelegate.qml" : ""
            property string _contactName: (name === "" ? jid : name)
            property string _contactJid: jid
            property string _statusText: statusText
            property string _accountId: accountId
            width: rosterView.width
            visible: rosterSearch.text !== "" ? (_contactName.toLowerCase().indexOf(rosterSearch.text.toLowerCase()) != -1) : true
            height: visible ? sourceComponent.height : 0
        }
    }

    ScrollBar {
        id: scrollBar

        anchors {
            top: parent.top
            bottom: rosterSearch.top
            right: parent.right
            margins: platformStyle.paddingSmall
        }
        flickableItem: rosterView
        platformInverted: main.platformInverted
    }

    /*********************************************************************/

    TextField {
        id: rosterSearch
        height: 0
        width: parent.width
        anchors.bottom: parent.bottom
        placeholderText: qsTr("Tap to write")

        Behavior on height { SmoothedAnimation { velocity: 200 } }
        onTextChanged: {
            if (text.length > 0) {
                if (!xmppConnectivity.offlineContactsVisibility)
                    xmppConnectivity.offlineContactsVisibility = true;
            } else if (xmppConnectivity.offlineContactsVisibility != !vars.hideOffline) xmppConnectivity.offlineContactsVisibility = !vars.hideOffline
        }
    }

    tools: ToolBarLayout {
        id: toolBarLayout
        ToolButton {
            iconSource: main.platformInverted ? "toolbar-back_inverse" : "toolbar-back"
            onClicked: pageStack.pop()
        }
        ToolButton {
            iconSource: main.platformInverted ? "toolbar-add_inverse" : "toolbar-add"
            onClicked: dialog.createWithContext("qrc:/dialogs/Contact/Add")
        }
        ToolButton {
            iconSource: main.platformInverted ? "toolbar-search_inverse" : "toolbar-search"
            onClicked: {
                if (rosterSearch.height == 50) {
                    if (xmppConnectivity.offlineContactsVisibility != !vars.hideOffline)
                            xmppConnectivity.offlineContactsVisibility = !vars.hideOffline;
                    rosterSearch.height = 0;
                    rosterSearch.text = "";
                } else rosterSearch.height = 50;
            }
        }
    }
}
