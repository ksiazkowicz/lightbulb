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
    void ShowGlobalNoteL(TAknGlobalNoteType aNoteType, const TDesC16& aMessage);
    void ShowNoteL(const TDesC& aMessage);
public:
    explicit globalnote(QObject *parent = 0);
    Q_INVOKABLE void displayGlobalNote(QString message);
signals:
    
public slots:
    
};

#endif // GLOBALNOTE_H
