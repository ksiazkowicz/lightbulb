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

# Add more folders to ship with the application, here
#folder_01.source = qml
#folder_01.target = qml
#DEPLOYMENTFOLDERS = folder_01

QT += declarative \
      network \
      sql

# Smart Installer package's UID
# This UID is from the protected range and therefore the package will
# fail to install if self-signed. By default qmake uses the unprotected
# range value if unprotected UID is defined for the application and
# 0x2002CCCF value if protected UID is given to the application
#symbian:DEPLOYMENT.installer_header = 0x2002CCCF

VERSION = 0.2.1

symbian {
    TARGET.UID3 = 0xE22AC278
    TARGET.CAPABILITY += NetworkServices
    TARGET.EPOCHEAPSIZE = 0x200000 0x1F400000
    CONFIG += qt-components

    vendorinfo += "%{\"n1958 Apps\"}" ":\"n1958 Apps\""
    my_deployment.pkg_prerules = vendorinfo
    DEPLOYMENT += my_deployment
    DEPLOYMENT.display_name = Lightbulb

    DEFINES += APP_VERSION=\"$$VERSION\"

    LIBS += -lavkon \
            -laknnotify \
            -leiksrv \
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
            -lcommondialogs
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
    src/ListModel.cpp \
    src/cache/MyCache.cpp \
    src/cache/StoreVCard.cpp \
    src/xmpp/MessageWrapper.cpp \
    src/AccountsItemModel.cpp \
    src/cache/QMLVCard.cpp \
    src/avkon/LightbulbHSWidget.cpp \
    src/database/DatabaseManager.cpp \
    src/avkon/QAvkonHelper.cpp \
    src/xmpp/XmppConnectivity.cpp \
    src/database/DatabaseWorker.cpp \
    src/database/Settings.cpp

HEADERS += src/xmpp/MyXmppClient.h \
    src/ListModel.h \
    src/cache/MyCache.h \
    src/cache/StoreVCard.h \
    src/xmpp/MessageWrapper.h \
    src/AccountsItemModel.h \
    src/AccountsListModel.h \
    src/cache/QMLVCard.h \
    src/avkon/QHSWidget.h \
    src/avkon/LightbulbHSWidget.h \
    src/database/DatabaseManager.h \
    src/avkon/QAvkonHelper.h \
    src/avkon/SymbiosisAPIClient.h \
    src/xmpp/XmppConnectivity.h \
    src/database/DatabaseWorker.h \
    src/database/Settings.h

OTHER_FILES += README.md \
    qml/Dialogs/AddContact.qml \
    qml/Dialogs/ChangeStatus.qml \
    qml/Dialogs/RemoveAccount.qml \
    qml/Dialogs/RemoveContact.qml \
    qml/Dialogs/RenameContact.qml \
    qml/Dialogs/QuerySubscribtion.qml \
    qml/Dialogs/VibrationSettings.qml \
    qml/Dialogs/SoundSettings.qml \
    qml/AccountAddPage.qml \
    qml/VCardPage.qml \
    qml/SettingsPage.qml \
    qml/main.qml \
    qml/RosterPage.qml \
    qml/MessagesPage.qml \
    qml/AccountsPage.qml \
    qml/AboutPage.qml \
    qml/Notifications.qml \
    qml/ArchivePage.qml \
    qml/Dialogs/ReconnectDialog.qml \
    qml/Dialogs/Chats.qml \
    qml/Dialogs/CloseDialog.qml \
    qml/Dialogs/MuteNotifications.qml \
    qml/FirstRun/01_gettingStarted.qml \
    qml/FirstRun/02_notificationLed.qml \
    qml/FirstRun/03_accountSetup.qml \
    qml/FirstRun/04_discreetPopupSettings.qml \
    qml/FirstRun/05_skinSettings.qml \
    qml/FirstRun/06_rosterLayoutSettings.qml \
    qml/FirstRun/07_congratulations.qml \
    qml/DiagnosticsPage.qml \
    qml/JavaScript/EmoticonInterpeter.js

# Please do not modify the following two lines. Required for deployment.
include(qmlapplicationviewer/qmlapplicationviewer.pri)
qtcAddDeployment()

#qxmpp
include(qxmpp/qxmpp.pri)
INCLUDEPATH += qxmpp/base/ qxmpp/client

addFiles.pkg_postrules += "\"HSWidgetPlugin0xE22AC278.dll\" - \"!:\\sys\\bin\\HSWidgetPlugin0xE22AC278.dll\""
addFiles.pkg_postrules += "\"images\\LightbulbWidget.png\" - \"!:\\data\\.config\\Lightbulb\\Lightbulb.png\""
addFiles.pkg_postrules += "\"images\\LightbulbWidget_attention.png\" - \"!:\\data\\.config\\Lightbulb\\LightbulbA.png\""

addFiles.pkg_postrules += "\"sounds\\Message_Received.wav\" - \"!:\\data\\.config\\Lightbulb\\sounds\\Message_Received.wav\""
addFiles.pkg_postrules += "\"sounds\\Message_Sent.wav\" - \"!:\\data\\.config\\Lightbulb\\sounds\\Message_Sent.wav\""
addFiles.pkg_postrules += "\"sounds\\New_Message.wav\" - \"!:\\data\\.config\\Lightbulb\\sounds\\Subscription_Request.wav\""

DEPLOYMENT += addFiles

RESOURCES += \
    resources.qrc
