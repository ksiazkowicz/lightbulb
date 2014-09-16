#include "MigrationManager.h"
#include "Settings.h"
#include <QFile>
#include <QDir>
#include <QDebug>
#include <QSettings>
#include <QVariant>
#include <QStringList>

const QString path = QDir::homePath() + QDir::separator() + ".config" + QDir::separator()+ "Lightbulb" + QDir::separator() + "Lightbulb.conf";

MigrationManager::MigrationManager(QObject *parent) :
  QObject(parent)
{
}

bool MigrationManager::isMigrationPossible() {
  qDebug() << "MigrationManager::isMigrationPossible() called. Checking if migration is possible.";
  QFile file;
  bool result = file.exists(path);
  qDebug() << "MigrationManager::isMigrationPossible() returned" << result;
  return result;
}

QVariant MigrationManager::getData(QString group, QString key) {
  if (oldSettings == NULL)
      oldSettings = new QSettings(path,QSettings::NativeFormat);

  oldSettings->beginGroup( group );
  QVariant ret = oldSettings->value( key, false );
  oldSettings->endGroup();
  return ret;
}

QStringList MigrationManager::getListOfAccounts() {
    return getData("accounts","accounts").toStringList();
}
