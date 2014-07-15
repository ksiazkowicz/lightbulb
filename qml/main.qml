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
    platformInverted:                  settings.gBool("ui","invertPlatform")
    platformSoftwareInputPanelEnabled: true

    function openChat() {
        xmppConnectivity.client.resetUnreadMessages( xmppConnectivity.chatJid )
        notify.updateNotifiers()

        if (pageStack.depth > 1) {
            if (!vars.isChatInProgress) pageStack.replace("qrc:/pages/Messages",{"contactName":xmppConnectivity.client.getPropertyByJid(xmppConnectivity.chatJid,"name")}); else xmppConnectivity.emitQmlChat()
        } else pageStack.push("qrc:/pages/Messages",{"contactName":xmppConnectivity.client.getPropertyByJid(xmppConnectivity.chatJid,"name")})
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
                    vars.isChatInProgress = true
                    vars.globalUnreadCount = vars.globalUnreadCount - vars.tempUnreadCount
                }
                vars.tempUnreadCount = 0
                if (vars.globalUnreadCount<0) vars.globalUnreadCount = 0
                notify.updateNotifiers()
            } else {
                vars.isActive = false
                if ((vars.globalUnreadCount>0 || vars.isBlinkingOverrideEnabled) && settings.gBool("behavior", "wibblyWobblyTimeyWimeyStuff")) blink.running = true
                vars.isChatInProgress = false
            }
        }
    }

    XmppConnectivity    {
        id: xmppConnectivity
        onNotifyMsgReceived: {
            // handle global unread count. I should have both global and local unread count later
            if (!vars.isChatInProgress) {
                vars.globalUnreadCount++
                if (jid === chatJid) vars.tempUnreadCount++
            } else if (jid !== chatJid || !vars.isActive) vars.globalUnreadCount++

            // show discreet popup if enabled
            if (settings.gBool("notifications", "usePopupRecv") && (chatJid !== jid || !vars.isActive)) {
                if (settings.gBool("behavior","msgInDiscrPopup"))
                        avkon.showPopup(name,body)
                else
                    avkon.showPopup(vars.globalUnreadCount + " unread messages", "New message from "+ name + ".")
            }

            // get the blinker running if enabled and app is inactive
            if (!vars.isActive && settings.gBool("behavior", "wibblyWobblyTimeyWimeyStuff")) blink.running = true;

            // play sound and vibration
            notify.notifySndVibr("MsgRecv")

            // update chats icon and widget if required
            notify.updateNotifiers()
        }
        onXmppConnectingChanged: {
            if (settings.gBool("notifications", "notifyConnection")) {
                switch (getConnectionStatusByAccountId(accountId)) {
                    case 0:
                        avkon.showPopup(getAccountName(accountId),"Disconnected. :c");
                        break;
                    case 1:
                        notify.notifySndVibr("NotifyConn")
                        avkon.showPopup(getAccountName(accountId),"Status changed to " + notify.getStatusNameByIndex(xmppConnectivity.client.status));
                        break;
                    case 2:
                        avkon.showPopup(getAccountName(accountId),"Connecting...");
                        break;
                }
            }
        }
        onXmppErrorHappened: {
            if (settings.gBool("behavior", "reconnectOnError"))
                dialog.createWithProperties("qrc:/dialogs/Status/Reconnect",{"accountId": accountId})
        }
        onXmppStatusChanged: {
            console.log( "XmppClient::onStatusChanged (" + accountId + ")" + getStatusByAccountId(accountId) )
            if (accountId == currentAccount)
                notify.updateNotifiers()
        }
        onXmppSubscriptionReceived: {
            console.log( "XmppConnectivity::onXmppSubscriptionReceived(" + accountId + "," + bareJid + ")" )
            if (settings.gBool("notifications","notifySubscription") == true)
                avkon.showPopup("Subscription request",bareJid)

            notify.notifySndVibr("MsgSub")

            if (avkon.displayAvkonQueryDialog("Subscription (" + getAccountName(accountId) + ")", qsTr("Do you want to accept subscription request from ") + bareJid + qsTr("?")))
                acceptSubscribtion(accountId,bareJid)
            else
                rejectSubscribtion(accountId,bareJid)

        }
        onXmppTypingChanged: {
            console.log( "XmppConnectivity::onXmppTypingChanged(" + accountId + "," + bareJid + "," + isTyping + ")" )
            if (settings.gBool("notifications", "notifyTyping") == true &&
               (chatJid !== bareJid || !vars.isActive) &&
               (currentAccount == accountId && client.myBareJid !== bareJid)) {
                if (isTyping)
                    avkon.showPopup(getPropertyByJid(accountId,"name",bareJid),"is typing a message...")
                else
                    avkon.showPopup(getPropertyByJid(accountId,"name",bareJid),"stopped typing.")
            }
        }
    }
    Settings            { id: settings }
    Clipboard           { id: clipboard }
    Notifications       { id: notify }
    ListModel           { id: listModelResources }
    NetworkManager      {
        id: network
        currentIAP: settings.gInt("behavior","internetAccessPoint");
    }
    MigrationManager    { id: migration }
    Globals             { id: vars }

    /************************( stuff to do when running this app )*****************************/
    Component.onCompleted:      {
        avkon.switchToApp = settings.gBool("behavior","linkInDiscrPopup")
        if (settings.gStr("behavior","lastAccount") !== "false")
            changeAccount(settings.gStr("behavior","lastAccount"));

        if (!settings.gBool("main","not_first_run")) {
            if (migration.isMigrationPossible())
                if (avkon.displayAvkonQueryDialog("Migration","Lightbulb detected a settings file from older version of the app, would you like the app to import them?"))
                    pageStack.push("qrc:/pages/Migration")
                else
                    pageStack.push("qrc:/pages/FirstRun")
            else
                pageStack.push("qrc:/pages/FirstRun")
        } else {
            if (!settings.gBool("behavior","isIAPSet"))
                dialog.create("qrc:/dialogs/AccessPointSelector")
            pageStack.push("qrc:/pages/Roster")
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
    }

    /***************( splitscreen input )***************/
    Item {
        id: splitViewInput
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }

        states: [
            State {
                name: "Visible"; when: inputContext.visible
                PropertyChanges { target: splitViewInput; height: inputContext.height }
                PropertyChanges { target: vars; inputInProgress: true }
                PropertyChanges { target: main; y: splitscreenY > 0 ? 0-splitscreenY : 0 }
            },
            State {
                name: "Hidden"; when: !inputContext.visible
                PropertyChanges { target: splitViewInput; }
                PropertyChanges { target: vars; inputInProgress: false }
            }
        ]
    }
    /***************(overlay)**********/
    Rectangle {
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
    }
}
