#ifndef SKINSELECTORHANDLER_H
#define SKINSELECTORHANDLER_H

#include <QObject>
#include <QStringList>

class SkinSelectorHandler : public QObject
{
    Q_OBJECT

    Q_PROPERTY( QStringList skins READ getAvailableSkins )
public:
    explicit SkinSelectorHandler(QObject *parent = 0);
    
signals:
    
public slots:
    QStringList getAvailableSkins();
    
};

#endif // SKINSELECTORHANDLER_H
