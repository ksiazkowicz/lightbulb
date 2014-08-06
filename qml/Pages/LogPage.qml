/********************************************************************

qml/Pages/LogPage.qml
-- log page for Lightbulb

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
    id: logPage
    property string pageName: "Log view"
    property string logText
    tools: ToolBarLayout {
        ToolButton {
            iconSource: main.platformInverted ? "toolbar-back_inverse" : "toolbar-back"
            onClicked: pageStack.pop()
        }
    }

    // Code for destroying the page after pop
    onStatusChanged: if (logPage.status === PageStatus.Inactive) logPage.destroy()

    TextArea {
        readOnly: true
        anchors.fill: parent
        text: logText.substring(0,logText.length-1)
    }
}

