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

import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls.Universal 2.0
import lightbulb 1.0

ApplicationWindow {
    id: main
    visible: true
    Universal.theme: Universal.Dark
    width: 500
    height: 700
    Universal.accent: Universal.Violet

    StackView {
        id: stack
        anchors.fill: parent
    }

    Item {
        property int                     globalUnreadCount: 0
        property string                  lastStatus: settings.gBool("behavior", "lastStatusText") ? settings.gStr("behavior","lastStatusText") : ""
        signal                           statusChanged
        property int                     lastUsedStatus: 0
        signal                           statusTextChanged
        property bool                    isActive: true
        property string                  context: ""

        // auto-away
        property bool                    autoAway: settings.gBool("behavior","autoAway")
        property int                     autoAwayTime: settings.gInt("behavior","autoAwayTime")

        // settings
        property bool                    areEmoticonsDisabled: settings.gBool("behavior","disableEmoticons")
        property int                     keepAliveInterval: settings.gInt("behavior","keepAliveInterval")
        property string                  defaultMUCNick: settings.gStr("behavior","defaultMUCNick")
        property string                  receivedFilesPath: settings.gStr("paths","recvFiles")

        property bool                    isRestartRequired: false
        property bool                    isBlinkingOverrideEnabled: false

        // roster
        property bool                    hideOffline: settings.gBool("ui","hideOffline")
        property int                     rosterItemHeight: settings.gInt("ui","rosterItemHeight")
        property bool                    showContactStatusText: settings.gBool("ui","showContactStatusText")
        property bool                    rosterLayoutAvatar: settings.gBool("ui","rosterLayoutAvatar")
        property string                  selectedJid: ""
        property bool                    awaitingContext: false
        property string                  dialogQmlFile: ""
        property bool					 showGroupTag: settings.gBool("ui", "rosterGroupTag")
        property bool					 groupContacts: settings.gBool("ui", "rosterGroupContacts")

        id: vars
        onAwaitingContextChanged: {
            if (!awaitingContext && dialogQmlFile != "") {
                dialog.createWithProperties(dialogQmlFile,{"accountId": vars.context})
                dialogQmlFile = "";
            }
        }

    }

    function openChat(account,name,jid,type) {
        stack.push("qrc:/Pages/Conversation",{"accountId":account,"contactName":name,"contactJid":jid,"isInArchiveMode":false,"chatType":type})
    }

    Timer {
        id: blink
        interval: 100
        running: true
        repeat:true
        property int blinkStatus: 0
        onTriggered: {
            if (vars.globalUnreadCount>0 || vars.isBlinkingOverrideEnabled) {
                //if (blinkStatus < 4) { avkon.notificationBlink(settings.gInt("notifications", "blinkScreenDevice")); blinkStatus++ } else { if (blinkStatus > 6) { blinkStatus = 0} else { blinkStatus++ } }
            } else { blinkStatus = 0; blink.running = false }
        }
    }

    Connections {
        target: xmppConnectivity
        onUnreadCountChanged: vars.globalUnreadCount = vars.globalUnreadCount+delta
        onXmppConnectingChanged: {
            /*if (xmppConnectivity.useClient(accountId).getStateConnect() == 1)
                main.color = "yellow";
            if (xmppConnectivity.useClient(accountId).getStateConnect() == 0)
                main.color = "red";
            if (xmppConnectivity.useClient(accountId).getStateConnect() == 2)
                main.color = "green";*/
        }
        onXmppErrorHappened: if (settings.gBool("behavior", "reconnectOnError"))
                                dialog.createWithProperties("qrc:/dialogs/Status/Reconnect",{"accountId": accountId})
        onXmppSubscriptionReceived: {
            /*if (avkon.displayAvkonQueryDialog("Subscription (" + getAccountName(accountId) + ")", qsTr("Do you want to accept subscription request from ") + bareJid + qsTr("?")))
                xmppConnectivity.useClient(accountId).acceptSubscription(bareJid)
            else
                xmppConnectivity.useClient(accountId).rejectSubscription(bareJid)*/
        }
        /*onMucInvitationReceived: {
            if (avkon.displayAvkonQueryDialog("Invitation (" + getAccountName(accountId) + ")", invSender + " invites you to chatroom " + bareJid + qsTr(". Do you want to join?")))
                dialog.createWithProperties("qrc:/dialogs/MUC/Join",{"accountId":accountId,"mucJid":bareJid})
        }*/
    }

    Connections {
        target: settings
        onAccountAdded: xmppConnectivity.accountAdded(accId)
        onAccountRemoved: xmppConnectivity.accountRemoved(accId)
        onAccountEdited: xmppConnectivity.accountModified(accId)
    }

    ListModel           { id: listModelResources }

    /************************( stuff to do when running this app )*****************************/
    Component.onCompleted: {
		xmppConnectivity.offlineContactsVisibility = !vars.hideOffline

        if (!settings.gBool("main","not_first_run")) {
            //pageStack.push("qrc:/pages/FirstRun")
        } else {
            settings.sStr(appVersion,"main","last_used_rel")

            //if (!settings.gBool("behavior","isIAPSet"))
            //    dialog.create("qrc:/dialogs/AccessPointSelector")
            //pageStack.push("qrc:/pages/Events")
        }

        stack.push("qrc:/Pages/MainPage")
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

            var newObject = c.createObject(main, properties);

        }
        function createWithContext(qmlFile) {
            c=Qt.createComponent("qrc:/dialogs/AccountSwitcher")
            c.createObject(main)
            vars.awaitingContext = true;
            vars.dialogQmlFile = qmlFile;
        }
    }

    NetworkManager {
        id: network
    }
}
