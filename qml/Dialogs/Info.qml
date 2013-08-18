// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1

CommonDialog {
    titleText: dialogTitle
    buttonTexts: [qsTr("OK")]

    Component.onCompleted: {
        open()
    }

    content: Text {
        id: dialogInfoLabel;
        text: dialogText
        color: "white";
        anchors { left: parent.left; right: parent.right; leftMargin: 10; rightMargin:10; verticalCenter: parent.verticalCenter; }
        wrapMode: Text.Wrap }
}
