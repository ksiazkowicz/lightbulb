/********************************************************************

qml/Dialogs/Contributors.qml
-- dialog containing list of contributors

Copyright (c) 2013-2014 Maciej Janiszewski

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

CommonDialog {
    titleText: qsTr("Developers")

    platformInverted: main.platformInverted
    buttonTexts: [qsTr("OK")]
    Component.onCompleted: open()

    height: 400

    content: Flickable {
        contentHeight: columnContent.height
        contentWidth: columnContent.width
        anchors { fill: parent; margins: platformStyle.paddingSmall }

        flickableDirection: Flickable.VerticalFlick

        Column {
            id: columnContent
            width: parent.width - 2*platformStyle.paddingSmall
            spacing: platformStyle.paddingSmall
            Label { anchors.horizontalCenter: parent.horizontalCenter; font.pixelSize: platformStyle.fontSizeLarge*1.2; text: qsTr("Core developers"); color: vars.textColor }
            Text {
                color: vars.textColor
                text: "Maciej Janiszewski\nAnatoliy Kozlov (MeegIM)"
            }
            Label { anchors.horizontalCenter: parent.horizontalCenter; font.pixelSize: platformStyle.fontSizeLarge*1.2; text: "Contributors"; color: vars.textColor}
            Text {
                color: vars.textColor
                text: "Fabian Hüllmantel\nPaul Wallace\nDickson Leong\nMotaz Alnuweiri"
            }
            Label { anchors.horizontalCenter: parent.horizontalCenter; font.pixelSize: platformStyle.fontSizeLarge*1.2; text: "Testing"; color: vars.textColor}
            Text {
                color: vars.textColor
                text: "Mohamed Zinhom\nKonrad Bąk\nGodwin Tgn\nRudmata\nRicardo Partida"
            }
            Label { anchors.horizontalCenter: parent.horizontalCenter; font.pixelSize: platformStyle.fontSizeLarge*1.2; text: "Donators"; color: vars.textColor}
            Text {
                color: vars.textColor
                text: "Elena Archinova"
            }
        }
     }
}
