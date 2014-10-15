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
import "../../global/qml"

PageStackWindow {
    id: main
    property int splitscreenY: 0
    property string textColor: main.platformInverted ? platformStyle.colorNormalDark : platformStyle.colorNormalLight
    property string midColor:  main.platformInverted ? platformStyle.colorNormalMid : platformStyle.colorNormalMidInverted
    property string disabledColor: main.platformInverted ? platformStyle.colorDisabledDark : platformStyle.colorDisabledLight

    function resetSplitscreen() {
        main.y = 0;
        main.splitscreenY = 0;
    }

    Connections {
        target: inputContext
        onVisibleChanged: inputContext.visible ? (main.y = main.splitscreenY > 0 ? 0-main.splitscreenY : 0) : resetSplitscreen();
    }

    platformInverted:                  settings.gBool("ui","invertPlatform")
    platformSoftwareInputPanelEnabled: true

    Globals {
        id: vars
        onAwaitingContextChanged: {
            if (!awaitingContext && dialogQmlFile != "" && vars.context != "") {
                dialog.createWithProperties(dialogQmlFile,{"accountId": vars.context})
                dialogQmlFile = "";
            }
        }

    }
    function openChat(account,name,jid,resource,type) {
        pageStack.push("qrc:/pages/Conversation",{"accountId":account,"contactName":name,"contactJid":jid,"contactResource":resource,"isInArchiveMode":false,"chatType":type})
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

    Timer {
        id: autoAway
        running: !vars.isActive && vars.autoAway
        repeat: false
        interval: 60000*vars.autoAwayTime
        onTriggered: xmppConnectivity.setGlobalAway()
    }

    Connections         {
        target: Qt.application
        onActiveChanged: {
            if (Qt.application.active) {
                vars.isActive = true
                blink.running = false

                if (xmppConnectivity.isRestoringNeeded() && vars.autoAway)
                    xmppConnectivity.restoreAllPrevStatuses()
            } else {
                vars.isActive = false
                if ((vars.globalUnreadCount>0 || vars.isBlinkingOverrideEnabled) && settings.gBool("behavior", "wibblyWobblyTimeyWimeyStuff")) blink.running = true
            }
        }
    }

    Connections    {
        target: xmppConnectivity
        onUnreadCountChanged: vars.globalUnreadCount = vars.globalUnreadCount+delta
        onXmppErrorHappened: if (settings.gBool("behavior", "reconnectOnError"))
                                 dialog.createWithProperties("qrc:/dialogs/Status/Reconnect",{"accountId": accountId})
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
    Clipboard           { id: clipboard }
    Notifications       { id: notify }

    /************************( stuff to do when running this app )*****************************/
    Component.onCompleted: {
        avkon.switchToApp = settings.gBool("behavior","linkInDiscrPopup")
        xmppConnectivity.offlineContactsVisibility = !vars.hideOffline
        avkon.setAppHiddenState(settings.gBool("behavior","hideFromTaskMgr"));

        var recvFilesPath = settings.gStr("paths","recvFiles");
        vars.receivedFilesPath = recvFilesPath == "false" ? "" : recvFilesPath

        if (!settings.gBool("behavior","disableUpdateChecker"))
            updater.checkForUpdate();

        if (!settings.gBool("main","not_first_run")) {
            if (migration.isMigrationPossible()) {
                if (avkon.displayAvkonQueryDialog("Migration","Fluorescent detected a settings file from older version of the app, would you like the app to import them?"))
                    pageStack.push("qrc:/pages/Migration")
                else
                    pageStack.push("qrc:/pages/FirstRun")
            } else
                pageStack.push("qrc:/pages/FirstRun")
        } else {
            settings.sStr(appVersion,"main","last_used_rel")

            if (!settings.gBool("behavior","isIAPSet"))
                dialog.create("qrc:/dialogs/AccessPointSelector")
            pageStack.push("qrc:/pages/Events")
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
            vars.context = ""
            vars.awaitingContext = true;
            vars.dialogQmlFile = qmlFile;
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
                font.bold: true
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
}
