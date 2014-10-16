/********************************************************************

qml/Preflets/Behavior.qml
-- Preflet with behavior options

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
import "../Components"

Item {
    height: content.height
    Column {
        id: content
        spacing: 5
        anchors { top: parent.top; topMargin: 10; left: parent.left; leftMargin: 10; right: parent.right; rightMargin: 10 }
        CheckBox {
           text: qsTr("Enable auto-away")
           checked: settings.gBool("behavior", "autoAway")
           platformInverted: main.platformInverted
           onCheckedChanged: {
              settings.sBool(checked,"behavior", "autoAway")
              vars.autoAway = checked;
           }
        }

        SettingField {
            settingLabel: qsTr("Time (in minutes)")
            width: content.width
            inputMethodHints: Qt.ImhFormattedNumbersOnly

            Component.onCompleted: value = vars.autoAwayTime

            onValueChanged: {
                var limit = parseInt(value)
                vars.autoAwayTime = limit;
                settings.sInt(limit,"behavior", "autoAwayTime")
            }
        }
    }
}
