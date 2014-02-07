// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1

Item {
    Image {
        id: darkImg
        x: 0
        y: 32
        width: 180
        height: 320
        source: "qrc:/FirstRun/img/black"
    }

    Image {
        id: whiteImg
        x: 180
        y: 32
        width: 180
        height: 320
        source: "qrc:/FirstRun/img/white"
    }

    RadioButton {
        id: dark
        x: 65
        anchors { top: darkImg.bottom; topMargin: 18; }
        text: ""
        checked: !settings.gBool("ui", "invertPlatform")
        onCheckedChanged: if (checked) light.checked = false;
    }

    RadioButton {
        id: light
        x: 245
        anchors { top: whiteImg.bottom; topMargin: 18; }
        text: ""
        checked: settings.gBool("ui", "invertPlatform")
        onCheckedChanged: {
            if (checked) dark.checked = false;
            settings.sBool(checked,"ui", "invertPlatform")
            main.platformInverted = checked
            vars.textColor = checked ? platformStyle.colorNormalDark : platformStyle.colorNormalLight
        }
    }


}
