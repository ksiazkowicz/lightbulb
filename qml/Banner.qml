// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1


Item{
    anchors { top: parent.top; left: parent.left; right: parent.right }
    property alias text: text.text
    property alias timeout : timer.interval
    function open(){
        go.start()
        if (timer.interval)
            timer.restart();
    }
    function hide() {
        back.start()
    }
    PropertyAnimation{
        id: go
        duration: 200
        target: bannerrect
        property: "scale"
        to: 1
    }
    PropertyAnimation{
        id: back
        duration: 200
        target: bannerrect
        property: "scale"
        to: 0
    }
    Rectangle{
        id: bannerrect
        scale: 0
        z: 10
        color: "black"
        height: 16 + text.lineCount*platformStyle.fontSizeMedium
        opacity: 0.800
        anchors { top: parent.top; left: parent.left; right: parent.right }

         Text{
             anchors.fill: parent
             anchors.leftMargin: 10
             anchors.rightMargin: 10
             wrapMode: Text.Wrap
             font {
                pixelSize: platformStyle.fontSizeMedium
                family: platformStyle.fontFamilyRegular
            }
             id: text
             color: platformStyle.colorNormalLight
             text: ""
             font.bold: true
             styleColor: "#ffffff"
         }
    }

    Timer{
        id: timer
        interval: 2000
        running: true
        onTriggered: {
            hide()
        }
    }
}
