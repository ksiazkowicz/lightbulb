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
       if( (xmppClient.status == XmppClient.Online) || (xmppClient.status == XmppClient.Chat) ) statusName = qsTr("Online")
       else if( (xmppClient.status == XmppClient.Away) || (xmppClient.status == XmppClient.XA) ) statusName = qsTr("Away")
       else if(  xmppClient.status == XmppClient.DND ) statusName = qsTr("Do Not Disturb")
       else if(  xmppClient.status == XmppClient.Offline ) statusName = qsTr("Offline")
       return statusName;
    }

    function updateNotifiers() {
        if (vars.globalUnreadCount > 0) avkon.showChatIcon(); else avkon.hideChatIcon();
        if (settings.gBool("behavior","enableHsWidget")) postWidget();
    }

    function postWidget() {
        var row1; var presence1 = -2;
        var row2; var presence2 = -2;
        var row3; var presence3 = -2;
        var row4; var presence4 = -2;

        var chatsCount = xmppClient.getLatestChatsCount()

        if (chatsCount>0) {
            row1 = xmppClient.getNameByIndex(chatsCount);
            presence1 = getPresenceId(xmppClient.getPresenceByIndex(chatsCount));
            if (chatsCount>1) {
                row2 = xmppClient.getNameByIndex(chatsCount-1);
                presence2 = getPresenceId(xmppClient.getPresenceByIndex(chatsCount-1));
                if (chatsCount>2) {
                    row3 = xmppClient.getNameByIndex(chatsCount-2);
                    presence3 = getPresenceId(xmppClient.getPresenceByIndex(chatsCount-2));
                    if (chatsCount>3) {
                        row4 = xmppClient.getNameByIndex(chatsCount-3);
                        presence4 = getPresenceId(xmppClient.getPresenceByIndex(chatsCount-3));
                    }
                }
            }
        }

        hsWidget.postWidget(row1,presence1,row2,presence2,row3,presence3,row4,presence4,vars.globalUnreadCount,xmppClient.status);
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

    HSWidget { id: hsWidget }

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
