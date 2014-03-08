/********************************************************************

src/avkon/SymbiosisAPIClient.h
-- interface to Symbiosis notification server

Copyright (c) 2013 Maciej Janiszewski

This file is part of Lightbulb.

Lightbulb is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

*********************************************************************/

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
