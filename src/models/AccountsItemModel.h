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
        accGRID = Qt::UserRole+1, //Globally Recognizable ID (sounds awesome :D)
        accName,
        accIcon,
        accJid,
        accPasswd,
        accResource,
        accHost,
        accPort,
        accManualHostPort
      };

public:
      AccountsItemModel(QObject *parent = 0): ListItem(parent) {}
      explicit AccountsItemModel( const QString &_accountGRID,
                                  const QString &_accountName,
                                  const QString &_accountIcon,
                                  const QString &_accountJid,
                                  const QString &_accountPasswd,
                                  const QString &_accountResource,
                                  const QString &_accountHost,
                                  const int _accountPort,
                                  const bool _manuallyHostPort,
                                  QObject *parent ) :
                   ListItem(parent),
                   m_GRID(_accountGRID),
                   m_name(_accountName),
                   m_icon(_accountIcon),
                   m_jid(_accountJid),
                   m_passwd(_accountPasswd),
                   m_resource(_accountResource),
                   m_host(_accountHost),
                   m_port(_accountPort),
                   m_manual_host_port(_manuallyHostPort)
               {
               }

      virtual QString id() const { return m_GRID; }

      void setGRID(QString &_accountGRID)
      {
        if(m_GRID != _accountGRID) {
          m_GRID = _accountGRID;
          emit dataChanged();
        }
      }

      void setName(QString &_accountName)
      {
        if(m_name != _accountName) {
          m_name = _accountName;
          emit dataChanged();
        }
      }

      void setIcon(QString &_accountIcon)
      {
        if(m_icon != _accountIcon) {
          m_icon = _accountIcon;
          emit dataChanged();
        }
      }

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
        names[accGRID] = "accGRID";
        names[accName] = "accName";
        names[accIcon] = "accIcon";
        names[accJid] = "accJid";
        names[accPasswd] = "accPasswd";
        names[accResource] = "accResource";
        names[accHost] = "accHost";
        names[accPort] = "accPort";
        names[accManualHostPort] = "accManualHostPort";
        return names;
      }

      virtual QVariant data(int role) const
      {
        switch(role) {
        case accGRID:
          return grid();
        case accName:
          return name();
        case accIcon:
          return icon();
        case accJid:
          return jid();
        case accPasswd:
          return passwd();
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

      inline QString grid() const { return m_GRID; }
      inline QString name() const { return m_name; }
      inline QString icon() const { return m_icon; }
      inline QString jid() const { return m_jid; }
      inline QString passwd() const { return m_passwd; }
      inline QString resource() const { return m_resource; }
      inline QString host() const { return m_host; }
      inline int port() const { return m_port; }
      inline bool isManuallyHostPort() const { return m_manual_host_port; }

    private:
      QString m_GRID;
      QString m_name;
      QString m_icon;
      QString m_jid;
      QString m_passwd;
      QString m_resource;
      QString m_host;
      int m_port;
      bool m_manual_host_port;

};

#endif // ACCOUNTSITEMMODEL_H
