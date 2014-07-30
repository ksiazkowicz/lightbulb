/********************************************************************

qml/Globals.qml
-- Contains global values available in the entire app.

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

Item {
    property string textColor:       main.platformInverted ? platformStyle.colorNormalDark : platformStyle.colorNormalLight
    property int                     globalUnreadCount: 0
    property int                     tempUnreadCount: 0
    property string                  lastStatus: settings.gBool("behavior", "lastStatusText") ? settings.gStr("behavior","lastStatusText") : ""
    signal                           statusChanged
    property int                     lastUsedStatus: 0
    signal                           statusTextChanged
    property bool                    isActive: true
    property bool                    isChatInProgress: false
    property int                     blinkerSet: 0
    property string                  resourceJid: ""
    property bool                    areEmoticonsDisabled: settings.gBool("behavior","disableEmoticons")

    property bool                    isRestartRequired: false
    property bool                    isBlinkingOverrideEnabled: false

    // roster
    property bool                    hideOffline: settings.gBool("ui","hideOffline")
    property bool                    markUnread: settings.gBool("ui","markUnread")
    property bool                    showUnreadCount: settings.gBool("ui","showUnreadCount")
    property int                     rosterItemHeight: settings.gInt("ui","rosterItemHeight")
    property bool                    showContactStatusText: settings.gBool("ui","showContactStatusText")
    property bool                    rosterLayoutAvatar: settings.gBool("ui","rosterLayoutAvatar")
    property string                  selectedJid: ""
    property bool                    awaitingContext: false
    property string                  dialogQmlFile: ""
}
