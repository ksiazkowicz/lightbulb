#include "lightbulbhswidget.h"
#include <QDebug>
#include <apgtask.h>
#include <eikenv.h>

const QString sw_type = "threerows";
const QString sw_name = "Lightbulb";
const QString sw_id = "0xE22AC278"; //can be any unique string

const QString sw_image ("image1");
const QString row1 ("text1");
const QString row2 ("text2");
const QString row3 ("text3");


LightbulbHSWidget::LightbulbHSWidget(QObject *parent) :
    QObject(parent)
{

    /*widget = QHSWidget::create(sw_type, sw_name, sw_id, this);
    connect(widget, SIGNAL(handleEvent(QHSWidget*, QHSEvent)), this, SLOT(handleEvent(QHSWidget*, QHSEvent) ));
    connect(widget, SIGNAL(handleItemEvent(QHSWidget*, QString, QHSItemEvent)), this, SLOT(handleItemEvent(QHSWidget*, QString, QHSItemEvent)));*/
}

void LightbulbHSWidget::registerWidget()
{
   // widget->RegisterWidget();

}

void LightbulbHSWidget::publishWidget()
{
    try {
        //widget->PublishWidget();
    }
    catch (...) {
    }
}

void LightbulbHSWidget::removeWidget()
{
   // widget->RemoveWidget();
}

void LightbulbHSWidget::handleEvent( QHSWidget* /*aSender*/, QHSEvent aEvent )
{
    switch(aEvent)
                    {
                    case EActivate:
                    case EResume:
                            {
                            //publishWidget();
                            }
                            break;
                    default:
                            break;
                    }

}

void LightbulbHSWidget::handleItemEvent( QHSWidget* /*aSender*/, QString aTemplateItemName,
    QHSItemEvent aEvent)
{
    if(aTemplateItemName.compare(sw_image)==0)
                    {
                    //publishWidget();
                    }
            else
                    {
                        this->bringToFront();
                    }
}


void LightbulbHSWidget::updateWidget( QString icon )
{
    //widget->SetItem(sw_image, icon);
    publishWidget();
}

void LightbulbHSWidget::postWidget( QString nRow1, QString nRow2, QString nRow3 )
{
    //widget->SetItem(row1, nRow1);
    //widget->SetItem(row2, nRow2);
    //widget->SetItem(row3, nRow3);
    publishWidget();
}

void LightbulbHSWidget::bringToFront()
{
    TApaTask task( CEikonEnv::Static()->WsSession() );
    task.SetWgId(CEikonEnv::Static()->RootWin().Identifier());
    task.BringToForeground();
}

void LightbulbHSWidget::postNotification(QString message) {
    /*QMessageBox msgBox;
    msgBox.setText(message);
    msgBox.exec();*/
}
