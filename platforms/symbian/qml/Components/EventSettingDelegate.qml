// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1

Item {
    width: parent.width
    height: msgRecvSettings.height * 2

    Text {
        anchors { left: parent.left; top: parent.top; topMargin: platformStyle.paddingSmall; right: msgRecvSettings.left; rightMargin: platformStyle.paddingSmall; leftMargin: platformStyle.paddingSmall }
        color: main.textColor
        property string color2: main.platformInverted ? "#333333" : "#888888"
        text: title + "<br /><font color='" + color2 + "' size='"+platformStyle.fontSizeSmall+"px'>" + description + "</font>"
        font.pixelSize: platformStyle.fontSizeMedium
        wrapMode: Text.WordWrap
    }
    ButtonRow {
        id: msgRecvSettings
        anchors { right: parent.right; rightMargin: platformStyle.paddingSmall; top: parent.top }
        ToolButton {
            visible: enableVibra;
            enabled: visible;
            iconSource: selected ? ":/Events/vibra" + invertStuff : ":/Events/vibra_disabled" + invertStuff
            property bool selected: settings.gBool("notifications","vibra"+eventSettingName)
            platformInverted: main.platformInverted
            onClicked: {
                selected = !selected;
                settings.sBool(selected,"notifications","vibra"+eventSettingName)
            }
        }
        ToolButton {
            visible: enableSound;
            enabled: visible
            iconSource: selected ? ":/Events/alarm" + invertStuff : ":/Events/alarm_disabled" + invertStuff
            property bool selected: settings.gBool("notifications","sound"+eventSettingName)
            platformInverted: main.platformInverted
            onClicked: {
                selected = !selected;
                settings.sBool(selected,"notifications","sound"+eventSettingName)
            }
        }
        ToolButton {
            visible: enablePopup;
            enabled: visible;
            iconSource: selected ? ":/Events/popup" + invertStuff : ":/Events/popup_disabled" + invertStuff
            property bool selected: settings.gBool("notifications","popup"+eventSettingName)
            platformInverted: main.platformInverted
            onClicked: {
                selected = !selected;
                settings.sBool(selected,"notifications","popup"+eventSettingName)
            }
        }
    }
    ButtonRow {
        width: msgRecvSettings.width
        anchors { right: parent.right; rightMargin: platformStyle.paddingSmall; top: msgRecvSettings.bottom }
        ToolButton {
            visible: enableVibra
            enabled: visible
            width: parent.width/3
            iconSource: "toolbar-settings"
            platformInverted: main.platformInverted
            onClicked: dialog.createWithProperties("qrc:/dialogs/Settings/Vibration", {"currentlyEditedParameter" : "vibra"+eventSettingName})
        }
        ToolButton {
            width: parent.width/3
            iconSource: "toolbar-settings"
            visible: enableSound
            enabled: visible
            platformInverted: main.platformInverted
            onClicked: {
                var filename = avkon.openFileSelectionDlg();
                if (filename != "") settings.sStr(filename,"notifications","sound"+eventSettingName + "File")
            }
            onPlatformPressAndHold: {
                var filename = avkon.openFileSelectionDlg(true,true,"Z:\\data\\sounds\\digital");
                if (filename != "") settings.sStr(filename,"notifications","sound"+eventSettingName + "File")
            }
        }
        ToolButton {
            enabled: false
            visible: enablePopup
            platformInverted: main.platformInverted
            height: msgRecvSettings.height
            width: parent.width/3
        }
    }
    Rectangle {
        height: 1
        anchors { left: parent.left; right: parent.right; leftMargin: platformStyle.paddingSmall; rightMargin: platformStyle.paddingSmall; bottom: parent.bottom }
        color: main.textColor
        opacity: 0.2
    }
}
