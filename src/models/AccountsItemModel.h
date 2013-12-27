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
                                  QObject *parent ) :
                   ListItem(parent),
                   m_jid(_accountJid),
                   m_passwd(_accountPasswd),
                   m_resource(_accountResource),
                   m_host(_accountHost),
                   m_port(_accountPort),
                   m_default(_accountDefault),
                   m_manual_host_port(_manuallyHostPort)
               {
               }

      virtual QString id() const { return m_jid; }

      void setJid(QString &_accountJid)
      {
        if(m_jid != _accountJid) {
          m_jid = _accountJid;
          emit dataChanged();
        }
      }

      void setPasswd(QString &_accountPasswd)
      {
        if(m_passwd != _accountPasswd) {
          m_passwd = _accountPasswd;
          emit dataChanged();
        }
      }

      void setDefault(bool &_accountDefault)
      {
        if(m_default != _accountDefault) {
          m_default = _accountDefault;
          emit dataChanged();
        }
      }

      void setHost(QString &_accountHost)
      {
        if(m_host!= _accountHost) {
          m_host = _accountHost;
          emit dataChanged();
        }
      }

      void setPort(int _accountPort)
      {
        if(m_port!= _accountPort) {
          m_port = _accountPort;
          emit dataChanged();
        }
      }

      void setManuallyHostPort(bool _manuallyHostPort)
      {
        if(m_manual_host_port != _manuallyHostPort) {
          m_manual_host_port = _manuallyHostPort;
          emit dataChanged();
        }
      }

      virtual QHash<int, QByteArray> roleNames() const
      {
        QHash<int, QByteArray> names;
        names[accJid] = "accJid";
        names[accPasswd] = "accPasswd";
        names[accDefault] = "accDefault";
        names[accResource] = "accResource";
        names[accHost] = "accHost";
        names[accPort] = "accPort";
        names[accManualHostPort] = "accManualHostPort";
        return names;
      }

      virtual QVariant data(int role) const
      {
        switch(role) {
        case accJid:
          return jid();
        case accPasswd:
          return passwd();
        case accDefault:
          return isDefault();
        case accResource:
          return resource();
        case accHost:
          return host();
        case accPort:
          return port();
        case accManualHostPort:
          return isManuallyHostPort();
        default:
          return QVariant();
        }
      }

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
