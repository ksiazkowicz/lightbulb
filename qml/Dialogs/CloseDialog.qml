// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1

CommonDialog {
    id: closeDialog
    titleText: "Confirmation"
    buttonTexts: [qsTr("Yes"), qsTr("No")]
    platformInverted: main.platformInverted

    Component.onCompleted: {
        open()
    }

    onButtonClicked: {
        if (index === 0) {
            avkon.hideChatIcon();
            Qt.quit()
        }
    }

    content: Text {
        color: main.textColor
        id: dialogQueryLabel;
        wrapMode: Text.Wrap;
        anchors { left: parent.left; right: parent.right; leftMargin: 10; rightMargin:10; verticalCenter: parent.verticalCenter }
        text: qsTr("Are you sure you want to close the app?")
    }
}
