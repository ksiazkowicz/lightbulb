#ifndef MIGRATIONMANAGER_H
#define MIGRATIONMANAGER_H

#include <QObject>

class MigrationManager : public QObject
{
  Q_OBJECT
public:
  explicit MigrationManager(QObject *parent = 0);
  
signals:
  
public slots:
  Q_INVOKABLE bool isMigrationPossible();
  bool migrateSettings();
  bool clearOldCache();
  
};

#endif // MIGRATIONMANAGER_H
