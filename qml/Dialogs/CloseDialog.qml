/********************************************************************

qml/Dialogs/CloseDialog.qml
-- Dialog for closing the app

Copyright (c) 2013 Maciej Janiszewski

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
    titleText: "Confirmation"
    buttonTexts: [qsTr("Yes"), qsTr("No")]
    platformInverted: main.platformInverted

    Component.onCompleted: open()
    onButtonClicked: if (index === 0) { avkon.hideChatIcon(); Qt.quit() }

    content: Text {
        color: vars.textColor
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignJustify
        anchors { fill: parent; margins: platformStyle.paddingSmall }
        text: qsTr("Are you sure you want to close the app?")
    }
}
