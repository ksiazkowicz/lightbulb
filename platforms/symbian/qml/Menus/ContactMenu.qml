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
    property string contactGroup: ""
    property bool isFavorite: false
    property bool shouldICareAnyway: false

    property bool isFacebook: xmppConnectivity.useClient(accountId).isFacebook()
    property bool isConnected: xmppConnectivity.useClient(accountId).isConnected

    onStatusChanged: {
        if (contactMenu.status == DialogStatus.Closed && shouldICareAnyway) {
            contactMenu.destroy();
            if (pageStack.currentPage.pageName == "Contacts")
                pageStack.currentPage.selectedJid = "";
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
            enabled: !(isFacebook || !isConnected)
            height: enabled ? privateStyle.menuItemHeight : 0
            clip: true
            onClicked: {
                if (avkon.displayAvkonQueryDialog("Remove", qsTr("Are you sure you want to remove ") + contactName + qsTr(" from your contact list?"))) {
                    xmppConnectivity.useClient(accountId).removeContact(contactJid);
                    avkon.showPopup("Contact " + contactName,"was removed from contact list.")
                }
            }
        }
        MenuItem {
            text: qsTr("Rename")
            platformInverted: main.platformInverted
            enabled: !(isFacebook || !isConnected)
            height: enabled ? privateStyle.menuItemHeight : 0
            clip: true
            onClicked: dialog.createWithProperties("qrc:/dialogs/Contact/Rename",{"accountId": accountId,"contactName": contactName, "contactJid": contactJid})
        }
        MenuItem {
            text: qsTr("Set group")
            platformInverted: main.platformInverted
            enabled: !(isFacebook || !isConnected)
            height: enabled ? privateStyle.menuItemHeight : 0
            clip: true
            onClicked: dialog.createWithProperties("qrc:/dialogs/Contact/Group",{"accountId": accountId, "contactJid": contactJid, "contactName": contactName, "contactGroup": contactGroup})
        }
        MenuItem {
            text: "Archive"
            platformInverted: main.platformInverted
            onClicked: pageStack.replace("qrc:/pages/Conversation",{"accountId": accountId,"contactName":contactName,"contactJid":contactJid,"isInArchiveMode":true})
        }

        MenuItem {
            text: qsTr("vCard")
            platformInverted: main.platformInverted
            onClicked: {
                pageStack.currentPage.selectedJid = "";
                main.pageStack.push("qrc:/pages/VCard",{"accountId": accountId,"contactJid":contactJid,"contactName":contactName})
            }
        }
        MenuItem {
            text: qsTr("Refresh")
            platformInverted: main.platformInverted
            enabled: isConnected
            height: enabled ? privateStyle.menuItemHeight : 0

            onClicked: {
                xmppConnectivity.useClient(accountId).forceRefreshVCard(contactJid)
                avkon.showPopup("Refreshing VCard for",contactName)
            }
        }
        MenuItem {
            text: !isFavorite ? qsTr("Mark as fav.") : qsTr("Unfav. contact")
            platformInverted: main.platformInverted
            onClicked: {
                xmppConnectivity.useClient(accountId).setFavContact(contactJid,!isFavorite)
                var body = !isFavorite ? "is now favorite" : "is no longer favorite"
                avkon.showPopup("Contact " + contactName,body)
            }
        }
        MenuItem {
            text: qsTr("Subscribe")
            platformInverted: main.platformInverted
            enabled: !(isFacebook || !isConnected)
            height: enabled ? privateStyle.menuItemHeight : 0
            clip: true
            onClicked: {
                xmppConnectivity.useClient(accountId).subscribe(contactJid)
                avkon.showPopup("Sent sub. request to",contactName)
            }
        }
        MenuItem {
            text: qsTr("Unsubscribe")
            platformInverted: main.platformInverted
            enabled: !(isFacebook || !isConnected)
            height: enabled ? privateStyle.menuItemHeight : 0
            clip: true
            onClicked: {
                contactMenu.close()
                xmppConnectivity.useClient(accountId).unsubscribe(contactJid)
                avkon.showPopup(contactName,"is no longer subscribed")
            }
        }
    }
}
