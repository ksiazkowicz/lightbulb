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

QT += declarative network sql

VERSION = 0.4
DEFINES += VERSION=\"$$VERSION\"

symbian {
    TARGET.UID3 = 0xE00AC666
    TARGET.CAPABILITY += NetworkServices WriteDeviceData ReadDeviceData ReadUserData WriteUserData LocalServices
    TARGET.EPOCHEAPSIZE = 0x200000 0x1F400000
    CONFIG += qt-components

    vendorinfo += "%{\"n1958 Apps\"}" ":\"n1958 Apps\""
    my_deployment.pkg_prerules = vendorinfo
    DEPLOYMENT += my_deployment
    DEPLOYMENT.display_name = Fluorescent

    DEFINES += APP_VERSION=\"$$VERSION\"

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
            -lcntmodel
}

# If your application uses the Qt Mobility libraries, uncomment the following
# lines and add the respective components to the MOBILITY variable.
CONFIG += mobility
MOBILITY += mutlimedia feedback systeminfo
MOBILITY += publishsubscribe

DEFINES += QT_USE_FAST_CONCATENATION QT_USE_FAST_OPERATOR_PLUS

# The .cpp file which was generated for your project. Feel free to hack it.
SOURCES += src/main.cpp \
    src/xmpp/MyXmppClient.cpp \
    src/cache/MyCache.cpp \
    src/cache/StoreVCard.cpp \
    src/xmpp/MessageWrapper.cpp \
    src/cache/QMLVCard.cpp \
    src/database/DatabaseManager.cpp \
    src/avkon/QAvkonHelper.cpp \
    src/xmpp/XmppConnectivity.cpp \
    src/database/DatabaseWorker.cpp \
    src/database/Settings.cpp \
    src/avkon/AvkonMedia.cpp \
    src/EmoticonParser.cpp \
    src/xmpp/ContactListManager.cpp \
    src/avkon/DataPublisher.cpp \
    src/avkon/NetworkManager.cpp \
    src/database/MigrationManager.cpp

HEADERS += src/xmpp/MyXmppClient.h \
    src/cache/MyCache.h \
    src/cache/StoreVCard.h \
    src/xmpp/MessageWrapper.h \
    src/cache/QMLVCard.h \
    src/database/DatabaseManager.h \
    src/avkon/QAvkonHelper.h \
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
    src/avkon/AvkonMedia.h \
    src/EmoticonParser.h \
    src/xmpp/ContactListManager.h \
    src/avkon/DataPublisher.h \
    src/avkon/NetworkManager.h \
    src/database/MigrationManager.h \
    src/models/NetworkCfgItemModel.h \
    src/models/NetworkCfgListModel.h

OTHER_FILES += README.md \
    qml/Dialogs/*.* \
    qml/*.* \
    qml/Pages/*.* \
    qml/FirstRun/*.* \
    qml/JavaScript/*.* \
    qml/Preflets/*.* \
    qml/Menus/*.* \
    qml/Components/*.*

# Please do not modify the following two lines. Required for deployment.
include(qmlapplicationviewer/qmlapplicationviewer.pri)
qtcAddDeployment()

#qxmpp
include(qxmpp/qxmpp.pri)
INCLUDEPATH += qxmpp/base/ qxmpp/client

DEPLOYMENT += addFiles

RESOURCES += resources.qrc
