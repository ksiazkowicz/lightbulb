import QtQuick 1.1
import com.nokia.symbian 1.1

CommonDialog {
    buttonTexts: [qsTr("Yes"), qsTr("No")]
    titleText: "Confirmation"
    platformInverted: main.platformInverted

    Component.onCompleted: open()

    onButtonClicked: {
        if (index === 0) {
            settings.removeAccount( main.accJid )
            settings.initListOfAccounts()
        }
    }

    content: Text {
        color: main.textColor
        id: dialogQueryLabel;
        wrapMode: Text.Wrap;
        anchors { left: parent.left; right: parent.right; leftMargin: 10; rightMargin:10; verticalCenter: parent.verticalCenter }
        text: qsTr("Remove ") + main.accJid + "?";
    }
}
