// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1

Item {
    property string textColor:       main.platformInverted ? platformStyle.colorNormalDark : platformStyle.colorNormalLight
    property int                     globalUnreadCount: 0
    property int                     tempUnreadCount: 0
    property bool                    inputInProgress: false
    property string                  accJid: ""
    property string                  accPass: ""
    property string                  accResource: ""
    property string                  accHost: ""
    property string                  accPort: ""
    property bool                    accManualHostPort: false
    property bool                    accDefault: false
    property bool                    connecting: false
    property string                  lastStatus: settings.gBool("behavior", "lastStatusText") ? settings.gStr("behavior","lastStatusText") : ""
    property string                  nowEditing: ""
    property string                  url: ""
    signal                           statusChanged
    property int                     lastUsedStatus: 0
    signal                           statusTextChanged
    property string                  dialogJid:       ""
    property string                  dialogTitle:     ""
    property string                  dialogText:      ""
    property string                  dialogName:      ""
    property bool                    isActive: true
    property bool                    isChatInProgress: false
    property int                     blinkerSet: 0
    property string                  selectedContactStatusText: ""
    property string                  contactName: ""
    property string                  selectedContactPresence: ""
}
