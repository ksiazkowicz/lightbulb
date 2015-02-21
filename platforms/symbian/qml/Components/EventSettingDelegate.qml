// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1
import "../Components"

Item {
    id: mainItem
    width: parent.width
    height: eventSettingsColumn.height

    Text {
        anchors { left: parent.left; top: parent.top; topMargin: platformStyle.paddingSmall; right: eventSettingsColumn.left; rightMargin: platformStyle.paddingSmall; leftMargin: platformStyle.paddingSmall }
        color: main.textColor
        property string color2: main.platformInverted ? "#333333" : "#888888"
        text: title + "<br /><font color='" + color2 + "' size='"+platformStyle.fontSizeSmall+"px'>" + description + "</font>"
        font.pixelSize: platformStyle.fontSizeMedium
        wrapMode: Text.WordWrap
        width: parent.width/2
    }
    
	Column {
        id: eventSettingsColumn
		anchors { right: parent.right; rightMargin: platformStyle.paddingSmall; top: parent.top }
		spacing: platformStyle.paddingSmall;
        width: parent.width/2
		
		EventSettingRowDelegate {
            enabled: enableVibra
            settingType: "vibra"
            settingName: eventSettingName
            icon: ":/Events/vibra"

            height: enabled ? platformStyle.graphicSizeMedium : 0
            visible: enabled
            anchors { left: parent.left; right: parent.right }
		}
		EventSettingRowDelegate {
            enabled: enableSound
			settingType: "sound"
			settingName: eventSettingName
            icon: ":/Events/alarm"

            height: enabled ? platformStyle.graphicSizeMedium : 0
            visible: enabled
            anchors { left: parent.left; right: parent.right }
		}
		EventSettingRowDelegate {
            enabled: enablePopup
			settingType: "popup"
			settingName: eventSettingName
            icon: ":/Events/popup"

            height: enabled ? platformStyle.graphicSizeMedium : 0
            visible: enabled
            anchors { left: parent.left; right: parent.right }
		}
	}

    Rectangle {
        height: 1
        anchors { left: parent.left; right: parent.right; leftMargin: platformStyle.paddingSmall; rightMargin: platformStyle.paddingSmall; bottom: parent.bottom }
        color: main.textColor
        opacity: 0.2
    }
}
