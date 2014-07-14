#include "MigrationManager.h"
#include "Settings.h"
#include <QFile.h>
#include <QDir.h>
#include <QDebug>

MigrationManager::MigrationManager(QObject *parent) :
  QObject(parent)
{
}

bool MigrationManager::isMigrationPossible() {
  qDebug() << "MigrationManager::isMigrationPossible() called. Checking if migration is possible.";
  qDebug() << QDir::homePath() + QDir::separator() + ".config" + QDir::separator()+ "Lightbulb" + QDir::separator() + "Lightbulb.conf";
  QFile file;
  bool result = file.exists(QDir::homePath() + QDir::separator() + ".config" + QDir::separator()+"Lightbulb"+QDir::separator() + "Lightbulb.conf");
  qDebug() << "MigrationManager::isMigrationPossible() returned" << result;
  return result;
}

bool MigrationManager::migrateSettings() {
  qDebug() << "MigrationManager::migrateSettings() called. Attempting to migrate settings.";
  QDir fileMgr;
  bool result;
  qDebug() << "MigrationManager::migrateSettings(): Attempting to remove new config.";
  result = fileMgr.remove(QDir::currentPath() + QDir::separator() + "Settings.conf");
  if (result) {
      result = fileMgr.rename(QDir::homePath() + QDir::separator() + ".config" + QDir::separator()+QDir::separator() + "Lightbulb.conf",QDir::currentPath() + QDir::separator() + "Settings.conf");
    }
  qDebug() << "MigrationManager::migrateSettings() returned" << result;
  return result;
}

bool MigrationManager::clearOldCache() {
  qDebug() << "MigrationManager::clearOldCache() called. Attempting to migrate settings.";
}
