/********************************************************************

src/AccountsItemModel.h
-- implements item model for account

Copyright (c) 2012 Anatoliy Kozlov

This file is part of Lightbulb and was derived from MeegIM.

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

#ifndef ACCOUNTSITEMMODEL_H
#define ACCOUNTSITEMMODEL_H

#include "listmodel.h"

class AccountsItemModel : public ListItem
{
    Q_OBJECT

public:
    enum Roles {
        accJid = Qt::UserRole+1,
        accPasswd,
        accDefault,
        accResource,
        accHost,
        accPort,
        accManualHostPort
      };

public:
      AccountsItemModel(QObject *parent = 0): ListItem(parent) {}
      explicit AccountsItemModel( const QString &_accountJid,
                                  const QString &_accountPasswd,
                                  const QString &_accountResource,
                                  const QString &_accountHost,
                                  const int _accountPort,
                                  const bool _accountDefault,
                                  const bool _manuallyHostPort,
                                  QObject *parent = 0 );

      virtual QVariant data(int role) const;
      virtual QHash<int, QByteArray> roleNames() const;

      virtual QString id() const { return m_jid; }

      void setJid( QString &_accountJid );
      void setPasswd( QString &_accountPasswd );

      void setDefault( bool &_accountDefault );
      void setHost( QString &_accountHost );
      void setPort( int _accountPort );
      void setManuallyHostPort( bool _manuallyHostPort );

      inline QString jid() const { return m_jid; }
      inline QString passwd() const { return m_passwd; }
      inline bool isDefault() const { return m_default; }
      inline QString resource() const { return m_resource; }
      inline QString host() const { return m_host; }
      inline int port() const { return m_port; }
      inline bool isManuallyHostPort() const { return m_manual_host_port; }


    private:
      QString m_jid;
      QString m_passwd;
      QString m_resource;
      QString m_host;
      int m_port;
      bool m_default;
      bool m_manual_host_port;

};

#endif // ACCOUNTSITEMMODEL_H
