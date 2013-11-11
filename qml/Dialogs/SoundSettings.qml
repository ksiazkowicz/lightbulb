// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1
import lightbulb 1.0

CommonDialog {
        titleText: qsTr("Effect settings")
        privateCloseIcon: true
        height: 216
        platformInverted: main.platformInverted

        Component.onCompleted: {
            open()
        }

        content: Rectangle {
            width: parent.width-20
            height: 200
            anchors.horizontalCenter: parent.horizontalCenter
            color: "transparent"

            Column {
                spacing: 5
                width: parent.width
                anchors { topMargin: 5; bottomMargin: 5; fill: parent }

                Text {
                    id: volumeText
                    text: "Volume (" + volumeSlider.value + "%)"
                    color: main.textColor
                }
                Slider {
                    id: volumeSlider
                    stepSize: 1
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    maximumValue: 100
                    //minimumValue: 24
                    value: settings.gInt("notifications", nowEditing + "Volume")
                    orientation: 1
                    platformInverted: main.platformInverted

                    onValueChanged: {
                        settings.sInt(value,"notifications", nowEditing + "Volume")
                    }
                }
                Button {
                    width: parent.width
                    text: "Select file"
                    platformInverted: main.platformInverted
                    onClicked: {
                        main.changeAudioFile()
                    }
                }
            }
        }
    }
