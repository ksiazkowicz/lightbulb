#ifndef FLUORESCENTLOGGER_H
#define FLUORESCENTLOGGER_H

#include <QObject>
#include <QFile>
#include <QTextStream>
#include <QDateTime>

class FluorescentLogger : public QObject
{
  Q_OBJECT

  QFile* debugLog;

public:
  explicit FluorescentLogger(QObject *parent = 0);

  void debug(QtMsgType type, const char *msg);
  void initLog();
  
signals:
  
public slots:
  
};

#endif // FLUORESCENTLOGGER_H
