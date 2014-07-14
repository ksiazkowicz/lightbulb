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

    Flickable {
        id: migra
        flickableDirection: Flickable.VerticalFlick
        anchors.fill: parent
        contentHeight: content.height

        Column {
            id: content
            spacing: 5

            Text {
                id: text
                color: vars.textColor
                anchors { left: parent.left; right: parent.right; leftMargin: 10; rightMargin: 10 }
                wrapMode: Text.WordWrap
                font.pixelSize: 20
                text: "Welcome back!\n\nIt looks like you've used Lightbulb 0.3 before and you want to import your old settings. You can choose the data relevant to you and the app would load them.\nTap on \"Next\" whenever you're ready to begin, or just tap on \"Close\" to close the wizard. :)"
            }

            CheckBox {
                text: qsTr("Accounts")
            }
            CheckBox {
                text: qsTr("User interface settings")
            }
            CheckBox {
                text: qsTr("Notification settings")
            }
            CheckBox {
                text: qsTr("Advanced settings")
            }
            CheckBox {
                text: qsTr("Use old avatar cache directory")
            }
            CheckBox {
                text: qsTr("Connection settings")
            }
            CheckBox {
                text: qsTr("Behavior")
            }
            CheckBox {
                text: qsTr("Saved status text")
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


