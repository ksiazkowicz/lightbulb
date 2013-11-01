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
  Q_INVOKABLE void sendMessage(QString message)
  {
      write(message.toLatin1());
  }
  Q_INVOKABLE void registerApp()
  {
      QString message = "registerApp ";
      message += uid + ";" + name + ";" + description + ";" + developer;
      sendMessage(message);
  }

  Q_INVOKABLE void unregisterApp()
  {
      QString message = "unregisterApp ";
      message += uid;
      sendMessage(message);
  }

  Q_INVOKABLE void registerEvent(QString evName)
  {
    QString message = "registerEvent ";
    message += uid + ";" + evName;
    sendMessage(message);
  }

  Q_INVOKABLE void unregisterEvent(QString evName)
  {
    QString message = "unregisterEvent ";
    message += uid + ";" + evName;
    sendMessage(message);
  }

  Q_INVOKABLE void setEventProperty(QString evName, QString property, QString value)
  {
      QString message = "setEventProperty ";
      message += uid + ";" + evName + ";" + property + ";" + value;
      sendMessage(message);
  }

  Q_INVOKABLE void triggerEvent(QString evName, QString evMsg, QString evDate)
  {
      QString message = "triggerEvent ";
      message += uid + ";" + evName + ";" + evMsg + ";" + evDate;
      sendMessage(message);
  }

  Q_INVOKABLE void markEventRead(QString evName)
  {
      QString message = "markEventRead ";
      message += uid + ";" + evName;
      sendMessage(message);
  }

  Q_INVOKABLE void changeAppData(QString propName, QString property, QString value)
  {
      QString message = "changeAppData ";
      message += uid + ";" + propName + ";" + property + ";" + value;
      sendMessage(message);
  }

private:
    QTimer* timer;
};

#endif // SYMBIOSISAPICLIENT_H
