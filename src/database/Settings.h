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
#include "AccountsListModel.h"

class Settings : public QSettings
{
    Q_OBJECT
    Q_DISABLE_COPY( Settings )

    Q_PROPERTY( AccountsListModel* accounts READ getAccounts NOTIFY accountsListChanged )
    AccountsListModel *alm;

    QString jid_indx0;
    QString pass_indx0;
    bool dflt_indx0;

protected:
    void addAccount(  const QString&  acc );
    QStringList getListAccounts();

public:
    explicit Settings(QObject *parent = 0);

    static QString appName;
    static QString confFolder;
    static QString cacheFolder;
    static QString confFile;

    Q_INVOKABLE bool gBool(QString group, QString key);
    Q_INVOKABLE void sBool(const bool isSet, QString group, QString key);
    Q_INVOKABLE int gInt(QString group, QString key);
    Q_INVOKABLE void sInt(const int isSet, QString group, QString key);
    Q_INVOKABLE QString gStr(QString group, QString key);
    Q_INVOKABLE void sStr(const QString isSet, QString group, QString key);

    Q_INVOKABLE void removeAccount( const QString& acc );

    Q_INVOKABLE void initListOfAccounts();
    Q_INVOKABLE QString getJidByIndex( int index );
    Q_INVOKABLE void setAccount( QString _jid, QString _pass, bool isDflt, QString _resource = "", QString _host = "", QString _port = "", bool manuallyHostPort = false );

    Q_INVOKABLE QString getJid_indx0() { return jid_indx0; }
    Q_INVOKABLE QString getPass_indx0() { return pass_indx0; }
    Q_INVOKABLE bool getDef_indx0() { return dflt_indx0; }


    AccountsListModel* getAccounts() const { return alm; }


signals:
    void accountsListChanged();
public slots:
    
};

#endif // MYSETTINGS_H
