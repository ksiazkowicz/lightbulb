#ifndef BROKENSOCKET_H
#define BROKENSOCKET_H

#include <QSslSocket>
#include <QHostAddress>
#include <QObject>
#include <QTcpSocket>
#include <QAbstractSocket>

class BrokenSocket : public QObject
{
  Q_OBJECT
public:
    BrokenSocket();
    QTcpSocket *suckit;

public slots:
    void connected();
        void disconnected();
        void bytesWritten(qint64 bytes);
        void readyRead();

};

#endif // BROKENSOCKET_H
