#ifndef QAVKONHELPER_H
#define QAVKONHELPER_H

#include <QObject>
#include <akndiscreetpopup.h>
#include <aknglobalnote.h>
#include <e32base.h>
#include <hwrmlight.h>

class QAvkonHelper : public QObject
{
    Q_OBJECT
public:
    explicit QAvkonHelper(QObject *parent = 0);
    Q_INVOKABLE void showPopup(QString title,QString message);
    Q_INVOKABLE void lockDevice();
    Q_INVOKABLE void unlockDevice();
    Q_INVOKABLE void screenBlink();
    Q_INVOKABLE void notificationBlink();
    Q_INVOKABLE void displayGlobalNote(QString message);

private:
    TInt iNoteId;
    CAknGlobalNote* iNote;
    CHWRMLight* light; // Light control
    CHWRMLight* notifyLight;
    void ShowNoteL(const TDesC& aMessage);
    
signals:
    
public slots:
    
};

#endif // QAVKONHELPER_H
