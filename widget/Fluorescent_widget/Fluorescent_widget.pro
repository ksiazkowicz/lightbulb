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

QT += declarative network sql svg

VERSION = 0.4

symbian {
    TARGET.UID3 = 0xE33AC111
    TARGET.CAPABILITY += NetworkServices WriteDeviceData ReadDeviceData ReadUserData WriteUserData LocalServices
    TARGET.EPOCHEAPSIZE = 0x200000 0x1F400000
    CONFIG += qt-components

    vendorinfo += "%{\"n1958 Apps\"}" ":\"n1958 Apps\""
    my_deployment.pkg_prerules = vendorinfo
    DEPLOYMENT += my_deployment
    DEPLOYMENT.display_name = Fluorescent widget

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

DEFINES += QT_USE_FAST_CONCATENATION QT_USE_FAST_OPERATOR_PLUS

# The .cpp file which was generated for your project. Feel free to hack it.
SOURCES += src/main.cpp \
    src/LightbulbHSWidget.cpp \
	src/SkinSelectorHandler.cpp \
	src/Settings.cpp

HEADERS += src/QHSWidget.h \
           src/LightbulbHSWidget.h \
           src/SkinSelectorHandler.h \
           src/Settings.h \
           src/WidgetDataModel.h \
           src/WidgetItemModel.h \
           src/ListModel.h

OTHER_FILES += README.md \
    qml/Dialogs/*.* \
    qml/*.* \
    qml/Pages/*.* \
    qml/FirstRun/*.* \
    qml/JavaScript/*.* \
    qml/Preflets/*.* \
    qml/Menus/*.* \
    qml/Components/*.* \
    qml/main.qml

# Please do not modify the following two lines. Required for deployment.
include(qmlapplicationviewer/qmlapplicationviewer.pri)
qtcAddDeployment()

addFiles.pkg_postrules += "\"HSWidgetPlugin0xE00AC666.dll\" - \"!:\\sys\\bin\\HSWidgetPlugin0xE00AC666.dll\""

# Belle Albus widget skin
addFiles.pkg_postrules += "\"widget\\Belle Albus\\background.png\" - \"C:\\data\\.config\\Fluorescent\\widgets\\Belle Albus\\background.png\""
addFiles.pkg_postrules += "\"widget\\Belle Albus\\fader.png\" - \"C:\\data\\.config\\Fluorescent\\widgets\\Belle Albus\\fader.png\""
addFiles.pkg_postrules += "\"widget\\Belle Albus\\settings.txt\" - \"C:\\data\\.config\\Fluorescent\\widgets\\Belle Albus\\settings.txt\""

# Belle Atricolor widget skin
addFiles.pkg_postrules += "\"widget\\Belle Atricolor\\background.png\" - \"C:\\data\\.config\\Fluorescent\\widgets\\Belle Atricolor\\background.png\""
addFiles.pkg_postrules += "\"widget\\Belle Atricolor\\fader.png\" - \"C:\\data\\.config\\Fluorescent\\widgets\\Belle Atricolor\\fader.png\""
addFiles.pkg_postrules += "\"widget\\Belle Atricolor\\settings.txt\" - \"C:\\data\\.config\\Fluorescent\\widgets\\Belle Atricolor\\settings.txt\""

# Jelly Bean by Rudmata
addFiles.pkg_postrules += "\"widget\\Jelly Bean\\background.png\" - \"C:\\data\\.config\\Fluorescent\\widgets\\Jelly Bean\\background.png\""
addFiles.pkg_postrules += "\"widget\\Jelly Bean\\fader.png\" - \"C:\\data\\.config\\Fluorescent\\widgets\\Jelly Bean\\fader.png\""
addFiles.pkg_postrules += "\"widget\\Jelly Bean\\settings.txt\" - \"C:\\data\\.config\\Fluorescent\\widgets\\Jelly Bean\\settings.txt\""
addFiles.pkg_postrules += "\"widget\\Jelly Bean\\unread.svg\" - \"C:\\data\\.config\\Fluorescent\\widgets\\Jelly Bean\\unread.svg\""
addFiles.pkg_postrules += "\"widget\\Jelly Bean\\presence\\away.svg\" - \"C:\\data\\.config\\Fluorescent\\widgets\\Jelly Bean\\presence\\away.svg\""
addFiles.pkg_postrules += "\"widget\\Jelly Bean\\presence\\busy.svg\" - \"C:\\data\\.config\\Fluorescent\\widgets\\Jelly Bean\\presence\\busy.svg\""
addFiles.pkg_postrules += "\"widget\\Jelly Bean\\presence\\chatty.svg\" - \"C:\\data\\.config\\Fluorescent\\widgets\\Jelly Bean\\presence\\chatty.svg\""
addFiles.pkg_postrules += "\"widget\\Jelly Bean\\presence\\offline.svg\" - \"C:\\data\\.config\\Fluorescent\\widgets\\Jelly Bean\\presence\\offline.svg\""
addFiles.pkg_postrules += "\"widget\\Jelly Bean\\presence\\online.svg\" - \"C:\\data\\.config\\Fluorescent\\widgets\\Jelly Bean\\presence\\online.svg\""
addFiles.pkg_postrules += "\"widget\\Jelly Bean\\presence\\xa.svg\" - \"C:\\data\\.config\\Fluorescent\\widgets\\Jelly Bean\\presence\\xa.svg\""

DEPLOYMENT += addFiles

RESOURCES += resources.qrc
