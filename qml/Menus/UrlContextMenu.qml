/********************************************************************

qml/Menus/UrlContextMenu.qml
-- contains a context menu which appears after tapping on URL

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

ContextMenu {
    id: contextDialog
    platformInverted: main.platformInverted
    property string url: ""
    MenuLayout {
        MenuItem {
            platformInverted: main.platformInverted
            text: qsTr("Copy");
            onClicked: {
                clipboard.setText(url)
                avkon.showPopup("URL copied to","clipboard.",false)
            }
        }
        MenuItem {
            text: qsTr("Open in default browser");
            platformInverted: main.platformInverted
            onClicked: avkon.openDefaultBrowser(url)
        }
    }
    Component.onCompleted: {
        open();
        isCreated = true }
    property bool isCreated: false

    onStatusChanged: { if (isCreated && contextDialog.status === DialogStatus.Closed) { contextDialog.destroy() } }
}
