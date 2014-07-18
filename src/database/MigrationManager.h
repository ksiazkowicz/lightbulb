#ifndef MIGRATIONMANAGER_H
#define MIGRATIONMANAGER_H

#include <QObject>
#include <QSettings>
#include <QStringList>

class MigrationManager : public QObject
{
  Q_OBJECT
public:
  explicit MigrationManager(QObject *parent = 0);
  
signals:
  
public slots:
  Q_INVOKABLE bool isMigrationPossible();
  Q_INVOKABLE QVariant getData(QString group, QString key);
  Q_INVOKABLE QStringList getListOfAccounts();

private:
  QSettings *oldSettings;  
};

#endif // MIGRATIONMANAGER_H
