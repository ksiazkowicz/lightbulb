/********************************************************************

src/cache/MyCache.h
-- stores VCards and avatars in cache

Copyright (c) 2013 Anatoliy Kozlov, Maciej Janiszewski

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

#ifndef MYCACHE_H
#define MYCACHE_H

#include <QObject>
#include <QDir>

#include "storevcard.h"

class MyCache : public StoreVCard
{
    Q_OBJECT
    QString cachePath;

public:
    explicit MyCache(QString path, QObject *parent = 0);

    bool createHomeDir() const;

    inline bool existsCacheJid(const QString &jid) const {
        QDir jD( cachePath + QDir::separator() + jid );
        return jD.exists();
    }
    bool addCacheJid( const QString &jid );

    bool setAvatarCache(QString jid, const QByteArray &avatar);
    QString getAvatarCache(const QString &jid) const;

    QString getCachePath() const { return cachePath; }
    
signals:
    void avatarUpdated(QString bareJid);
    
public slots:
    
};

#endif // MYCACHE_H
