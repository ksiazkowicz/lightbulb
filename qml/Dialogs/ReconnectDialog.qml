// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1
import lightbulb 1.0

CommonDialog {
    id: reconDialog
    titleText: qsTr("Connection lost")
    property int timeLeft: 10

    buttonTexts: [qsTr("Cancel")]

    Component.onCompleted: {
        open()
    }

    onButtonClicked: {
        timeLeftTimer.running = false
    }



    Timer {
        id: timeLeftTimer
        running: true; repeat: true
        onTriggered: {
            if (timeLeft > 0) {
                timeLeft--
            } else {
                xmppClient.setMyPresence( XmppClient.Online, main.laststatus )
                reconDialog.close()
                running = false
            }
        }
    }

    content: Text {
        color: "white";
        id: reconLabel;
        wrapMode: Text.Wrap;
        anchors { left: parent.left; right: parent.right; leftMargin: 10; rightMargin:10; verticalCenter: parent.verticalCenter }
        text: qsTr("Attempting to reconnect in ")+timeLeft+qsTr(" seconds.")
    }
}
