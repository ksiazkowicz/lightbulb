/********************************************************************

qml/Pages/FirstRunPage.qml
-- new first run page

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
import com.nokia.symbian 1.1
import com.nokia.extras 1.1

Page {
    id: preferencesPage
    property int selectedIndex: 0
    tools: ToolBarLayout {
        id: toolBarLayout
        ToolButton {
            iconSource: selectedIndex == 0 ? (main.platformInverted ? "qrc:/toolbar/close_inverse" : "qrc:/toolbar/close") : (main.platformInverted ? "toolbar-back_inverse" : "toolbar-back")
            onClicked: {
                if (selectedIndex == 0) {
                    setDefaultSettings()
                    settings.sBool(true,"ui","markUnread")
                    settings.sBool(true,"ui","showUnreadCount")
                    settings.sInt(75,"ui","rosterItemHeight")
                    settings.sBool(true,"ui","showContactStatusText")
                    do {
                        pageStack.pop()
                    } while (pageStack.depth > 1)
                    pageStack.push("qrc:/pages/Roster")
                } else { selectedIndex--; switchPreflet(); }
            }
        }

        ToolButton {
            iconSource: selectedIndex == 6 ? (main.platformInverted ? "qrc:/toolbar/close_inverse" : "qrc:/toolbar/close") : main.platformInverted ? "toolbar-next_inverse" : "toolbar-next"
            onClicked: {
                if (selectedIndex == 6) {
                    setDefaultSettings()

                    settings.sBool(true,"notifications","notifyConnection")
                    settings.sBool(true,"notifications","notifySubscription")
                    settings.sBool(true,"notifications","notifyTyping")

                    settings.sBool(true,"behavior","reconnectOnError")
                    settings.sInt(60,"behavior","keepAliveInterval")

                    settings.sBool(true,"behavior","storeLastStatus")

                    do {
                        pageStack.pop()
                    } while (pageStack.depth > 1)
                    pageStack.push("qrc:/pages/Roster")
                } else {
                    selectedIndex++;
                    switchPreflet();
                }
            }
        }

    }

    function switchPreflet() {
        switch (selectedIndex) {
            case 0: {
                titleText.text = "Getting Started"
                preflet.source = "qrc:/FirstRun/01";
                break;
            }
            case 1: {
                settings.gBool("behavior","wibblyWobblyTimeyWimeyStuff")
                titleText.text = "Notification LED"
                preflet.source = "qrc:/Preflets/LED";
                break;
            }
            case 2: {
                /*titleText.text = "Account"
                preflet.source = "qrc:/FirstRun/03";*/
                selectedIndex++;
                switchPreflet();
                break;
            }
            case 3: {
                titleText.text = "Popups"
                preflet.source = "qrc:/Preflets/Popups";
                break;
            }
            case 4: {
                titleText.text = "Colors"
                preflet.source = "qrc:/Preflets/Colors";
                break;
            }
            case 5: {
                titleText.text = "Contact list";
                settings.sBool(true,"ui","markUnread");
                settings.sBool(true,"ui","showUnreadCount");
                settings.sInt(75,"ui","rosterItemHeight");
                settings.sBool(true,"ui","showContactStatusText");
                settings.sBool(true,"ui", "hideOffline");
                preflet.source = "qrc:/Preflets/Roster";
                break;
            }
            case 6: {
                titleText.text = "Congratulations"
                preflet.source = "qrc:/FirstRun/07";
                break;
            }
            default: break;
        }
        if (selectedIndex == 1) {
            blink.running = true;
            vars.isBlinkingOverrideEnabled = true;
        } else {
            vars.isBlinkingOverrideEnabled = false;
        }
    }

    function setDefaultSettings() {
        settings.sBool(true,"main","not_first_run")
        settings.sStr(xmppConnectivity.client.version,"main","last_used_rel")

        settings.sBool(true,"behavior","reconnectOnError")
        settings.sInt(60,"behavior","keepAliveInterval")

        settings.sInt(800,"notifications","vibraMsgRecvDuration")
        settings.sInt(100,"notifications","vibraMsgRecvIntensity")

        settings.sStr("file:///C:/Data/.config/Lightbulb/sounds/Message_Received.wav", "notifications","soundMsgRecvFile")

        settings.sInt(400,"notifications","vibraMsgSentDuration")
        settings.sInt(100,"notifications","vibraMsgSentIntensity")

        settings.sStr("file:///C:/Data/.config/Lightbulb/sounds/Message_Sent.wav", "notifications","soundMsgSentFile")

        settings.sInt(500,"notifications","vibraMsgSubDuration")
        settings.sInt(50,"notifications","vibraMsgSubIntensity")

        settings.sStr("file:///C:/Data/.config/Lightbulb/sounds/Subscription_Request.wav", "notifications","soundMsgSubFile")
    }

    Rectangle {
        id: prefletSwitcher
        height: 64
        z: 1
        color: 'transparent'
        anchors { top: parent.top; left: parent.left; right: parent.right }

        Text {
            id: titleText
            anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }
            text: "Getting Started"
            color: "white"
            font.pixelSize: platformStyle.fontSizeMedium*1.5
        }
    }
    Flickable {
        id: prefletView
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom; top: prefletSwitcher.bottom }
        contentHeight: preflet.item.height
        contentWidth: width
        flickableDirection: Flickable.VerticalFlick
        clip: true
        Loader {
            id: preflet
            source: "qrc:/FirstRun/01"
            anchors.fill: parent
        }
    }

    Component.onCompleted: statusBarText.text = qsTr("First Run")

}
