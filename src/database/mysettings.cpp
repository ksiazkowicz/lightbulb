#include "mysettings.h"

#include <QDir>

QString MySettings::appName = "Lightbulb";
QString MySettings::pathMeegIMHome = QDir::homePath() + QDir::separator() + ".config" + QDir::separator() + appName;
QString MySettings::pathMeegIMCache = pathMeegIMHome + QDir::separator() + QString("cache");
QString MySettings::fileConfig = pathMeegIMHome + QDir::separator() + MySettings::appName + ".conf";

MySettings::MySettings(QObject *parent) : QSettings(MySettings::fileConfig, QSettings::NativeFormat , parent)
{
    group_notifications    = "notifications";
    group_gui              = "ui";
    group_behavior         = "behavior";

    group_xmpp             = "xmpp";
    group_accounts         = "accounts";

    key_jid = "jid";
    key_passwd = "passwd";
    key_showGroup = "show_groups";
    key_lastPresence = "show_last_presence";
    key_accounts = "accounts";
    key_resource = "resource";
    key_status_text = "status_text";
    key_status = "status";
    key_default = "is_default";
    key_useHostPort = "use_host_port";
    key_host = "host";
    key_port = "port";

    /*************************** (new message) ***************************
    key_vibraMsgRecv           = "vibraMsgRecv";
    key_vibraMsgRecvDuration   = "vibraMsgRecvDuration";
    key_vibraMsgRecvIntensity  = "vibraMsgRecvIntensity";

    key_soundMsgRecv           = "soundMsgRecv";
    key_soundMsgRecvFile       = "soundMsgRecvFile";
    key_soundMsgRecvVol        = "soundMsgRecvVol";

    key_notifyMsgRecv          = "notifyMsgRecv";
    key_blinkScrOnMsgRecv      = "blinkScrOnMsgRecv";
    key_useGlobalNote          = "useGlobalNote";
    *************************** (message sent) ***************************
    key_vibraMsgSent           = "vibraMsgSent";
    key_vibraMsgSentDuration   = "vibraMsgSentDuration";
    key_vibraMsgSentIntensity  = "vibraMsgSentIntensity";

    key_soundMsgSent           = "soundMsgSent";
    key_soundMsgSentFile       = "soundMsgSentFile";
    key_soundMsgSentVol        = "soundMsgSentVol";
    ************************ (connection changed) ************************
    key_notifyConnection       = "notifyConnection";

    key_soundNotifyConn        = "soundNotifyConn";
    key_soundNotifyConnFile    = "soundNotifyConnFile";
    key_soundNotifyConnVol     = "soundNotifyConnVol";
    *********************** (subscription request) ***********************
    key_notifySubscription     = "notifySubscription";

    key_vibraMsgSub            = "vibraMsgSub";
    key_vibraMsgSubDuration    = "vibraMsgSubDuration";
    key_vibraMsgSubIntensity   = "vibraMsgSubIntensity";

    key_soundNotifySub         = "soundNotifySub";
    key_soundNotifySubFile     = "soundNotifySubFile";
    key_soundNotifySubVol      = "soundNotifySubVol";
    ************************* (contact is typing) ************************
    key_notifyTyping           = "notifyTyping";
    ******************************* ( UI ) *******************************
    key_hideOffline            = "hideOffline";
    key_markUnread             = "markUnread";
    key_showUnreadCount        = "showUnreadCount";
    key_rosterItemHeight       = "rosterItemHeight";
    key_showContactStatusText  = "showContactStatusText";

    key_rosterLayoutAvatar     = "rosterLayoutAvatar"; //display avatar if true, only state if false
    key_platformInvert         = "platformInvert";
    key_splitscreenAnimation   = "splitscreenAnimation";
    **************************** ( behavior ) ****************************
    key_reconnectOnError       = "reconnectOnError";
    key_keepAliveInterval      = "keepAliveInterval";

    key_storeStatusText        = "storeStatusText";
    key_lastStatusText         = "lastStatusText";

    key_archiveIncMsg          = "archiveIncMsg";
    key_enableHsWidget         = "enableHsWidget";
    key_showStatusRow          = "showStatusRow";
    key_showLastUpdate         = "showLastUpdate";


    key_disableNotify          = "disableNotifications";
    key_disableNotifyDuration  = "disableNotificationsDuration";
    */
}

/*************************** (new message) **************************/
bool MySettings::getBool(QString group, QString key)
{
    beginGroup( group );
    QVariant ret = value( key, false );
    endGroup();
    return ret.toBool();
}
void MySettings::setBool(const bool isSet, QString group, QString key)
{
    beginGroup( group );
    setValue( key, QVariant(isSet) );
    endGroup();
}

int MySettings::getInt(QString group, QString key)
{
    beginGroup( group );
    QVariant ret = value( key, false );
    endGroup();
    return ret.toInt();
}
void MySettings::setInt(const int isSet, QString group, QString key)
{
    beginGroup( group );
    setValue( key, QVariant(isSet) );
    endGroup();
}

QString MySettings::getString(QString group, QString key)
{
    beginGroup( group );
    QVariant ret = value( key, false );
    endGroup();
    return ret.toString();
}
void MySettings::setString(const QString isSet, QString group, QString key)
{
    beginGroup( group );
    setValue( key, QVariant(isSet) );
    endGroup();
}
/******** ACCOUNT RELATED SHIT *******/
QStringList MySettings::getListAccounts()
{
    beginGroup( group_accounts );
    QVariant ret = value( key_accounts, QStringList() );
    endGroup();
    return ret.toStringList();
}
/*-------------------*/
void MySettings::addAccount( const QString &acc )
{
    beginGroup( group_accounts );
    QVariant retList = value( key_accounts, QStringList() );
    QStringList sl = retList.toStringList();
    if( sl.indexOf(acc) < 0 ) {
        sl.append(acc);
        setValue( key_accounts, QVariant(sl) );
    }
    endGroup();
}
void MySettings::remAccount( const QString &acc )
{
    beginGroup( group_accounts );
    QVariant retList = value( key_accounts, QStringList() );
    QStringList sl = retList.toStringList();
    if( sl.indexOf(acc) >= 0 ) {
        sl.removeOne(acc);
        setValue( key_accounts, QVariant(sl) );
    }
    endGroup();
}
/*-------------------*/
QString MySettings::getPasswd(const QString &jid)
{
    beginGroup( jid );
    QVariant ret = value( key_passwd, QString("") );
    endGroup();
    return ret.toString();
}
void MySettings::setPasswd(const QString &jid, const QString &passwd)
{
    beginGroup( jid );
    setValue( key_passwd, QVariant(passwd) );
    endGroup();
}
/*-----------*/
QString MySettings::getResource(const QString &jid)
{
    beginGroup( jid );
    QVariant ret = value( key_resource, QString("") );
    endGroup();
    return ret.toString();
}
void MySettings::setResource(const QString &jid, const QString &resource)
{
    beginGroup( jid );
    setValue( key_resource, QVariant(resource) );
    endGroup();
}
/*-----------*/
bool MySettings::isAccDefault(const QString &jid)
{
    beginGroup( jid );
    QVariant ret = value( key_default, false );
    endGroup();
    return ret.toBool();
}
void MySettings::setAccDefault(const QString &jid, const bool &def)
{
    beginGroup( jid );
    setValue( key_default, QVariant(def) );
    endGroup();
}
/*-----------*/
bool MySettings::isHostPortManually(const QString &jid)
{
    beginGroup( jid );
    QVariant ret = value( key_useHostPort, false );
    endGroup();
    return ret.toBool();
}
void MySettings::setHostPortManually(const QString &jid, const bool &def)
{
    beginGroup( jid );
    setValue( key_useHostPort, QVariant(def) );
    endGroup();
}
/*-----------*/
QString MySettings::getHost(const QString &jid)
{
    beginGroup( jid );
    QVariant ret = value( key_host, QString("") );
    endGroup();
    return ret.toString();
}
void MySettings::setHost(const QString &jid, const QString &host)
{
    beginGroup( jid );
    setValue( key_host, QVariant(host) );
    endGroup();
}
/*-----------*/
int MySettings::getPort(const QString &jid)
{
    beginGroup( jid );
    QVariant ret = value( key_port, 0 );
    endGroup();
    return ret.toInt();
}
void MySettings::setPort(const QString &jid, const int port)
{
    beginGroup( jid );
    setValue( key_port, QVariant(port) );
    endGroup();
}
/*-----------*/
QString MySettings::getStatus()
{
    beginGroup( group_behavior );
    QVariant ret = value( key_status, QString("") );
    endGroup();
    return ret.toString();
}
void MySettings::setStatus( const QString &status)
{
    beginGroup( group_behavior );
    setValue( key_status, QVariant(status) );
    endGroup();
}
/*-----------*/
QString MySettings::getStatusText()
{
    beginGroup( group_behavior );
    QVariant ret = value( key_status_text, QString("") );
    endGroup();
    return ret.toString();
}
void MySettings::setStatusText( const QString &status_text)
{
    beginGroup( group_behavior );
    setValue( key_status_text, QVariant(status_text) );
    endGroup();
}

