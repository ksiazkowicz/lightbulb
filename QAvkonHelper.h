#ifndef QAVKONHELPER_H
#define QAVKONHELPER_H

#include <QObject>
#include <akndiscreetpopup.h>
#include <aknglobalnote.h>
#include <CAknFileSelectionDialog.h>
#include <e32base.h>
#include <hwrmlight.h>
#include <QUrl>

class QAvkonHelper : public QObject
{
    Q_OBJECT
public:
    explicit QAvkonHelper(QObject *parent = 0);
    Q_INVOKABLE void showPopup(QString title,QString message, bool goToApp);
    Q_INVOKABLE void screenBlink();
    Q_INVOKABLE void notificationBlink(int device);
    Q_INVOKABLE void displayGlobalNote(QString message);
    Q_INVOKABLE QString openFileSelectionDlg();
    Q_INVOKABLE void openDefaultBrowser(const QUrl &url) const;

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
