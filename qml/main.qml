import QtQuick 1.1
import com.nokia.symbian 1.1
import com.nokia.extras 1.1
import lightbulb 1.0

PageStackWindow {
    id: main
    property int splitscreenY:       0
    platformInverted:                settings.gBool("ui","invertPlatform")

    Globals { id: vars }

    function openChat() {
        xmppConnectivity.client.resetUnreadMessages( xmppConnectivity.chatJid )
        if (settings.gBool("behavior","enableHsWidget")) notify.updateNotifiers()

        if (pageStack.depth > 1) pageStack.replace("qrc:/pages/Messages")
        else pageStack.push("qrc:/pages/Messages")
    }

    Timer {
        id: blink
        interval: 100
        running: true
        repeat:true
        property int blinkStatus: 0
        onTriggered: {
            if (vars.globalUnreadCount>0) {
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
                if (vars.globalUnreadCount>0 && settings.gBool("notifications", "wibblyWobblyTimeyWimeyStuff")) blink.running = true
                vars.isChatInProgress = false
            }
        }
    }

    Connections {
        target: xmppConnectivity.client
        onRosterChanged: vars.connecting = false
        onErrorHappened: {
            vars.connecting = false
            if (settings.gBool("behavior", "reconnectOnError")) dialog.create("qrc:/dialogs/Status/Reconnect")
        }
        onMessageReceived: {
            if( xmppConnectivity.client.myBareJid != xmppConnectivity.client.bareJidLastMsg ) {
                if (!vars.isChatInProgress) {
                    vars.globalUnreadCount++
                    if (xmppConnectivity.client.bareJidLastMsg == xmppConnectivity.chatJid) vars.tempUnreadCount++
                } else if (xmppConnectivity.client.bareJidLastMsg != xmppConnectivity.chatJid || !vars.isActive) vars.globalUnreadCount++

                if (!vars.isActive && settings.gBool("notifications", "wibblyWobblyTimeyWimeyStuff")) { blink.running = true }

                if (settings.gBool("notifications", "usePopupRecv") == true && (xmppConnectivity.chatJid !== xmppConnectivity.client.bareJidLastMsg || !vars.isActive)) {
                    if (settings.gBool("behavior","msgInDiscrPopup")) avkon.showPopup(xmppConnectivity.client.getPropertyByJid(xmppConnectivity.client.bareJidLastMsg,"name"), xmppConnectivity.client.getLastSqlMessage(),settings.gBool("behavior","linkInDiscrPopup"))
                    else avkon.showPopup(globalUnreadCount + " unread messages", "New message from "+ xmppConnectivity.client.getPropertyByJid(xmppConnectivity.client.bareJidLastMsg,"name") + ".",settings.gBool("behavior","linkInDiscrPopup"))
                }
                notify.notifySndVibr("MsgRecv")
                notify.updateNotifiers()
            }
        }
        onStatusChanged: {
            console.log( "XmppClient::onStatusChanged:" + xmppConnectivity.client.status )
            notify.notifySndVibr("NotifyConn")
            if (settings.gBool("notifications", "notifyConnection") && !vars.connecting) {
                if (xmppConnectivity.client.statusText == "") avkon.showPopup("Status changed to " + notify.getStatusName(),xmppConnectivity.client.statusText,settings.gBool("behavior","linkInDiscrPopup"))
                else avkon.showPopup("Status changed to",notify.getStatusName(),settings.gBool("behavior","linkInDiscrPopup"))
            }
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
                if (isTyping) avkon.showPopup(xmppConnectivity.client.getPropertyByJid(bareJid,"name"),"is typing a message...",settings.gBool("behavior","linkInDiscrPopup"))
                else avkon.showPopup(xmppConnectivity.client.getPropertyByJid(bareJid,"name"),"stopped typing.",settings.gBool("behavior","linkInDiscrPopup"))
            }
        }
    } //XmppClient

    XmppConnectivity { id: xmppConnectivity }
    Settings { id: settings }
    XmppVCard { id: xmppVCard }

    Component.onCompleted: {
        initAccount()
        checkIfFirstRun()
        xmppConnectivity.client.keepAlive = settings.gInt("behavior", "keepAliveInterval")
        if (settings.gBool("behavior","goOnlineOnStart")) xmppConnectivity.client.setMyPresence( XmppClient.Online, lastStatus )
    }

    /************************( stuff to do when running this app )*****************************/

    function checkIfFirstRun() {
        if (!settings.gBool("main","not_first_run")) pageStack.push("qrc:/FirstRun/01")
        else pageStack.push("qrc:/pages/Roster")
    }

    property bool _existDefaultAccount: false

    function initAccount() {
        var accc=0
        _existDefaultAccount = false
        for( var j=0; j<settings.accounts.count(); j++ )
        {
            if( settings.gBool( settings.getJidByIndex( j ),"is_default" ) )
            {
                _existDefaultAccount = true
                changeAccount(accc)
            } else {
                    _existDefaultAccount = true
                    accc++
            }
        }
        vars.globalUnreadCount = xmppConnectivity.client.getUnreadCount()
    }

    function changeAccount(acc) {
        xmppConnectivity.changeAccount(acc);
        avkon.hideChatIcon()
        notify.updateNotifiers()
        vars.globalUnreadCount = xmppConnectivity.client.getUnreadCount()
    }

    /****************************( Dialog windows, menus and stuff)****************************/

    QtObject{
        id:dialog;
        property Component c:null;
        function create(qmlfile){
            c=Qt.createComponent(qmlfile);
            c.createObject(main)
        }
    }

    ContextMenu {
        id: linkContextMenu
        MenuLayout {
            MenuItem {text: qsTr("Copy"); onClicked: {
                    clipboard.setText(vars.url)
                    avkon.showPopup("URL copied to","clipboard.",false)
                }
            }
            MenuItem {text: qsTr("Open in default browser"); onClicked: avkon.openDefaultBrowser(vars.url) }
      }
    }

    Clipboard { id: clipboard }

    Notifications { id: notify }

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
        visible: vars.connecting
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
