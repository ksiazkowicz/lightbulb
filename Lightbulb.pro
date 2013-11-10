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

VERSION = 0.2.0

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
SOURCES += main.cpp \
    MyXmppClient.cpp \
    listmodel.cpp \
    mycache.cpp \
    storevcard.cpp \
    mysettings.cpp \
    messagewrapper.cpp \
    accountsitemmodel.cpp \
    accountslistmodel.cpp \
    qmlvcard.cpp \
    lightbulbhswidget.cpp \
    DatabaseManager.cpp \
    QAvkonHelper.cpp \
    SettingsDBWrapper.cpp

HEADERS += MyXmppClient.h \
    listmodel.h \
    mycache.h \
    storevcard.h \
    mysettings.h \
    messagewrapper.h \
    accountsitemmodel.h \
    accountslistmodel.h \
    qmlvcard.h \
    qhswidget.h \
    lightbulbhswidget.h \
    qmlclipboardadapter.h \
    DatabaseManager.h \
    QAvkonHelper.h \
    SettingsDBWrapper.h \
    SymbiosisAPIClient.h

OTHER_FILES += README \
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
    qml/FirstRun/07_congratulations.qml

# Please do not modify the following two lines. Required for deployment.
include(qmlapplicationviewer/qmlapplicationviewer.pri)
qtcAddDeployment()

#qxmpp
include(qxmpp/qxmpp.pri)
INCLUDEPATH += qxmpp/base/ qxmpp/client

addFiles.pkg_postrules += "\"C:\\Projekty\\Lightbulb\\HSWidgetPlugin0xE22AC278.dll\" - \"!:\\sys\\bin\\HSWidgetPlugin0xE22AC278.dll\""
addFiles.pkg_postrules += "\"C:\\Projekty\\Lightbulb\\qml\\images\\LightbulbWidget.png\" - \"!:\\data\\.config\\Lightbulb\\Lightbulb.png\""
addFiles.pkg_postrules += "\"C:\\Projekty\\Lightbulb\\qml\\images\\LightbulbWidget_attention.png\" - \"!:\\data\\.config\\Lightbulb\\LightbulbA.png\""

addFiles.pkg_postrules += "\"C:\\Projekty\\Lightbulb\\sounds\\Message_Received.wav\" - \"!:\\data\\.config\\Lightbulb\\sounds\\Message_Received.wav\""
addFiles.pkg_postrules += "\"C:\\Projekty\\Lightbulb\\sounds\\Message_Sent.wav\" - \"!:\\data\\.config\\Lightbulb\\sounds\\Message_Sent.wav\""
addFiles.pkg_postrules += "\"C:\\Projekty\\Lightbulb\\sounds\\New_Message.wav\" - \"!:\\data\\.config\\Lightbulb\\sounds\\Subscription_Request.wav\""

DEPLOYMENT += addFiles

RESOURCES += \
    resources.qrc
