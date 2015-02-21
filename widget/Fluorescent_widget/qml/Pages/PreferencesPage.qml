/********************************************************************

qml/Pages/PreferencesPage.qml
-- preferences page, displays preflets

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
import com.nokia.extras 1.1

Page {
    id: preferencesPage
    tools: ToolBarLayout {
        id: toolBarLayout
        ToolButton {
            iconSource: main.platformInverted ? "toolbar-back_inverse" : "toolbar-back"
            onClicked: avkon.minimize();
            onPlatformPressAndHold: {
                notify.cleanWidget()
                Qt.quit();
            }
        }
    }

    Flickable {
        id: prefletView
        anchors.fill: preferencesPage;
        contentHeight: preflet.item.height
        contentWidth: width
        flickableDirection: Flickable.VerticalFlick
        clip: true
        Loader {
            id: preflet
            source: "qrc:/Preflets/Widget"
            anchors.fill: parent
        }
    }

    // Code for destroying the page after pop
    onStatusChanged: if (preferencesPage.status === PageStatus.Inactive) preferencesPage.destroy()

    Component.onCompleted: statusBarText.text = "Widget settings"
}
