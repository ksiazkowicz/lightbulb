#include "qmlvcard.h"
#include <QDebug>

QMLVCard::QMLVCard(QObject *parent) : QObject(parent)
{
    m_photo = "";
    m_nickname = "";
    m_name = "";
    m_middlename = "";
    m_lastname = "";
    m_fullname = "";
    m_birthday = "";
    m_email = "";
    m_url = "";
}

void QMLVCard::setVCard( QMLVCard *value )
{
    m_vcard =value;

    m_photo = value->getPhoto();
    m_nickname = value->getNickName();
    m_name = value->getName();
    m_middlename = value->getMiddleName();
    m_lastname = value->getLastName();
    m_fullname = value->getFullName();
    m_birthday = value->getBirthday();
    m_email = value->getEMail();
    m_url = value->getUrl();
    m_jid = value->getJid();
    //qDebug()<<"***>"<<m_photo <<m_nickname<<m_name<<m_middlename<<m_lastname<<m_fullname<<m_birthday<<m_email<<m_url<<m_jid;

    emit vCardChanged();
}

void QMLVCard::clearData() //Q_INVOKABLE
{
    m_vcard = 0;
    m_photo = "";
    m_nickname = "";
    m_name = "";
    m_middlename = "";
    m_lastname = "";
    m_fullname = "";
    m_birthday = "";
    m_email = "";
    m_url = "";
    m_jid = "";
}
