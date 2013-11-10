// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1

Page {
    id: firstRunPage
    tools: toolBarLayout
    orientationLock: 1

    Text {
        id: chapter
        color: main.textColor
        anchors { top: parent.top; topMargin: 32; horizontalCenterOffset: 0; horizontalCenter: parent.horizontalCenter }
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: platformStyle.fontSizeMedium*1.5
        text: "Congratulations!"
    }

    Text {
        id: text
        color: main.textColor
        anchors { top: chapter.bottom; topMargin: 24; left: parent.left; right: parent.right; leftMargin: 10; rightMargin: 10 }
        wrapMode: Text.WordWrap
        font.pixelSize: 20
        text: qsTr("Your app is now configured and it's ready to work. :) You can close the wizard now. After that, just tap Options button and choose Status to go online and start chatting.")
    }

    // toolbar

    ToolBarLayout {
        id: toolBarLayout
        ToolButton {
            iconSource: main.platformInverted ? "toolbar-previous_inverse" : "toolbar-previous"
            onClicked: pageStack.pop()
        }

        ToolButton {
            iconSource: main.platformInverted ? "toolbar-next_inverse" : "toolbar-next"
            onClicked: {
                do {
                    pageStack.pop()
                } while (pageStack.depth > 1)
                pageStack.push("qrc:/pages/Roster")
                settings.sBool(true,"main","not_first_run")
                settings.sStr(xmppClient.version,"main","last_used_rel")

                //settings.sBool(true,"notifications","vibraMsgRecv")
                //settings.sInt(800,"notifications","vibraMsgRecvDuration")
                //settings.sInt(100,"notifications","vibraMsgRecvIntensity")

                //settings.sBool(true,"notifications","soundMsgRecv")
                //settings.sStr("file:///C:/Data/.config/Lightbulb/sounds/Message_Received.wav", "notifications","soundMsgRecvFile")
                //settings.sInt(100,"notifications","soundMsgRecvVolume")

                //settings.sBool(true,"notifications","notifyMsgRecv")
                //settings.sBool(true,"notifications","useGlobalNote")

                //settings.sInt(400,"notifications","vibraMsgSentDuration")
                //settings.sInt(100,"notifications","vibraMsgSentIntensity")

                //settings.sBool(true,"notifications","soundMsgSent")
                //settings.sStr("file:///C:/Data/.config/Lightbulb/sounds/Message_Sent.wav", "notifications","soundMsgSentFile")
                //settings.sInt(100,"notifications","soundMsgSentVolume")

                //settings.sInt(500,"notifications","vibraMsgSubDuration")
                //settings.sInt(50,"notifications","vibraMsgSubIntensity")

                //settings.sBool(true,"notifications","soundMsgSub")
                //settings.sStr("file:///C:/Data/.config/Lightbulb/sounds/Subscription_Request.wav", "notifications","soundMsgSubFile")
                //settings.sInt(100,"notifications","soundMsgSubVolume")

                //settings.sBool(true,"notifications","notifyConnection")

                //settings.sBool(true,"notifications","notifySubscription")

                //settings.sBool(true,"notifications","notifyTyping")

                //settings.sBool(true,"ui","markUnread")
                //settings.sBool(true,"ui","showUnreadCount")
                //settings.sInt(75,"ui","rosterItemHeight")
                //settings.sBool(true,"ui","showContactStatusText")

                //settings.sBool(true,"behavior","reconnectOnError")
                //settings.sInt(60,"behavior","keepAliveInterval")

                //settings.sBool(true,"behavior","storeStatusText")

                //settings.sBool(true,"behavior","linkInDiscrPopup")
                //settings.sBool(true,"behavior","msgInDiscrPopup")
            }
        }

    }


}

