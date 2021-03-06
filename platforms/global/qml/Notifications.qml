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
import QtMobility.feedback 1.1 //@QtQuick1
//import QtFeedback 5.0 //@QtQuick2
import lightbulb 1.0

Item {
    id: notify
    Connections {
        target: xmppConnectivity
        onNotifyMsgReceived: {
            // get the blinker running if enabled and app is inactive
            if (!vars.isActive && settings.gBool("behavior", "wibblyWobblyTimeyWimeyStuff")) blink.running = true;

            // update chats icon and widget if required
            notify.updateNotifiers()
        }
        onPushedSystemNotification: {
            console.log("XmppConnectivity::onPushedSystemNotification("+type+")")

            // play sound and vibration
            notify.notifySndVibr(type)

            // show popup if enabled
            if (settings.gBool("notifications","popup"+type) && title != "" && description != "") {
                if (type == "MsgRecv" && !settings.gBool("behavior","msgInDiscrPopup")) {
                    avkon.showPopup(vars.globalUnreadCount+1 + " unread messages", "New message from "+ title + ".")
                } else avkon.showPopup(title,description);
            }

        }

        onXmppTypingChanged: {
            console.log( "XmppConnectivity::onXmppTypingChanged(" + accountId + "," + bareJid + "," + isTyping + ")" )
            if (settings.gBool("notifications", "notifyTyping") == true) {
                if (isTyping)
                    avkon.showPopup(xmppConnectivity.getPropertyByJid(accountId,"name",bareJid),"is typing a message...")
                else
                    avkon.showPopup(xmppConnectivity.getPropertyByJid(accountId,"name",bareJid),"stopped typing.")
            }
        }
        onXmppStatusChanged: notify.updateNotifiers()
    }

    Connections {
        target: vars
        onGlobalUnreadCountChanged: {
            notify.updateNotifiers()
        }
        onIsActiveChanged: {
            if (vars.isActive && repeatHapticsEffect.running) {
                repeatHapticsEffect.stop()
                hapticsEffect.running = false;
            }

            if (vars.isActive) avkon.stopNotification()
        }
    }

    function getStatusNameByIndex(status) {
       if (status == 1) return "online"
       else if (status == 2) return "chatty"
       else if (status == 3) return "away"
       else if (status == 4) return "xa"
       else if (status == 5) return "busy"
       else if (status == 0) return "offline"
    }

    function updateNotifiers() {
        if (vars.globalUnreadCount > 0 && !settings.gBool("behavior","disableChatIcon"))
            avkon.showChatIcon();
        else avkon.hideChatIcon();
    }

    function postInfo(messageString) { avkon.displayGlobalNote(messageString,false) }
    function postError(messageString) { avkon.displayGlobalNote(messageString,true) }

    HapticsEffect {
        id: hapticsEffect;
        attackTime: 250;
        fadeTime: 250;
        attackIntensity: 0;
        fadeIntensity: 0
    }

    Timer {
        id: repeatHapticsEffect;
        repeat: true;
        property int amount: 3; // will repeat haptics effect three times, means it plays 4 times
        property int at: 0;
        running: false;
        interval: hapticsEffect.duration + hapticsEffect.attackTime;

        onTriggered: {
            // if the effect was already played required number of times, stop it
            if (at == amount || !avkon.isDeviceLocked()) { running = false; at = 0; } else {
                // repeat the effect
                at++; hapticsEffect.running = true;
            }
        }
    }

    function notifySndVibr(how) {
        console.log("notifySndVibra called for "+how);

        if (avkon.isInSilentMode()) {
            console.log("Silent mode is active, aborting")
            return;
        }

        if (settings.gBool("notifications","vibra"+how)) {
            hapticsEffect.duration = settings.gInt("notifications","vibra"+how+"Duration")*(vars.isActive || !avkon.isDeviceLocked() ? 0.5 : 1)
            hapticsEffect.intensity = settings.gInt("notifications","vibra"+how+"Intensity")
            hapticsEffect.running = true

            if (!vars.isActive && avkon.isDeviceLocked())
                repeatHapticsEffect.start()
        }
        if (settings.gBool("notifications","sound"+how ))
            avkon.playNotification(settings.gStr("notifications","sound"+how+"File" ));
    }
}
