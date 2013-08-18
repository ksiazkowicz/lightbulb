// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1

CommonDialog {
    titleText: qsTr("Add contact")

    buttonTexts: [qsTr("OK"), qsTr("Cancel")]

    Component.onCompleted: {
        open()
        main.splitscreenY = 0
    }

    onButtonClicked: {
        if (index === 0) {
            if(( addName.text != "" ) && (addJid.text != "") ) {
                xmppClient.addContact( addJid.text, addName.text, "", true )
            }
        }
    }

    content: Rectangle {
        width: parent.width-20
        height: column.height
        anchors.horizontalCenter: parent.horizontalCenter
        color: "transparent"

        Column {
            id: column
            spacing: 5
            width: parent.width
            Label { id: addNameLabel; anchors.horizontalCenter: parent.horizontalCenter; text: qsTr("Contact name:");}
            TextField {
                id: addName
                height: 50
                anchors { left: parent.left; right: parent.right }
                placeholderText: qsTr("Name")
                onActiveFocusChanged: {
                    splitscreenY = 0
                }
            }
            Label { id: addJidLabel; anchors.horizontalCenter: parent.horizontalCenter; text: "JID:";}
            TextField {
                id: addJid
                height: 50
                anchors { left: parent.left; right: parent.right }
                placeholderText: qsTr("example@server.com")
                onActiveFocusChanged: {
                    splitscreenY = 0
                }
            }

        }
    }
}
