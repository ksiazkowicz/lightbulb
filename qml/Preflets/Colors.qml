/********************************************************************

qml/Preflets/Colors.qml
-- Preflet with theme options

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

Item {
    height: text.height + darkImg.height + dark.height + 18*2 + 4*platformStyle.paddingSmall
    Text {
        y: platformStyle.paddingSmall
        id: text
        anchors { top: parent.top; topMargin: platformStyle.paddingSmall; horizontalCenter: parent.horizontalCenter }
        color: main.textColor
        text: qsTr("Choose one of the following themes")
        font.pixelSize: 20
        wrapMode: Text.WordWrap
    }

    Image {
        id: darkImg
        anchors { top: text.bottom; topMargin: platformStyle.paddingSmall; left: parent.left }
        width: 180
        height: 320
        source: "qrc:/FirstRun/img/black"
    }

    Image {
        id: whiteImg
        anchors { top: text.bottom; topMargin: platformStyle.paddingSmall; right: parent.right }
        width: 180
        height: 320
        source: "qrc:/FirstRun/img/white"
    }

    RadioButton {
        id: dark
        anchors { horizontalCenter: darkImg.horizontalCenter; top: darkImg.bottom; topMargin: 18; }
        text: ""
        checked: !settings.gBool("ui", "invertPlatform")
        onCheckedChanged: if (checked) light.checked = false;
    }

    RadioButton {
        id: light
        anchors { horizontalCenter: whiteImg.horizontalCenter; top: whiteImg.bottom; topMargin: 18; }
        text: ""
        checked: settings.gBool("ui", "invertPlatform")
        onCheckedChanged: {
            if (checked) dark.checked = false;
            settings.sBool(checked,"ui", "invertPlatform")
            main.platformInverted = checked
            main.textColor = checked ? platformStyle.colorNormalDark : platformStyle.colorNormalLight
        }
    }


}
