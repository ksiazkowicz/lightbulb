#######################################################################
# Lightbulb.pro
# -- Lightbulb project file
#
# Copyright (c) 2013 Maciej Janiszewski
#
# This file is part of Lightbulb.
#
# Lightbulb is free software: you can redistribute it and/or modify
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

VERSION = 0.2.3

symbian {
    TARGET.UID3 = 0xE22AC278
    TARGET.CAPABILITY += NetworkServices WriteDeviceData
    TARGET.EPOCHEAPSIZE = 0x200000 0x1F400000
    CONFIG += qt-components

    vendorinfo += "%{\"n1958 Apps\"}" ":\"n1958 Apps\""
    my_deployment.pkg_prerules = vendorinfo
    DEPLOYMENT += my_deployment
    DEPLOYMENT.display_name = Lightbulb

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
            -lesock
}

# If your application uses the Qt Mobility libraries, uncomment the following
# lines and add the respective components to the MOBILITY variable.
CONFIG += mobility
MOBILITY += feedback \
            systeminfo

DEFINES += QT_USE_FAST_CONCATENATION QT_USE_FAST_OPERATOR_PLUS

# The .cpp file which was generated for your project. Feel free to hack it.
SOURCES += src/main.cpp \
    src/xmpp/MyXmppClient.cpp \
    src/cache/MyCache.cpp \
    src/cache/StoreVCard.cpp \
    src/xmpp/MessageWrapper.cpp \
    src/cache/QMLVCard.cpp \
    src/avkon/LightbulbHSWidget.cpp \
    src/database/DatabaseManager.cpp \
    src/avkon/QAvkonHelper.cpp \
    src/xmpp/XmppConnectivity.cpp \
    src/database/DatabaseWorker.cpp \
    src/database/Settings.cpp \
    src/models/AccountsItemModel.cpp \
    src/models/ListModel.cpp \
    src/models/MessageItemModel.cpp \
    src/models/MessageListModel.cpp

HEADERS += src/xmpp/MyXmppClient.h \
    src/cache/MyCache.h \
    src/cache/StoreVCard.h \
    src/xmpp/MessageWrapper.h \
    src/cache/QMLVCard.h \
    src/avkon/QHSWidget.h \
    src/avkon/LightbulbHSWidget.h \
    src/database/DatabaseManager.h \
    src/avkon/QAvkonHelper.h \
    src/avkon/SymbiosisAPIClient.h \
    src/xmpp/XmppConnectivity.h \
    src/database/DatabaseWorker.h \
    src/database/Settings.h \
    src/models/AccountsItemModel.h \
    src/models/AccountsListModel.h \
    src/models/ListModel.h \
    src/models/MessageItemModel.h \
    src/models/MessageListModel.h \
    src/models/RosterItemModel.h \
    src/models/RosterListModel.h

OTHER_FILES += README.md \
    qml/Dialogs/*.* \
    qml/*.* \
    qml/Pages/*.* \
    qml/FirstRun/*.* \
    qml/JavaScript/*.* \
    qml/Globals.qml


# Please do not modify the following two lines. Required for deployment.
include(qmlapplicationviewer/qmlapplicationviewer.pri)
qtcAddDeployment()

#qxmpp
include(qxmpp/qxmpp.pri)
INCLUDEPATH += qxmpp/base/ qxmpp/client

addFiles.pkg_postrules += "\"HSWidgetPlugin0xE22AC278.dll\" - \"!:\\sys\\bin\\HSWidgetPlugin0xE22AC278.dll\""

addFiles.pkg_postrules += "\"sounds\\Message_Received.wav\" - \"!:\\data\\.config\\Lightbulb\\sounds\\Message_Received.wav\""
addFiles.pkg_postrules += "\"sounds\\Message_Sent.wav\" - \"!:\\data\\.config\\Lightbulb\\sounds\\Message_Sent.wav\""
addFiles.pkg_postrules += "\"sounds\\New_Message.wav\" - \"!:\\data\\.config\\Lightbulb\\sounds\\Subscription_Request.wav\""

# Belle Albus widget skin
addFiles.pkg_postrules += "\"widget\\Belle Albus\\background.png\" - \"C:\\data\\.config\\Lightbulb\\widgets\\Belle Albus\\background.png\""

DEPLOYMENT += addFiles

RESOURCES += resources.qrc
