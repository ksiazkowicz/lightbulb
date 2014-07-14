#ifndef NETWORKMANAGER_H
#define NETWORKMANAGER_H

#include <QObject>
#include <qnetworkinterface.h>

// QtMobility
#include <qnetworkconfigmanager.h>
#include <qnetworksession.h>

#include "NetworkCfgListModel.h"
#include "NetworkCfgItemModel.h"

class NetworkManager : public QObject
{
  Q_OBJECT

  Q_PROPERTY(bool connectionStatus READ getConnectionStatus NOTIFY connectionChanged)
  Q_PROPERTY(NetworkCfgListModel* configurations READ getConfigurations NOTIFY configurationsChanged)
  Q_PROPERTY(int currentIAP READ getCurrentIAP WRITE setCurrentIAP NOTIFY currentIAPChanged)

public:
  explicit NetworkManager(QObject *parent = 0);
  ~NetworkManager();
  
public slots:
    // Open network connection
    Q_INVOKABLE void openConnection();

    Q_INVOKABLE QString getIAPNameByID(int _iapId);

    NetworkCfgListModel* getConfigurations() { return m_configurations; }

private:
    // Session of the connection
    QNetworkSession *m_session;
    NetworkCfgListModel *m_configurations;
    QNetworkConfigurationManager *m_configurationsManager;
    int currentIAP;

    bool getConnectionStatus();

signals:
    void connectionOpened(QString iap);
    void connectionFailed(QString error);
    void connectionChanged();
    void configurationsChanged();
    void currentIAPChanged();

private slots:
    void connectionStatusChanged();

    void deleteConfig(int id);
    void appendConfig(QString name, QString bearer, int id);

    inline int getCurrentIAP()   { return currentIAP; }
    void setCurrentIAP(int _IAP) { currentIAP = _IAP; emit currentIAPChanged(); }
  
};

#endif // NETWORKMANAGER_H
