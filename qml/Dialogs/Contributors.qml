// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1

CommonDialog {
    titleText: qsTr("Developers")

    platformInverted: main.platformInverted
    buttonTexts: [qsTr("OK")]
    Component.onCompleted: open()

    height: 400

    content: Flickable {
        contentHeight: columnContent.height
        contentWidth: columnContent.width
        anchors { fill: parent; margins: platformStyle.paddingSmall }

        flickableDirection: Flickable.VerticalFlick

        Column {
            id: columnContent
            width: parent.width - 2*platformStyle.paddingSmall
            spacing: platformStyle.paddingSmall
            Label { anchors.horizontalCenter: parent.horizontalCenter; font.pixelSize: platformStyle.fontSizeLarge*1.2; text: qsTr("Core developers"); color: vars.textColor }
            Text {
                color: vars.textColor
                text: "Maciej Janiszewski\nAnatoliy Kozlov (MeegIM)"
            }
            Label { anchors.horizontalCenter: parent.horizontalCenter; font.pixelSize: platformStyle.fontSizeLarge*1.2; text: "Contributors"; color: vars.textColor}
            Text {
                color: vars.textColor
                text: "Fabian Hüllmantel\nPaul Wallace\nDickson Leong\nMotaz Alnuweiri"
            }
            Label { anchors.horizontalCenter: parent.horizontalCenter; font.pixelSize: platformStyle.fontSizeLarge*1.2; text: "Testing"; color: vars.textColor}
            Text {
                color: vars.textColor
                text: "Mohamed Zinhom\nKonrad Bąk\nGodwin Tgn\nRudmata\nRicardo Partida"
            }
            Label { anchors.horizontalCenter: parent.horizontalCenter; font.pixelSize: platformStyle.fontSizeLarge*1.2; text: "Donators"; color: vars.textColor}
            Text {
                color: vars.textColor
                text: "Elena Archinova"
            }
        }
     }
}
