// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import QtMultimediaKit 1.1
import QtMobility.feedback 1.1
import lightbulb 1.0

Item {
    id: notifications

    Component.onCompleted: {
        if (settings.gBool("behavior","enableHsWidget")) {
            hsWidget.registerWidget()
        }
    }

    property string iconPath: "C:\\data\\.config\\Lightbulb\\Lightbulb.png"
    property string row1: ""
    property string row2: ""
    property string row3: ""
    property string statusName: ""

    function getStatusName() {
       if( (xmppClient.status == XmppClient.Online) || (xmppClient.status == XmppClient.Chat) ) {
           statusName = qsTr("Online")
       } else if( (xmppClient.status == XmppClient.Away) || (xmppClient.status == XmppClient.XA) ) {
           statusName = qsTr("Away")
       } else if(  xmppClient.status == XmppClient.DND ) {
           statusName = qsTr("Do Not Disturb")
       } else if(  xmppClient.status == XmppClient.Offline ) {
           statusName = qsTr("Offline")
       }
       return statusName;
    }

    function postHSWidget() {
        getStatusName()
        row1 = globalUnreadCount + qsTr(" ~ unread messages")
        row2 = statusName + qsTr(" ~ status")
        row3 = " ~ " + Qt.formatDateTime(new Date(), "dd.MM.yyyy ~ hh:mm") + " ~ "
        hsWidget.postWidget(row1, row2, row3)
        if (globalUnreadCount>0) {
            iconPath = "C:\\data\\.config\\Lightbulb\\LightbulbA.png"
        } else {
            iconPath = "C:\\data\\.config\\Lightbulb\\Lightbulb.png"
        }
        hsWidget.updateWidget(iconPath)
    }

    Hswidget {
        id: hsWidget

    }

    GlobalNote {
        id: notify
    }

    function postGlobalNote(messageString) {
        if ((!inputInProgress) && (!Qt.application.active) ) {
            notify.displayGlobalNote(messageString)
        }
    }

    function notifyMessageSent() {
        if( vibraMsgSent ) {
            hapticsEffectSentMsg.running = true
        }
        if( soundMsgRecv ) {
            sndEffectSent.play()
        }
    }

    function registerWidget()
    {
        hsWidget.registerWidget()
    }

    function removeWidget()
    {
        hsWidget.removeWidget()
    }
}
