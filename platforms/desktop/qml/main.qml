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
import "Components"

ApplicationWindow {
    id: main
    visible: true
    Universal.theme: Universal.Dark
    width: 1024
    height: 700
    Universal.accent: Universal.Amber
    property string textColor: "white"
    property string midColor: "gray"

    function switch_sidepages(page) {
        if (page == "roster") {
            rosterSwitcher.selected = true
            eventsSwitcher.selected = false
        }
        if (page == "events") {
            rosterSwitcher.selected = false
            eventsSwitcher.selected = true
        }
    }

    Rectangle {
        id: drawer
        property bool isOpen: false
        color: "#2B2B2B"
        width: isOpen ? Math.min(main.width, 200) : 48
        anchors {
            top: parent.top; bottom: parent.bottom; left: parent.left;
        }

        function open() {
            isOpen = !isOpen;
        }

        ColumnLayout {
            id: listView
            anchors.fill: parent

            ToolButton {
                text: "\uE700"
                font.family: "Segoe MDL2 Assets"
                font.pixelSize: 16
                onClicked: drawer.open()
                implicitWidth: 48; implicitHeight: 48;
            }
            Rectangle {
                id: rosterSwitcher
                height: 48
                width: 200
                property bool selected: false
                color: selected ? "#1f1f1f" : "transparent"
                ToolButton {
                    id: rosterBtn
                    implicitWidth: 48; implicitHeight: 48;
                    text: "\uE780"
                    font.pixelSize: 16
                    font.family: "Segoe MDL2 Assets"
                    onClicked: { sideStack.replace( "qrc:/Pages/RosterPage" ); switch_sidepages("roster"); }
                }
                Label {
                    anchors { left: rosterBtn.right; verticalCenter: parent.verticalCenter }
                    text: "Contacts"
                }
            }
            Rectangle {
                id: eventsSwitcher
                height: 48
                width: 200
                property bool selected: true
                color: selected ? "#1f1f1f" : "transparent"
                ToolButton {
                    id: eventsBtn
                    implicitWidth: 48; implicitHeight: 48;
                    text: "\uE8BD"
                    font.pixelSize: 16
                    font.family: "Segoe MDL2 Assets"
                    onClicked: { sideStack.replace( "qrc:/Pages/MainPage" ); switch_sidepages("events"); }
                }
                Label {
                    anchors { left: eventsBtn.right; verticalCenter: parent.verticalCenter }
                    text: "Events"
                }
            }
            Item { Layout.fillHeight: true }
            ToolButton {
                text: "\uE713"
                font.family: "Segoe MDL2 Assets"
                onClicked: mainStack.push("qrc:/Pages/AccountPage")
                font.pixelSize: 16
                implicitWidth: 48; implicitHeight: 48;
            }

            AccountHamburgerPersonality {}
            Repeater { delegate: AccountHamburgerDelegate { } model: settings.accounts }
        }
    }

    StackView {
        id: sideStack
        width: 320
        anchors { left: drawer.right; top: parent.top; bottom: parent.bottom; }
        pushEnter: Transition { PropertyAnimation { property: "opacity"; from: 1; to: 1; duration: 0}}
        pushExit: Transition { PropertyAnimation { property: "opacity"; from: 1; to: 1; duration: 0}}
        popEnter: Transition { PropertyAnimation { property: "opacity"; from: 1; to: 1; duration: 0}}
        popExit: Transition { PropertyAnimation { property: "opacity"; from: 1; to: 1; duration: 0}}
        replaceEnter: Transition { PropertyAnimation { property: "opacity"; from: 1; to: 1; duration: 0}}
        replaceExit: Transition { PropertyAnimation { property: "opacity"; from: 1; to: 1; duration: 0}}

    }


    StackView {
        id: mainStack
        width: main.width - sideStack.width - 48
        anchors { left: sideStack.right; top: parent.top; bottom: parent.bottom; }
        pushEnter: Transition { PropertyAnimation { property: "opacity"; from: 1; to: 1; duration: 0}}
        pushExit: Transition { PropertyAnimation { property: "opacity"; from: 1; to: 1; duration: 0}}
        popEnter: Transition { PropertyAnimation { property: "opacity"; from: 1; to: 1; duration: 0}}
        popExit: Transition { PropertyAnimation { property: "opacity"; from: 1; to: 1; duration: 0}}
        replaceEnter: Transition { PropertyAnimation { property: "opacity"; from: 1; to: 1; duration: 0}}
        replaceExit: Transition { PropertyAnimation { property: "opacity"; from: 1; to: 1; duration: 0}}
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
        mainStack.push("qrc:/Pages/Conversation",{"accountId":account,"contactName":name,"contactJid":jid,"isInArchiveMode":false,"chatType":type})
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

        sideStack.push("qrc:/Pages/MainPage")
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
}
