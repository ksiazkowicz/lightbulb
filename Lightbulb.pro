# Add more folders to ship with the application, here
#folder_01.source = qml
#folder_01.target = qml
#DEPLOYMENTFOLDERS = folder_01

QT += declarative
QT += network

symbian:TARGET.UID3 = 0xE22AC278

# Smart Installer package's UID
# This UID is from the protected range and therefore the package will
# fail to install if self-signed. By default qmake uses the unprotected
# range value if unprotected UID is defined for the application and
# 0x2002CCCF value if protected UID is given to the application
#symbian:DEPLOYMENT.installer_header = 0x2002CCCF

# Allow network access on Symbian
symbian:TARGET.CAPABILITY += NetworkServices

#NOTE: Update your version number with each build.
#NOTE: You may also need a different name than the executable for your caption.
#    packageheader = "$${LITERAL_HASH}{\"Lightbulb (pre-release)\"}, (0xE22AC278), 0, 1, 7, TYPE=SA"

#NOTE: Add a vendor (company) names.
#NOTE: The global name is mandatory for Symbian Signed and should match the name in your Symbian Signed account.
#    vendorinfo = \
#     "%{\"Maciej Janiszewski\"}" \
#     ":\"Maciej Janiszewski\""

#NOTE: The new new package header and vendor information are defined but not yet used
#NOTE: Add the variables to ''my_deployment.pkg_prerules'', and add this to the DEPLOYMENT
# my_deployment.pkg_prerules = package header vendorinfo
# DEPLOYMENT += my_deployment


TARGET.EPOCHEAPSIZE = 0x200000 0x1F400000

symbian {
    LIBS += -lavkon \
            -laknnotify \
            -leiksrv \
            -lhwrmlightclient
}

# If your application uses the Qt Mobility libraries, uncomment the following
# lines and add the respective components to the MOBILITY variable.
 CONFIG += mobility
MOBILITY += feedback
 MOBILITY += systeminfo #QSystemNetworkInfo

# Add dependency to Symbian components
CONFIG += qt-components

DEFINES += QT_USE_FAST_CONCATENATION QT_USE_FAST_OPERATOR_PLUS

# The .cpp file which was generated for your project. Feel free to hack it.
SOURCES += main.cpp \
    MyXmppClient.cpp \
    listmodel.cpp \
    rosterlistmodel.cpp \
    rosteritemmodel.cpp \
    mycache.cpp \
    storevcard.cpp \
    mysettings.cpp \
    messagewrapper.cpp \
    msgitemmodel.cpp \
    msglistmodel.cpp \
    chatslistmodel.cpp \
    chatsitemmodel.cpp \
    accountsitemmodel.cpp \
    accountslistmodel.cpp \
    meegimsettings.cpp \
    qmlvcard.cpp \
    qmlrostermodel.cpp \
    lightbulbhswidget.cpp \
    globalnote.cpp \
    filemodel.cpp \
    nativechaticon.cpp \
    fileio.cpp \
    lock.cpp \
    xmppclientmanager.cpp \
    discreetpopup.cpp


HEADERS += MyXmppClient.h \
    listmodel.h \
    rosterlistmodel.h \
    rosteritemmodel.h \
    mycache.h \
    storevcard.h \
    mysettings.h \
    messagewrapper.h \
    msgitemmodel.h \
    msglistmodel.h \
    chatslistmodel.h \
    chatsitemmodel.h \
    accountsitemmodel.h \
    accountslistmodel.h \
    meegimsettings.h \
    qmlvcard.h \
    qmlrostermodel.h \
    qhswidget.h \
    lightbulbhswidget.h \
    qmlclipboardadapter.h \
    globalnote.h \
    filemodel.h \
    nativechaticon.h \
    fileio.h \
    lock.h \
    xmppclientmanager.h \
    discreetpopup.h

OTHER_FILES += \
    README \
    qml/Dialogs/AddContact.qml \
    qml/Dialogs/ChangeStatus.qml \
    qml/Dialogs/RemoveAccount.qml \
    qml/Dialogs/Info.qml \
    qml/Dialogs/RemoveContact.qml \
    qml/Dialogs/RenameContact.qml \
    qml/Dialogs/QuerySubscribtion.qml \
    qml/Dialogs/FileDialog.qml \
    qml/ChatsPage.qml \
    qml/AccountAddPage.qml \
    qml/VCardPage.qml \
    qml/SettingsPage.qml \
    qml/main.qml \
    qml/RosterPage.qml \
    qml/MessagesPage.qml \
    qml/AccountsPage.qml \
    qml/AboutPage.qml \
    qml/DialogChangeStatus.qml \
    qml/Notifications.qml \
    qml/Dialogs/VibrationSettings.qml \
    qml/Dialogs/SoundSettings.qml \
    qml/Banner.qml \
    qml/ArchivePage.qml

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

#that library should be copied to SDK folder
#LIBS += -lhswidgetpublisher
#Libs for appswitcher
LIBS += -lapgrfx -lcone -lws32
#Libs for CFbsBimap
LIBS += -lbitgdi -lfbscli -laknskins -laknskinsrv -leikcore # -laknswallpaperutils

TRANSLATIONS = lang\pl.ts
