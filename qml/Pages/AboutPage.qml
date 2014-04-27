/********************************************************************

qml/Pages/AboutPage.qml
-- about page for Lightbulb

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

Page {
    id: aboutPage
    tools: toolBarLayout

    Component.onCompleted: { statusBarText.text = qsTr("About...") } //set statusbar text to "About..."

    // Code for destroying the page after pop
    onStatusChanged: if (aboutPage.status === PageStatus.Inactive) aboutPage.destroy()

    Flickable {
        id: about
        flickableDirection: Flickable.VerticalFlick
        anchors.fill: parent

        contentHeight: logo.height + 32 + programName.height + 5 + names.height + niceInfo.height + 24 + buttons.height + 64 + licenseStuff.height
        Image {
            id: logo
            source: "qrc:/Lightbulb.svg"
            sourceSize { width: 128; height: 128 }
            width: 128
            height: 128
            smooth: true
            scale: 1
            anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: 32 }
        }
        Text {
            id: programName
            color: vars.textColor
            text: "Lightbulb IM " + xmppConnectivity.client.version + " α"
            anchors { top: logo.bottom; topMargin: 5; horizontalCenterOffset: 0; horizontalCenter: parent.horizontalCenter }
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: platformStyle.fontSizeMedium*1.3
        }

        Text {
            id: names
            anchors { top: programName.bottom; leftMargin: 10; rightMargin: 10; left: parent.left; right: parent.right }
            color: vars.textColor
            wrapMode: Text.Wrap
            text: "coded with ♥ and coffee"
            font.pixelSize: platformStyle.fontSizeSmall
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            id: licenseStuff
            width: parent.width
            text: qsTr("This program comes with ABSOLUTELY NO WARRANTY. This is free software, and you are welcome to redistribute it under certain conditions. See GPL v3 license for details.")
            anchors { top: buttons.bottom; topMargin: 14; horizontalCenterOffset: 0; horizontalCenter: parent.horizontalCenter }
            font.bold: true
            wrapMode: Text.WordWrap
            font.pixelSize: platformStyle.fontSizeSmall
            horizontalAlignment: Text.AlignHCenter
            color: "red"
        }

        Text {
            id: niceInfo
            color: vars.textColor
            text: qsTr("During development of this software, no mobile device was harmed.")
            width: parent.width
            anchors { top: names.bottom; topMargin: 24; horizontalCenter: parent.horizontalCenter }
            wrapMode: Text.WordWrap
            font.pixelSize: platformStyle.fontSizeSmall
            horizontalAlignment: Text.AlignHCenter
        }
        Row {
            id: buttons
            anchors { horizontalCenter: parent.horizontalCenter; top: niceInfo.bottom; topMargin: 14 }
            spacing: platformStyle.paddingMedium
            Button {
                platformInverted: main.platformInverted
                text: "Contributors"
                onClicked: dialog.create("qrc:/dialogs/Contributors")
            }
            Button {
                text: "Donate"
                platformInverted: main.platformInverted
                onClicked: dialog.createWithProperties("qrc:/menus/UrlContext", {"url": "https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=SA8DZYA7PUCCU"})
            }
        }
    }

    ScrollBar {
        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
            margins: platformStyle.paddingSmall - 2
        }

        flickableItem: about
        interactive: false
        orientation: Qt.Vertical
        platformInverted: main.platformInverted
    }

    ToolBarLayout {
        id: toolBarLayout
        ToolButton {
            iconSource: main.platformInverted ? "toolbar-back_inverse" : "toolbar-back"
            onClicked: { statusBarText.text = "Contacts"
                pageStack.pop() }
        }
    }
}

