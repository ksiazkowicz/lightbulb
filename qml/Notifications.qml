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

        if (settings.gBool("behavior","enableHsWidget")) {
            hsWidget.postWidget(vars.globalUnreadCount + qsTr(" ~ unread messages"), getStatusName() + qsTr(" ~ status"), " ~ " + Qt.formatDateTime(new Date(), "dd.MM.yyyy ~ hh:mm") + " ~ ")
            if (vars.globalUnreadCount>0) hsWidget.updateWidget("C:\\data\\.config\\Lightbulb\\LightbulbA.png")
            else hsWidget.updateWidget("C:\\data\\.config\\Lightbulb\\Lightbulb.png")
        }
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
        if (settings.gBool("behavior","enableHsWidget")) hsWidget.registerWidget()
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
