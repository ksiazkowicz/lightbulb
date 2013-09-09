#ifndef GLOBALNOTE_H
#define GLOBALNOTE_H

#include <QObject>
#include <aknglobalnote.h>

class globalnote : public QObject
{
    Q_OBJECT
private:
    TInt iNoteId;
    CAknGlobalNote* iNote;
    void StopGlobalNoteL(void);
    void ShowNoteL(const TDesC& aMessage);
    void ShowInfoL(const TDesC& aMessage);
public:
    explicit globalnote(QObject *parent = 0);
    Q_INVOKABLE void displayGlobalNote(QString message);
    Q_INVOKABLE void displayInfo(QString message);
signals:
    
public slots:
    
};

#endif // GLOBALNOTE_H
