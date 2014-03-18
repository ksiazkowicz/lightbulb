/********************************************************************

qml/Menus/ContactMenu.qml
-- contains contact menu, which appears on long tap

Copyright (c) 2014 Maciej Janiszewski

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

Menu {
    id: contactMenu
    platformInverted: main.platformInverted

    property bool shouldICareAnyway: false

    onStatusChanged: {
        if (status == DialogStatus.Closed && shouldICareAnyway) {
            vars.selectedJid = "";
            destroy();
        }
    }
    Component.onCompleted: {
        open()
        shouldICareAnyway = true;
    }

    // define the items in the menu and corresponding actions
    content: MenuLayout {
        MenuItem {
            text: qsTr("Remove")
            platformInverted: main.platformInverted
            onClicked: {
                xmppConnectivity.chatJid = vars.selectedJid
                contactMenu.close()
                if (avkon.displayAvkonQueryDialog("Remove", qsTr("Are you sure you want to remove ") + vars.dialogName + qsTr(" from your contact list?")))
                    xmppConnectivity.client.removeContact( vars.selectedJid );
            }
        }
        MenuItem {
            text: qsTr("Rename")
            platformInverted: main.platformInverted
            onClicked: {
                xmppConnectivity.chatJid = vars.selectedJid
                dialog.create("qrc:/dialogs/Contact/Rename")
            }
        }
        MenuItem {
            text: qsTr("vCard")
            platformInverted: main.platformInverted
            onClicked: {
                xmppConnectivity.chatJid = vars.selectedJid
                main.pageStack.push( "qrc:/pages/VCard" )
                xmppConnectivity.chatJid = vars.selectedJid
            }
        }
        MenuItem {
            text: qsTr("Subscribe")
            platformInverted: main.platformInverted
            onClicked: {
                xmppConnectivity.client.subscribe( vars.selectedJid )
                notify.postGlobalNote(qsTr("Sent request to ")+vars.dialogName)
            }
        }
        MenuItem {
            text: qsTr("Unsubscribe")
            platformInverted: main.platformInverted
            onClicked: {
                contactMenu.close()
                xmppConnectivity.client.unsubscribe( vars.selectedJid )
                notify.postGlobalNote(qsTr("Unsuscribed ")+vars.dialogName)
            }
        }
    }
}
