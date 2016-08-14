#include "NetworkManager.h"
//#include <QDebug>

NetworkManager::NetworkManager(QObject *parent) :
  QObject(parent) {
  //qDebug() << "NetworkManager::NetworkManager(): initialized";

  m_configurationsManager = new QNetworkConfigurationManager();
  m_configurations = new NetworkCfgListModel();
  appendConfig("Use default","Default",-1);

  QList<QNetworkConfiguration> confList = m_configurationsManager->allConfigurations();
  qDebug() << confList.count();
  for (int i=0; i<confList.count();i++) {
      QNetworkConfiguration conf = confList.at(i);
      if (conf.bearerTypeName() != "") {
        qDebug() << "NetworkManager::NetworkManager(): found config at" << i << "name:" << conf.name() << "typeName" << conf.bearerTypeName();
        appendConfig(conf.name(),conf.bearerTypeName(),i);
      }
  }
}

NetworkManager::~NetworkManager() {
    // Remeber to close connection
    if (m_session && m_session->isOpen()) {
        m_session->close();  
        //qDebug() << "NetworkManager::~NetworkManager(): Connection closed on destruction.";
      }
}

void NetworkManager::openConnection() {
    // Set Internet Access Point
    QNetworkConfigurationManager manager;

    const bool canStartIAP = (manager.capabilities()
        & QNetworkConfigurationManager::CanStartAndStopInterfaces);

    QNetworkConfiguration cfg;

    if (currentIAP < 0)
      cfg = manager.defaultConfiguration();
    else
      cfg = manager.allConfigurations().at(currentIAP);

    qDebug() << "NetworkManager::NetworkManager(): attempting to use access point. name:" << cfg.name() << "typeName" << cfg.bearerTypeName();

    if (!cfg.isValid() || !canStartIAP) {
        // Available Access Points not found
        qDebug() << "NetworkManager::openConnection(): No access points found.";

        emit connectionFailed("CFG_INVALID_NO_ACCESSPOINTS");
        emit connectionChanged();
        return;
    }

    m_session = new QNetworkSession(cfg);
    connect(m_session,SIGNAL(stateChanged(QNetworkSession::State)),SLOT(connectionStatusChanged()));

    // Open session
    m_session->open();
}

bool NetworkManager::getConnectionStatus() {
  if (m_session != NULL) {
    return m_session->isOpen();
  } else return false;
}

void NetworkManager::connectionStatusChanged() {
  if (m_session && m_session->isOpen()) {
      QNetworkInterface iff = m_session->interface();
      emit connectionOpened(iff.humanReadableName());
      qDebug().nospace() << "NetworkManager::connectionStatusChanged(): Connection opened on interface " << qPrintable(iff.humanReadableName()) << " using access point " << qPrintable(m_session->configuration().name()) << ".";
    } else {
      if (!m_session) {
        qDebug().nospace() <<"NetworkManager::connectionStatusChanged(): Connection failed. QNetworkSession not initialized.";
        emit connectionFailed("NOT_INITIALIZED");
      } else {
          qDebug().nospace() <<"NetworkManager::connectionStatusChanged(): Connection failed. " << qPrintable(m_session->errorString());
          emit connectionFailed(m_session->errorString());
        }
    }
  emit connectionChanged();
}

void NetworkManager::appendConfig(QString name, QString bearer, int id) {
  NetworkCfgItemModel *item = new NetworkCfgItemModel(name,bearer,id);
  m_configurations->append(item);

  emit configurationsChanged();
}

void NetworkManager::deleteConfig(int id) {
  int rowNumber;
  NetworkCfgItemModel *itemExists = (NetworkCfgItemModel*)m_configurations->find(QString::number(id),rowNumber);
  if (itemExists != NULL)
    m_configurations->takeRow(rowNumber);

  emit configurationsChanged();
}

QString NetworkManager::getIAPNameByID(int _iapId) {
  NetworkCfgItemModel *itemExists = (NetworkCfgItemModel*)m_configurations->find(QString::number(_iapId));
  if (itemExists != NULL)
    return itemExists->getCfgName();
  else return "(unknown)";
}
