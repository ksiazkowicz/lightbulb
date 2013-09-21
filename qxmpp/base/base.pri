# Header files
HEADERS += \
    qxmpp/base/QXmppBindIq.h \
    qxmpp/base/QXmppByteStreamIq.h \
    qxmpp/base/QXmppConstants.h \
    qxmpp/base/QXmppDataForm.h \
    qxmpp/base/QXmppDiscoveryIq.h \
    qxmpp/base/QXmppElement.h \
    qxmpp/base/QXmppEntityTimeIq.h \
    qxmpp/base/QXmppGlobal.h \
    qxmpp/base/QXmppIbbIq.h \
    qxmpp/base/QXmppIq.h \
    qxmpp/base/QXmppJingleIq.h \
    qxmpp/base/QXmppLogger.h \
    qxmpp/base/QXmppMessage.h \
    qxmpp/base/QXmppMucIq.h \
    qxmpp/base/QXmppNonSASLAuth.h \
    qxmpp/base/QXmppPingIq.h \
    qxmpp/base/QXmppPresence.h \
    qxmpp/base/QXmppPubSubIq.h \
    qxmpp/base/QXmppRegisterIq.h \
    qxmpp/base/QXmppResultSet.h \
    qxmpp/base/QXmppRosterIq.h \
    qxmpp/base/QXmppRpcIq.h \
    qxmpp/base/QXmppRtpChannel.h \
    qxmpp/base/QXmppSessionIq.h \
    qxmpp/base/QXmppSocks.h \
    qxmpp/base/QXmppStanza.h \
    qxmpp/base/QXmppStream.h \
    qxmpp/base/QXmppStreamFeatures.h \
    qxmpp/base/QXmppStun.h \
    qxmpp/base/QXmppUtils.h \
    qxmpp/base/QXmppVCardIq.h \
    qxmpp/base/QXmppVersionIq.h \
    qxmpp/base/QXmppCodec_p.h \
    qxmpp/base/QXmppSasl_p.h \
    qxmpp/base/QXmppStreamInitiationIq_p.h
	
# Source files
SOURCES += \
    qxmpp/base/QXmppBindIq.cpp \
    qxmpp/base/QXmppByteStreamIq.cpp \
    qxmpp/base/QXmppCodec.cpp \
    qxmpp/base/QXmppConstants.cpp \
    qxmpp/base/QXmppDataForm.cpp \
    qxmpp/base/QXmppDiscoveryIq.cpp \
    qxmpp/base/QXmppElement.cpp \
    qxmpp/base/QXmppEntityTimeIq.cpp \
    qxmpp/base/QXmppGlobal.cpp \
    qxmpp/base/QXmppIbbIq.cpp \
    qxmpp/base/QXmppIq.cpp \
    qxmpp/base/QXmppJingleIq.cpp \
    qxmpp/base/QXmppLogger.cpp \
    qxmpp/base/QXmppMessage.cpp \
    qxmpp/base/QXmppMucIq.cpp \
    qxmpp/base/QXmppNonSASLAuth.cpp \
    qxmpp/base/QXmppPingIq.cpp \
    qxmpp/base/QXmppPresence.cpp \
    qxmpp/base/QXmppPubSubIq.cpp \
    qxmpp/base/QXmppRegisterIq.cpp \
    qxmpp/base/QXmppResultSet.cpp \
    qxmpp/base/QXmppRosterIq.cpp \
    qxmpp/base/QXmppRpcIq.cpp \
    qxmpp/base/QXmppRtpChannel.cpp \
    qxmpp/base/QXmppSasl.cpp \
    qxmpp/base/QXmppSessionIq.cpp \
    qxmpp/base/QXmppSocks.cpp \
    qxmpp/base/QXmppStanza.cpp \
    qxmpp/base/QXmppStream.cpp \
    qxmpp/base/QXmppStreamFeatures.cpp \
    qxmpp/base/QXmppStreamInitiationIq.cpp \
    qxmpp/base/QXmppStun.cpp \
    qxmpp/base/QXmppUtils.cpp \
    qxmpp/base/QXmppVCardIq.cpp \
    qxmpp/base/QXmppVersionIq.cpp

# DNS
qt_version = $$QT_MAJOR_VERSION
contains(qt_version, 4) {
    HEADERS += qxmpp/base/qdnslookup.h qxmpp/base/qdnslookup_p.h
    SOURCES += qxmpp/base/qdnslookup.cpp
    android:SOURCES += qxmpp/base/qdnslookup_stub.cpp
    else:symbian:SOURCES += qxmpp/base/qdnslookup_symbian.cpp
    else:unix:SOURCES += qxmpp/base/qdnslookup_unix.cpp
    else:win32:SOURCES += qxmpp/base/qdnslookup_win.cpp
}


# DNqxmpp/S
#SOURCES += qxmpp/base/qdnslookup.cpp
#android:SOURCES += qxmpp/base/qdnslookup_stub.cpp
#else:symbian:SOURCES += qxmpp/base/qdnslookup_symbian.cpp
#else:unix:SOURCES += qxmpp/base/qdnslookup_unix.cpp
#else:win32:SOURCES += qxmpp/base/qdnslookup_win.cpp
