#include "accountsitemmodel.h"


AccountsItemModel::AccountsItemModel( const QString &_accountJid,
                                      const QString &_accountPasswd,
                                      const QString &_accountIcon,
                                      const QString &_accountType,
                                      const QString &_accountResource,
                                      const QString &_accountHost,
                                      const int _accountPort,
                                      const bool _accountDefault,
                                      const bool _manuallyHostPort,
                                      QObject *parent ) :
    ListItem(parent),
    m_jid(_accountJid),
    m_passwd(_accountPasswd),
    m_icon(_accountIcon),
    m_type(_accountType),
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

void AccountsItemModel::setIcon(QString &_accountIcon)
{
  if(m_icon != _accountIcon) {
    m_icon = _accountIcon;
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

void AccountsItemModel::setType(QString &_accountType)
{
  if(m_type!= _accountType) {
    m_type = _accountType;
    emit dataChanged();
  }
}

void AccountsItemModel::setResource(QString &_accountResource)
{
  if(m_type!= _accountResource) {
    m_type = _accountResource;
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
  names[accIcon] = "accIcon";
  names[accDefault] = "accDefault";
  names[accType] = "accType";
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
  case accIcon:
    return icon();
  case accDefault:
    return isDefault();
  case accType:
    return type();
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
