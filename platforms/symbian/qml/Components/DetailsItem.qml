import QtQuick 1.1
import com.nokia.symbian 1.1

Column {
    id: root
    width: parent.width
    spacing: platformStyle.paddingSmall

    property alias title: titleLabel.text
    property alias value: valueLabel.text
    property alias titleFont: titleLabel.font
    property alias valueFont: valueLabel.font
    property alias textAlignment: titleLabel.horizontalAlignment
    property alias wrapMode: titleLabel.wrapMode

    Label {
        id: titleLabel
        platformInverted: main.platformInverted
        anchors { left: parent.left; right: parent.right }
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignLeft
    }

    Label {
        id: valueLabel
        platformInverted: main.platformInverted
        anchors { left: parent.left; right: parent.right }
        wrapMode: Text.Wrap
        horizontalAlignment: titleLabel.horizontalAlignment
        onLinkActivated: dialog.createWithProperties("qrc:/menus/UrlContext", {"url": link})
    }
}
