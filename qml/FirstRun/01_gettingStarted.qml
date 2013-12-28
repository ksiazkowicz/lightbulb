import QtQuick 1.1
import com.nokia.symbian 1.1

Page {
    id: firstRunPage
    tools: toolBarLayout
    orientationLock: 1

    Component.onCompleted: statusBarText.text = qsTr("First run")

    Text {
        id: chapter
        color: vars.textColor
        anchors { top: parent.top; topMargin: 32; horizontalCenterOffset: 0; horizontalCenter: parent.horizontalCenter }
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: platformStyle.fontSizeMedium*1.5
        text: "Getting Started"
    }

    Text {
        id: text
        color: vars.textColor
        anchors { top: chapter.bottom; topMargin: 24; left: parent.left; right: parent.right; leftMargin: 10; rightMargin: 10 }
        wrapMode: Text.WordWrap
        font.pixelSize: 20
        text: "Welcome to Lightbulb!\n\nIt looks like it's your first time! In the next few steps, app will be configured for you.\n\nTap on \"Next\" whenever you're ready to begin, or just tap on \"Close\" to close the wizard. Don't worry, if you change your mind or simply get something wrong, you can change all the settings later. :)"
    }

    // toolbar

    ToolBarLayout {
        id: toolBarLayout
        ToolButton {
            iconSource: main.platformInverted ? "qrc:/toolbar/close_inverse" : "qrc:/toolbar/close"
            onClicked: {
                settings.sBool(true,"main","not_first_run")
                settings.sStr(xmppConnectivity.client.version,"main","last_used_rel")
                settings.sBool(true,"ui","markUnread")
                settings.sBool(true,"ui","showUnreadCount")
                settings.sInt(75,"ui","rosterItemHeight")
                settings.sBool(true,"ui","showContactStatusText")

                settings.sBool(true,"behavior","reconnectOnError")
                settings.sInt(60,"behavior","keepAliveInterval")

                settings.sInt(800,"notifications","vibraMsgRecvDuration")
                settings.sInt(100,"notifications","vibraMsgRecvIntensity")

                settings.sStr("file:///C:/Data/.config/Lightbulb/sounds/Message_Received.wav", "notifications","soundMsgRecvFile")
                settings.sInt(100,"notifications","soundMsgRecvVolume")

                settings.sInt(400,"notifications","vibraMsgSentDuration")
                settings.sInt(100,"notifications","vibraMsgSentIntensity")

                settings.sStr("file:///C:/Data/.config/Lightbulb/sounds/Message_Sent.wav", "notifications","soundMsgSentFile")
                settings.sInt(100,"notifications","soundMsgSentVolume")

                settings.sInt(500,"notifications","vibraMsgSubDuration")
                settings.sInt(50,"notifications","vibraMsgSubIntensity")

                settings.sStr("file:///C:/Data/.config/Lightbulb/sounds/Subscription_Request.wav", "notifications","soundMsgSubFile")
                settings.sInt(100,"notifications","soundMsgSubVolume")
                pageStack.replace("qrc:/pages/Roster")
            }
        }

        ToolButton {
            iconSource: main.platformInverted ? "toolbar-next_inverse" : "toolbar-next"
            onClicked: pageStack.push("qrc:/FirstRun/02")
        }

    }


}

