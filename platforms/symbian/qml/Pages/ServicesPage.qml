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
import "../Components"

Page {
    id: aboutPage
    property string pageName: bareJid
    property string accountId: ""
    property string bareJid: ""
    tools: ToolBarLayout {
        ToolButton {
            iconSource: main.platformInverted ? "toolbar-back_inverse" : "toolbar-back"
            onClicked: pageStack.pop()
        }
    }

    ListView {
        id: services
        model: xmppConnectivity.useClient(accountId).serviceModel(bareJid);
        anchors.fill: parent
        delegate: Item {
            height: column.height + 2* platformStyle.paddingSmall
            width: services.width

            MouseArea {
                anchors.fill: parent;
                onClicked: {
                    var monkeylol = /@/;
                    if (features == "conference" && monkeylol.test(jid)) {
                        dialog.createWithProperties("qrc:/dialogs/MUC/Join",{"accountId":accountId,"mucJid":jid});
                    } else {
                        xmppConnectivity.useClient(accountId).askServer(jid)
                        main.pageStack.push("qrc:/pages/Services",{"accountId": accountId,"bareJid":jid})
                    }
                }
            }

            Column {
                id: column
                anchors { left: parent.left; leftMargin: platformStyle.paddingLarge; right: parent.right; rightMargin: platformStyle.paddingLarge; verticalCenter: parent.verticalCenter }
                Label { text: name !== "" ? name : jid; font.bold: true; wrapMode: Text.Wrap; width: parent.width - 2*platformStyle.paddingLarge; clip: true }
                Label { text: features; opacity: 0.5 }
                Label { text: type; opacity: 0.5 }
            }
            LineItem { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } }
        }
    }

    Label {
        anchors.centerIn: parent
        text: "Nothing to display"
        font.bold: true
        visible: services.count == 0
    }

    ScrollBar {
        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
            margins: platformStyle.paddingSmall - 2
        }

        flickableItem: services
        orientation: Qt.Vertical
        platformInverted: main.platformInverted
    }
}
