import QtQuick 1.1

Rectangle {
    id: root
    height: 1
    anchors { left: parent.left; right: parent.right }
    color:  main.platformInverted ? "black" : "white"
    opacity: 0.15
}
