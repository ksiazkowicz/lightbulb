/********************************************************************

qml/Dialogs/VibrationSettings.qml
-- Dialog in which you can configure vibration parameters

Copyright (c) 2013 Maciej Janiszewski

This file is part of Lightbulb.

Lightbulb is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

*********************************************************************/

import QtQuick 1.1
import com.nokia.symbian 1.1
import lightbulb 1.0

CommonDialog {
    titleText: qsTr("Vibration settings")
    privateCloseIcon: true
    height: 250
    platformInverted: main.platformInverted

    // Code for dynamic load
    Component.onCompleted: {
        open();
        isCreated = true }
    property bool isCreated: false

    onStatusChanged: { if (isCreated && status === DialogStatus.Closed) { destroy() } }

    content: Item {
        width: parent.width-20
        anchors.horizontalCenter: parent.horizontalCenter
        Column {
            spacing: platformStyle.paddingSmall
            width: parent.width
            anchors { topMargin: spacing; bottomMargin: spacing; fill: parent }

            Text {
                text: qsTr("Intensity") + " (" + intensitySlider.value + "%)"
                color: vars.textColor
            }
            Slider {
                id: intensitySlider
                stepSize: 1
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                maximumValue: 100
                value: settings.gInt("notifications", vars.nowEditing + "Intensity")
                orientation: 1
                platformInverted: main.platformInverted
                onValueChanged: settings.sInt(value,"notifications", vars.nowEditing + "Intensity")
            }
            Text {
                text: qsTr("Duration") + " (" + durationSlider.value + " ms)"
                color: vars.textColor
            }
            Slider {
                id: durationSlider
                stepSize: 10
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                maximumValue: 2000
                value: settings.gInt("notifications", vars.nowEditing + "Duration")
                orientation: 1
                platformInverted: main.platformInverted
                onValueChanged: settings.sInt(value,"notifications", vars.nowEditing + "Duration")
            }
        }
    }
}
