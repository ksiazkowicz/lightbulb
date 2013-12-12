#ifndef MYSETTINGS_H
#define MYSETTINGS_H

#include <QSettings>

class MySettings : public QSettings
{
    Q_OBJECT

    QString group_notifications;
    QString group_gui;
    QString group_behavior;
    QString group_xmpp;
    QString group_accounts;

    QString key_jid;
    QString key_passwd;
    QString key_showGroup;
    QString key_lastPresence;
    QString key_accounts;
    QString key_resource;
    QString key_status_text;
    QString key_status;
    QString key_default;
    QString key_host;
    QString key_port;
    QString key_useHostPort;

protected:
    void addAccount(  const QString&  acc );
    QStringList getListAccounts();
    void remAccount( const QString& acc );

public:
    explicit MySettings(QObject *parent = 0);

    static QString appName;
    static QString pathMeegIMHome;
    static QString pathMeegIMCache;

    static QString fileConfig;

    QString getPasswd( const QString &jid );
    void setPasswd( const QString &jid, const QString& passwd );

    QString getResource( const QString &jid );
    void setResource( const QString &jid, const QString& resource );

    QString getHost( const QString &jid );
    void setHost( const QString &jid, const QString& host );

    int getPort( const QString &jid );
    void setPort( const QString &jid, const int port );

    bool isAccDefault( const QString &jid );
    void setAccDefault( const QString &jid, const bool& def );
    
    QString getStatus();
    void setStatus( const QString& status );

    QString getStatusText();
    void setStatusText( const QString& status_text );

    bool isHostPortManually( const QString &jid );
    void setHostPortManually( const QString &jid, const bool& def );

    bool getBool(QString group, QString key);
    void setBool(const bool isSet, QString group, QString key);
    int getInt(QString group, QString key);
    void setInt(const int isSet, QString group, QString key);
    QString getString(QString group, QString key);
    void setString(const QString isSet, QString group, QString key);


signals:
    
public slots:
    
};

#endif // MYSETTINGS_H
