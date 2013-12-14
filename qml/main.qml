import QtQuick 1.1
import com.nokia.symbian 1.1
import com.nokia.extras 1.1
import QtMultimediaKit 1.1
import QtMobility.feedback 1.1
import lightbulb 1.0

PageStackWindow {
    id: main

    showStatusBar:                   true
    platformInverted:                settings.gBool("ui","invertPlatform")
    property string textColor:       platformInverted ? platformStyle.colorNormalDark : platformStyle.colorNormalLight
    property int                     globalUnreadCount: 0
    property int                     tempUnreadCount: 0
    property bool                    inputInProgress: false
    property string                  accJid: ""
    property string                  accPass: ""
    property string                  accResource: ""
    property string                  accHost: ""
    property string                  accPort: ""
    property bool                    accManualHostPort: false
    property bool                    accDefault: false
    property bool                    connecting: false
    property int                     splitscreenY: 0
    property string                  lastStatus: settings.gBool("behavior", "lastStatusText") ? settings.gStr("behavior","lastStatusText") : ""
    property string                  nowEditing: ""
    property string                  url: ""
    signal                           statusChanged
    property int                     lastUsedStatus: 0
    signal                           statusTextChanged
    property string                  dialogJid:       ""
    property string                  dialogTitle:     ""
    property string                  dialogText:      ""
    property string                  dialogName:      ""
    property bool                    isActive: true
    property bool                    isChatInProgress: false
    property int                     blinkerSet: 0
    property string                  selectedContactStatusText: ""
    property string                  selectedContactPresence: ""

    function openChat() {
        if (pageStack.depth > 1) {
            pageStack.replace("qrc:/pages/Messages")
        } else {
            pageStack.push("qrc:/pages/Messages")
        }
        dialog.source = ""
    }

    Timer {
        id: blinker
        interval: 100
        running: true; repeat:true
        onTriggered: {
            if (globalUnreadCount>0) {
                if (blinkerSet < 4) { avkon.notificationBlink(settings.gInt("notifications", "blinkScreenDevice")); blinkerSet++ } else { if (blinkerSet > 6) { blinkerSet = 0} else { blinkerSet++ } }
            } else { blinkerSet = 0; blinker.running = false }
        }
    }

    Connections {
        target: Qt.application
        onActiveChanged: {
            if (Qt.application.active) {
                isActive = true
                blinker.running = false
                if (xmppClient.chatJid != "") {
                    isChatInProgress = true
                    globalUnreadCount = globalUnreadCount - tempUnreadCount
                }
                tempUnreadCount = 0
                if (globalUnreadCount<0) {
                    globalUnreadCount = 0
                }
            } else {
                isActive = false
                if (globalUnreadCount>0 && settings.gBool("notifications", "wibblyWobblyTimeyWimeyStuff")) {
                    blinker.running = true
                }
                isChatInProgress = false
            }
        }
    }

    XmppClient {
        id: xmppClient
        onRosterUpdated: { connecting = false }
        onErrorHappened: {
            connecting = false
            if (settings.gBool("behavior", "reconnectOnError")) {
                dialog.source = ""
                dialog.source = "qrc:/dialogs/Status/Reconnect"
            }
        }
        onMessageReceived: {
            if( xmppClient.myBareJid != bareJidLastMsg ) {
                if (!isChatInProgress) {
                    globalUnreadCount++
                    if (bareJidLastMsg == xmppClient.chatJid) {
                        tempUnreadCount++
                    }
                } else {
                        if (bareJidLastMsg != xmppClient.chatJid || !isActive) {
                            globalUnreadCount++
                        }
                }
                if (!isActive && settings.gBool("notifications", "wibblyWobblyTimeyWimeyStuff")) { blinker.running = true }
                if (settings.gBool("notifications", "usePopupRecv") == true && (xmppClient.chatJid !== bareJidLastMsg || !isActive)) {
                    if (settings.gBool("behavior","msgInDiscrPopup")) {
                        avkon.showPopup(getPropertyByJid(bareJidLastMsg,"name"), getLastSqlMessage(),settings.gBool("behavior","linkInDiscrPopup"))
                    } else {
                        avkon.showPopup(globalUnreadCount + " unread messages", "New message from "+ getPropertyByJid(bareJidLastMsg,"name") + ".",settings.gBool("behavior","linkInDiscrPopup"))
                        }
                }
                notifySndVibr("MsgRecv")
                if (settings.gBool("behavior","enableHsWidget")) notify.postHSWidget()
            }
        }
        onStatusChanged: {
            console.log( "XmppClient::onStatusChanged:" + status )
            main.statusChanged()
            notifySndVibr("NotifyConn")
            if (settings.gBool("notifications", "notifyConnection") && !connecting) {
                if (xmppClient.statusText == "") {
                avkon.showPopup("Status changed to " + notify.getStatusName(),xmppClient.statusText,settings.gBool("behavior","linkInDiscrPopup"))
                } else { avkon.showPopup("Status changed to",notify.getStatusName(),settings.gBool("behavior","linkInDiscrPopup")) }
            }
            if (settings.gBool("behavior","enableHsWidget")) {
                notify.postHSWidget()
            }
        }
        onVCardChanged: { xmppVCard.vcard = xmppClient.vcard }
        onSubscriptionReceived: {
            console.log( "QML: Main: ::onSubscriptionReceived: [" + bareJid + "]" )
            if (settings.gBool("notifications","notifySubscription") == true) {
                avkon.showPopup("Subscription request",bareJid,settings.gBool("behavior","linkInDiscrPopup"))
            }
            notifySndVibr("MsgSub")
            dialogJid = bareJid
            dialog.source = ""
            dialog.source = "qrc:/dialogs/Contact/Subscribe"
        }
        onTypingChanged: {
            if (settings.gBool("notifications", "notifyTyping") == true && (xmppClient.chatJid !== bareJid || !isActive) && xmppClient.myBareJid !== bareJid) {
                if (isTyping) {
                    avkon.showPopup(getPropertyByJid(bareJid,"name"),"is typing a message...",settings.gBool("behavior","linkInDiscrPopup"))
                } else { avkon.showPopup(getPropertyByJid(bareJid,"name"),"stopped typing.",settings.gBool("behavior","linkInDiscrPopup")) }
            }
        }
    } //XmppClient

    Settings { id: settings }
    XmppVCard { id: xmppVCard }

    Component.onCompleted: {
        initAccount()
        checkIfFirstRun()
        xmppClient.keepAlive = settings.gInt("behavior", "keepAliveInterval")
        if (settings.gBool("behavior","goOnlineOnStart")) { xmppClient.setMyPresence( XmppClient.Online, lastStatus ) }
    }

    function changeAudioFile() {
        var filename = avkon.openFileSelectionDlg();

        if (filename != "") {
            settings.sStr(filename,"notifications",nowEditing+"File")
        }
    }

    /************************( stuff to do when running this app )*****************************/

    function checkIfFirstRun() {
        if (!settings.gBool("main","not_first_run")) {
            pageStack.push("qrc:/FirstRun/01")
        } else {
            pageStack.push("qrc:/pages/Roster")
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
                globalUnreadCount = xmppClient.getUnreadCount()

                console.log("QML: main::initAccount():" + xmppClient.myBareJid + "/" + xmppClient.resource);
                xmppClient.updateChats()
            } else {
                    _existDefaultAccount = true
                    accc++
            }
        }
    }

    /****************************( Dialog windows, menus and stuff)****************************/

    Loader { id: dialog }
    ContextMenu {
        id: linkContextMenu
        MenuLayout {
            MenuItem {text: qsTr("Copy"); onClicked: { clipboard.setText(url) } }
            MenuItem {text: qsTr("Open in default browser"); onClicked: { avkon.openDefaultBrowser(url) }}
      }
    }
    Clipboard { id: clipboard }

    /**************(* notify *)**************/

    Avkon { id: avkon }

    Notifications { id: notify }

    StatusBar { id: sbar; x: 0; y: -main.y; opacity: showStatusBar ? 1 : 0
        Rectangle {
                  anchors { left: parent.left; leftMargin: 6; verticalCenter: parent.verticalCenter }
                  width: sbar.width - 183; height: parent.height
                  clip: true;
                  color: "#00000000"

                  Text{
                      id: statusBarText
                      anchors.verticalCenter: parent.verticalCenter
                      maximumLineCount: 1
                      x: 0
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

    function notifySndVibr(how) {
        if( settings.gBool("notifications","vibra"+how )) {
            hapticsEffect.duration = settings.gInt("notifications","vibra"+how+"Duration" )
            hapticsEffect.intensity = settings.gInt("notifications","vibra"+how+"Intensity" )/100
            hapticsEffect.running = true
        }
        if( settings.gBool("notifications","sound"+how )) {
            sndEffect.source = settings.gStr("notifications","sound"+how+"File" )
            sndEffect.volume = settings.gInt("notifications","sound"+how+"Volume" )/100
            sndEffect.play()
        }
    }
    Audio { id: sndEffect }
    HapticsEffect {
        id: hapticsEffect
        attackIntensity: 0
        attackTime: 250
        fadeTime: 250
        fadeIntensity: 0
        running: false
    }

    /***************( splitscreen input )***************/
    Item {
        id: splitViewInput
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }

        states: [
            State {
                name: "Visible"; when: inputContext.visible
                PropertyChanges { target: splitViewInput; height: inputContext.height }
                PropertyChanges { target: main; inputInProgress: true }
                PropertyChanges { target: main; y: splitscreenY > 0 ? 0-splitscreenY : 0 }
            },
            State {
                name: "Hidden"; when: !inputContext.visible
                PropertyChanges { target: splitViewInput; }
                PropertyChanges { target: main; inputInProgress: false }
            }
        ]
    }


    /***************(overlay)**********/
    Rectangle {
        color: main.platformInverted ? "white" : "black"
        opacity: (!xmppClient.rosterIsAvailable || connecting) ? 1 : 0.5
        Behavior on opacity { PropertyAnimation { duration: 500 } }
        anchors.fill: parent

        visible: main.pageStack.busy || (!xmppClient.rosterIsAvailable && statusBarText.text == "Contacts" ) || connecting
        BusyIndicator {
            id: busyindicator1
            anchors.centerIn: parent
            running: true
        }
        Text {
            id: rosterUpdate
            text: !xmppClient.rosterIsAvailable ? "Updating contact list..." : "Connecting..."
            anchors { horizontalCenter: parent.horizontalCenter; top: busyindicator1.bottom; topMargin: 15 }
            color: main.textColor
            font.pixelSize: 20
            visible: !xmppClient.rosterIsAvailable || connecting
        }

    }

}
