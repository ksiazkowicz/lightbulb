// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1

CommonDialog {
    titleText: qsTr("Subscription request")

    buttonTexts: [qsTr("Accept"), qsTr("Decline")]

    Component.onCompleted: {
        open()
    }

    onButtonClicked: {
        if (index === 0) xmppClient.acceptSubscribtion(dialogJid); else xmppClient.rejectSubscribtion(dialogJid);
    }

    content: Text {
        color: "white";
        id: subQueryLabel;
        wrapMode: Text.Wrap;
        anchors { fill: parent; leftMargin: 10; rightMargin:10 }
        text: qsTr("Accept subscription request from ") + dialogJid + "?";
    }
}
