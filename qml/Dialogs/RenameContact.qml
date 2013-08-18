// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1

CommonDialog {
    titleText: qsTr("Rename contact")

    buttonTexts: [qsTr("OK"), qsTr("Cancel")]

    Component.onCompleted: {
        open()
        main.splitscreenY = 0
    }

    onButtonClicked: {
        if ((index === 0) && ( newNameText.text != "" )) {
           xmppClient.renameContact( xmppClient.chatJid, newNameText.text )
        }
    }

    content: Rectangle {
        width: parent.width-20
        height: 100
        anchors.horizontalCenter: parent.horizontalCenter
        color: "transparent"

        Text {
            id: queryLabel;
            color: "white";
            anchors { left: parent.left; leftMargin: 10; right: parent.right; rightMargin: 10; top: parent.top; topMargin: 10 }
            text: qsTr("Choose new name:");
        }
        TextField {
            id: newNameText
            text: dialogName
            height: 50
            anchors { bottom: parent.bottom; bottomMargin: 5; left: parent.left; right: parent.right }
            placeholderText: qsTr("New name")

            onActiveFocusChanged: {
                splitscreenY = 0
            }
        }
    }
}
