import QtQuick 1.1
import QtMobility.feedback 1.1

Item {
    id: root
    implicitHeight: 44
    implicitWidth: 44

    property string iconSource
    property bool platformInverted: false

    signal clicked
    signal platformReleased
    signal platformPressAndHold

    Rectangle {
        id: highlightRec
        //radius: 18
        opacity: 0.0
        visible: false
        gradient: Gradient {
            GradientStop { position: 0; color: platformInverted ?  "#3c000000" : "#3cffffff" }
            GradientStop { position: 1; color: platformInverted ?  "#78000000" : "#78ffffff" }
        }
        anchors.fill: parent
        smooth: true
    }

    Image {
        id: iconImage
        anchors.centerIn: parent
        sourceSize.width: platformStyle.graphicSizeSmall
        sourceSize.height: platformStyle.graphicSizeSmall
        source: privateStyle.toolBarIconPath(iconSource, platformInverted)
        smooth: true
    }

    MouseArea {
        anchors.fill: parent
        onPressed: stateGroup.state = 'Pressed'
        onReleased: stateGroup.state = 'Released'
        onCanceled: stateGroup.state = 'Canceled'
        onExited: stateGroup.state = 'Canceled'
        onPressAndHold: root.platformPressAndHold()
    }

    QtObject {
        id: actions

        function pressed()
        {
            privateStyle.play(ThemeEffect.BasicButton)

            highlightRec.visible = true
            highlightRec.opacity = 1.0
            iconImage.scale = 0.95
        }

        function click()
        {
            root.clicked()
        }

        function released()
        {
            releasedAnimation.restart()
            root.platformReleased()
        }
    }

    StateGroup {
        id: stateGroup

        states: [
            State { name: "Pressed" },
            State { name: "Released" },
            State { name: "Canceled" }
        ]

        transitions: [
            Transition {
                to: "Pressed"
                ScriptAction { script: actions.pressed() }
            },

            Transition {
                from: "Pressed"
                to: "Released"
                ScriptAction { script: actions.released() }
                ScriptAction { script: actions.click() }
            },

            Transition {
                from: "Pressed"
                to: "Canceled"
                ScriptAction { script: actions.released() }
            }
        ]
    }

    SequentialAnimation {
        id: releasedAnimation

        NumberAnimation {
            target: iconImage
            property: "scale"
            to: 1.0
            duration: 100
            easing.type: Easing.Linear
        }

        NumberAnimation {
            target: highlightRec
            property: "opacity"
            to: 0.0
            duration: 150
            easing.type: Easing.Linear
        }

        PropertyAction {
            target: highlightRec
            property: "visible"
            value: false
        }
    }
}
