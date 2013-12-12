#ifndef SYMBIOSISAPICLIENT_H
#define SYMBIOSISAPICLIENT_H

#include <QtNetwork>
#include <QtCore>

//constants (set your own parameters here)
const QString uid("0xE22AC278");
const QString name("Lightbulb");
const QString description("Instant Messenger for Symbian");
const QString developer("Maciej Janiszewski (n1958 Apps)");

class SymbiosisAPIClient:public QTcpSocket
{
  Q_OBJECT
public:
  SymbiosisAPIClient()
  {
    timer = new QTimer(this);

    //Register app after 5 seconds
    timer->singleShot(5000,this,SLOT(registerApp()));

    connectToHost("127.0.0.1",1958);
  }

public slots:
  void sendMessage(QString message)
  {
      write(message.toLatin1());
  }
  void registerApp()
  {
      QString message = "registerApp ";
      message += uid + ";" + name + ";" + description + ";" + developer;
      sendMessage(message);
  }
private:
    QTimer* timer;
};

#endif // SYMBIOSISAPICLIENT_H
