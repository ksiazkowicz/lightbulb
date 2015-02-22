/********************************************************************

qml/Pages/xmlConsole.qml
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
import "../Components"

Page {
    id: xmlConsole
    property string pageName: "XML Console"
    property string accountId: ""

    tools: ToolBarLayout {
        ToolButton {
            iconSource: main.platformInverted ? "toolbar-back_inverse" : "toolbar-back"
            onClicked: pageStack.pop()
        }
        ToolButton {
            text: "Export"
            enabled: false
        }
    }

    // Code for destroying the page after pop
    onStatusChanged: if (xmlConsole.status === PageStatus.Inactive) xmlConsole.destroy()

    Rectangle {
        id: accountSwitcher

        height: 46
        z: 1
        color: "transparent"

        BorderImage {
            anchors.fill: parent
            source: privateStyle.imagePath("qtg_fr_tab_bar", main.platformInverted)
            border { left: 20; top: 20; right: 20; bottom: 20 }
        }

        anchors { top: parent.top; left: parent.left; right: parent.right }

        Label {
            id: titleText

            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                leftMargin: platformStyle.paddingMedium
            }

            platformInverted: main.platformInverted
            text: "Account not selected"
        }

        HeaderButton {
            id: accountsButton
            iconSource: "toolbar-list"
            width: height
            platformInverted: main.platformInverted

            anchors {
                right: parent.right
                top: parent.top
                bottom: parent.bottom
                topMargin: 2
            }

            onClicked: {
                dialog.c=Qt.createComponent("qrc:/dialogs/AccountSwitcher")
                dialog.c.createObject(main)
                vars.context = ""
                vars.awaitingContext = true;
                vars.dialogQmlFile = "";
            }
        }

        Connections {
            target: vars
            onAwaitingContextChanged: {
                if (!vars.awaitingContext && vars.context != "") {
                    accountId = vars.context
                    titleText.text = xmppConnectivity.getAccountName(accountId)
                    data.model = xmppConnectivity.useClient(accountId).xmlLog
                }
            }
        }
    }

    ListView {
        id: data
        anchors {
            top: accountSwitcher.bottom
            bottom: parent.bottom
            right: parent.right
            left: parent.left;
            leftMargin: platformStyle.paddingSmall; rightMargin: platformStyle.paddingSmall
        }
        delegate: Component {
            Rectangle {
                id: logItem
                height: logText.paintedHeight + platformStyle.paddingSmall*2
                width: parent.width
                color: "transparent"

                Text {
                    id: logText
                    text: replaceTags(modelData)
                    font.pixelSize: platformStyle.fontSizeMedium
                    anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; }
                    wrapMode: Text.Wrap
                    color: main.textColor
                }

                function replaceTags(text) {
                    text = text.replace(/</g,"&lt;");
                    text = text.replace(/>/g,"&gt;<br/>");

                    console.log(text)

                    text = text.replace("[INFO]","<font color='"+main.midColor+"'><i>info</i></font><br/>");
                    text = text.replace("[WARN]","<font color='#efb813'><i>warning</i></font><br/>");
                    text = text.replace("[DEBUG]","<font color='#ff3333'><i>debug</i></font><br/>");

                    text = text.replace("[RECV]","<font color='#9999FF'><i>sent</i></font><br/>");
                    text = text.replace("[SENT]","<font color='#00FF00'><i>received</i></font><br/>");

                    return text;
                }

                LineItem { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } }
            }
        } //Component
    }

    ScrollBar {
        anchors {
            top: accountSwitcher.bottom
            bottom: parent.bottom
            right: parent.right
            margins: platformStyle.paddingSmall - 2
        }

        flickableItem: data
        orientation: Qt.Vertical
        platformInverted: main.platformInverted
    }
}

