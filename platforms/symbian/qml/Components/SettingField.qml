// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1

Rectangle {
    id: settingField
    height: 66
    radius: 4
    color: highlighted ? (platformInverted ? "black" : "white") : "transparent"

    property bool highlighted: false
    property alias enabled: dataInputField.enabled
    property bool platformInverted: main.platformInverted
    property string settingLabel
    property string placeholder
    property alias value: dataInputField.text
    property alias echoMode: dataInputField.echoMode
    property alias inputMask: dataInputField.inputMask

    MouseArea {
        anchors.fill: parent;
        onClicked: dataInputField.focus = true;
    }

    Column {
        spacing: platformStyle.paddingSmall
        anchors { left: parent.left; leftMargin: 40; rightMargin: 40; right: parent.right; verticalCenter: parent.verticalCenter }
        Label {
            text: settingLabel
            platformInverted: highlighted ? !settingField.platformInverted : settingField.platformInverted
            opacity: enabled ? 1 : 0.5
        }
        TextInput {
            id: dataInputField
            color: platformInverted ? (highlighted ? "white" : "black") : (highlighted ? "black" : "white")
            font.pixelSize: platformStyle.fontSizeMedium
            font.bold: true
            width: parent.width

            onFocusChanged: {
                // highlight the field
                if (focus)
                    highlighted = true;

                // (main.height - inputContext.height = visible space)
                var visibleSpace = Math.abs(main.height - inputContext.height);
                // calculate position + required space (font size + padding)
                var posAndSpace = Math.abs(settingField.y + platformStyle.fontSizeMedium + platformStyle.paddingSmall);

                // check if position + required space > (visibleSpace - settingField.height) to determine if there is need to move it up or not
                var isMovementRequired = posAndSpace > Math.abs(visibleSpace-settingField.height);

                // set splitscreenY
                main.splitscreenY = isMovementRequired ? Math.abs(posAndSpace - visibleSpace + settingField.height) : 0
            }

            Connections {
                target: inputContext
                onVisibleChanged: if (!visible) dataInputField.focus = false;
            }

            Text {
                color: parent.color
                opacity: 0.5
                font.pixelSize: platformStyle.fontSizeMedium
                font.bold: true
                visible: dataInputField.text == ""
                text: placeholder
            }
        }
    }
    LineItem { anchors.bottom: parent.bottom }
}
