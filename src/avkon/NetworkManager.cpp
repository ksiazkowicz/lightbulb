#include "NetworkManager.h"
#include <QDebug>

NetworkManager::NetworkManager(QObject *parent) :
  QObject(parent) {
  qDebug() << "NetworkManager::NetworkManager(): initialized";
}

NetworkManager::~NetworkManager() {
    // Remeber to close connection
    if (m_session && m_session->isOpen()) {
        m_session->close();  
        qDebug() << "NetworkManager::~NetworkManager(): Connection closed on destruction.";
      }
}

void NetworkManager::openConnection() {
    // Set Internet Access Point
    QNetworkConfigurationManager manager;

    const bool canStartIAP = (manager.capabilities()
        & QNetworkConfigurationManager::CanStartAndStopInterfaces);

    // Is there default access point, use it
    QNetworkConfiguration cfg = manager.defaultConfiguration();
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
  if (m_session)
    return m_session->isOpen();
  else return false;
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
