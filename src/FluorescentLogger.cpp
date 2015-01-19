// simple custom log handler based on:
// http://www.qt-coding.com/2013/08/06/tip-of-the-day-redirect-qdebug-to-a-file/
#include "FluorescentLogger.h"
#include <QDebug>
#include <QDir>

FluorescentLogger::FluorescentLogger(QObject *parent) :
  QObject(parent)
{
}

void FluorescentLogger::start() {
#ifdef Q_OS_BLACKBERRY
  debugLog = new QFile("/sdcard/fluorescentlog.txt");
#else
  debugLog = new QFile(QDir::homePath() + QDir::separator() + "LightbulbLog.txt");
#endif
  debugLog->open(QIODevice::WriteOnly);
}

void FluorescentLogger::initLog() {
  // initialize textstream
  QTextStream logWriter(debugLog);

  // begin log
  logWriter << "---------------" << endl;
  logWriter << "Fluorescent " << QString(VERSION).mid(1,5) << ". Built on: " << QString(BUILDDATE).mid(1,10) << endl;
  logWriter << "This program comes with ABSOLUTELY NO WARRANTY. This is free software, and you are welcome to redistribute it under certain conditions. See GPL v3 license for details." << endl;
  logWriter << "Log started on: " << QDateTime::currentDateTime().toString("dd/MM/yyyy hh:mm:ss") << endl;
  logWriter << "----" << endl;
}

void FluorescentLogger::debug(QtMsgType type, const char *msg)
{
   QString date = QDateTime::currentDateTime().toString("dd/MM/yyyy hh:mm:ss");
   QString text = QString("[%1] ").arg(date);

   switch (type)  {
      case QtDebugMsg:
         text += QString("{Debug} \t\t %1").arg(msg);
         break;
      case QtWarningMsg:
         text += QString("{Warning} \t %1").arg(msg);
         break;
      case QtCriticalMsg:
         text += QString("{Critical} \t %1").arg(msg);
         break;
      case QtFatalMsg:
         text += QString("{Fatal} \t\t %1").arg(msg);
         abort();
         break;
   }

   // initialize textstream
   QTextStream logWriter(debugLog);

   // write to log file
   logWriter << text << endl;
}
