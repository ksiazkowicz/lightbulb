/********************************************************************

src/AccountsItemModel.cpp
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

#include "accountsitemmodel.h"


AccountsItemModel::AccountsItemModel( const QString &_accountJid,
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

void AccountsItemModel::setJid(QString &_accountJid)
{
  if(m_jid != _accountJid) {
    m_jid = _accountJid;
    emit dataChanged();
  }
}

void AccountsItemModel::setPasswd(QString &_accountPasswd)
{
  if(m_passwd != _accountPasswd) {
    m_passwd = _accountPasswd;
    emit dataChanged();
  }
}

void AccountsItemModel::setDefault(bool &_accountDefault)
{
  if(m_default != _accountDefault) {
    m_default = _accountDefault;
    emit dataChanged();
  }
}

void AccountsItemModel::setHost(QString &_accountHost)
{
  if(m_host!= _accountHost) {
    m_host = _accountHost;
    emit dataChanged();
  }
}

void AccountsItemModel::setPort(int _accountPort)
{
  if(m_port!= _accountPort) {
    m_port = _accountPort;
    emit dataChanged();
  }
}

void AccountsItemModel::setManuallyHostPort(bool _manuallyHostPort)
{
  if(m_manual_host_port != _manuallyHostPort) {
    m_manual_host_port = _manuallyHostPort;
    emit dataChanged();
  }
}




QHash<int, QByteArray> AccountsItemModel::roleNames() const
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

QVariant AccountsItemModel::data(int role) const
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
