#ifndef STOREVCARD_H
#define STOREVCARD_H

#include <QObject>
#include <QDomDocument>
#include <QDomElement>


class vCardData
{
public:
    QString nickName;
    QString firstName;
    QString middleName;
    QString lastName;
    QString url;
    QString eMail;
    QString fullName;
    vCardData() {
        nickName = "";
        firstName = "";
        middleName = "";
        lastName = "";
        url = "";
        eMail = "";
        fullName = "";
    }
    bool isEmpty() {
        return (nickName.isEmpty() &&
                firstName.isEmpty() &&
                middleName.isEmpty() &&
                lastName.isEmpty() &&
                url.isEmpty() &&
                eMail.isEmpty() &&
                fullName.isEmpty()
                );
    }
};

class StoreVCard : public QObject
{
    Q_OBJECT

    //QDomDocument *vCardXMLDoc;
    //QDomElement rootVCard;

    QString pathCache;

    //void setElementStore( const QString &nodeName, const QString &text );
    QString getElementStore( const QDomDocument *doc, const QString &nodeName );
public:
    explicit StoreVCard(QObject *parent = 0);

    void setCachePath( const QString &path ) {
        pathCache = path;
    }

    bool setVCard( const QString &bareJid, vCardData &vCard );
    vCardData getVCard( const QString &bareJid );
    
signals:
    
public slots:

private:
    QString m_birthday;
    QString m_url;
    
};

#endif // STOREVCARD_H
