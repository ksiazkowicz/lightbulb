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
    id: contributors
    titleText: qsTr("Developers")

    platformInverted: main.platformInverted
    buttonTexts: [qsTr("OK")]

    content: Item {
        height: Math.min(flickable.contentHeight, platformContentMaximumHeight)
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

                Column {
                    width: parent.width
                    spacing: platformStyle.paddingSmall

                    Label {
                        id: titleLabel
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.bold: true
                        font.pixelSize: platformStyle.fontSizeLarge + 1
                        text: qsTr("Core Developers")
                        color: vars.textColor
                    }

                    Text {
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: platformStyle.fontSizeMedium
                        color: vars.textColor
                        text: "Maciej Janiszewski\nAnatoliy Kozlov (MeegIM)"
                    }
                }

                Column {
                    width: parent.width
                    spacing: platformStyle.paddingSmall

                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.bold: true
                        font.pixelSize: platformStyle.fontSizeLarge + 1
                        text: qsTr("Contributors")
                        color: vars.textColor
                    }

                    Text {
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: platformStyle.fontSizeMedium
                        color: vars.textColor
                        text: "Fabian Hüllmantel\nPaul Wallace\nDickson Leong\nMotaz Alnuweiri"
                    }
                }

                Column {
                    width: parent.width
                    spacing: platformStyle.paddingSmall

                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.bold: true
                        font.pixelSize: platformStyle.fontSizeLarge + 1
                        text: qsTr("Testing")
                        color: vars.textColor
                    }

                    Text {
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: platformStyle.fontSizeMedium
                        color: vars.textColor
                        text: "Mohamed Zinhom\nKonrad Bąk\nGodwin Tgn\nRudmata\nRicardo Partida\nmassi93"
                    }

                }

                Column {
                    width: parent.width
                    spacing: platformStyle.paddingSmall

                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.bold: true
                        font.pixelSize: platformStyle.fontSizeLarge + 1
                        text: qsTr("Donators")
                        color: vars.textColor
                    }

                    Text {
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: platformStyle.fontSizeMedium
                        color: vars.textColor
                        text: "Elena Archinova"
                    }
                }
            }
        }

        ScrollBar {
            id: scrollBar

            anchors {
                top: parent.top
                bottom: parent.bottom
                right: parent.right
                margins: platformStyle.paddingSmall
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
    onStatusChanged: {
        if (isCreated && status === DialogStatus.Closed) {
            destroy()
        }
    }
}
