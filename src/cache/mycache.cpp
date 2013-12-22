#include "mycache.h"
#include <QBuffer>
#include <QImageReader>
#include <QFile>
#include <QDebug>

MyCache::MyCache(QObject *parent) : StoreVCard(parent)
{
    pathMeegIMHome = QDir::homePath() + "\\" + ".config" + "\\" + "Lightbulb";
    pathMeegIMCache = pathMeegIMHome + "\\" + QString("cache");

    this->setCachePath( pathMeegIMCache );
}

bool MyCache::createHomeDir() const
{
    bool retValue = false;

    QDir hD( pathMeegIMHome );
    if( hD.exists() == false ) {
        if( ! hD.mkdir(pathMeegIMHome) ) {
            qCritical() << "Error: Cannot create home directory !";
            return retValue;
        }
    }

    QDir cD( pathMeegIMCache );
    if( cD.exists() == false ) {
        if( ! cD.mkdir(pathMeegIMCache) ) {
            qCritical() << "Error: Cannot create cache directory !";
            return retValue;
        }
    }

    retValue = true;

    return retValue;
}


bool MyCache::addCacheJid(const QString &jid)
{
    if( this->existsCacheJid(jid) ) {
        return true;
    }

    QString jidCache = pathMeegIMCache + "\\" + jid;
    QDir jD( jidCache );
    if( ! jD.mkdir(jidCache) ) {
        qCritical() << "Error: Cannot create cache directory: " << jid;
        return false;
    }

    return true;
}

bool MyCache::setAvatarCache(const QString &jid, const QByteArray &avatar) const
{
    if( !(this->existsCacheJid(jid)) ) return false;

    QBuffer buffer;
    buffer.setData( avatar );
    buffer.open(QIODevice::ReadOnly);
    QImageReader imageReader(&buffer);
    QImage avatarImage = imageReader.read();

    QString avatarJid = pathMeegIMCache + "\\" + jid + "\\" + QString("avatar.png");

    if( avatarImage.save(avatarJid) ) {
        return true;
    }

    return false;
}

QString MyCache::getAvatarCache(const QString &jid) const
{
    QString avatarJid = pathMeegIMCache + "\\" + jid + "\\" + QString("avatar.png");
    if( QFile::exists(avatarJid) ) return avatarJid;

    return "qrc:/avatar";
}

QString MyCache::getContactCache(const QString &jid) const
{
    QString contactJid = pathMeegIMHome + "\\" + QString("archive") + "\\" + jid;
    return contactJid;
}

