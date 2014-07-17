#ifndef MIGRATIONMANAGER_H
#define MIGRATIONMANAGER_H

#include <QObject>
#include <QSettings>

class MigrationManager : public QObject
{
  Q_OBJECT
public:
  explicit MigrationManager(QObject *parent = 0);
  
signals:
  
public slots:
  Q_INVOKABLE bool isMigrationPossible();
  Q_INVOKABLE QVariant getData(QString group, QString key);

private:
  QSettings *oldSettings;  
};

#endif // MIGRATIONMANAGER_H
