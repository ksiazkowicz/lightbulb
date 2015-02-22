/********************************************************************

qml/Preflets/Roster.qml
-- Preflet with contact list options

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

Item {
    height: content.height
    Column {
        id: content
        spacing: 5
        anchors { top: parent.top; topMargin: 10; left: parent.left; leftMargin: 10; right: parent.right; rightMargin: 10 }
        CheckBox {
           id: hideOffline
           text: qsTr("Hide Offline contacts")
           platformInverted: main.platformInverted
           checked: settings.gBool("ui", "hideOffline")
           onCheckedChanged: {
              settings.sBool(checked,"ui", "hideOffline")
               vars.hideOffline = checked;
              xmppConnectivity.offlineContactsVisibility = !checked;
           }
        }
        CheckBox {
           id: showContactStatusText
           text: qsTr("Show contacts status text")
           platformInverted: main.platformInverted
           checked: settings.gBool("ui", "showContactStatusText")
           onCheckedChanged: {
              settings.sBool(checked,"ui", "showContactStatusText")
               vars.showContactStatusText = checked;
           }
        }
        CheckBox {
           id: rosterLayout
           text: qsTr("Show avatars")
           platformInverted: main.platformInverted
           checked: settings.gBool("ui", "rosterLayoutAvatar")
           onCheckedChanged: {
              settings.sBool(checked,"ui", "rosterLayoutAvatar")
              vars.rosterLayoutAvatar = checked;
           }
        }

        CheckBox {
           id: showGroupTag
           text: qsTr("Show group tag")
           platformInverted: main.platformInverted
           checked: settings.gBool("ui", "rosterGroupTag")
           onCheckedChanged: {
              settings.sBool(checked,"ui", "rosterGroupTag")
              vars.showGroupTag = checked;
           }
        }

        CheckBox {
           id: groupContacts
           text: qsTr("Group contacts")
           platformInverted: main.platformInverted
           checked: settings.gBool("ui", "rosterGroupContacts")
           onCheckedChanged: {
              settings.sBool(checked,"ui", "rosterGroupContacts")
              vars.groupContacts = checked;
              xmppConnectivity.contactGroupingEnabled = checked
           }
        }
    }
}

