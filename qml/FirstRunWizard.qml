// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1

Page {
    id: firstRunPage
    tools: null
    orientationLock: 1
    property int setupStage:    0
    property int tmpValue:      0
    property bool prevButton:   true
    property bool nextButton:   true
    property bool accountSetup: false

    Component.onCompleted: {
        main.showToolBar  = false
        main.showStatusBar = false
        statusBarText.text = qsTr("First run")
        loadStep()
    }

    function loadStep() {
        switch (setupStage) {
            case 0:
                chapter.text = "Getting Started";
                text.text = qsTr("Welcome to Lightbulb!\n\nIt looks like it's your first time! In the next few steps, app will be configured for you.\n\nTap on \"Next\" whenever you're ready to begin, or just tap on \"Close\" to close the wizard. Don't worry, if you change your mind or simply get something wrong, you can change all the settings later. :)");
                prevButton = false;
                break;
            case 1:
                chapter.text = "Notification LED";
                text.text = qsTr("Because every phone is different, we need you do do a couple of tests before proceeding to ensure that all the features will work properly. Lightbulb will now try different ways to access your phones notification LED. \n\nObserve your menu button. Tap on \"Next\" if it's blinking, or \"Try again\" if it isn't.");
                tmpValue = 2;
                settings.sBool(true,"notifications","wibblyWobblyTimeyWimeyStuff")
                settings.sInt(tmpValue, "notifications", "blinkScreenDevice");
                blinker.running = true;
                globalUnreadCount++;
                prevButton = true;
                break;
            case 2:
                chapter.text = "Account setup";
                text.text = qsTr("In this step you're going to configure your account. Choose a server and tap Next to continue.");
                nextButton = true;
                break;
            case 3:
                if (!accountSetup) addAccountPageOpen();
                chapter.text = "Congratulations!";
                text.text = qsTr("Your app is now configured and it's ready to work. :) You can close the wizard now. After that, just tap Options button and choose Status to go online and start chatting.");
                nextButton = false;
                break;
        }
    }

    Text {
        id: chapter
        color: main.textColor
        anchors { top: parent.top; topMargin: 32; horizontalCenterOffset: 0; horizontalCenter: parent.horizontalCenter }
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: platformStyle.fontSizeMedium*1.5

    }

    ButtonRow {
        id: steps
        width: 256
        height: 40
        anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 10 }

        Button {
            id: prevBtn
            text: prevButton ? "Previous" : "Close"
            onClicked: {
                if (prevButton) {
                    if (setupStage == 1)  globalUnreadCount--;
                    setupStage--;
                    loadStep();
                } else {
                    pageStack.replace("qrc:/pages/Roster")
                    main.showToolBar  = true
                    main.showStatusBar = true
                    settings.sBool(true,"main","not_first_run")
                    settings.sStr(xmppClient.version,"main","last_used_rel")
                }
            }
        }

        Button {
            id: nextBtn
            text: nextButton ? "Next" : "Close"
            onClicked: {
                if (nextButton) {
                    if (setupStage ==2 && !selectionDialog.selectedIndex >= 0) {
                    } else {
                        if (setupStage == 1)  globalUnreadCount--;
                        setupStage++;
                        loadStep();
                    }
                } else {
                    pageStack.replace("qrc:/pages/Roster")
                    main.showToolBar  = true
                    main.showStatusBar = true
                    settings.sBool(true,"main","not_first_run")
                    settings.sStr(xmppClient.version,"main","last_used_rel")

                    settings.sBool(true,"notifications","vibraMsgRecv")
                    settings.sInt(800,"notifications","vibraMsgRecvDuration")
                    settings.sInt(100,"notifications","vibraMsgRecvIntensity")

                    settings.sBool(true,"notifications","soundMsgRecv")
                    settings.sStr("file:///C:/Data/.config/Lightbulb/sounds/Message_Received.wav", "notifications","soundMsgRecvFile")
                    settings.sInt(100,"notifications","soundMsgRecvVolume")

                    settings.sBool(true,"notifications","notifyMsgRecv")
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

                    settings.sBool(true,"behavior","linkInDiscrPopup")
                    settings.sBool(true,"behavior","msgInDiscrPopup")
                }
            }
        }
    }

    Text {
        id: text
        color: main.textColor
        anchors { top: chapter.bottom; topMargin: 24; left: parent.left; right: parent.right; leftMargin: 10; rightMargin: 10 }
        //horizontalAlignment: Text.AlignJustify;
        wrapMode: Text.WordWrap
        font.pixelSize: 20
    }

    // notification LED setup

    Button {
        id: ledNo
        text: "Try again"
        width: parent.width/2 - 10
        visible: setupStage == 1
        enabled: visible
        height: 40
        anchors.horizontalCenter: parent.horizontalCenter
        anchors { bottom: steps.top; bottomMargin: 186 }
        onClicked: {
            switch (tmpValue) {
                case 2: tmpValue = 1; break;
                case 1: tmpValue = 4; break;
                case 4: tmpValue = 2; break;
            }
            settings.sInt(tmpValue, "notifications", "blinkScreenDevice")
        }
    }

    // account setup

    SelectionListItem {
        id: serverSelection
        x: 0
        y: 164
        subTitle: selectionDialog.selectedIndex >= 0
                  ? selectionDialog.model.get(selectionDialog.selectedIndex).name
                  : "FB Chat, GTalk or manual settings"
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 392
        title: "Server"

        visible: setupStage == 2
        enabled: visible

        onClicked: selectionDialog.open()

        SelectionDialog {
            id: selectionDialog
            titleText: "Available options"
            selectedIndex: -1
            model: ListModel {
                ListElement { name: "Facebook Chat" }
                ListElement { name: "Google Talk" }
                ListElement { name: "Generic XMPP server" }
            }
        }
    }


    function addAccountPageOpen() {
        main.accJid = ""
        main.accPass = ""
        main.accDefault = true
        main.accResource = ""
        main.accHost = ""
        main.accPort = "5222"
        switch (selectionDialog.selectedIndex) {
            case 1:
                main.accJid = "@chat.facebook.com"
                main.accManualHostPort = true
                main.accHost = "chat.facebook.com"
                break;
            case 2:
                main.accJid = "@gmail.com"
                main.accManualHostPort = true
                main.accHost = "talk.google.com"
                break;
        }
        pageStack.push( "qrc:/pages/AccountsAdd" )
        accountSetup = true;
        main.showToolBar = true
    }


}

