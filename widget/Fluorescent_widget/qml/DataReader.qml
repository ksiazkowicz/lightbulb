// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import QtMobility.publishsubscribe 1.1

Item {
    property alias unreadCount: unread.value

    function getName(index,dataToRead) {
        name.path = "/Fluorescent/widget/"+dataToRead+index+"/name"
        return name.value
    }

    function getStatus(index,dataToRead) {
        status.path = "/Fluorescent/widget/"+dataToRead+index+"/status"
        return status.value
    }

    function getUnreadCount(index,dataToRead) {
        unreadCount.path = "/Fluorescent/widget/"+dataToRead+index+"/unreadCount"
        return unreadCount.value
    }

    // all the handleeees
    ValueSpaceSubscriber { id: unread; path: "/Fluorescent/widget/unreadCount" }

    ValueSpaceSubscriber { id: name }
    ValueSpaceSubscriber { id: status }
    ValueSpaceSubscriber { id: unreadCount }

}
