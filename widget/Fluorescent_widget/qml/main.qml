/********************************************************************

qml/main.qml
-- Main QML file, contains PageStack and loads globally available
-- objects

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
import com.nokia.extras 1.1
import lightbulb 1.0

PageStackWindow {
    id: main
    platformInverted: settings.gBool("ui","invertPlatform")
    property string textColor: platformInverted ? platformStyle.colorNormalDark : platformStyle.colorNormalLight

    Settings { id: settings }

    Notifications       { id: notify }
    ListModel           { id: listModelResources }

    /************************( stuff to do when running this app )*****************************/
    Component.onCompleted:      {
        avkon.setAppHiddenState(true);
        pageStack.push("qrc:/pages/Preferences")
    }

    /****************************( Dialog windows, menus and stuff)****************************/

    StatusBar {
        y: 0
        Item {
            anchors { left: parent.left; leftMargin: 6; bottom: parent.bottom; top: parent.top }
            width: parent.width - 186;
            clip: true
            Text {
                id: statusBarText
                anchors.verticalCenter: parent.verticalCenter
                maximumLineCount: 1
                color: "white"
                font.pointSize: 6
             }
             Rectangle {
                width: 25
                anchors { top: parent.top; bottom: parent.bottom; right: parent.right }
                rotation: -90
                gradient: Gradient {
                            GradientStop { position: 0.0; color: "#00000000" }
                            GradientStop { position: 1.0; color: "#ff000000" }
                        }
             }
        }
    }
}
