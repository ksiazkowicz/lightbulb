/********************************************************************

qml/Notifications.qml
-- Handles notifications. Should be redone with C++ in XmppConnectivity
-- class

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
import QtMultimediaKit 1.1
import QtMobility.feedback 1.1
import lightbulb 1.0

Item {
    Component.onCompleted: if (settings.gBool("behavior","enableHsWidget")) hsWidget.registerWidget()

    function getStatusName() {
       var statusName;
       if (xmppConnectivity.client.status == XmppClient.Online) statusName = qsTr("online")
       else if (xmppConnectivity.client.status == XmppClient.Chat) statusName = qsTr("chatty")
       else if (xmppConnectivity.client.status == XmppClient.Away) statusName = qsTr("away")
       else if (xmppConnectivity.client.status == XmppClient.XA) statusName = qsTr("xa")
       else if (xmppConnectivity.client.status == XmppClient.DND) statusName = qsTr("busy")
       else if (xmppConnectivity.client.status == XmppClient.Offline) statusName = qsTr("offline")
       return statusName;
    }

    function updateNotifiers() {
        if (vars.globalUnreadCount > 0) avkon.showChatIcon(); else avkon.hideChatIcon();
        if (settings.gBool("behavior","enableHsWidget")) {
            hsWidget.status = xmppConnectivity.client.status
            hsWidget.unreadCount = vars.globalUnreadCount
            hsWidget.getLatest4Chats()
            hsWidget.getFirst4Contacts()
            hsWidget.pushWidget()
        }
    }

    function cleanWidget() {
        hsWidget.row1 = " "
        hsWidget.row2 = " "
        hsWidget.row3 = " "
        hsWidget.row4 = " "
        hsWidget.r1presence = -2
        hsWidget.r2presence = -2
        hsWidget.r3presence = -2
        hsWidget.r4presence = -2
        hsWidget.unreadCount = 0
        hsWidget.status = 0
        hsWidget.postWidget(" ",-2," ",-2," ",-2," ",-2,0,0);
    }

    HSWidget {
        id: hsWidget
        property string row1: " "
        property string row2: " "
        property string row3: " "
        property string row4: " "
        property int r1presence: -2
        property int r2presence: -2
        property int r3presence: -2
        property int r4presence: -2
        property int unreadCount: 0
        property int status: 0

        Component.onCompleted: {
            var skinName = settings.gStr("ui","widgetSkin")
            if (skinName === "false") skinName = "C:\\data\\.config\\Lightbulb\\widgets\\Belle Albus";
            loadSkin(skinName);
        }

        function pushWidget() { postWidget(row1,r1presence,row2,r2presence,row3,r3presence,row4,r4presence,unreadCount,status); }

        function getLatest4Chats() {
            var chatsCount = xmppConnectivity.client.getLatestChatsCount()
            row1 = xmppConnectivity.client.getNameByIndex(chatsCount);
            r1presence = getPresenceId(xmppConnectivity.client.getPresenceByIndex(chatsCount));
            row2 = xmppConnectivity.client.getNameByIndex(chatsCount-1);
            r2presence = getPresenceId(xmppConnectivity.client.getPresenceByIndex(chatsCount-1));
            row3 = xmppConnectivity.client.getNameByIndex(chatsCount-2);
            r3presence = getPresenceId(xmppConnectivity.client.getPresenceByIndex(chatsCount-2));
            row4 = xmppConnectivity.client.getNameByIndex(chatsCount-3);
            r4presence = getPresenceId(xmppConnectivity.client.getPresenceByIndex(chatsCount-3));
        }
        function getFirst4Contacts() {
            row1 = xmppConnectivity.client.getNameByOrderID(0);
            r1presence = getPresenceId(xmppConnectivity.client.getPresenceByOrderID(0));
            row2 = xmppConnectivity.client.getNameByOrderID(1);
            r2presence = getPresenceId(xmppConnectivity.client.getPresenceByOrderID(1));
            row3 = xmppConnectivity.client.getNameByOrderID(2);
            r3presence = getPresenceId(xmppConnectivity.client.getPresenceByOrderID(2));
            row4 = xmppConnectivity.client.getNameByOrderID(3);
            r4presence = getPresenceId(xmppConnectivity.client.getPresenceByOrderID(3));
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
        var skinName = settings.gStr("ui","widgetSkin")
        if (skinName === "false") skinName = "C:\\data\\.config\\Lightbulb\\widgets\\Belle Albus";
        hsWidget.loadSkin(skinName);
        hsWidget.renderWidget();
    }

    function postInfo(messageString) {
        avkon.displayGlobalNote(messageString,false)
    }

    function postError(messageString) {
        avkon.displayGlobalNote(messageString,true)
    }

    function notifyMessageSent() {
        if( vibraMsgSent ) hapticsEffectSentMsg.running = true
        if( soundMsgSent ) sndEffectSent.play()
    }

    function registerWidget() {
        if (settings.gBool("behavior","enableHsWidget")) {
            hsWidget.registerWidget()
            hsWidget.publishWidget()
        }
    }

    function removeWidget() {
        if (settings.gBool("behavior","enableHsWidget")) hsWidget.removeWidget()
    }

    SoundEffect { id: sndEffect }
    HapticsEffect { id: hapticsEffect }

    function notifySndVibr(how) {
        if( settings.gBool("notifications","vibra"+how )) {
            hapticsEffect.duration = settings.gInt("notifications","vibra"+how+"Duration" )
            hapticsEffect.intensity = settings.gInt("notifications","vibra"+how+"Intensity" )/100
            hapticsEffect.running = true
        }
        if( settings.gBool("notifications","sound"+how )) {
            sndEffect.source = settings.gStr("notifications","sound"+how+"File" )
            sndEffect.volume = settings.gInt("notifications","sound"+how+"Volume" )/100
            sndEffect.play()
        }
    }
}
