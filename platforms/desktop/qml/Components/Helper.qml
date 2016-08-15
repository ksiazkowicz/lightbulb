pragma Singleton
import QtQuick 2.0

QtObject {
    function getStatusNameByIndex(status) {
        if (status == 1) return "online"
        else if (status == 2) return "chatty"
        else if (status == 3) return "away"
        else if (status == 4) return "xa"
        else if (status == 5) return "busy"
        else if (status == 0) return "offline"
    }
}
