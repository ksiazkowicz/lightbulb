// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1
import lightbulb 1.0

Item {
    SelectorHandler { id: selector }
    height: list.contentHeight;

    ListView {
        id: list;
        anchors { fill: parent }
        model: selector.skins
        delegate: MouseArea {
                    height: 48
                    width: parent.width
                    Text {
                        anchors { fill: parent; margins: 10 }
                        text: selector.getSkinName(modelData)
                        color: vars.textColor
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        settings.sStr("C:\\data\\.config\\Lightbulb\\widgets\\" + modelData,"ui","widgetSkin")
                        notify.updateSkin()
                        notify.postInfo("Skin changed to " + modelData + ".");
                    }
        }
    }

}

