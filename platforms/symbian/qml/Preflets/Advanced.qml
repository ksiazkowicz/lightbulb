/********************************************************************

qml/Preflets/Advanced.qml
-- Preflet with advanced options

Copyright (c) 2013-2014 Maciej Janiszewski

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

import "../Components"

Item {
    height: column.height

    Column {
        id: column
        spacing: platformStyle.paddingSmall
        anchors.horizontalCenter: parent.horizontalCenter;
        width: parent.width - 2*platformStyle.paddingSmall

        CheckBox {
            id: disableChatIcon
            text: qsTr("Disable chat icon")
            checked: settings.gBool("behavior","disableChatIcon")
            platformInverted: main.platformInverted
            onCheckedChanged: {
                settings.sBool(checked,"behavior","disableChatIcon")
                if (checked) {
                    avkon.hideChatIcon();
                } else if (vars.globalUnreadCount > 0){
                    avkon.showChatIcon();
                }
            }
        }

        CheckBox {
            id: disableUpdateChecker
            text: qsTr("Disable update checker")
            checked: settings.gBool("behavior","disableUpdateChecker")
            platformInverted: main.platformInverted
            onCheckedChanged: settings.sBool(checked,"behavior","disableUpdateChecker")
        }

        CheckBox {
            id: disableEmoticons
            text: qsTr("Disable emoticons")
            checked: vars.areEmoticonsDisabled
            platformInverted: main.platformInverted
            onCheckedChanged: {
                settings.sBool(checked,"behavior","disableEmoticons")
                vars.areEmoticonsDisabled = checked
            }
        }

        CheckBox {
            id: disableAvatarCaching
            text: qsTr("Disable avatar caching")
            checked: settings.gBool("behavior","disableAvatarCaching")
            platformInverted: main.platformInverted
            onCheckedChanged: {
                settings.sBool(checked,"behavior","disableAvatarCaching")
                xmppConnectivity.updateAvatarCachingSetting(checked)
            }
        }

        CheckBox {
            id: useOnlyLegacyAvatarCaching
            text: qsTr("Use only legacy avatar caching")
            checked: settings.gBool("behavior","legacyAvatarCaching")
            platformInverted: main.platformInverted
            onCheckedChanged: {
                settings.sBool(checked,"behavior","legacyAvatarCaching")
                xmppConnectivity.updateLegacyAvatarCachingSetting(checked)
            }
        }

        CheckBox {
            id: hideFromTaskMgr
            text: qsTr("Hide app from task manager")
            checked: settings.gBool("behavior","hideFromTaskMgr")
            platformInverted: main.platformInverted
            onCheckedChanged: {
                settings.sBool(checked,"behavior","hideFromTaskMgr")
                avkon.setAppHiddenState(checked);
            }
        }

        SettingField {
            id: tiVisibleMsgLimit
            settingLabel: "Visible messages limit"
            width: column.width
            inputMethodHints: Qt.ImhFormattedNumbersOnly

            Component.onCompleted: value = settings.gInt("behavior", "visibleMessagesLimit")

            onValueChanged: {
                var limit = parseInt(value)
                xmppConnectivity.messagesLimit = limit
                settings.sInt(limit,"behavior", "visibleMessagesLimit")
            }
        }

        Button {
            id: rmvDbButton
            text: "Remove database"
            anchors { left: parent.left; right: parent.right }
            platformInverted: main.platformInverted
            onClicked: {
                if (xmppConnectivity.dbRemoveDb()) {
                    notify.postInfo("Database cleaned.")
                    if (!vars.isRestartRequired) vars.isRestartRequired = true;
                } else notify.postError("Unable to clean database.")
            }
        }

        Text {
            width: parent.width
            anchors { left: parent.left; right: parent.right }
            color: main.textColor
            text: "This option will remove all the archived messages."
            font.pixelSize: platformStyle.fontSizeSmall
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignJustify
        }

        Button {
            text: "Clean avatar cache"
            platformInverted: main.platformInverted
            anchors { left: parent.left; right: parent.right }
            onClicked: {
                if (xmppConnectivity.cleanCache()) {
                    notify.postInfo("Avatar cache cleaned.")
                    if (!vars.isRestartRequired) vars.isRestartRequired = true;
                } else notify.postError("Unable to clean avatar cache.")
            }
        }

        Text {
            width: parent.width
            color: main.textColor
            anchors { left: parent.left; right: parent.right }
            font.pixelSize: platformStyle.fontSizeSmall
            text: "Useful option if avatars are not displayed properly, or cache is filled with useless files."
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignJustify
        }

        Button {
            id: moveFolderSelectionDlg
            text: "Change cache directory"
            platformInverted: main.platformInverted
            anchors { left: parent.left; right: parent.right }
            onClicked: {
                var cacheFolder = avkon.openFolderSelectionDlg(settings.gStr("paths","cache"));

                settings.sStr(cacheFolder,"paths","cache")
                if (cacheFolder != "")
                    cacheDirText.text = "Currently used cache folder is " + settings.gStr("paths","cache")
                else
                    cacheDirText.text = "Not using custom cache folder.";
            }
        }

        Text {
            id: cacheDirText
            width: parent.width
            color: main.textColor
            anchors { left: parent.left; right: parent.right }
            font.pixelSize: platformStyle.fontSizeSmall
            text: settings.gStr("paths","cache") != "" ? "Currently used cache folder is " + settings.gStr("paths","cache") : "Not using custom cache folder."
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignJustify
        }

        Button {
            id: reSettingsBtn
            text: "Reset settings"
            anchors { left: parent.left; right: parent.right }
            platformInverted: main.platformInverted
            onClicked: {
                if (xmppConnectivity.resetSettings()) {
                    notify.postInfo("Settings resetted to default.")
                    if (!vars.isRestartRequired) vars.isRestartRequired = true;
                } else notify.postError("Unable to reset settings.")
            }
        }
        Text {
            id: reSettingsText
            width: parent.width
            color: main.textColor
            font.pixelSize: platformStyle.fontSizeSmall
            anchors { left: parent.left; right: parent.right }
            text: "Have you updated your app and something went wrong? Want to remove your accounts details? Do you miss first run wizard? This is an option for you."
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignJustify
        }
        Text {
            id: restartNotice
            width: parent.width
            color: "#ff0000"
            font.pixelSize: platformStyle.fontSizeSmall
            text: "It is required to restart the app after using above options."
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignJustify
        }
    }
}

