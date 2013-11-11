// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1

CommonDialog {
    id: muteNotifications
    titleText: qsTr("Mute notifications")

    buttonTexts: [qsTr("OK"), qsTr("Cancel")]
    platformInverted: main.platformInverted

    Component.onCompleted: {
        open()
    }

    onButtonClicked: {
        if ((index === 0) && ( notifyHoldDuration.text != "" )) {
            main.notifyHoldDuration = parseInt(notifyHoldDuration.text)
            main.notifyHold = true
            notifyHoldTimer.running = true
        }
    }

    content: Rectangle {
        width: parent.width-20
        height: 100
        anchors.horizontalCenter: parent.horizontalCenter
        color: "transparent"

        Text {
            id: queryLabel;
            color: main.textColor
            anchors { left: parent.left; leftMargin: 10; right: parent.right; rightMargin: 10; top: parent.top; topMargin: 10 }
            text: qsTr("Mute notifications for...");
        }
        TextField {
            id: notifyHoldDuration
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            text: dialogName
            height: 50
            anchors { bottom: parent.bottom; bottomMargin: 5; left: parent.left; right: parent.right }
            placeholderText: qsTr("Time in minutes (ex. 15)")

            onActiveFocusChanged: {
                splitscreenY = 0
            }
        }
    }
}


