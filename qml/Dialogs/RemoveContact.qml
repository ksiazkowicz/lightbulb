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
            xmppClient.removeContact( xmppClient.chatJid )
        }
    }

    content: Text {
        color: "white";
        id: dialogQueryLabel;
        wrapMode: Text.Wrap;
        anchors { left: parent.left; right: parent.right; leftMargin: 10; rightMargin:10; verticalCenter: parent.verticalCenter }
        text: qsTr("Are you sure you want to remove ") + dialogName + qsTr(" from your contact list?");
    }
}
