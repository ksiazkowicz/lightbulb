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

QString Settings::cacheFolder;
QString Settings::confFile = QDir::currentPath() + QDir::separator() + "Settings.conf";

Settings::Settings(QObject *parent) : QSettings(Settings::confFile, QSettings::NativeFormat , parent) {
    alm = new AccountsListModel(this);
    this->initListOfAccounts();

    cacheFolder = QDir::currentPath() + QDir::separator() + QString("cache");

    if (get("paths","cache") != "")
      cacheFolder = get("paths","cache").toString();
}

/*************************** (generic settings) **************************/
QVariant Settings::get(QString group, QString key) {
    beginGroup( group );
    QVariant ret = value( key, false );
    endGroup();
    return ret;
}
void     Settings::set(QVariant data, QString group, QString key) {
    beginGroup(group);
    setValue(key,data);
    endGroup();
}

/******** ACCOUNT RELATED SHIT *******/
QStringList Settings::getListAccounts() {
    beginGroup( "accounts" );
    QStringList acc = value( "accounts", QStringList() ).toStringList();
    endGroup();
    return acc;
}
/*-------------------*/
void Settings::addAccount( const QString &acc ) {
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
void Settings::removeAccount( const QString &acc ) {
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
    beginGroup( "accounts" );
    QStringList listAcc = value("accounts",QStringList()).toStringList();
    endGroup();

    for (int i=0; i<alm->rowCount(); i++)
        alm->removeRow(i);

    QStringList::const_iterator itr = listAcc.begin();
    while ( itr != listAcc.end() ) {
        QString grid = *itr;
        itr++;

        QString name = get(grid,"name").toString();
        QString icon = get(grid,"icon").toString();
        QString jid = get(grid,"jid").toString();
        QString passwd = get(grid,"passwd").toString();

        QString host = get(grid,"host").toString();
        int port = get(grid,"port").toInt();
        QString resource = get(grid,"resource").toString();
        bool isManuallyHostPort = get(grid,"use_host_port").toBool();

        AccountsItemModel *aim = new AccountsItemModel( grid, name, icon, jid, passwd, resource, host, port, isManuallyHostPort, this );
        alm->append(aim);
    }
    emit accountsListChanged();
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

    set(QVariant(_name),_grid,"name");
    set(QVariant(_icon),_grid,"icon");
    set(QVariant(_jid),_grid,"jid");
    set(QVariant(_pass),_grid,"passwd");

    set(QVariant(_resource),_grid,"resource");
    set(QVariant(_host),_grid,"host");
    set(QVariant(manuallyHostPort),_grid,"use_host_port");
    set(QVariant(_connectOnStart),_grid,"connectOnStart");

    bool ok = false;
    int p = _port.toInt(&ok);
    if( ok ) { set( QVariant(p), _jid, "port" ); }

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
