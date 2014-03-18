import QtQuick 1.1
import com.nokia.symbian 1.1

Item {
    Text {
        id: text
        color: vars.textColor
        anchors { top: parent.top; topMargin: 24; left: parent.left; right: parent.right; leftMargin: 10; rightMargin: 10 }
        wrapMode: Text.WordWrap
        font.pixelSize: 20
        text: "Welcome to Lightbulb!\n\nIt looks like it's your first time! In the next few steps, app will be configured for you.\n\nTap on \"Next\" whenever you're ready to begin, or just tap on \"Close\" to close the wizard. Don't worry, if you change your mind or simply get something wrong, you can change all the settings later. :)"
    }
}

