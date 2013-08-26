#ifndef DISCREETPOPUP_H
#define DISCREETPOPUP_H

#include <QObject>
#include <akndiscreetpopup.h>

class discreetpopup : public QObject
{
    Q_OBJECT
public:
    explicit discreetpopup(QObject *parent = 0);
    Q_INVOKABLE void showPopup(QString title,QString message);
    
signals:
    
public slots:
    
};

#endif // DISCREETPOPUP_H
