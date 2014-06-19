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
    property int splitscreenY:       0
    platformInverted:                settings.gBool("ui","invertPlatform")
    platformSoftwareInputPanelEnabled: true

    Globals { id: vars
        onAwaitingContextChanged: {
            if (!awaitingContext && dialogQmlFile != "") {
                dialog.create(dialogQmlFile)
                dialogQmlFile = "";
            }
        }

    }

    function getAccountStatusIcon()
    {
        if (xmppConnectivity.client.stateConnect === 2)
            return "qrc:/presence/unknown"
        else
            return "qrc:/presence/" + notify.getStatusNameByIndex(xmppConnectivity.client.status)
    }

    function openChat() {
        xmppConnectivity.resetUnreadMessages( xmppConnectivity.currentAccount, xmppConnectivity.chatJid )
        notify.updateNotifiers()

        if (pageStack.depth > 1) {
            if (!vars.isChatInProgress) pageStack.replace("qrc:/pages/Messages",{"contactName":xmppConnectivity.getPropertyByJid(xmppConnectivity.currentAccount,xmppConnectivity.chatJid,"name")}); else xmppConnectivity.emitQmlChat()
        } else pageStack.push("qrc:/pages/Messages",{"contactName":xmppConnectivity.getPropertyByJid(xmppConnectivity.currentAccount,xmppConnectivity.chatJid,"name")})
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

    Connections {
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

    Connections {
        target: xmppConnectivity
        onNotifyMsgReceived: {
            // handle global unread count. I should have both global and local unread count later
            if (!vars.isChatInProgress) {
                vars.globalUnreadCount++
                if (jid === xmppConnectivity.chatJid) vars.tempUnreadCount++
            } else if (jid !== xmppConnectivity.chatJid || !vars.isActive) vars.globalUnreadCount++

            // show discreet popup if enabled
            if (settings.gBool("notifications", "usePopupRecv") && (xmppConnectivity.chatJid !== jid || !vars.isActive)) {
                if (settings.gBool("behavior","msgInDiscrPopup"))
                        avkon.showPopup(name,body,settings.gBool("behavior","linkInDiscrPopup"))
                else
                    avkon.showPopup(vars.globalUnreadCount + " unread messages", "New message from "+ name + ".",settings.gBool("behavior","linkInDiscrPopup"))
            }

            // get the blinker running if enabled and app is inactive
            if (!vars.isActive && settings.gBool("behavior", "wibblyWobblyTimeyWimeyStuff")) blink.running = true;

            // play sound and vibration
            notify.notifySndVibr("MsgRecv")

            // update chats icon and widget if required
            notify.updateNotifiers()
        }
    }

    Connections {
        target: xmppConnectivity.client
        onConnectingChanged: {
            if (settings.gBool("notifications", "notifyConnection")) {
                if (xmppConnectivity.client.stateConnect === 0) {
                    avkon.showPopup(xmppConnectivity.currentAccountName,"Disconnected. :c",settings.gBool("behavior","linkInDiscrPopup"));
                }
                if (xmppConnectivity.client.stateConnect === 1) {
                    notify.notifySndVibr("NotifyConn")
                    avkon.showPopup(xmppConnectivity.currentAccountName,"Status changed to " + notify.getStatusNameByIndex(xmppConnectivity.client.status),settings.gBool("behavior","linkInDiscrPopup"));
                }
                if (xmppConnectivity.client.stateConnect === 2) {
                    avkon.showPopup(xmppConnectivity.currentAccountName,"Connecting...",settings.gBool("behavior","linkInDiscrPopup"));
                }
            }
        }
        onErrorHappened: {
            if (settings.gBool("behavior", "reconnectOnError"))
                dialog.create("qrc:/dialogs/Status/Reconnect")
        }
        onStatusChanged: {
            console.log( "XmppClient::onStatusChanged:" + xmppConnectivity.client.status )
            notify.updateNotifiers()
        }
        onVCardChanged: xmppVCard.vcard = xmppConnectivity.client.vcard
        onSubscriptionReceived: {
            console.log( "XmppClient::onSubscriptionReceived(" + bareJid + ")" )
            if (settings.gBool("notifications","notifySubscription") == true) avkon.showPopup("Subscription request",bareJid,settings.gBool("behavior","linkInDiscrPopup"))
            notify.notifySndVibr("MsgSub")            
            if (avkon.displayAvkonQueryDialog("Subscription", qsTr("Do you want to accept subscription request from ") + bareJid + qsTr("?"))) {
                xmppConnectivity.client.acceptSubscribtion(bareJid)
            } else {
                xmppConnectivity.client.rejectSubscribtion(bareJid)
            }

        }
        onTypingChanged: {
            if (settings.gBool("notifications", "notifyTyping") == true && (xmppConnectivity.chatJid !== bareJid || !vars.isActive) && xmppConnectivity.client.myBareJid !== bareJid) {
                if (isTyping) avkon.showPopup(xmppConnectivity.getPropertyByJid(xmppConnectivity.currentAccount,bareJid,"name"),"is typing a message...",settings.gBool("behavior","linkInDiscrPopup"))
                else avkon.showPopup(xmppConnectivity.getPropertyByJid(xmppConnectivity.currentAccount,bareJid,"name"),"stopped typing.",settings.gBool("behavior","linkInDiscrPopup"))
            }
        }
    } //XmppClient

    XmppConnectivity { id: xmppConnectivity }
    Settings { id: settings }
    XmppVCard { id: xmppVCard }

    Component.onCompleted: {
        if (settings.gStr("behavior","lastAccount") !== "false") changeAccount(settings.gStr("behavior","lastAccount"));
        checkIfFirstRun()
        xmppConnectivity.client.keepAlive = settings.gInt("behavior", "keepAliveInterval")
        xmppConnectivity.offlineContactsVisibility = !vars.hideOffline
    }

    /************************( stuff to do when running this app )*****************************/

    function checkIfFirstRun() {
        if (!settings.gBool("main","not_first_run")) pageStack.push("qrc:/pages/FirstRun")
        else pageStack.push("qrc:/pages/Roster")
    }

    function changeAccount(acc) {
        xmppConnectivity.changeAccount(acc);
        avkon.hideChatIcon()
        notify.updateNotifiers()
        settings.sStr(xmppConnectivity.currentAccount,"behavior","lastAccount")
    }

    /****************************( Dialog windows, menus and stuff)****************************/

    QtObject{
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

    Clipboard { id: clipboard }

    Notifications { id: notify }

    ListModel { id: listModelResources }

    StatusBar { id: sbar; y: -main.y
        Item {
                  anchors { left: parent.left; leftMargin: 6; verticalCenter: parent.verticalCenter }
                  width: sbar.width - 183; height: parent.height
                  clip: true;

                  Text{
                      id: statusBarText
                      anchors.verticalCenter: parent.verticalCenter
                      maximumLineCount: 1
                      color: "white"
                      font.pointSize: 6
                    }
                    Rectangle{
                        width: 25
                        anchors { top: parent.top; bottom: parent.bottom; right: parent.right }
                        rotation: -90

                        gradient: Gradient{
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
