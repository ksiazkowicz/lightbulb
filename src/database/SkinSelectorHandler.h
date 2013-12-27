#ifndef SKINSELECTORHANDLER_H
#define SKINSELECTORHANDLER_H

#include <QObject>
#include <QStringList>
#include <QSettings>

class SkinSelectorHandler : public QObject
{
    Q_OBJECT

    Q_PROPERTY( QStringList skins READ getAvailableSkins NOTIFY availableSkinsChanged )
public:
    explicit SkinSelectorHandler(QObject *parent = 0);
    
signals:
    void availableSkinsChanged();

public slots:
    QStringList getAvailableSkins() { return availableSkins; }
    void loadAvailableSkins();
    Q_INVOKABLE QString getSkinName(QString path);

private:
    QStringList availableSkins;
    QSettings* skinVerifier;
    
};

#endif // SKINSELECTORHANDLER_H
