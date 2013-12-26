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
        xmppClient.resetUnreadMessages( xmppClient.chatJid )
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
                if (xmppClient.chatJid != "") {
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

    XmppClient {
        id: xmppClient
        onRosterChanged: vars.connecting = false
        onErrorHappened: {
            vars.connecting = false
            if (settings.gBool("behavior", "reconnectOnError")) dialog.create("qrc:/dialogs/Status/Reconnect")
        }
        onMessageReceived: {
            if( xmppClient.myBareJid != bareJidLastMsg ) {
                if (!vars.isChatInProgress) {
                    vars.globalUnreadCount++
                    if (bareJidLastMsg == xmppClient.chatJid) vars.tempUnreadCount++
                } else if (bareJidLastMsg != xmppClient.chatJid || !vars.isActive) vars.globalUnreadCount++

                if (!vars.isActive && settings.gBool("notifications", "wibblyWobblyTimeyWimeyStuff")) { blink.running = true }

                if (settings.gBool("notifications", "usePopupRecv") == true && (xmppClient.chatJid !== bareJidLastMsg || !vars.isActive)) {
                    if (settings.gBool("behavior","msgInDiscrPopup")) avkon.showPopup(getPropertyByJid(bareJidLastMsg,"name"), getLastSqlMessage(),settings.gBool("behavior","linkInDiscrPopup"))
                    else avkon.showPopup(globalUnreadCount + " unread messages", "New message from "+ getPropertyByJid(bareJidLastMsg,"name") + ".",settings.gBool("behavior","linkInDiscrPopup"))
                }
                notify.notifySndVibr("MsgRecv")
                notify.updateNotifiers()
            }
        }
        onStatusChanged: {
            console.log( "XmppClient::onStatusChanged:" + status )
            notify.notifySndVibr("NotifyConn")
            if (settings.gBool("notifications", "notifyConnection") && !vars.connecting) {
                if (xmppClient.statusText == "") avkon.showPopup("Status changed to " + notify.getStatusName(),xmppClient.statusText,settings.gBool("behavior","linkInDiscrPopup"))
                else avkon.showPopup("Status changed to",notify.getStatusName(),settings.gBool("behavior","linkInDiscrPopup"))
            }
            notify.updateNotifiers()
        }
        onVCardChanged: xmppVCard.vcard = xmppClient.vcard
        onSubscriptionReceived: {
            console.log( "QML: Main: ::onSubscriptionReceived: [" + bareJid + "]" )
            if (settings.gBool("notifications","notifySubscription") == true) avkon.showPopup("Subscription request",bareJid,settings.gBool("behavior","linkInDiscrPopup"))
            notify.notifySndVibr("MsgSub")
            vars.dialogJid = bareJid
            dialog.create("qrc:/dialogs/Contact/Subscribe")
        }
        onTypingChanged: {
            if (settings.gBool("notifications", "notifyTyping") == true && (xmppClient.chatJid !== bareJid || !vars.isActive) && xmppClient.myBareJid !== bareJid) {
                if (isTyping) avkon.showPopup(getPropertyByJid(bareJid,"name"),"is typing a message...",settings.gBool("behavior","linkInDiscrPopup"))
                else avkon.showPopup(getPropertyByJid(bareJid,"name"),"stopped typing.",settings.gBool("behavior","linkInDiscrPopup"))
            }
        }
    } //XmppClient

    Settings { id: settings }
    XmppVCard { id: xmppVCard }

    Component.onCompleted: {
        initAccount()
        checkIfFirstRun()
        xmppClient.keepAlive = settings.gInt("behavior", "keepAliveInterval")
        if (settings.gBool("behavior","goOnlineOnStart")) xmppClient.setMyPresence( XmppClient.Online, lastStatus )
    }

    function changeAudioFile() {
        var filename = avkon.openFileSelectionDlg();
        if (filename != "") settings.sStr(filename,"notifications",nowEditing+"File")
    }

    /************************( stuff to do when running this app )*****************************/

    function checkIfFirstRun() {
        if (!settings.gBool("main","not_first_run")) pageStack.push("qrc:/FirstRun/01")
        else pageStack.push("qrc:/pages/Roster")
        if (!settings.gBool("main","christmas2013")) {
            notify.postInfo("Merry Christmas and a Happy New Year from pisarz1958! Enjoy testing this build. :)")
            settings.sBool(true,"main","christmas2013");
        }
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
                xmppClient.myBareJid = settings.getJidByIndex( j );
                xmppClient.myPassword = settings.gStr( settings.getJidByIndex( j ),"passwd" );
                xmppClient.resource = settings.gStr( settings.getJidByIndex( j ), "resource" )

                if(  settings.gBool( settings.getJidByIndex( j ),"use_host_port" ) ) {
                    xmppClient.host = settings.gStr(settings.getJidByIndex(j), "host")
                    xmppClient.port = settings.gInt(settings.getJidByIndex(j), "port")
                } else {
                    xmppClient.host = "";
                    xmppClient.port = 5222;
                }

                xmppClient.accountId = j;
                avkon.hideChatIcon()
                notify.updateNotifiers()

                console.log("QML: main::initAccount():" + xmppClient.myBareJid + "/" + xmppClient.resource);
            } else {
                    _existDefaultAccount = true
                    accc++
            }
        }
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
