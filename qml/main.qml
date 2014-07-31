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
import com.nokia.symbian 1.1
import com.nokia.extras 1.1
import lightbulb 1.0

PageStackWindow {
    id: main
    property int splitscreenY:         0

    Connections {
        target: inputContext
        onVisibleChanged: inputContext.visible ? (y = splitscreenY > 0 ? 0-splitscreenY : 0) : y = 0
    }

    platformInverted:                  settings.gBool("ui","invertPlatform")
    platformSoftwareInputPanelEnabled: true

    Globals { id: vars
        onAwaitingContextChanged: {
            if (!awaitingContext && dialogQmlFile != "") {
                dialog.create(dialogQmlFile)
                dialogQmlFile = "";
            }
        }

    }
    function openChat(account,jid) {
        console.log("updating globalUnreadCount")
        console.log(vars.globalUnreadCount)
        console.log(xmppConnectivity.getPropertyByJid(account,"unreadMsg",jid))
        vars.globalUnreadCount = vars.globalUnreadCount - parseInt(xmppConnectivity.getPropertyByJid(account,"unreadMsg",jid))
        console.log(vars.globalUnreadCount)
        xmppConnectivity.resetUnreadMessages(account,jid)
        notify.updateNotifiers()

        if (pageStack.depth > 1) {
            pageStack.replace("qrc:/pages/Conversation",{"accountId":account,"contactName":xmppConnectivity.getPropertyByJid(account,"name",jid),"contactJid":jid,"isInArchiveMode":false})
        } else
            pageStack.push("qrc:/pages/Conversation",{"accountId":account,"contactName":xmppConnectivity.getPropertyByJid(account,"name",jid),"contactJid":jid,"isInArchiveMode":false})
    }

    Timer               {
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
                if (xmppConnectivity.chatJid != "") {
                    vars.globalUnreadCount = vars.globalUnreadCount - vars.tempUnreadCount
                }
                vars.tempUnreadCount = 0
                if (vars.globalUnreadCount<0) vars.globalUnreadCount = 0
                notify.updateNotifiers()
            } else {
                vars.isActive = false
                if ((vars.globalUnreadCount>0 || vars.isBlinkingOverrideEnabled) && settings.gBool("behavior", "wibblyWobblyTimeyWimeyStuff")) blink.running = true
            }
        }
    }

    XmppConnectivity    {
        id: xmppConnectivity
        onXmppErrorHappened: if (settings.gBool("behavior", "reconnectOnError"))
                                dialog.createWithProperties("qrc:/dialogs/Status/Reconnect",{"accountId": accountId})
        onXmppSubscriptionReceived: {
            if (avkon.displayAvkonQueryDialog("Subscription (" + getAccountName(accountId) + ")", qsTr("Do you want to accept subscription request from ") + bareJid + qsTr("?")))
                acceptSubscribtion(accountId,bareJid)
            else
                rejectSubscribtion(accountId,bareJid)
        }
    }
	
    Settings {
        id: settings
        onAccountAdded: xmppConnectivity.accountAdded(accId)
        onAccountRemoved: xmppConnectivity.accountRemoved(accId)
        onAccountEdited: xmppConnectivity.accountModified(accId)
    }

    NetworkManager  {
        id: network
        currentIAP: settings.gInt("behavior","internetAccessPoint");
    }
    Clipboard           { id: clipboard }
    Notifications       { id: notify }
    ListModel           { id: listModelResources }
    MigrationManager    { id: migration }

    /************************( stuff to do when running this app )*****************************/
    Component.onCompleted:      {
        avkon.switchToApp = settings.gBool("behavior","linkInDiscrPopup")
		xmppConnectivity.offlineContactsVisibility = !vars.hideOffline
        avkon.setAppHiddenState(settings.gBool("behavior","hideFromTaskMgr"));

        if (!settings.gBool("main","not_first_run")) {
            if (migration.isMigrationPossible()) {
                if (avkon.displayAvkonQueryDialog("Migration","Fluorescent detected a settings file from older version of the app, would you like the app to import them?"))
                    pageStack.push("qrc:/pages/Migration")
                else
                    pageStack.push("qrc:/pages/FirstRun")
            } else
                pageStack.push("qrc:/pages/FirstRun")
        } else {
            settings.sStr(xmppConnectivity.client.version,"main","last_used_rel")

            if (!settings.gBool("behavior","isIAPSet"))
                dialog.create("qrc:/dialogs/AccessPointSelector")
            pageStack.push("qrc:/pages/Events")
        }
    }
    function changeAccount(acc) {
        xmppConnectivity.changeAccount(acc);
        notify.updateNotifiers()
        settings.sStr(xmppConnectivity.currentAccount,"behavior","lastAccount")
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
    }
    StatusBar {
        y: -main.y
        Item {
            anchors { left: parent.left; leftMargin: 6; bottom: parent.bottom; top: parent.top }
            width: parent.width - 186;
            clip: true
            Text {
                id: statusBarText
                anchors.verticalCenter: parent.verticalCenter
                maximumLineCount: 1
                color: "white"
                font.pointSize: 6
             }
             Rectangle {
                width: 25
                anchors { top: parent.top; bottom: parent.bottom; right: parent.right }
                rotation: -90
                gradient: Gradient {
                            GradientStop { position: 0.0; color: "#00000000" }
                            GradientStop { position: 1.0; color: "#ff000000" }
                        }
             }
        }
        Connections {
            target: pageStack
            onCurrentPageChanged: statusBarText.text = pageStack.currentPage.pageName
        }
    }
    /***************(overlay)**********/
    /*Rectangle {
        color: main.platformInverted ? "white" : "black"
        anchors.fill: parent
        visible: xmppConnectivity.client.stateConnect === 2
        opacity: 0.7

        Column {
            anchors.centerIn: parent;
            BusyIndicator { anchors.horizontalCenter: parent.horizontalCenter; running: true }
            Text {
                text: "Connecting..."
                color: vars.textColor
                font.pixelSize: platformStyle.fontSizeSmall
            }
        }
    }*/
}
