#ifndef QMLAPPLICATIONVIEWER_H
#define QMLAPPLICATIONVIEWER_H

#include <QtDeclarative/QDeclarativeView>

class QmlApplicationViewer : public QDeclarativeView
{
    Q_OBJECT

public:
    explicit QmlApplicationViewer(QWidget *parent = 0);
    virtual ~QmlApplicationViewer();

    static QmlApplicationViewer *create();


private:
    class QmlApplicationViewerPrivate *d;
};


#endif // QMLAPPLICATIONVIEWER_H
