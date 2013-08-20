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
    property bool                    inputInProgress: false

    property string                  accJid: ""
    property string                  accPass: ""
    property string                  accResource: ""
    property string                  accHost: ""
    property string                  accPort: ""
    property bool                    accManualHostPort: false
    property bool                    accDefault: false

    property int                     splitscreenY: 0

    property string                  lastStatus: settings.gStr("behavior","lastStatusText")
    property string nowEditing:      ""
    property string url:             ""

    signal statusChanged
    property string statStatusText:  xmppClient.statusText
    signal statusTextChanged

    property bool requestMyVCard:    false

    property string dialogTitle:     ""
    property string dialogText:      ""
    property string dialogName:      ""

    initialPage: RosterPage {}

    XmppClient {
        id: xmppClient
        onMessageReceived: {
            if( xmppClient.myBareJid != bareJidLastMsg ) {
                globalUnreadCount++
                if (settings.gBool("notifications","notifyMsgRecv") == true) {
                    sb.text = "[" + globalUnreadCount + "] " + qsTr("Message from ") + getNameByJid(bareJidLastMsg)
                    sb.open()
                }
                if (settings.gBool("behavior","enableHsWidget")) {
                    notify.postHSWidget()
                }
                if (settings.gBool("notifications", "useGlobalNote") == true) {
                    notify.postGlobalNote(qsTr("New message from ") + getNameByJid(bareJidLastMsg) + qsTr(". You have ") + globalUnreadCount + qsTr(" unread messages."))
                }
                notifySndVibr("MsgRecv")
                chatIcon.setChatIconStatus(1);
            }
        }
        onStatusChanged: {
            console.log( "XmppClient::onStatusChanged:" + status )
            main.statusChanged()
            notifySndVibr("NotifyConn")
            if (settings.gBool("notifications", "notifyConnection") == true) {
                sb.text = qsTr("Status changed to ") + notify.getStatusName()
                sb.open()
            }
            if (settings.gBool("behavior","enableHsWidget")) {
                notify.postHSWidget()
            }
        }
        onVCardChanged: { xmppVCard.vcard = xmppClient.vcard }
        onErrorHappened: {
            console.log("QML: Error: " + errorString )
            sb.text = "Error: "+errorString
            sb.open()
        }
        onPresenceJidChanged: { if (presenceBareJid == xmppClient.myBareJid ) notify.getStatusName(); }
        onSubscriptionReceived: {
            if (settings.gBool("notifications","notifySubscription") == true) {
                sb.text = "Subscription request from " + bareJid
                sb.open()
            }
            notifySndVibr("MsgSub")
            dialogJid = bareJid
            dialog.source = ""
            dialog.source = "Dialogs/QuerySubscribtion.qml"
        }
    } //XmppClient

    MeegIMSettings { id: settings }
    XmppVCard { id: xmppVCard }

    Component.onCompleted: {
        initAccount()
        checkIfFirstRun()
        xmppClient.keepAlive = settings.gInt("behavior", "keepAliveInterval")
        xmppClient.reconnectOnError = settings.gBool("behavior", "reconnectOnError")
        xmppClient.archiveIncMessage = settings.gBool("behavior", "archiveIncMessage")
    }

    function changeAudioFile() {
                var component = Qt.createComponent("qrc:/qml/Dialogs/FileDialog.qml");
                var dialog = component.createObject(main);
                if( dialog !== null ) {
                    dialog.dirMode = false;
                    dialog.fileSelected.connect(fileSelected);
                    dialog.directorySelected.connect(directorySelected);
                    dialog.open();
                }
            }

    /************************( file selection dialog )*****************************/
    FileModel { id: fileModel }

    function openFile( dirMode ) {
                var component = Qt.createComponent("qrc:/qml/Dialogs/FileDialog.qml");
                var dialog = component.createObject(main);
                if( dialog !== null ) {
                    if( dirMode) {
                        dialog.dirMode = true;
                    }
                    dialog.fileSelected.connect(fileSelected);
                    dialog.directorySelected.connect(directorySelected);
                    dialog.open();
                }
            }

    function fileSelected( filePath ) {
        settings.sStr("file:///" + filePath.substring(0,2) + filePath.substring(3,filePath.length),"notifications",nowEditing+"File")
    }

    function directorySelected( dirPath) {
            console.debug("directoryAdded:" + dirPath);
    }

    /************************( stuff to do when running this app )*****************************/

    function checkIfFirstRun() {
        if (!settings.gBool("main","not_first_run") || settings.gBool("main","build006")) {
            settings.sBool(true,"main","not_first_run")
            settings.sBool(true,"main","build007")
            settings.sBool(false,"main","build006")

            settings.sBool(true,"notifications","vibraMsgRecv")
            settings.sInt(800,"notifications","vibraMsgRecvDuration")
            settings.sInt(100,"notifications","vibraMsgRecvIntensity")

            settings.sBool(true,"notifications","soundMsgRecv")
            settings.sStr("file:///C:/Data/.config/Lightbulb/sounds/Message_Received.wav", "notifications","soundMsgRecvFile")
            settings.sInt(100,"notifications","soundMsgRecvVolume")

            settings.sBool(true,"notifications","notifyMsgRecv")
            settings.sBool(true,"notifications","blinkScrOnMsgRecv")
            settings.sBool(true,"notifications","useGlobalNote")

            settings.sInt(400,"notifications","vibraMsgSentDuration")
            settings.sInt(100,"notifications","vibraMsgSentIntensity")

            settings.sBool(true,"notifications","soundMsgSent")
            settings.sStr("file:///C:/Data/.config/Lightbulb/sounds/Message_Sent.wav", "notifications","soundMsgSentFile")
            settings.sInt(100,"notifications","soundMsgSentVolume")

            settings.sInt(500,"notifications","vibraMsgSubDuration")
            settings.sInt(50,"notifications","vibraMsgSubIntensity")

            settings.sBool(true,"notifications","soundMsgSub")
            settings.sStr("file:///C:/Data/.config/Lightbulb/sounds/Subscription_Request.wav", "notifications","soundMsgSubFile")
            settings.sInt(100,"notifications","soundMsgSubVolume")

            settings.sBool(true,"notifications","notifyConnection")

            settings.sBool(true,"notifications","notifySubscription")

            settings.sBool(true,"notifications","notifyTyping")

            settings.sBool(true,"ui","markUnread")
            settings.sBool(true,"ui","showUnreadCount")
            settings.sInt(75,"ui","rosterItemHeight")
            settings.sBool(true,"ui","showContactStatusText")

            settings.sBool(true,"behavior","reconnectOnError")
            settings.sInt(60,"behavior","keepAliveInterval")

            settings.sBool(true,"behavior","storeStatusText")

            dialogTitle = qsTr("First run")
            dialogText = qsTr("Welcome to Lightbulb! I guess it's your first time, isn't it? Have fun with testing! #whyIevenPutThisDialogHere?")
            dialog.source = ""
            dialog.source = "Dialogs/Info.qml"

            pageStack.replace("qrc:/qml/RosterPage.qml")

        }

    }
    property bool _existDefaultAccount: false
    function initAccount() {
        var accc=0
        _existDefaultAccount = false
        for( var j=0; j<settings.accounts.count(); j++ )
        {
            if( settings.accIsDefault( j ) )
            {
                _existDefaultAccount = true
                xmppClient.myBareJid = settings.accGetJid( j );
                xmppClient.myPassword = settings.accGetPassword( j );
                xmppClient.resource = settings.accGetResource( j );

                if( settings.accIsManuallyHostPort( j ) ) {
                    xmppClient.host = settings.accGetHost( j  );
                } else {
                    xmppClient.host = "";
                }

                if( settings.accIsManuallyHostPort( j ) ) {
                    xmppClient.port = settings.accGetPort( j  );
                } else {
                    xmppClient.port = 0;
                }

                console.log("QML: main::initAccount():" + xmppClient.myBareJid + "/" + xmppClient.resource);
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
            MenuItem {text: qsTr("Open in default browser"); onClicked: { Qt.openUrlExternally(url) }}
      }
    }
    Clipboard { id: clipboard }

    /**************(* notify *)**************/

    /*ChatIcon {
        id: chatIcon
    }*/

    Notifications { id: notify }
    StatusBar { id: sbar; x: 0; y: -main.y
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
        Banner { z: 10; id: sb }

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

}
