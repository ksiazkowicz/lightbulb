#ifndef QHSWIDGET_H
#define QHSWIDGET_H

#include <QObject>
#include <QString>
#include <QLibrary>

const QString DLLName("HSWidgetPlugin0xE22AC278.dll");




/**
 * Defines the events that may take place for a homescreen widget.
 */
enum QHSEvent
{
    EUnknown    = 0, ///< Unknown event: Means that event has not been defined.
    EActivate   = 1, ///< Activation event: Means that widget has been added to HS as content.
    EDeactivate = 2, ///< Deactivation event: Means that widget has been removed frm.
    ESuspend    = 3, ///< Suspension event: Means that HS reading widget data is suspended.
    EResume     = 4  ///< Resume event. Means that HS reading widget data is resumed.
};

/**
 * Defines the events that may take place for a homescreen widget item.
 */
enum QHSItemEvent
{
    EUnknownItemEvent = 0, ///< Unknown event: Means that event has note been defined.
    ESelect           = 1  ///< Selection event: Means that the widget item has been selected.
};




class QHSWidget : public QObject
{
    Q_OBJECT
protected:
    explicit QHSWidget(QString templateType, QString widgetName, QString widgetId, QObject *parent = 0): QObject(parent)
    {
    }
public:
    virtual ~QHSWidget(){}


    virtual void RegisterWidget() = 0;
    virtual void PublishWidget() = 0;
    virtual void SetItem(QString item, QString value) = 0;
    virtual void SetItem(QString item, int value) = 0;
    virtual void RemoveWidget() = 0;
    virtual QString WidgetName() = 0;

signals:
    void handleEvent(QHSWidget* sender, QHSEvent event);
    void handleItemEvent(QHSWidget* sender, QString WidgetItemName, QHSItemEvent event);


public:
    typedef QHSWidget* (*createHSWidget)(QString, QString, QString, QObject*);
    static QHSWidget* create(QString templateType, QString widgetName, QString widgetId, QObject *parent = 0)
    {
        QLibrary lib(DLLName);

        if (lib.load())
        {

            createHSWidget func = (createHSWidget) lib.resolve("5");

            if (func)
            {
                QHSWidget* widget = func(templateType,widgetName,widgetId,parent);
                if (widget)
                {
                    lib.setParent(widget); // implementation unloads its QLibrary children in destructor
                    return widget;
                }

            }
            lib.unload();
        }

        return 0;
    }
};





#endif // QHSWIDGET_H
