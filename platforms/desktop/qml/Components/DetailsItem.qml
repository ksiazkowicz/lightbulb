import QtQuick 1.1
import com.nokia.symbian 1.1

Column {
    id: root
    width: parent.width
    spacing: platformStyle.paddingSmall

    property alias title: titleLabel.text
    property alias value: valueLabel.text
    property alias textAlignment: titleLabel.horizontalAlignment
    property alias wrapMode: titleLabel.wrapMode

    Label {
        id: titleLabel
        platformInverted: main.platformInverted
        anchors { left: parent.left; right: parent.right }
        wrapMode: Text.Wrap
        font.bold: true
        horizontalAlignment: Text.AlignLeft
    }

    Text {
        id: valueLabel
        anchors { left: parent.left; right: parent.right }
        wrapMode: Text.Wrap
        color: main.textColor
        opacity: 0.7
        font.pixelSize: platformStyle.fontSizeSmall
        horizontalAlignment: titleLabel.horizontalAlignment
        onLinkActivated: dialog.createWithProperties("qrc:/menus/UrlContext", {"url": link})
    }
}
