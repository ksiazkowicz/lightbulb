import QtQuick 1.1
import com.nokia.symbian 1.1

Item {
    Text {
        id: text
        color: main.textColor
        anchors { top: parent.top; topMargin: 24; left: parent.left; right: parent.right; leftMargin: 10; rightMargin: 10 }
        wrapMode: Text.WordWrap
        font.pixelSize: 20
        text: qsTr("Your app is now configured and it's ready to work. :) You can close the wizard now. After that, just tap Options button and choose Status to go online and start chatting.")
    }
}

