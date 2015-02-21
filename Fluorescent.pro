#######################################################################
# Fluorescent.pro
# -- Fluorescent project file
#
# Copyright (c) 2013 Maciej Janiszewski
#
# This file is part of Fluorescent.
#
# Fluorescent is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#######################################################################

# global Qt bits
QT += network sql
DEFINES += QT_USE_FAST_CONCATENATION QT_USE_FAST_OPERATOR_PLUS

TEMPLATE = app

VERSION = 0.4.0
DATE = $$system(date /t) # might break on something else than winshit, damn you people who fuck standards
DEFINES += VERSION=\"\\\"$$VERSION\\\"\"
DEFINES += BUILDDATE=\"\\\"$$DATE\\\"\"

# QML Preprocessor by Katastrophos
# since BB uses Cascades, I don't think we need this one
!blackberry { include(qmlpp.pri) }

# import qxmpp
symbian|blackberry|sailfish {
    # static import if mobile
    include(qxmpp/qxmpp.pri)
    INCLUDEPATH += qxmpp/base/ qxmpp/client
} else {
    # dynamic import if else (breaks Qt4 on desktop but whateva')
    packagesExist(qxmpp_d) {
        include(../qxmpp/qxmpp.pri)
        QMAKE_LIBDIR += ../qxmpp/src
        INCLUDEPATH += $$QXMPP_INCLUDEPATH
        LIBS += $$QXMPP_LIBS
    } else {
        include(qxmpp/qxmpp.pri)
        INCLUDEPATH += qxmpp/base/ qxmpp/client
    }
}

# desktop support
macx|win32|linux|haiku {
    RESOURCES += platforms/desktop.qrc
    SOURCES   += src/desktop/main.cpp
}

# BlackBerry-only Qt bits
blackberry {
	APP_NAME = Fluorescent

	QT += declarative
        CONFIG += cascades
	
        SOURCES += src/bb/main.cpp src/bb/applicationui.cpp
	HEADERS += src/bb/applicationui.hpp

        # abstract item model adapter
        SOURCES += src/bb/AbstractItemModel.cpp
        HEADERS += src/bb/AbstractItemModel.hpp

        LIBS += -lbbdata -lbb -lbbcascades

        OTHER_FILES += bar-descriptor.xml \
                       platforms/blackberry/*.* \
                       platforms/blackberry/Pages/*.*
}

# Sailfish-only Qt bits
sailfish {
    DEFINES += Q_OS_SAILFISH # it's good to make Qt know we're building for Sailfish
    CONFIG += sailfishapp
    TARGET = fluorescent

    RESOURCES += platforms/sailfish.qrc

    #other files, useful for haxing qml code
    OTHER_FILES += platforms/sailfish/qml/Dialogs/*.* \
                   platforms/sailfish/qml/*.* \
                   platforms/sailfish/qml/Pages/*.* \
                   platforms/sailfish/qml/Cover/*.* \
                   platforms/sailfish/qml/FirstRun/*.* \
                   platforms/sailfish/qml/JavaScript/*.* \
                   platforms/sailfish/qml/Preflets/*.* \
                   platforms/sailfish/qml/Menus/*.* \
                   platforms/sailfish/qml/Components/*.*

}

# Symbian-only bits
symbian {
    TARGET.UID3 = 0xE00AC666
    TARGET.CAPABILITY += NetworkServices WriteDeviceData ReadDeviceData ReadUserData WriteUserData LocalServices Location
    TARGET.EPOCHEAPSIZE = 0x200000 0x1F400000
    CONFIG += qt-components
    ICON = platforms/global/images/Fluorescent.svg

    RESOURCES += platforms/symbian.qrc

    vendorinfo += "%{\"n1958 Apps\"}" ":\"n1958 Apps\""
    my_deployment.pkg_prerules = vendorinfo
    DEPLOYMENT += my_deployment
    DEPLOYMENT.display_name = Fluorescent

    SOURCES += src/symbian/main.cpp

    SOURCES += src/avkon/AvkonMedia.cpp \
               src/avkon/QAvkonHelper.cpp \
               src/avkon/DataPublisher.cpp
    HEADERS += src/avkon/QAvkonHelper.h \
               src/avkon/AvkonMedia.h \
               src/avkon/DataPublisher.h

    DEFINES += APP_VERSION=\"$$VERSION\"

    # Please do not modify the following two lines. Required for deployment.
    include(qmlapplicationviewer/qmlapplicationviewer.pri)
    qtcAddDeployment()

    crmlFiles.sources = platforms/symbian/crml/com.fluorescent.widget.qcrml
    crmlFiles.path = /resource/qt/crml

    DEPLOYMENT += crmlFiles

    qmlPreprocessFolder(platforms/global, @QtQuick1, 1.1)

    OTHER_FILES += platforms/symbian/qml/Dialogs/*.* \
                   platforms/symbian/qml/*.* \
                   platforms/symbian/qml/Pages/*.* \
                   platforms/symbian/qml/FirstRun/*.* \
                   platforms/symbian/qml/JavaScript/*.* \
                   platforms/symbian/qml/Preflets/*.* \
                   platforms/symbian/qml/Menus/*.* \
                   platforms/symbian/qml/Components/*.*

    LIBS += -lavkon \
            -laknnotify \
            -lhwrmlightclient \
            -lapgrfx \
            -lcone \
            -lws32 \
            -lbitgdi \
            -lfbscli \
            -laknskins \
            -laknskinsrv \
            -leikcore \
            -lapmime \
            -lefsrv \
            -leuser \
            -lcommondialogs \
            -lesock \
            -lmediaclientaudio \
            -lprofileengine \
            -lcntmodel \
            -lbafl \
            -lmgfetch
}

# Qt5 bits
greaterThan(QT_MAJOR_VERSION, 4) {
    QT += qml quick widgets
    !sailfish:!blackberry { include(deployment.pri) }
    !blackberry { qmlPreprocessFolder(platforms/global, @QtQuick2, 2.0) }
} else {
    QT += declarative
}

!blackberry {
	# If your application uses the Qt Mobility libraries, uncomment the following
	# lines and add the respective components to the MOBILITY variable.
	CONFIG += mobility
	MOBILITY += mutlimedia feedback systeminfo
	MOBILITY += publishsubscribe
}

SOURCES += src/xmpp/MyXmppClient.cpp \
           src/cache/MyCache.cpp \
           src/cache/StoreVCard.cpp \
           src/xmpp/MessageWrapper.cpp \
           src/cache/QMLVCard.cpp \
           src/database/DatabaseManager.cpp \
           src/xmpp/XmppConnectivity.cpp \
        src/database/DatabaseWorker.cpp \
        src/database/Settings.cpp \
        src/EmoticonParser.cpp \
        src/xmpp/ContactListManager.cpp \
        src/avkon/NetworkManager.cpp \
        src/database/MigrationManager.cpp \
        src/xmpp/EventsManager.cpp \
        src/UpdateManager.cpp \
        src/models/RosterItemFilter.cpp \
        src/api/GraphAPIExtensions.cpp \
        src/models/ServiceItemFilter.cpp

        HEADERS += src/xmpp/MyXmppClient.h \
        src/cache/MyCache.h \
        src/cache/StoreVCard.h \
        src/xmpp/MessageWrapper.h \
        src/cache/QMLVCard.h \
        src/database/DatabaseManager.h \
        src/xmpp/XmppConnectivity.h \
        src/database/DatabaseWorker.h \
        src/database/Settings.h \
        src/models/AccountsItemModel.h \
        src/models/AccountsListModel.h \
        src/models/ListModel.h \
        src/models/RosterItemModel.h \
        src/models/RosterListModel.h \
        src/models/ChatsListModel.h \
        src/models/ChatsItemModel.h \
        src/models/MsgListModel.h \
        src/models/MsgItemModel.h \
        src/EmoticonParser.h \
        src/xmpp/ContactListManager.h \
        src/avkon/NetworkManager.h \
        src/database/MigrationManager.h \
        src/models/NetworkCfgItemModel.h \
        src/models/NetworkCfgListModel.h \
        src/models/ParticipantListModel.h \
        src/models/ParticipantItemModel.h \
        src/models/EventListModel.h \
        src/models/EventItemModel.h \
        src/xmpp/EventsManager.h \
        src/UpdateManager.h \
        src/models/RosterItemFilter.h \
        src/api/GraphAPIExtensions.h \
        src/models/ServiceItemModel.h \
        src/models/ServiceListModel.h \
        src/models/ServiceItemFilter.h

        # Fluorescent Logger
        SOURCES += src/FluorescentLogger.cpp
        HEADERS += src/FluorescentLogger.h

OTHER_FILES +=
