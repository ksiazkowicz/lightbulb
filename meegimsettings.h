#ifndef MEEGIMSETTINGS_H
#define MEEGIMSETTINGS_H

#include "mysettings.h"
#include "accountsitemmodel.h"
#include "accountslistmodel.h"

#include "QXmppConfiguration.h"

#include <QtDeclarative>

class MeegIMSettings : public MySettings
{
    Q_OBJECT
    Q_DISABLE_COPY( MeegIMSettings )

    Q_PROPERTY( AccountsListModel* accounts READ getAccounts NOTIFY accountsListChanged )
    AccountsListModel *alm;

    QString jid_indx0;
    QString pass_indx0;
    bool dflt_indx0;

public:
    explicit MeegIMSettings();

    QXmppConfiguration getDefaultAccount();

    Q_INVOKABLE void initListOfAccounts();
    Q_INVOKABLE void setAccount( QString _jid, QString _pass, bool isDflt, QString _resource = "", QString _host = "", QString _port = "", bool manuallyHostPort = false );
    Q_INVOKABLE void removeAccount( QString _jid );
    Q_INVOKABLE void saveStatusText( QString statusText );

    Q_INVOKABLE QString getJid_indx0() { return jid_indx0; }
    Q_INVOKABLE QString getPass_indx0() { return pass_indx0; }
    Q_INVOKABLE bool getDef_indx0() { return dflt_indx0; }

    Q_INVOKABLE bool accIsDefault( int index );
    Q_INVOKABLE QString accGetJid( int index );
    Q_INVOKABLE QString accGetPassword( int index );
    Q_INVOKABLE QString accGetResource( int index );
    Q_INVOKABLE QString accGetHost( int index );
    Q_INVOKABLE int accGetPort( int index );
    Q_INVOKABLE bool accIsManuallyHostPort( int index );

    Q_INVOKABLE bool gBool(QString group, QString key);
    Q_INVOKABLE void sBool(const bool isSet, QString group, QString key);
    Q_INVOKABLE int gInt(QString group, QString key);
    Q_INVOKABLE void sInt(const int isSet, QString group, QString key);
    Q_INVOKABLE QString gStr(QString group, QString key);
    Q_INVOKABLE void sStr(const QString isSet, QString group, QString key);

    AccountsListModel* getAccounts() const { return alm; }

signals:
    void accountsListChanged();
};

QML_DECLARE_TYPE( MeegIMSettings )

#endif // MEEGIMSETTINGS_H
