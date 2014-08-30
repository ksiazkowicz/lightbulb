/********************************************************************

src/UpdateManager.h
-- autoupdater written using QNetworkAccessManager, hosted on GitHub
-- Pages.

Copyright (c) 2014 Maciej Janiszewski

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

#ifndef UPDATEMANAGER_H
#define UPDATEMANAGER_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QDateTime>
#include <QStringList>
#include <QUrl>
#include <QDebug>
#include <QThread>

class UpdateManager : public QObject
{
  Q_OBJECT

  Q_PROPERTY(bool isUpdateAvailable READ getUpdateAvailability NOTIFY updateFound)
  Q_PROPERTY(QString latestVersion READ getLatestVersion NOTIFY updateFound)
  Q_PROPERTY(QString updateUrl READ getUpdateUrl NOTIFY updateFound)

public:
  explicit UpdateManager(QObject *parent = 0);

  Q_INVOKABLE void checkForUpdate();
  
signals:
  void updateFound(QString version, QString date);
  void versionUpToDate();
  void errorOccured(QString errorString);

private slots:
  void dataReceived(QNetworkReply *reply);

private:
  QNetworkAccessManager *httpStuff;
  bool updateAvailable;
  bool getUpdateAvailability() { return updateAvailable; }

  QDateTime getUpdateDate();
  QString getLatestVersion();
  QString getUpdateUrl();

  QString replyData;

  void compareVersions();
};

#endif // UPDATEMANAGER_H
