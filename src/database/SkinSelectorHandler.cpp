#include "SkinSelectorHandler.h"
#include <QSettings>
#include <QDir>
#include <QDebug>
#include <QStringList>

SkinSelectorHandler::SkinSelectorHandler(QObject *parent) :
    QObject(parent)
{
}

QStringList SkinSelectorHandler::getAvailableSkins() {
    QStringList skins;
    QDir dir("C:\\data\\.config\\Lightbulb\\widgets");

    if (dir.exists("C:\\data\\.config\\Lightbulb\\widgets")) {
        Q_FOREACH(QFileInfo info, dir.entryInfoList(QDir::NoDotAndDotDot | QDir::System | QDir::Hidden  | QDir::AllDirs | QDir::Files, QDir::DirsFirst)) {
            if (info.isDir() && dir.exists(info.absoluteFilePath() + "/settings.txt")) {
                skins.append(info.baseName());
            }
        }
    }
    qDebug() << skins;
    return skins;
}
