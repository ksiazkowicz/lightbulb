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
            onClicked: {
                if (vars.isRestartRequired) {
                    if (settings.gBool("widget","enableHsWidget")) notify.cleanWidget()
                    avkon.restartApp();
                } else pageStack.pop();
                vars.isBlinkingOverrideEnabled = false;
                statusBarText.text = "Contacts"
            }
        }
    }

    SelectionDialog {
        id: selectionDialog
        titleText: "Pages"
        selectedIndex: -1
        platformInverted: main.platformInverted
        model: ListModel {
            ListElement { name: "Events" }
            ListElement { name: "Popups" }
            ListElement { name: "Widget" }
            ListElement { name: "Connection" }
            ListElement { name: "Notification LED" }
            ListElement { name: "Colors" }
            ListElement { name: "Contact list" }
            ListElement { name: "Advanced" }
        }
        onSelectedIndexChanged: {
            switch (selectedIndex) {
                case 0: {
                    titleText.text = "Events";
                    preflet.source = "qrc:/Preflets/Events";
                    break;
                }
                case 1: {
                    titleText.text = "Discreet popups";
                    preflet.source = "qrc:/Preflets/Popups";
                    break;
                }
                case 2: {
                    titleText.text = "Homescreen widget";
                    preflet.source = "qrc:/Preflets/Widget";
                    break;
                }
                case 3: {
                    titleText.text = "Connection";
                    preflet.source = "qrc:/Preflets/Connection";
                    break;
                }
                case 4: {
                    titleText.text = "Notification LED";
                    preflet.source = "qrc:/Preflets/LED";
                    break;
                }
                case 5: {
                    titleText.text = "Colors";
                    preflet.source = "qrc:/Preflets/Colors";
                    break;
                }
                case 6: {
                    titleText.text = "Contact list";
                    preflet.source = "qrc:/Preflets/Roster";
                    break;
                }
                case 7: {
                    titleText.text = "Advanced";
                    preflet.source = "qrc:/Preflets/Advanced";
                    break;
                }
                default: break;
            }
            if (selectedIndex == 4) {
                blink.running = true;
                vars.isBlinkingOverrideEnabled = true;
            } else {
                vars.isBlinkingOverrideEnabled = false;
            }
        }
    }


    Rectangle {
        id: prefletSwitcher

        height: 46

        z: 1

        gradient: Gradient {
            GradientStop { position: 0; color: "#3c3c3c" }
            GradientStop { position: 0.04; color: "#6c6c6c" }
            GradientStop { position: 0.05; color: "#3c3c3c" }
            GradientStop { position: 0.06; color: "#4c4c4c" }
            GradientStop { position: 1; color: "#191919" }
        }

        anchors { top: parent.top; left: parent.left; right: parent.right }

        Text {
            id: titleText
            anchors { verticalCenter: parent.verticalCenter; left: parent.left; leftMargin: platformStyle.paddingSmall  }
            text: "Discreet popups"
            color: "white"
            font.pixelSize: 20
        }
        ToolButton {
            iconSource: "toolbar-list"
            anchors { verticalCenter: parent.verticalCenter; right: parent.right; rightMargin: platformStyle.paddingSmall }
            onClicked: {
                selectionDialog.open()
            }
        }
    }
    Flickable {
        id: prefletView
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom; top: prefletSwitcher.bottom }
        contentHeight: preflet.item.height
        contentWidth: width
        flickableDirection: Flickable.VerticalFlick
        clip: true
        Loader {
            id: preflet
            source: "qrc:/Preflets/Popups"
            anchors.fill: parent
        }
    }

    // Code for destroying the page after pop
    onStatusChanged: if (status === PageStatus.Inactive) destroy()

    Component.onCompleted: statusBarText.text = "Preferences"
}
