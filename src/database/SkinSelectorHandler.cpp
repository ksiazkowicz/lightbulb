#include "SkinSelectorHandler.h"
#include <QSettings>
#include <QDir>
#include <QDebug>
#include <QStringList>

SkinSelectorHandler::SkinSelectorHandler(QObject *parent) :
    QObject(parent)
{
    loadAvailableSkins();
}

void SkinSelectorHandler::loadAvailableSkins() {
    QStringList skins;
    QDir dir("C:\\data\\.config\\Lightbulb\\widgets");

    if (dir.exists("C:\\data\\.config\\Lightbulb\\widgets")) {
        Q_FOREACH(QFileInfo info, dir.entryInfoList(QDir::NoDotAndDotDot | QDir::System | QDir::Hidden  | QDir::AllDirs | QDir::Files, QDir::DirsFirst)) {
            if (info.isDir() && dir.exists(info.absoluteFilePath() + "/settings.txt")) {
                QString skinName = getSkinName(info.baseName());
                if (skinName != "-!-404-!-") {
                    qDebug() << "SkinSelectorHandler::loadAvailableSkins(): found skin " << skinName;
                    skins.append(info.baseName());
                }
            }
        }
    }
    qDebug() << "SkinSelectorHandler::loadAvailableSkins(): available - "<< skins;
    availableSkins = skins;
}

QString SkinSelectorHandler::getSkinName(QString path) {
    skinVerifier = new QSettings("C:\\data\\.config\\Lightbulb\\widgets\\" + path + "\\settings.txt",QSettings::NativeFormat);
    skinVerifier->beginGroup("Details");
    QString skinName = skinVerifier->value("name","-!-404-!-").toString();
    skinVerifier->endGroup();
    return skinName;
}
