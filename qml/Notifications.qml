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
import QtMobility.feedback 1.1
import lightbulb 1.0

Item {
    Connections {
        target: xmppConnectivity
        onNotifyMsgReceived: {
            // handle global unread count. I should have both global and local unread count later
            if (!vars.isChatInProgress) {
                vars.globalUnreadCount++
                if (jid === xmppConnectivity.chatJid) vars.tempUnreadCount++
            } else if (jid !== xmppConnectivity.chatJid || !vars.isActive) vars.globalUnreadCount++

            // show discreet popup if enabled
            if (settings.gBool("notifications", "usePopupRecv") && (xmppConnectivity.chatJid !== jid || !vars.isActive)) {
                if (settings.gBool("behavior","msgInDiscrPopup"))
                        avkon.showPopup(name,body)
                else
                    avkon.showPopup(vars.globalUnreadCount + " unread messages", "New message from "+ name + ".")
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
            if (settings.gBool("notifications", "notifyTyping") == true &&
               (xmppConnectivity.chatJid !== bareJid || !vars.isActive) &&
               (currentAccount == accountId && client.myBareJid !== bareJid)) {
                if (isTyping)
                    avkon.showPopup(getPropertyByJid(accountId,"name",bareJid),"is typing a message...")
                else
                    avkon.showPopup(getPropertyByJid(accountId,"name",bareJid),"stopped typing.")
            }
        }
        onXmppStatusChanged: {
            console.log( "XmppClient::onStatusChanged (" + accountId + ")" + xmppConnectivity.getStatusByAccountId(accountId) )
            notify.updateNotifiers()
        }
        onXmppSubscriptionReceived: {
            console.log( "XmppConnectivity::onXmppSubscriptionReceived(" + accountId + "," + bareJid + ")" )
            if (settings.gBool("notifications","notifySubscription") == true)
                avkon.showPopup("Subscription request",bareJid)

            notify.notifySndVibr("MsgSub")
        }
        onXmppConnectingChanged: {
            if (settings.gBool("notifications", "notifyConnection")) {
                switch (xmppConnectivity.getConnectionStatusByAccountId(accountId)) {
                    case 0:
                        avkon.showPopup(xmppConnectivity.getAccountName(accountId),"Disconnected. :c");
                        break;
                    case 1:
                        notify.notifySndVibr("NotifyConn")
                        avkon.showPopup(xmppConnectivity.getAccountName(accountId),"Status changed to " + notify.getStatusNameByIndex(xmppConnectivity.client.status));
                        break;
                    case 2:
                        avkon.showPopup(xmppConnectivity.getAccountName(accountId),"Connecting...");
                        break;
                }
            }
        }
    }


    function getStatusNameByIndex(status) {
       if (status == XmppClient.Online) return "online"
       else if (status == XmppClient.Chat) return "chatty"
       else if (status == XmppClient.Away) return "away"
       else if (status == XmppClient.XA) return "xa"
       else if (status == XmppClient.DND) return "busy"
       else if (status == XmppClient.Offline) return "offline"
    }

    function updateNotifiers() {
        if (vars.globalUnreadCount > 0 && !settings.gBool("behavior","disableChatIcon"))
            avkon.showChatIcon();
        else avkon.hideChatIcon();
    }

    function postInfo(messageString) { avkon.displayGlobalNote(messageString,false) }
    function postError(messageString) { avkon.displayGlobalNote(messageString,true) }

    HapticsEffect { id: hapticsEffect }

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
