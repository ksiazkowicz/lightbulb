/********************************************************************

qml/Preflets/LED.qml
-- Preflet with notification LED options

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
    height: column.height
    property int tmpValue: settings.gInt("notifications", "blinkScreenDevice") == 0 ? 1 : settings.gInt("notifications", "blinkScreenDevice")

    Column {
        id: column
        spacing: platformStyle.paddingSmall
        anchors.horizontalCenter: parent.horizontalCenter;
        width: parent.width
        Item { height: 32 }
        Text {
            id: text
            color: main.textColor
            anchors {left: parent.left; right: parent.right; leftMargin: 10; rightMargin: 10 }
            wrapMode: Text.WordWrap
            font.pixelSize: 20
            text: qsTr("Because every phone is different, we need you do do a couple of tests before proceeding to ensure that all the features will work properly. Lightbulb will now try different ways to access your phones notification LED. \n\nObserve your menu button. Tap on \"Try again\" if it isn't blinking.")
        }
        CheckBox {
            id: enableLED
            text: qsTr("Enable notification LED support")
            checked: settings.gBool("behavior","wibblyWobblyTimeyWimeyStuff")
            platformInverted: main.platformInverted
            onCheckedChanged: {
                settings.sBool(checked,"behavior","wibblyWobblyTimeyWimeyStuff")
                if (!checked) blink.running = false; else blink.running = true;
                ledNo.enabled = checked
            }
        }
        Item { height: 24 }
        Button {
            id: ledNo
            text: "Try again"
            width: parent.width/2 - 10
            enabled: enableLED
            platformInverted: main.platformInverted
            anchors { horizontalCenter: parent.horizontalCenter}
            onClicked: {
                switch (tmpValue) {
                    case 2: tmpValue = 1; break;
                    case 1: tmpValue = 2; break;
                }
                settings.sInt(tmpValue, "notifications", "blinkScreenDevice")
            }
        }

    }
}

