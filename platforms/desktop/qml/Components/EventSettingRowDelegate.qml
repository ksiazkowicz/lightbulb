// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1


Item {
    property bool enabled;
    property string settingType;
    property string settingName;
	property string icon;

	Row {
        visible: enabled
        anchors.fill: parent
        spacing: platformStyle.paddingMedium

		Image {
			id: settingIcon
			source: icon + invertStuff
			smooth: true
            sourceSize { width: platformStyle.graphicSizeSmall; height: platformStyle.graphicSizeSmall }
            anchors { verticalCenter: parent.verticalCenter }
            width: sourceSize.width; height: sourceSize.height
		}
		Switch {
            id: switchBtn
            checked: settings.gBool("notifications",settingType+settingName)
            anchors.verticalCenter: parent.verticalCenter

            onCheckedChanged: settings.sBool(checked,"notifications",settingType+settingName)
		}
		ToolButton {
            iconSource: "toolbar-settings"
			visible: settingType == "popup" ? false : enabled
			enabled: visible
            anchors.verticalCenter: parent.verticalCenter
			platformInverted: main.platformInverted
			onClicked: {
				if (settingType == "sound") {
					var filename = avkon.openFileSelectionDlg();
                    if (filename != "") settings.sStr(filename,"notifications","sound"+settingName + "File")
				} else if (settingType == "vibra") 
                    dialog.createWithProperties("qrc:/dialogs/settings/Vibration", {"currentlyEditedParameter" : "vibra"+settingName})
			}
			onPlatformPressAndHold: if (settingType == "sound") {
					var filename = avkon.openFileSelectionDlg(true,true,"Z:\\data\\sounds\\digital");
                    if (filename != "") settings.sStr(filename,"notifications","sound"+settingName + "File")
				}
		}
	}
}
