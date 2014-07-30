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

ContextMenu {
    id: contactMenu
    platformInverted: main.platformInverted

    property string contactName: ""
    property string contactJid:  ""
    property string accountId: ""
    property bool shouldICareAnyway: false

    onStatusChanged: {
        if (contactMenu.status == DialogStatus.Closed && shouldICareAnyway) {
            vars.selectedJid = "";
            contactMenu.destroy();
        }
    }
    Component.onCompleted: {
        open()
        shouldICareAnyway = true;
    }

    // define the items in the menu and corresponding actions
    MenuLayout {
        MenuItem {
            text: qsTr("Remove")
            platformInverted: main.platformInverted
            onClicked: {
                if (avkon.displayAvkonQueryDialog("Remove", qsTr("Are you sure you want to remove ") + contactName + qsTr(" from your contact list?")))
                    xmppConnectivity.removeContact(accountId,contactJid);
            }
        }
        MenuItem {
            text: qsTr("Rename")
            platformInverted: main.platformInverted
            onClicked: dialog.createWithProperties("qrc:/dialogs/Contact/Rename",{"accountId": accountId,"contactName": contactName, "contactJid": contactJid})
        }
        MenuItem {
            text: "Archive"
            platformInverted: main.platformInverted
            onClicked: {
                xmppConnectivity.page = 1
                pageStack.push("qrc:/pages/Conversation",{"accountId": accountId,"contactName":contactName,"contactJid":contactJid,"isInArchiveMode":true})
            }
        }

        MenuItem {
            text: qsTr("vCard")
            platformInverted: main.platformInverted
            onClicked: main.pageStack.push("qrc:/pages/VCard",{"accountId": accountId,"contactJid":contactJid,"contactName":contactName})
        }
        MenuItem {
            text: qsTr("Subscribe")
            platformInverted: main.platformInverted
            onClicked: {
                xmppConnectivity.subscribe(accountId,contactJid)
                notify.postGlobalNote(qsTr("Sent request to ")+contactName)
            }
        }
        MenuItem {
            text: qsTr("Unsubscribe")
            platformInverted: main.platformInverted
            onClicked: {
                contactMenu.close()
                xmppConnectivity.unsubscribe(accountId,contactJid)
                notify.postGlobalNote(qsTr("Unsuscribed ")+contactName)
            }
        }
    }
}
