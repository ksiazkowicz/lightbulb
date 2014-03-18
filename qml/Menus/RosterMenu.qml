/********************************************************************

qml/Menus/RosterMenu.qml
-- contains roster main menu (options button)

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

Menu {
    id: rosterMenu
    platformInverted: main.platformInverted

    // define the items in the menu and corresponding actions
    content: MenuLayout {
        MenuItem {
            text: qsTr("Preferences")
            platformInverted: main.platformInverted
            onClicked: main.pageStack.push( "qrc:/pages/Preferences" )
        }
        MenuItem {
            text: qsTr("About...")
            platformInverted: main.platformInverted
            onClicked: main.pageStack.push( "qrc:/pages/About" )
        }
        MenuItem {
            text: qsTr("Exit")
            platformInverted: main.platformInverted
            onClicked: {
                rosterMenu.close()
                if (avkon.displayAvkonQueryDialog("Close", qsTr("Are you sure you want to close the app?"))) {
                    avkon.hideChatIcon()
                    Qt.quit()
                }
            }
        }
    }

    Component.onCompleted: {
        open();
        isCreated = true }
    property bool isCreated: false

    onStatusChanged: { if (isCreated && status === DialogStatus.Closed) { destroy() } }
}
