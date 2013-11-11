// import QtQnotificationsck 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1
import lightbulb 1.0

CommonDialog {
        titleText: qsTr("Vibration settings")
        privateCloseIcon: true
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
                    id: intensityText
                    text: "Intensity (" + intensitySlider.value + "%)"
                    color: main.textColor
                }
                Slider {
                    id: intensitySlider
                    stepSize: 1
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    maximumValue: 100
                    //minimumValue: 24
                    value: settings.gInt("notifications", nowEditing + "Intensity")
                    orientation: 1
                    platformInverted: main.platformInverted

                    onValueChanged: {
                        settings.sInt(value,"notifications", nowEditing + "Intensity")
                    }
                }
                Text {
                    id: durationText
                    text: "Duration (" + durationSlider.value + " ms)"
                    color: main.textColor
                }
                Slider {
                    id: durationSlider
                    stepSize: 10
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    maximumValue: 2000
                    //minimumValue: 24
                    value: settings.gInt("notifications", nowEditing + "Duration")
                    orientation: 1
                    platformInverted: main.platformInverted

                    onValueChanged: {
                        settings.sInt(value,"notifications", nowEditing + "Duration")
                    }
                }
            }
        }
    }
