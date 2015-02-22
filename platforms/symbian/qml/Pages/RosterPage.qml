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
    onStatusChanged: if (rosterPage.status === PageStatus.Inactive) { xmppConnectivity.setFilter(""); rosterSearch.text = ""; }

    property string selectedJid

    property string pageName: "Contacts"

    /*******************************************************************************/

    ListView {
        id: rosterView
        anchors { top: parent.top; left: parent.left; right: parent.right; bottom: rosterSearch.top; }
        model: xmppConnectivity.roster
        delegate: RosterItemDelegate {width: rosterView.width }

        section.property: "groups"
        section.delegate: Rectangle {
            width: rosterView.width
            height: section != "" && vars.groupContacts ? 32 : 0
            color: "gray"
            Text {
                text: section
                font.pixelSize: platformStyle.fontSizeSmall
                font.bold: true
                color: "white"
                visible: section != "" && vars.groupContacts
                anchors { left: parent.left; leftMargin: platformStyle.paddingMedium; verticalCenter: parent.verticalCenter }
            }
        }

    }

    ScrollBar {
        anchors {
            top: parent.top
            bottom: rosterSearch.top
            right: parent.right
        }
        flickableItem: rosterView
        platformInverted: main.platformInverted
    }

    /*********************************************************************/

    TextField {
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
    }
}
