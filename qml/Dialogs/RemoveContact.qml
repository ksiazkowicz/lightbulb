// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1

CommonDialog {
    buttonTexts: [qsTr("Yes"), qsTr("No")]
    titleText: "Confirmation"

    Component.onCompleted: {
        open()
    }

    onButtonClicked: {
        if (index === 0) {
            selectedName = ""
            __selectedContactItemType = 0
            xmppClient.removeContact( xmppClient.chatJid )
        }
    }

    content: Text {
        color: "white";
        id: dialogQueryLabel;
        wrapMode: Text.Wrap;
        anchors { fill: parent; leftMargin: 10; rightMargin:10; topMargin: 10 }
        text: qsTr("Remove ") + dialogName + "?";
    }
}
