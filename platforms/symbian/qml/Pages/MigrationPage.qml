/********************************************************************

qml/Pages/MigrationPage.qml
-- migration page in Lightbulb

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

Page {
    id: migraPage

    property string settingsVersion: migration.getData("main","last_used_rel")
    property string pageName: "Migration"

    tools: ToolBarLayout {
        id: toolBarLayout
        ToolButton {
            iconSource: main.platformInverted ? "qrc:/toolbar/close_inverse" : "qrc:/toolbar/close"
            onClicked: Qt.quit()
        }

        ToolButton {
            iconSource: main.platformInverted ? "toolbar-next_inverse" : "toolbar-next"
            onClicked: migrate()
        }

    }

    // Code for destroying the page after pop
    onStatusChanged: if (migraPage.status === PageStatus.Inactive) migraPage.destroy()

    function migrate() {
        if (accCheckBox.checked) {
            var verCheck = settingsVersion.substring(0,3);
            var list = migration.getListOfAccounts();

            for (var i=0;i<list.length;i++) {
                var temp;
                settings.addAccount(list[i])

                temp = migration.getData(list[i],"connectOnStart");

                if (temp == "false")
                    settings.sBool(false,list[i],"connectOnStart")
                else
                    settings.sBool(true,list[i],"connectOnStart")

                settings.sStr(migration.getData(list[i],"host"),list[i],"host")

                temp = migration.getData(list[i],"icon");
                if (temp !== "false")
                    settings.sStr(temp,list[i],"icon")

                temp = migration.getData(list[i],"name");
                if (temp !== "false")
                    settings.sStr(temp,list[i],"name")


                settings.sStr(migration.getData(list[i],"passwd"),list[i],"passwd")

                temp = migration.getData(list[i],"resource");
                if (temp !== "false")
                    settings.sStr(temp,list[i],"resource");

                if (verCheck == "0.2" || verCheck == "0.1" || verCheck == "0.0")
                    settings.sStr(list[i],list[i],"jid")
                else
                    settings.sStr(migration.getData(list[i],"jid"),list[i],"jid")

                settings.sBool(migration.getData(list[i],"use_host_port"),list[i],"use_host_port")
            }
        }
        if (widgetCheckBox.checked) {
            settings.sBool(migration.getData("widget","enableHsWidget"),"widget","enableHsWidget")
            settings.sBool(migration.getData("widget","showGlobalUnreadCnt"),"widget","showGlobalUnreadCnt")
            settings.sBool(migration.getData("widget","showUnreadCntChat"),"widget","showUnreadCntChat")
            settings.sBool(migration.getData("widget","showStatus"),"widget","showStatus")
            settings.sInt(migration.getData("widget","data"),"widget","data")
            settings.sStr(migration.getData("widget","skin"),"widget","skin")
        }
        if (uiCheckBox.checked) {
            settings.sBool(migration.getData("ui","hideOffline"),"ui","hideOffline")
            settings.sBool(migration.getData("ui","invertPlatform"),"ui","invertPlatform")
            settings.sBool(migration.getData("ui","markUnread"),"ui","markUnread")
            settings.sBool(migration.getData("ui","showContactStatusText"),"ui","showContactStatusText")
            settings.sBool(migration.getData("ui","showUnreadCount"),"ui","showUnreadCount")
            settings.sInt(migration.getData("ui","rosterItemHeight"),"ui","rosterItemHeight")
        }
        if (eventsCheckBox.checked) {
            settings.sInt(migration.getData("notifications","blinkScreenDevice"),"notifications","blinkScreenDevice")

            settings.sBool(migration.getData("notifications","notifyConnection"),"notifications","notifyConnection")
            settings.sBool(migration.getData("notifications","notifySubscription"),"notifications","notifySubscription")
            settings.sBool(migration.getData("notifications","notifyTyping"),"notifications","notifyTyping")

            settings.sBool(migration.getData("notifications","usePopupRecv"),"notifications","usePopupRecv")
            settings.sBool(migration.getData("notifications","soundMsgRecv"),"notifications","soundMsgRecv")
            settings.sStr(migration.getData("notifications","soundMsgRecvFile"),"notifications","soundMsgRecvFile")
            settings.sBool(migration.getData("notifications","vibraMsgRecv"),"notifications","vibraMsgRecv")
            settings.sInt(migration.getData("notifications","vibraMsgRecvDuration"),"notifications","vibraMsgRecvDuration")
            settings.sInt(migration.getData("notifications","vibraMsgRecvIntensity"),"notifications","vibraMsgRecvIntensity")

            settings.sBool(migration.getData("notifications","soundMsgSent"),"notifications","soundMsgSent")
            settings.sStr(migration.getData("notifications","soundMsgSentFile"),"notifications","soundMsgSentFile")
            settings.sBool(migration.getData("notifications","vibraMsgSent"),"notifications","vibraMsgSent")
            settings.sInt(migration.getData("notifications","vibraMsgSentDuration"),"notifications","vibraMsgSentDuration")
            settings.sInt(migration.getData("notifications","vibraMsgSentIntensity"),"notifications","vibraMsgSentIntensity")

            settings.sBool(migration.getData("notifications","vibraMsgSub"),"notifications","vibraMsgSub")
            settings.sInt(migration.getData("notifications","vibraMsgSubDuration"),"notifications","vibraMsgSubDuration")
            settings.sInt(migration.getData("notifications","vibraMsgSubIntensity"),"notifications","vibraMsgSubIntensity")

            settings.sBool(migration.getData("notifications","soundMsgSub"),"notifications","soundMsgSub")
            settings.sStr(migration.getData("notifications","soundMsgSubFile"),"notifications","soundMsgSubFile")
        }
        if (advCheckBox.checked) {
            settings.sBool(migration.getData("behavior","wibblyWobblyTimeyWimeyStuff"),"behavior","wibblyWobblyTimeyWimeyStuff")
            settings.sBool(migration.getData("behavior","disableEmoticons"),"behavior","disableEmoticons")
            settings.sBool(migration.getData("behavior","disableChatIcon"),"behavior","disableChatIcon")
            settings.sInt(migration.getData("behavior","visibleMessagesLimit"),"behavior","visibleMessagesLimit")
        }
        if (cacheCheckBox.checked) {
            settings.sStr("C:\\Data\\.config\\Lightbulb\\cache","paths","cache")
        } else {
            xmppConnectivity.cleanCache("C:\\Data\\.config\\Lightbulb\\cache")
        }

        if (behaviorCheckBox.checked) {
            settings.sInt(migration.getData("behavior","keepAliveInterval"),"behavior","keepAliveInterval")
            settings.sBool(migration.getData("behavior","msgInDiscrPopup"),"behavior","msgInDiscrPopup")
            settings.sBool(migration.getData("behavior","linkInDiscrPopup"),"behavior","linkInDiscrPopup")
            settings.sBool(migration.getData("behavior","reconnectOnError"),"behavior","reconnectOnError")
            settings.sBool(migration.getData("behavior","storeLastStatus"),"behavior","storeLastStatus")
            settings.sStr(migration.getData("behavior","lastAccount"),"behavior","lastAccount")
            settings.sStr(migration.getData("behavior","lastStatusText"),"behavior","lastStatusText")
        }

        settings.sStr("0.3.1","main","last_used_rel")
        settings.sBool(true,"main","not_first_run")

        avkon.restartAppMigra();
    }

    Flickable {
        id: migra
        flickableDirection: Flickable.VerticalFlick
        anchors.fill: parent
        contentHeight: content.height

        Column {
            id: content
            spacing: 5

            Text {
                color: main.textColor
                anchors { left: parent.left; right: parent.right; leftMargin: 10; rightMargin: 10 }
                font.pixelSize: 32
                text: "Welcome back!"
                height: 64
                verticalAlignment: Text.AlignVCenter
            }

            Text {
                id: text
                color: main.textColor
                anchors { left: parent.left; right: parent.right; leftMargin: 10; rightMargin: 10 }
                wrapMode: Text.WordWrap

                font.pixelSize: 20
                text: "Apparently you've been using Lightbulb " + settingsVersion + " before. You can choose the data you want to import.\n\nTap on \"Next\" whenever you're ready to begin, or just tap on \"Close\" to close the wizard. :)"
            }

            CheckBox {
                id: accCheckBox
                platformInverted: main.platformInverted
                text: qsTr("Accounts")
            }
            CheckBox {
                id: uiCheckBox
                platformInverted: main.platformInverted
                text: qsTr("User interface settings")
            }
            CheckBox {
                id: eventsCheckBox
                platformInverted: main.platformInverted
                text: qsTr("Notification settings")
            }
            CheckBox {
                id: advCheckBox
                platformInverted: main.platformInverted
                text: qsTr("Advanced settings")
            }
            CheckBox {
                id: cacheCheckBox
                platformInverted: main.platformInverted
                text: qsTr("Use old avatar cache directory")
            }
            CheckBox {
                id: behaviorCheckBox
                platformInverted: main.platformInverted
                text: qsTr("Behavior")
            }
            CheckBox {
                id: widgetCheckBox
                platformInverted: main.platformInverted
                text: qsTr("Widget settings")
            }
        }

    }

    ScrollBar {
        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
            margins: platformStyle.paddingSmall - 2
        }

        flickableItem: migra
        orientation: Qt.Vertical
        platformInverted: main.platformInverted
    }
}


