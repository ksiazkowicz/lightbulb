import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.1

Item {
    property bool highlighted: dataInputField.focus
    property alias enabled: dataInputField.enabled
    property string settingLabel
    property string placeholder
    property alias value: dataInputField.text
    property alias echoMode: dataInputField.echoMode
    property alias inputMask: dataInputField.inputMask
    property alias inputMethodHints: dataInputField.inputMethodHints

    anchors { margins: 40; }
    height: label.height + dataInputField.height + 5

    Label {
        id: label
        text: settingLabel
        anchors { left: parent.left; right: parent.right; top: parent.top; }
        opacity: enabled ? 1 : 0.5
    }
    TextField {
        id: dataInputField
        placeholderText: placeholder
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom; }
    }
}
