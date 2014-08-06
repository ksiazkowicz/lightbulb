// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import lightbulb 1.0
import com.nokia.symbian 1.1

Item {
    id: mucPartDelegate
    height: 48
    Image {
        id: imgPresence
        source: presence
        sourceSize.height: 24
        sourceSize.width: 24
        anchors { verticalCenter: mucPartDelegate.verticalCenter; left: parent.left; leftMargin: 10; }
        height: 24
        width: 24
    }
    Flickable {
        flickableDirection: Flickable.HorizontalFlick
        //boundsBehavior: Flickable.DragOverBounds
        height: 48
        width: mucPartDelegate.width
        contentWidth: wrapper.width + buttonRow.width
        Rectangle {
            id: wrapper
            width: mucPartDelegate.width
            anchors.left: parent.left
            height: 48
            /*Image {
                id: imgRole
                source:
                sourceSize.height: 24
                sourceSize.width: 24
                anchors { verticalCenter: parent.verticalCenter; right: closeBtn.left; rightMargin: 10 }
                height: 24
                width: 24
            }*/
            Text {
                id: partName
                anchors { verticalCenter: parent.verticalCenter; left: parent.left; right: parent.right; rightMargin: 5; leftMargin: 44 }
                text: name
                font.pixelSize: 18
                clip: true
                color: vars.textColor
                elide: Text.ElideRight
            }
        }
        ButtonRow {
            id: buttonRow
            anchors.left: wrapper.right;
            ToolButton {
                text: "Kick"
            }
            ToolButton {
                text: "Ban"
            }
        }
    }
}
