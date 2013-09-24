#include "SettingsDBWrapper.h"

#include "MyXmppClient.h"

SettingsDBWrapper::SettingsDBWrapper() : MySettings(0)
{

    jid_indx0 = "";
    pass_indx0 = "";
    dflt_indx0 = "";

    alm = new AccountsListModel( this );
    this->initListOfAccounts();
}

QXmppConfiguration SettingsDBWrapper::getDefaultAccount()
{
    QXmppConfiguration xmppConfig;

    //QString passwd("");

    QStringList listAcc = getListAccounts();
    QStringList::const_iterator itr = listAcc.begin();
    while ( itr != listAcc.end() )
    {
        QString jid = *itr;
        itr++;

        QString passwd = getPasswd( jid );
        QString host = getHost( jid );
        int port = getPort( jid );
        QString resource = getResource( jid );

        bool isDefault = isAccDefault( jid );
        if( isDefault ) {
            //MyXmppClient::myPass = passwd;
            //MyXmppClient::myJid = jid;

            xmppConfig.setJid( jid );
            xmppConfig.setPassword( passwd );

            if( !resource.isEmpty() ) {
                xmppConfig.setResource( resource );
            }

            if( !host.isEmpty() ) {
                xmppConfig.setHost( host );
            }

            if( port > 0 ) {
                xmppConfig.setPort( port );
            }

            return xmppConfig;
        }
    }
    return xmppConfig;
}


void SettingsDBWrapper::initListOfAccounts() //Q_INVOKABLE
{
    QStringList listAcc = getListAccounts();

    alm->removeRows( 0, alm->count() );

    QStringList::const_iterator itr = listAcc.begin();
    int i = 0;
    while ( itr != listAcc.end() )
    {
        QString jid = *itr;
        itr++;

        QString passwd = getPasswd( jid );
        QString icon = "qrc:/qml/images/accXMPP.png";

        bool isDefault = isAccDefault( jid );

        QString type = "xmpp";
        QString host = getHost( jid );
        int port = getPort( jid );
        QString resource = getResource( jid );
        bool isManuallyHostPort = isHostPortManually( jid );

        AccountsItemModel *aim = new AccountsItemModel( jid, passwd, icon, type, resource, host, port, isDefault, isManuallyHostPort, this );
        alm->append(aim);

        if(i==0) {
            jid_indx0 = jid;
            pass_indx0 = passwd;
            dflt_indx0 = isDefault;
        }
        i++;
    }

    emit accountsListChanged();
}


void SettingsDBWrapper::setAccount(
        QString _jid,
        QString _pass,
        bool _isDflt,
        QString _resource,
        QString _host,
        QString _port,
        bool manuallyHostPort) //Q_INVOKABLE
{
    this->addAccount( _jid );
    this->setPasswd( _jid, _pass );
    this->setAccDefault( _jid, _isDflt );

    this->setResource( _jid, _resource );
    this->setHost( _jid, _host );
    this->setHostPortManually( _jid, manuallyHostPort );

    bool ok = false;
    int p = _port.toInt(&ok);
    if( ok ) {
        this->setPort( _jid, p );
    }

    this->getDefaultAccount();
}


void SettingsDBWrapper::removeAccount( QString _jid ) //Q_INVOKABLE
{
    this->remAccount( _jid );
    this->remove( _jid );
}


bool SettingsDBWrapper::accIsDefault(int index)
{
    bool val = false;
    if( (index>=0) and (index<alm->count()) ) {
        AccountsItemModel *aim = reinterpret_cast<AccountsItemModel*>( alm->value( index ) );
        val = aim->isDefault();
    }
    return val;
}

QString SettingsDBWrapper::accGetJid(int index)
{
    QString val = "";
    if( (index>=0) and (index<alm->count()) ) {
        AccountsItemModel *aim = reinterpret_cast<AccountsItemModel*>( alm->value( index ) );
        val = aim->jid();
    }
    return val;
}

QString SettingsDBWrapper::accGetPassword(int index)
{
    QString val = "";
    if( (index>=0) and (index<alm->count()) ) {
        AccountsItemModel *aim = reinterpret_cast<AccountsItemModel*>( alm->value( index ) );
        val = aim->passwd();
    }
    return val;
}

QString SettingsDBWrapper::accGetResource(int index)
{
    QString val = "";
    if( (index>=0) and (index<alm->count()) ) {
        AccountsItemModel *aim = reinterpret_cast<AccountsItemModel*>( alm->value( index ) );
        val = aim->resource();
    }
    return val;
}

QString SettingsDBWrapper::accGetHost(int index)
{
    QString val = "";
    if( (index>=0) and (index<alm->count()) ) {
        AccountsItemModel *aim = reinterpret_cast<AccountsItemModel*>( alm->value( index ) );
        val = aim->host();
    }
    return val;
}

int SettingsDBWrapper::accGetPort(int index)
{
    int val = 0;
    if( (index>=0) and (index<alm->count()) ) {
        AccountsItemModel *aim = reinterpret_cast<AccountsItemModel*>( alm->value( index ) );
        val = aim->port();
    }
    return val;
}

bool SettingsDBWrapper::accIsManuallyHostPort(int index)
{
    bool val = false;
    if( (index>=0) and (index<alm->count()) ) {
        AccountsItemModel *aim = reinterpret_cast<AccountsItemModel*>( alm->value( index ) );
        val = aim->isManuallyHostPort();
    }
    return val;
}

void SettingsDBWrapper::saveStatusText(QString statusText)
{
    if( statusText != this->getStatusText() )
    {
        this->setStatusText( statusText );
    }
}

bool SettingsDBWrapper::gBool(QString group, QString key) // Q_INVOKABLE
{
    return this->getBool(group,key);
}
void SettingsDBWrapper::sBool(const bool isSet, QString group, QString key) // Q_INVOKABLE
{
    this->setBool(isSet,group,key);
}


int SettingsDBWrapper::gInt(QString group, QString key) // Q_INVOKABLE
{
    return this->getInt(group,key);
}
void SettingsDBWrapper::sInt(const int isSet, QString group, QString key) // Q_INVOKABLE
{
    this->setInt(isSet,group,key);
}


QString SettingsDBWrapper::gStr(QString group, QString key) // Q_INVOKABLE
{
    return this->getString(group,key);
}
void SettingsDBWrapper::sStr(const QString isSet, QString group, QString key) // Q_INVOKABLE
{
    this->setString(isSet,group,key);
}
