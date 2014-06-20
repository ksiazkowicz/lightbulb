#ifndef NETWORKMANAGER_H
#define NETWORKMANAGER_H

#include <QObject>
#include <qnetworkinterface.h>

// QtMobility
#include <qnetworkconfigmanager.h>
#include <qnetworksession.h>

class NetworkManager : public QObject
{
  Q_OBJECT

  Q_PROPERTY(bool connectionStatus READ getConnectionStatus NOTIFY connectionChanged)

public:
  explicit NetworkManager(QObject *parent = 0);
  ~NetworkManager();
  
public slots:
    // Open network connection
    Q_INVOKABLE void openConnection();

private:
    // Session of the connection
    QNetworkSession *m_session;

    bool getConnectionStatus();

signals:
    void connectionOpened(QString iap);
    void connectionFailed(QString error);
    void connectionChanged();

private slots:
    void connectionStatusChanged();
  
};

#endif // NETWORKMANAGER_H
