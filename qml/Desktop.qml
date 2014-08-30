/********************************************************************

qml/main.qml
-- Main QML file, contains PageStack and loads globally available
-- objects

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
import QtQuick.Controls 1.2
import lightbulb 1.0

ApplicationWindow {
    id: main
    visible: true
    width: 320
    minimumWidth: 320
    height: 480
    minimumHeight: 200
    title: qsTr("Lightbulb")

    Globals {
        id: vars
        onAwaitingContextChanged: {
            if (!awaitingContext && dialogQmlFile != "") {
                dialog.createWithProperties(dialogQmlFile,{"accountId": vars.context})
                dialogQmlFile = "";
            }
        }

    }
    function openChat(account,name,jid,type) {
        //pageStack.push("qrc:/pages/Conversation",{"accountId":account,"contactName":name,"contactJid":jid,"isInArchiveMode":false,"chatType":type})
    }

    Timer {
        id: blink
        interval: 100
        running: true
        repeat:true
        property int blinkStatus: 0
        onTriggered: {
            if (vars.globalUnreadCount>0 || vars.isBlinkingOverrideEnabled) {
                if (blinkStatus < 4) { avkon.notificationBlink(settings.gInt("notifications", "blinkScreenDevice")); blinkStatus++ } else { if (blinkStatus > 6) { blinkStatus = 0} else { blinkStatus++ } }
            } else { blinkStatus = 0; blink.running = false }
        }
    }

    Connections         {
        target: Qt.application
        onActiveChanged: {
            if (Qt.application.active) {
                vars.isActive = true
                blink.running = false
            } else {
                vars.isActive = false
                if ((vars.globalUnreadCount>0 || vars.isBlinkingOverrideEnabled) && settings.gBool("behavior", "wibblyWobblyTimeyWimeyStuff")) blink.running = true
            }
        }
    }

    Connections {
        target: xmppConnectivity
        onUnreadCountChanged: vars.globalUnreadCount = vars.globalUnreadCount+delta
        onXmppErrorHappened: if (settings.gBool("behavior", "reconnectOnError"))
                                dialog.createWithProperties("qrc:/dialogs/Status/Reconnect",{"accountId": accountId})
        onXmppSubscriptionReceived: {
            if (avkon.displayAvkonQueryDialog("Subscription (" + getAccountName(accountId) + ")", qsTr("Do you want to accept subscription request from ") + bareJid + qsTr("?")))
                xmppConnectivity.useClient(accountId).acceptSubscription(bareJid)
            else
                xmppConnectivity.useClient(accountId).rejectSubscription(bareJid)
        }
        onMucInvitationReceived: {
            if (avkon.displayAvkonQueryDialog("Invitation (" + getAccountName(accountId) + ")", invSender + " invites you to chatroom " + bareJid + qsTr(". Do you want to join?")))
                dialog.createWithProperties("qrc:/dialogs/MUC/Join",{"accountId":accountId,"mucJid":bareJid})
        }
    }

    Connections {
        target: settings
        onAccountAdded: xmppConnectivity.accountAdded(accId)
        onAccountRemoved: xmppConnectivity.accountRemoved(accId)
        onAccountEdited: xmppConnectivity.accountModified(accId)
    }

    Connections {
        target: updater
        onUpdateFound: xmppConnectivity.pushUpdate(version, date)
        onVersionUpToDate: xmppConnectivity.pushNoUpdate()
        onErrorOccured: xmppConnectivity.pushSystemError("Update check failed. "+errorString)
    }

    NetworkManager  {
        id: network
        currentIAP: settings.gInt("behavior","internetAccessPoint");
    }

    ListModel           { id: listModelResources }
    Notifications       { id: notify }

    /************************( stuff to do when running this app )*****************************/
    Component.onCompleted: {
		xmppConnectivity.offlineContactsVisibility = !vars.hideOffline

        if (!settings.gBool("main","not_first_run")) {
            //if (migration.isMigrationPossible()) {
                //if (avkon.displayAvkonQueryDialog("Migration","Fluorescent detected a settings file from older version of the app, would you like the app to import them?"))
                   // pageStack.push("qrc:/pages/Migration")
                //else
                   // pageStack.push("qrc:/pages/FirstRun")
            //} else
               //pageStack.push("qrc:/pages/FirstRun")
        } else {
            settings.sStr(appVersion,"main","last_used_rel")

            if (!settings.gBool("behavior","isIAPSet"))
                dialog.create("qrc:/dialogs/AccessPointSelector")
            //pageStack.push("qrc:/pages/Events")
        }
    }
    /****************************( Dialog windows, menus and stuff)****************************/

    QtObject  {
        id:dialog;
        property Component c:null;

        function create(qmlfile){
            c=Qt.createComponent(qmlfile);
            c.createObject(main)
        }
        function createWithProperties(qmlfile, properties){
            c=Qt.createComponent(qmlfile);
            c.createObject(main, properties)
        }
        function createWithContext(qmlFile) {
            c=Qt.createComponent("qrc:/dialogs/AccountSwitcher")
            c.createObject(main)
            vars.awaitingContext = true;
            vars.dialogQmlFile = qmlFile;
        }
    }
}
