#include "GraphAPIExtensions.h"

GraphAPIExtensions::GraphAPIExtensions(MyCache *cache, QObject *parent) :
  QObject(parent)
{
  fbProfilePicDownloader = new QNetworkAccessManager;
  connect(fbProfilePicDownloader,SIGNAL(finished(QNetworkReply*)),this,SLOT(pushFacebookPic(QNetworkReply*)));
  currentSessions = 0;
  cacheManager = cache;
}

void GraphAPIExtensions::pushNextCacheURL() {
  if (currentSessions < 3 && urlQueue.count() > 0) {
      currentSessions++;
      fbProfilePicDownloader->get(QNetworkRequest(QUrl(urlQueue.first())));
      urlQueue.takeFirst();
    }
}

void GraphAPIExtensions::downloadProfilePic(QString bareJid) {
  // try to download profile pic
  QString picUrl = "http://graph.facebook.com/";

  QString profileId = bareJid.split("@").at(0);

  // if it's your profile, not someone else, don't omit the first char
  if (profileId.left(1) == "-")
    profileId = profileId.right(profileId.length()-1);

  picUrl += profileId;
  picUrl += "/picture?width=128&height=128";
  urlQueue.append(picUrl);
  pushNextCacheURL();
}


void GraphAPIExtensions::pushFacebookPic(QNetworkReply *pReply) {
  if (currentSessions > 0)
    currentSessions--;

  if (pReply->error() == QNetworkReply::NoError) {
      // no error occured, check if reply is a redirection
      QVariant possibleRedirectUrl = pReply->attribute(QNetworkRequest::RedirectionTargetAttribute);

      if (!possibleRedirectUrl.toString().isEmpty() && !profilePicCache.values().contains(pReply->url().toString())) {
          // redirect found, append another url
          urlQueue.append(possibleRedirectUrl.toString());
          profilePicCache.insert(pReply->url().toString(),possibleRedirectUrl.toString());
        } else {
          // generate jid back from profile cache
          QString key = profilePicCache.key(pReply->url().toString());

          QByteArray data = pReply->readAll();

          // check if is a number and if is, append -
          bool isNumber;
          key.mid(26,1).toInt(&isNumber);
          QString bareJid = isNumber ? "-" : "";

          bareJid += key.mid(26,key.length()-55) + "@chat.facebook.com";

          // update avatar cache
          if (!cacheManager->setAvatarCache(bareJid, data)) {
            emit errorOccured("something failed miserably while saving avatar");
            }

          // remove element from profile pic url list
          profilePicCache.remove(key);
        }
    } else {
      // throw an error
      emit errorOccured("error occured while downloading " + pReply->url().toString());
    }

  pushNextCacheURL();
}
