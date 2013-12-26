#ifndef LIGHTBULBHSWIDGET_H
#define LIGHTBULBHSWIDGET_H

#include <QObject>
#include <QImage>
#include "qhswidget.h"

class LightbulbHSWidget : public QObject
{
    Q_OBJECT
public:
    explicit LightbulbHSWidget(QObject *parent = 0);
    Q_INVOKABLE void registerWidget();
    Q_INVOKABLE void publishWidget();
    Q_INVOKABLE void removeWidget();
    Q_INVOKABLE void updateWidget( QString icon ) { }
    Q_INVOKABLE void postWidget( QString nRow1, int r1Presence, QString nRow2, int r2Presence, QString nRow3, int r3Presence, QString nRow4, int r4Presence, int unreadCount, int presence );
    Q_INVOKABLE void postNotification( QString message );
    void bringToFront();
signals:
    void HomescreenUpdated();
public slots:
    void handleEvent(QHSWidget*, QHSEvent aEvent );
    void handleItemEvent(QHSWidget*, QString aTemplateItemName,
                             QHSItemEvent aEvent);
private:
    QHSWidget* widget;
};

#endif // QSAMPLEWIDGET_H
