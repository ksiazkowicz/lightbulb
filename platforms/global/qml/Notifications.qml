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
import lightbulb 1.0

Item {
    id: notify
    Connections {
        target: xmppConnectivity
        onNotifyMsgReceived: {
            // show discreet popup if enabled
            if (settings.gBool("notifications", "usePopupRecv") && (xmppConnectivity.chatJid !== jid || !vars.isActive)) {
                if (settings.gBool("behavior","msgInDiscrPopup"))
                        avkon.showPopup(name,body)
                else
                    avkon.showPopup(vars.globalUnreadCount+1 + " unread messages", "New message from "+ name + ".")
            }

            // get the blinker running if enabled and app is inactive
            if (!vars.isActive && settings.gBool("behavior", "wibblyWobblyTimeyWimeyStuff")) blink.running = true;

            // play sound and vibration
            notify.notifySndVibr("MsgRecv")

            // update chats icon and widget if required
            notify.updateNotifiers()
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
        onXmppSubscriptionReceived: {
            console.log( "XmppConnectivity::onXmppSubscriptionReceived(" + accountId + "," + bareJid + ")" )
            if (settings.gBool("notifications","notifySubscription") == true)
                avkon.showPopup("Subscription request",bareJid)

            notify.notifySndVibr("MsgSub")
        }
        onXmppConnectingChanged: {
            if (settings.gBool("notifications", "notifyConnection")) {
                switch (xmppConnectivity.useClient(accountId).getStateConnect()) {
                    case 0:
                        avkon.showPopup(xmppConnectivity.getAccountName(accountId),"Disconnected. :c");
                        break;
                    case 2:
                        notify.notifySndVibr("NotifyConn")
                        avkon.showPopup(xmppConnectivity.getAccountName(accountId),"Status changed to " + notify.getStatusNameByIndex(xmppConnectivity.getStatusByIndex(accountId)));
                        break;
                    case 1:
                        avkon.showPopup(xmppConnectivity.getAccountName(accountId),"Connecting...");
                        break;
                }
            }
        }
    }

    Connections {
        target: vars
        onGlobalUnreadCountChanged: {
            notify.updateNotifiers()
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

    HapticsEffect { id: hapticsEffect } //@QtQuick1

    function notifySndVibr(how) {
        if( settings.gBool("notifications","vibra"+how && !avkon.isInSilentMode())) {
            hapticsEffect.duration = settings.gInt("notifications","vibra"+how+"Duration" )
            hapticsEffect.intensity = settings.gInt("notifications","vibra"+how+"Intensity" )/100
            hapticsEffect.running = true
        }
        if( settings.gBool("notifications","sound"+how ))
            avkon.playNotification(settings.gStr("notifications","sound"+how+"File" ));
    }
}
