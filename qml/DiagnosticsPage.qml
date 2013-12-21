import QtQuick 1.1
import com.nokia.symbian 1.1

Page {
    id: aboutPage
    orientationLock: 1
    tools: toolBarLayout
    property bool closeTheApp: false;

    Component.onCompleted: {
        statusBarText.text = qsTr("Maintenance")
    }

    Text {
        id: removeDbDescription
        width: parent.width - 20
        height: 64
        color: main.textColor
        text: "This option will remove all the archived messages."
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.WordWrap
        anchors { top: removeDb.bottom; horizontalCenterOffset: 1; horizontalCenter: parent.horizontalCenter }
        font.pixelSize: platformStyle.fontSizeSmall
        horizontalAlignment: Text.AlignLeft
    }


    ToolBarLayout {
        id: toolBarLayout
        ToolButton {
            iconSource: main.platformInverted ? "toolbar-back_inverse" : "toolbar-back"
            onClicked: { statusBarText.text = "Contacts"
                if (!closeTheApp) pageStack.pop(); else dialog.create("qrc:/dialogs/Close")
            }
        }
    }

    Button {
        id: removeDb
        anchors { top: parent.top; topMargin: 24; horizontalCenter: parent.horizontalCenter }
        text: "Remove database"
        platformInverted: main.platformInverted
        onClicked: {
            if (xmppClient.dbRemoveDb()) {
                notify.postInfo("Database cleaned.")
                if (!closeTheApp) closeTheApp = true;
            } else { notify.postError("Unable to clean database.") }
        }
    }

    Button {
        id: cleanAvatarCache
        anchors { top: removeDbDescription.bottom; horizontalCenter: parent.horizontalCenter }
        text: "Clean avatar cache"
        platformInverted: main.platformInverted
        onClicked: {
            if (xmppClient.cleanCache()) {
                notify.postInfo("Avatar cache cleaned.")
                if (!closeTheApp) closeTheApp = true;
            } else { notify.postError("Unable to clean avatar cache.") }
        }
    }

    Text {
        id: cleanAvatarCacheDescription
        width: 340
        height: 104
        color: main.textColor
        text: "Useful option if avatars are not displayed properly, or cache is filled with useless files (for example, avatars of contacts you don't have on your contact list anymore."
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: platformStyle.fontSizeSmall
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: cleanAvatarCache.bottom
        wrapMode: Text.WordWrap
        anchors.horizontalCenterOffset: 1
        horizontalAlignment: Text.AlignLeft
    }

    Button {
        id: resetSettings
        anchors { top: cleanAvatarCacheDescription.bottom; horizontalCenter: parent.horizontalCenter }
        text: "Reset settings"
        platformInverted: main.platformInverted
        onClicked: {
            if (xmppClient.resetSettings()) {
                notify.postInfo("Settings resetted to default.")
                if (!closeTheApp) closeTheApp = true;
            } else { notify.postError("Unable to reset settings.") }
        }
    }

    Text {
        id: resetSettingsDescription
        width: 340
        height: 104
        color: main.textColor
        text: "Have you updated your app and something went wrong? Want to remove your account's details? Do you miss first run wizard? This is an option for you."
        font.pixelSize: platformStyle.fontSizeSmall
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: resetSettings.bottom
        wrapMode: Text.WordWrap
        anchors.horizontalCenterOffset: 1
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
    }

    Text {
        id: resetSettingsDescription1
        x: 11
        y: 478
        width: 340
        height: 104
        color: "#ff0000"
        text: "It is recommended to restart the app after using any of these options."
        anchors.topMargin: 116
        font.pixelSize: platformStyle.fontSizeSmall
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: resetSettings.bottom
        wrapMode: Text.WordWrap
        anchors.horizontalCenterOffset: 1
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
    }
}

