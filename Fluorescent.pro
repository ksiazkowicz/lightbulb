#######################################################################
# Fluorescent.pro
# -- Fluorescent project file
#
# Copyright (c) 2016 Maciej Janiszewski
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
QT += network sql core quickcontrols2
TEMPLATE = vcapp

winrt {
    CONFIG += windeployqt
    winphone:equals(WINSDK_VER, 8.0) {
        WINRT_MANIFEST.capabilities += ID_CAP_NETWORKING
    } else {
        WINRT_MANIFEST.capabilities += internetClient
    }
}

VERSION = 0.4.0

# import qxmpp
include(qxmpp/qxmpp.pri)
INCLUDEPATH += qxmpp/base/ qxmpp/client

# desktop support
RESOURCES += platforms/desktop.qrc
SOURCES   += src/desktop/main.cpp

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
           src/xmpp/EventsManager.cpp \
           src/models/RosterItemFilter.cpp \
           src/models/ServiceItemFilter.cpp \
           src/winrt/QNetworkProxy.cpp

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
        src/models/NetworkCfgItemModel.h \
        src/models/NetworkCfgListModel.h \
        src/models/ParticipantListModel.h \
        src/models/ParticipantItemModel.h \
        src/models/EventListModel.h \
        src/models/EventItemModel.h \
        src/xmpp/EventsManager.h \
        src/models/RosterItemFilter.h \
        src/models/ServiceItemModel.h \
        src/models/ServiceListModel.h \
        src/models/ServiceItemFilter.h \
        src/winrt/QNetworkProxy.h

# Fluorescent Logger
SOURCES += src/FluorescentLogger.cpp
HEADERS += src/FluorescentLogger.h
