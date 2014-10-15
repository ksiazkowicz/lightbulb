#ifndef GRAPHAPIEXTENSIONS_H
#define GRAPHAPIEXTENSIONS_H

#include <QObject>
#include <QMap>
#include <QList>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include "../cache/mycache.h";
#include <QNetworkReply>

class GraphAPIExtensions : public QObject
{
  Q_OBJECT
public:
  explicit GraphAPIExtensions(MyCache* cache, QObject *parent = 0);
  void downloadProfilePic(QString bareJid);
  
signals:
  void avatarDownloaded(QString bareJid);
  void errorOccured(QString error);

private slots:
  void pushFacebookPic(QNetworkReply* pReply);

private:
  int currentSessions;
  QMap<QString,QString> profilePicCache;
  QList<QString> urlQueue;
  MyCache* cacheManager;

  QNetworkAccessManager* fbProfilePicDownloader;

  void pushNextCacheURL();
};

#endif // GRAPHAPIEXTENSIONS_H
