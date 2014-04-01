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
#include "src/models/AccountsListModel.h"
#include <QDebug>

QString Settings::appName = "Lightbulb";
QString Settings::confFolder = QDir::homePath() + QDir::separator() + ".config" + QDir::separator() + appName;
QString Settings::cacheFolder = confFolder + QDir::separator() + QString("cache");
QString Settings::confFile = confFolder + QDir::separator() + Settings::appName + ".conf";

Settings::Settings(QObject *parent) : QSettings(Settings::confFile, QSettings::NativeFormat , parent) {
    alm = new AccountsListModel(this);
    this->initListOfAccounts();
    qDebug() << getAppDrive();
}

QString Settings::getAppDrive() {
  return QDir::currentPath().left(3);
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
    QStringList acc = value( "accounts", QStringList() ).toStringList();
    endGroup();
    return acc;
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
    }
    endGroup();
    emit accountAdded(acc);
}
void Settings::removeAccount( const QString &acc )
{
    // remove account from config file
    beginGroup(acc);
    remove("");
    endGroup();

    // remove account from list
    beginGroup( "accounts" );
    QVariant retList = value( "accounts", QStringList() );
    QStringList sl = retList.toStringList();
    int index = sl.indexOf(acc);
    if( index >= 0 ) {
        sl.removeOne(acc);
        setValue( "accounts", QVariant(sl) );
    }
    endGroup();

    int indxItem = -1;
    AccountsItemModel *itemExists = (AccountsItemModel*)alm->find( acc, indxItem );
    if( itemExists ) if( indxItem >= 0 ) alm->takeRow( indxItem );
    emit accountsListChanged();
    emit accountRemoved(acc);
}

void Settings::initListOfAccounts() {
    qDebug() << "Settings::initListOfAccounts(): called";
    beginGroup( "accounts" );
    QStringList listAcc = value("accounts",QStringList()).toStringList();
    endGroup();

    qDebug() << "Settings::initListOfAccounts(): read list from settings." << listAcc;

    qDebug() << "Settings::initListOfAccounts(): removing accounts from list model";
    for (int i=0; i<alm->rowCount(); i++)
        alm->removeRow(i);

    QStringList::const_iterator itr = listAcc.begin();
    while ( itr != listAcc.end() ) {
        QString grid = *itr;
        itr++;

        qDebug() << "Settings::initListOfAccounts(): found element" << grid;

        QString name = gStr(grid,"name");
        QString icon = gStr(grid,"icon");
        QString jid = gStr(grid,"jid");
        QString passwd = gStr(grid,"passwd");

        QString host = gStr(grid,"host");
        int port = gInt(grid,"port");
        QString resource = gStr(grid,"resource");
        bool isManuallyHostPort = gBool(grid,"use_host_port");

        AccountsItemModel *aim = new AccountsItemModel( grid, name, icon, jid, passwd, resource, host, port, isManuallyHostPort, this );
        alm->append(aim);
        qDebug() << "Settings::initListOfAccounts(): element appended";
    }
    emit accountsListChanged();
    qDebug() << "Settings::initListOfAccounts(): accountsListChanged() emited";
}

void Settings::setAccount(
        QString _grid, QString _name, QString _icon,
        QString _jid,
        QString _pass,
        bool _connectOnStart,
        QString _resource,
        QString _host,
        QString _port,
        bool manuallyHostPort) //Q_INVOKABLE
{
    bool isNew = false;
    beginGroup( "accounts" );

    QVariant retList = value( "accounts", QStringList() );
    QStringList sl = retList.toStringList();
    if( sl.indexOf(_grid) < 0 )
        isNew = true;
    endGroup();

    sStr(_name,_grid,"name");
    sStr(_icon,_grid,"icon");
    sStr(_jid,_grid,"jid");
    sStr(_pass,_grid,"passwd");

    sStr(_resource,_grid,"resource");
    sStr(_host,_grid,"host");
    sBool(manuallyHostPort,_grid,"use_host_port");
    sBool(_connectOnStart,_grid,"connectOnStart");

    bool ok = false;
    int p = _port.toInt(&ok);
    if( ok ) { sInt( p, _jid, "port" ); }

    if (isNew) {
        AccountsItemModel* account = new AccountsItemModel();
        account->setGRID(_grid);
        account->setHost(_host);
        account->setIcon(_icon);
        account->setJid(_jid);
        account->setPasswd(_pass);
        account->setManuallyHostPort(manuallyHostPort);
        account->setPort(p);
        alm->append(account);
        qDebug() << "element appended but this piece of shit is retarded";
        emit accountsListChanged();
        addAccount(_grid);
    } else {
        initListOfAccounts();
        emit accountEdited(_grid);
    }
}

AccountsItemModel* Settings::getAccount(int index) {
  if (alm->getElementByID(index) != 0)
    return (AccountsItemModel*)alm->getElementByID(index);
}

int Settings::getAccountId(QString grid) {
    return getListAccounts().indexOf(grid);
}

QString Settings::getJidByIndex(int index) {
    return getListAccounts().at(index);
}
