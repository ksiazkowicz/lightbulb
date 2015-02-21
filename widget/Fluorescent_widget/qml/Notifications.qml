/********************************************************************

qml/Notifications.qml
-- Handles notifications

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
import lightbulb 1.0

Item {
    Component.onCompleted: if (settings.gBool("widget","enableHsWidget")) hsWidget.registerWidget()

    function updateNotifiers() {
        updateWidget();
    }

    function cleanWidget() {
        hsWidget.changeRow(0,"",-2,"",0,false)
        hsWidget.changeRow(1,"",-2,"",0,false)
        hsWidget.changeRow(2,"",-2,"",0,false)
        hsWidget.changeRow(3,"",-2,"",0,false)
        hsWidget.unreadCount = 0
        hsWidget.pushWidget()
    }

    function updateWidget() {
        if (settings.gBool("widget","enableHsWidget")) {
            hsWidget.unreadCount = reader.unreadCount
            switch (settings.gInt("widget","data")) {
                case 0: hsWidget.getData("chat"); break;
                case 1: hsWidget.getData("fav"); break;
                case 2: hsWidget.getData("lastSChange"); break;
            }
            hsWidget.pushWidget();
        }
    }

    DataReader {
        id: reader

        onUnreadCountChanged: updateNotifiers()
    }

    HSWidget {
        id: hsWidget
        property int unreadCount: 0

        Component.onCompleted: {
            var skinName = settings.gStr("widget","skin")
            if (skinName === "false") skinName = "C:\\data\\.config\\Lightbulb\\widgets\\Belle Albus";
            loadSkin(skinName);
            if (settings.gBool("widget","enableHsWidget")) cleanWidget()
        }

        onHomescreenUpdated: updateNotifiers()

        function pushWidget() { postWidget(unreadCount,settings.gBool("widget","showGlobalUnreadCnt"),settings.gBool("widget","showUnreadCntChat")); }

        function getData(type) {
            var name,presence,unreadCount,accountId;
            for (var i=1; i<=4;i++) {
                name = reader.getName(i,type)
                presence = reader.getStatus(i,type)
                unreadCount = reader.getUnreadCount(i,type)
                accountId = "test"
                hsWidget.changeRow(i,name,presence,accountId,unreadCount,false)
            }
            hsWidget.renderWidget()
        }

        function getPresenceId(presence) {
            if (presence == "qrc:/presence/online") return 0;
            else if (presence == "qrc:/presence/chatty") return 1;
            else if (presence == "qrc:/presence/away") return 2;
            else if (presence == "qrc:/presence/busy") return 3;
            else if (presence == "qrc:/presence/xa") return 4;
            else if (presence == "qrc:/presence/offline") return 5;
            else return -2;
        }
    }

    function updateSkin() {
        var skinName = settings.gStr("widget","skin")
        if (skinName === "false") skinName = "C:\\data\\.config\\Lightbulb\\widgets\\Belle Albus";
        hsWidget.loadSkin(skinName);
        hsWidget.renderWidget();
    }

    function postInfo(messageString) { avkon.displayGlobalNote(messageString,false) }
    function postError(messageString) { avkon.displayGlobalNote(messageString,true) }

    function registerWidget() {
        if (settings.gBool("widget","enableHsWidget")) {
            hsWidget.registerWidget()
            hsWidget.publishWidget()
        }
    }

    function removeWidget() { hsWidget.removeWidget() }
}
