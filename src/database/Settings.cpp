/********************************************************************

src/database/Settings.cpp
-- holds settings of the app and accounts details

Copyright (c) 2013 Maciej Janiszewski

This file is part of Lightbulb.

Lightbulb is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

*********************************************************************/

#include "Settings.h"

#include <QDir>
#include "AccountsListModel.h"
#include <QDebug>

QString Settings::appName = "Lightbulb";
QString Settings::confFolder = QDir::homePath() + QDir::separator() + ".config" + QDir::separator() + appName;
QString Settings::cacheFolder = confFolder + QDir::separator() + QString("cache");
QString Settings::confFile = confFolder + QDir::separator() + Settings::appName + ".conf";

Settings::Settings(QObject *parent) : QSettings(Settings::confFile, QSettings::NativeFormat , parent)
{
    jid_indx0 = "";
    pass_indx0 = "";
    dflt_indx0 = "";

    alm = new AccountsListModel(this);
    this->initListOfAccounts();
}

/*************************** (generic settings) **************************/
bool Settings::gBool(QString group, QString key) {
    beginGroup( group );
    QVariant ret = value( key, false );
    endGroup();
    return ret.toBool();
}
void Settings::sBool(const bool isSet, QString group, QString key) {
    beginGroup( group );
    setValue( key, QVariant(isSet) );
    endGroup();
}
int Settings::gInt(QString group, QString key) {
    beginGroup( group );
    QVariant ret = value( key, false );
    endGroup();
    return ret.toInt();
}
void Settings::sInt(const int isSet, QString group, QString key) {
    beginGroup( group );
    setValue( key, QVariant(isSet) );
    endGroup();
}
QString Settings::gStr(QString group, QString key) {
    beginGroup( group );
    QVariant ret = value( key, false );
    endGroup();
    return ret.toString();
}
void Settings::sStr(const QString isSet, QString group, QString key) {
    beginGroup( group );
    setValue( key, QVariant(isSet) );
    endGroup();
}

/******** ACCOUNT RELATED SHIT *******/
QStringList Settings::getListAccounts()
{
    beginGroup( "accounts" );
    QVariant ret = value( "accounts", QStringList() );
    endGroup();
    return ret.toStringList();
}
/*-------------------*/
void Settings::addAccount( const QString &acc )
{
    beginGroup( "accounts" );
    QVariant retList = value( "accounts", QStringList() );
    QStringList sl = retList.toStringList();
    if( sl.indexOf(acc) < 0 ) {
        sl.append(acc);
        setValue( "accounts", QVariant(sl) );
        emit accountAdded(sl.indexOf(acc));
    }
    endGroup();
}
void Settings::removeAccount( const QString &acc )
{
    beginGroup( "accounts" );
    QVariant retList = value( "accounts", QStringList() );
    QStringList sl = retList.toStringList();
    int index = sl.indexOf(acc);
    if( index >= 0 ) {
        sl.removeOne(acc);
        setValue( "accounts", QVariant(sl) );
    }
    endGroup();
}

void Settings::initListOfAccounts() {
    QStringList listAcc = getListAccounts();

    qDebug() << "initializing list";

    alm->takeRows( 0, alm->count() );

    qDebug() << "rows removed";
    qDebug() << listAcc;
    qDebug() << alm->count();

    QStringList::const_iterator itr = listAcc.begin();
    int i = 0;
    while ( itr != listAcc.end() ) {
        QString jid = *itr;
        itr++;

        qDebug() << "initializing" << jid;

        QString passwd = gStr(jid,"passwd");
        bool isDefault = gBool(jid,"is_default");

        QString host = gStr(jid,"host");
        int port = gInt(jid,"port");
        QString resource = gStr(jid,"resource");
        bool isManuallyHostPort = gBool(jid,"use_host_port");

        AccountsItemModel *aim = new AccountsItemModel( jid, passwd, resource, host, port, isDefault, isManuallyHostPort, this );
        qDebug() << "account item model done";
        alm->append(aim);
        qDebug() << "account item model appended";

        if(i==0) { jid_indx0 = jid; pass_indx0 = passwd; dflt_indx0 = isDefault; }
        qDebug() << "now it should crash";
        i++;
    }

    qDebug() << "...and it's done";

    emit accountsListChanged();
}


void Settings::setAccount(
        QString _jid,
        QString _pass,
        bool _isDflt,
        QString _resource,
        QString _host,
        QString _port,
        bool manuallyHostPort) //Q_INVOKABLE
{
    addAccount( _jid );
    sStr(_pass,_jid,"passwd");
    sBool(_isDflt,_jid,"is_default");

    sStr(_resource,_jid,"resource");
    sStr(_host,_jid,"host");
    sBool(manuallyHostPort,_jid,"use_host_port");

    bool ok = false;
    int p = _port.toInt(&ok);
    if( ok ) { sInt( p, _jid, "port" ); }

    beginGroup( "accounts" ); // get the ID and notify xmppconnectivity because its fun, thats why
    QStringList sl = value( "accounts", QStringList() ).toStringList();

    //this->initListOfAccounts();

    emit accountEdited(sl.indexOf(_jid));
    endGroup();
}

AccountsItemModel* Settings::getAccount(int index) {
    return (AccountsItemModel*)alm->getElementByID(index);
}

QString Settings::getJidByIndex(int index) {
    return getListAccounts().at(index);
}
