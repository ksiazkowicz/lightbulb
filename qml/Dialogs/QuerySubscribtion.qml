import QtQuick 1.1
import com.nokia.symbian 1.1

CommonDialog {
    titleText: qsTr("Subscription request")
    platformInverted: main.platformInverted

    buttonTexts: [qsTr("Accept"), qsTr("Decline")]

    Component.onCompleted: open()

    onButtonClicked: {
        if (index === 0) xmppClient.acceptSubscribtion(vars.dialogJid); else xmppClient.rejectSubscribtion(vars.dialogJid);
    }

    content: Text {
        color: vars.textColor
        id: subQueryLabel;
        wrapMode: Text.Wrap;
        anchors { fill: parent; leftMargin: 10; rightMargin:10 }
        text: qsTr("Accept subscription request from ") + vars.dialogJid + "?";
    }
}
