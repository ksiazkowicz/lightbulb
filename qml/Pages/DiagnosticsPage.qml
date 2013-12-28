/********************************************************************

qml/Pages/DiagnosticsPage.qml
-- Page with diagnostic options

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

Page {
    orientationLock: 1
    tools: ToolBarLayout {
               ToolButton {
                   iconSource: main.platformInverted ? "toolbar-back_inverse" : "toolbar-back"
                   onClicked: { statusBarText.text = "Contacts"
                       if (!closeTheApp) pageStack.pop(); else avkon.restartApp() }
                }
    }

    property bool closeTheApp: false
    Component.onCompleted: statusBarText.text = qsTr("Maintenance")

    Column {
        anchors { fill: parent; margins: platformStyle.paddingSmall; }
        spacing: platformStyle.paddingSmall

        Button {
            text: "Remove database"
            platformInverted: main.platformInverted
            onClicked: {
                if (xmppConnectivity.client.dbRemoveDb()) {
                    notify.postInfo("Database cleaned.")
                    if (!closeTheApp) closeTheApp = true;
                } else notify.postError("Unable to clean database.")
            }
        }

        Text {
            width: parent.width
            color: vars.textColor
            text: "This option will remove all the archived messages."
            font.pixelSize: platformStyle.fontSizeSmall
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignJustify
        }

        Button {
            text: "Clean avatar cache"
            platformInverted: main.platformInverted
            onClicked: {
                if (xmppConnectivity.client.cleanCache()) {
                    notify.postInfo("Avatar cache cleaned.")
                    if (!closeTheApp) closeTheApp = true;
                } else notify.postError("Unable to clean avatar cache.")
            }
        }

        Text {
            width: parent.width
            color: vars.textColor
            font.pixelSize: platformStyle.fontSizeSmall
            text: "Useful option if avatars are not displayed properly, or cache is filled with useless files."
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignJustify
        }

        Button {
            text: "Reset settings"
            platformInverted: main.platformInverted
            onClicked: {
                if (xmppConnectivity.client.resetSettings()) {
                    notify.postInfo("Settings resetted to default.")
                    if (!closeTheApp) closeTheApp = true;
                } else notify.postError("Unable to reset settings.")
            }
        }
        Text {
            width: parent.width
            color: vars.textColor
            font.pixelSize: platformStyle.fontSizeSmall
            text: "Have you updated your app and something went wrong? Want to remove your accounts details? Do you miss first run wizard? This is an option for you."
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignJustify
        }
        Text {
            width: parent.width
            color: "#ff0000"
            font.pixelSize: platformStyle.fontSizeSmall
            text: "It is required to restart the app after using above options."
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignJustify
        }
    }
}

