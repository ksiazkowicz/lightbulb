#include "brokensocket.h"
#include <QSslSocket>

BrokenSocket::BrokenSocket()
{
    suckit = new QTcpSocket();
    connect(suckit, SIGNAL(connected()), this, SLOT(connected()));
    connect(suckit, SIGNAL(disconnected()),this, SLOT(disconnected()));
    connect(suckit, SIGNAL(bytesWritten(qint64)),this, SLOT(bytesWritten(qint64)));
    connect(suckit, SIGNAL(readyRead()),this, SLOT(readyRead()));

    qDebug() << "connecting...";

    suckit->connectToHost("google.com", 80);

    if(!suckit->waitForConnected(5000))
    {
        qDebug() << "Error: " << suckit->errorString();
    }
    qDebug() << "ssl" << QSslSocket::supportsSsl();
}

void BrokenSocket::connected() {
    qDebug() << "connected to" << suckit->peerAddress() << suckit->peerPort();
    qDebug() << "connected...";

    // Hey server, tell me about you.
    suckit->write("HEAD / HTTP/1.0\r\n\r\n\r\n\r\n");
}

void BrokenSocket::disconnected()
{
    qDebug() << "disconnected...";
}

void BrokenSocket::bytesWritten(qint64 bytes)
{
    qDebug() << bytes << " bytes written...";
}

void BrokenSocket::readyRead()
{
    qDebug() << "reading...";

    // read the data from the socket
    qDebug() << suckit->readAll();
}
