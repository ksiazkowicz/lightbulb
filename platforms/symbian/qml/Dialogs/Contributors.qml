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
import "../Components"

CommonDialog {
    id: contributors
    titleText: qsTr("Developers")

    platformInverted: main.platformInverted
    buttonTexts: [qsTr("OK")]

    content: Item {
        height: Math.min(flickable.contentHeight + (platformStyle.paddingLarge * 2), platformContentMaximumHeight)
        width: parent.width

        Flickable {
            id: flickable
            contentHeight: columnContent.height
            height: parent.height - (platformStyle.paddingLarge * 2)
            width: parent.width - (platformStyle.paddingLarge * 2)
            anchors { left: parent.left; top: parent.top; margins: platformStyle.paddingLarge}
            flickableDirection: Flickable.VerticalFlick
            clip: true
            interactive: contentHeight > height

            Column {
                id: columnContent
                width: parent.width
                spacing: platformStyle.paddingLarge

                DetailsItem {
                    textAlignment: Text.AlignHCenter
                    title: qsTr("Core Developer")
                    value: "Maciej Janiszewski"
                }

                DetailsItem {
                    textAlignment: Text.AlignHCenter
                    title: qsTr("Contributors")
                    value: "Fabian Hüllmantel\nPaul Wallace\nDickson Leong\nBhavin Gandhi\nMotaz Alnuweiri"
                }

                DetailsItem {
                    textAlignment: Text.AlignHCenter
                    title: qsTr("Testing")
                    value: "Mohamed Zinhom\nKonrad Bąk\nGodwin Tgn\nRudmata\nRicardo Partida\nMaximiliano Caleca"
                }

                DetailsItem {
                    textAlignment: Text.AlignHCenter
                    title: qsTr("Donators")
                    value: "Pece Murtanovski\nPaul Wallace\nFabian Hüllmantel\nJerome Redon\nElena Archinova\nJuan Pablo Ambriz Guzman"
                }

                DetailsItem {
                    textAlignment: Text.AlignHCenter
                    title: qsTr("Special thanks to")
                    value: "Anatoliy Kozlov (MeegIM)\nStackOverflow users\nNokia\nCountless users of Qt support forums"
                }
            }
        }

        ScrollBar {
            id: scrollBar

            anchors {
                top: parent.top
                bottom: parent.bottom
                right: parent.right
                margins: platformStyle.paddingSmall - 2
            }

            flickableItem: flickable
            interactive: false
            orientation: Qt.Vertical
            platformInverted: main.platformInverted
        }
    }

    // Code for dynamic load
    Component.onCompleted: {
        open()
        isCreated = true
    }

    property bool isCreated: false
    onStatusChanged: if (isCreated && contributors.status === DialogStatus.Closed) contributors.destroy()
}
