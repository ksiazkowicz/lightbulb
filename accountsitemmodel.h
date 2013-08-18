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
        accIcon,
        accDefault,
        accType,
        accResource,
        accHost,
        accPort,
        accManualHostPort
      };

public:
      AccountsItemModel(QObject *parent = 0): ListItem(parent) {}
      explicit AccountsItemModel( const QString &_accountJid,
                                  const QString &_accountPasswd,
                                  const QString &_accountIcon,
                                  const QString &_accountType,
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
      void setIcon( QString &_accountIcon );
      void setDefault( bool &_accountDefault );
      void setType( QString &_accountType );
      void setResource( QString &_accountResource );
      void setHost( QString &_accountHost );
      void setPort( int _accountPort );
      void setManuallyHostPort( bool _manuallyHostPort );

      inline QString jid() const { return m_jid; }
      inline QString passwd() const { return m_passwd; }
      inline QString icon() const { return m_icon; }
      inline bool isDefault() const { return m_default; }
      inline QString type() const { return m_type; }
      inline QString resource() const { return m_resource; }
      inline QString host() const { return m_host; }
      inline int port() const { return m_port; }
      inline bool isManuallyHostPort() const { return m_manual_host_port; }


    private:
      QString m_jid;
      QString m_passwd;
      QString m_icon;
      QString m_type;
      QString m_resource;
      QString m_host;
      int m_port;
      bool m_default;
      bool m_manual_host_port;

};

#endif // ACCOUNTSITEMMODEL_H
