#ifndef MYCACHE_H
#define MYCACHE_H

#include <QObject>
#include <QDir>

#include "storevcard.h"

class MyCache : public StoreVCard
{
    Q_OBJECT

    QString pathMeegIMHome;
    QString pathMeegIMCache;

public:
    explicit MyCache(QObject *parent = 0);

    bool createHomeDir() const;

    inline bool existsCacheJid(const QString &jid) const {
        QDir jD( pathMeegIMCache + QDir::separator() + jid );
        return jD.exists();
    }
    bool addCacheJid( const QString &jid );

    bool setAvatarCache( const QString &jid, const QByteArray &avatar ) const;
    QString getAvatarCache( const QString &jid ) const;

    QString getMeegIMCachePath() const { return pathMeegIMCache; }
    QString getMeegIMHomePath() const { return pathMeegIMHome; }
    
signals:
    
public slots:
    
};

#endif // MYCACHE_H
