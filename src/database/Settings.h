/********************************************************************

src/database/Settings.h
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

#ifndef MYSETTINGS_H
#define MYSETTINGS_H

#include <QSettings>
#include <QDir>
#include <QDebug>
#include <QUuid>
#include "src/models/AccountsListModel.h"

class Settings : public QSettings
{
    Q_OBJECT
    Q_DISABLE_COPY( Settings )

    Q_PROPERTY( AccountsListModel* accounts READ getAccounts NOTIFY accountsListChanged )
    AccountsListModel *alm;

protected:
    void addAccount(  const QString&  acc );
    QStringList getListAccounts();

public:
    explicit Settings(QObject *parent = 0);

    static QString appName;
    static QString confFolder;
    static QString cacheFolder;
    static QString confFile;

    Q_INVOKABLE QVariant get(QString group, QString key);
    Q_INVOKABLE void     set(QVariant data, QString group, QString key);

    Q_INVOKABLE void removeAccount( const QString& acc );

    Q_INVOKABLE QString generateGRID() { return QUuid::createUuid().toString(); }

    Q_INVOKABLE void initListOfAccounts();
    Q_INVOKABLE QString getJidByIndex( int index );
    Q_INVOKABLE void setAccount( QString _grid, QString _name, QString _icon, QString _jid, QString _pass, bool _connectOnStart, QString _resource = "", QString _host = "", QString _port = "", bool manuallyHostPort = false );

    AccountsListModel* getAccounts() const { return alm; }

    AccountsItemModel* getAccount(int index);
    int getAccountId(QString grid);
    int accountsCount() { return alm->count(); }

    QString getAppDrive();

    Q_INVOKABLE bool gBool(QString group, QString key) { return get(group,key).toBool(); }
    Q_INVOKABLE void sBool(const bool isSet, QString group, QString key) { set(QVariant(isSet),group,key); }
    Q_INVOKABLE int gInt(QString group, QString key) { return get(group,key).toInt(); }
    Q_INVOKABLE void sInt(const int isSet, QString group, QString key) { set(QVariant(isSet),group,key); }
    Q_INVOKABLE QString gStr(QString group, QString key) { return get(group,key).toString(); }
    Q_INVOKABLE void sStr(const QString isSet, QString group, QString key) { set(QVariant(isSet),group,key); }

signals:
    void accountsListChanged();
    void accountAdded(QString accId);
    void accountRemoved(QString accId);
    void accountEdited(QString accId);
public slots:
    
};

#endif // MYSETTINGS_H
