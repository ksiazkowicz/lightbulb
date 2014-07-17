/********************************************************************

qml/Pages/MigrationPage.qml
-- migration page in Lightbulb

Copyright (c) 2014 Maciej Janiszewski

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

Page {
    id: migraPage
    tools: ToolBarLayout {
        id: toolBarLayout
        ToolButton {
            iconSource: main.platformInverted ? "qrc:/toolbar/close_inverse" : "qrc:/toolbar/close"
            onClicked: {
                Qt.quit()
            }
        }

        ToolButton {
            iconSource: main.platformInverted ? "toolbar-next_inverse" : "toolbar-next"
            onClicked: {
            }
        }

    }

    Component.onCompleted: { statusBarText.text = qsTr("Migration") }

    // Code for destroying the page after pop
    onStatusChanged: if (migraPage.status === PageStatus.Inactive) migraPage.destroy()

    function migrate() {
        if (accCheckBox.checked) {

        }
        if (uiCheckbox.checked) {

        }
        if (eventsCheckBox.checked) {

        }
        if (advCheckBox.checked) {

        }
        if (cacheCheckBox.checked) {

        }
        if (behaviorCheckBox.checked) {

        }
    }

    Flickable {
        id: migra
        flickableDirection: Flickable.VerticalFlick
        anchors.fill: parent
        contentHeight: content.height

        Column {
            id: content
            spacing: 5

            Text {
                color: vars.textColor
                anchors { left: parent.left; right: parent.right; leftMargin: 10; rightMargin: 10 }
                font.pixelSize: 32
                text: "Welcome back!"
                height: 64
                verticalAlignment: Text.AlignVCenter
            }

            Text {
                id: text
                color: vars.textColor
                anchors { left: parent.left; right: parent.right; leftMargin: 10; rightMargin: 10 }
                wrapMode: Text.WordWrap

                font.pixelSize: 20
                text: "Apparently you've been using Lightbulb " + migration.getData("main","last_used_rel") + " before. You can choose the data relevant to you and the app would import them.\n\nTap on \"Next\" whenever you're ready to begin, or just tap on \"Close\" to close the wizard. :)"
            }

            CheckBox {
                id: accCheckBox
                platformInverted: main.platformInverted
                text: qsTr("Accounts")
            }
            CheckBox {
                id: uiCheckBox
                platformInverted: main.platformInverted
                text: qsTr("User interface settings")
            }
            CheckBox {
                id: eventsCheckBox
                platformInverted: main.platformInverted
                text: qsTr("Notification settings")
            }
            CheckBox {
                id: advCheckBox
                platformInverted: main.platformInverted
                text: qsTr("Advanced settings")
            }
            CheckBox {
                id: cacheCheckBox
                platformInverted: main.platformInverted
                text: qsTr("Use old avatar cache directory")
            }
            CheckBox {
                id: behaviorCheckBox
                platformInverted: main.platformInverted
                text: qsTr("Behavior")
            }
        }

    }

    ScrollBar {
        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
            margins: platformStyle.paddingSmall - 2
        }

        flickableItem: migra
        orientation: Qt.Vertical
        platformInverted: main.platformInverted
    }
}


