#include "chatsitemmodel.h"



ChatsItemModel::ChatsItemModel( const QString &_picStatus,
                                 const QString &_contactName,
                                 const QString &_contactJid,
                                 const QString &_contactResource,
                                 const QString &_contactTextStatus,
                                 const QString &_contactPicAvatar,
                                 QObject *parent) :
  ListItem(parent),
    m_pic_status(_picStatus),
    m_name(_contactName),
    m_jid(_contactJid),
    m_resource(_contactResource),
    m_text_status(_contactTextStatus),
    m_avatar(_contactPicAvatar)
{
}


void ChatsItemModel::setPicStatus(QString &_picStatus)
{
  if(m_pic_status != _picStatus) {
    m_pic_status = _picStatus;
    emit dataChanged();
  }
}

void ChatsItemModel::setContactName(QString &_contactName)
{
  if(m_name != _contactName) {
    m_name = _contactName;
    emit dataChanged();
  }
}

void ChatsItemModel::setJid(QString &_contactJid)
{
  if(m_jid != _contactJid) {
    m_jid = _contactJid;
    emit dataChanged();
  }
}

void ChatsItemModel::setResource(QString &_contactResource)
{
  if(m_resource != _contactResource) {
    m_resource = _contactResource;
    emit dataChanged();
  }
}

void ChatsItemModel::setTextStatus(QString &_contactTextStatus)
{
  if(m_text_status != _contactTextStatus) {
    m_text_status = _contactTextStatus;
    emit dataChanged();
  }
}

void ChatsItemModel::setAvatar(QString &_contactPicAvatar)
{
  if(m_avatar != _contactPicAvatar) {
    m_avatar = _contactPicAvatar;
    emit dataChanged();
  }
}


QHash<int, QByteArray> ChatsItemModel::roleNames() const
{
  QHash<int, QByteArray> names;
  names[cntPicStatus] = "contactPicStatus";
  names[cntName] = "contactName";
  names[cntJid] = "contactJid";
  names[cntResource] = "contactResource";
  names[cntTextStatus] = "contactTextStatus";
  names[cntPicAvatar] = "contactPicAvatar";
  return names;
}

QVariant ChatsItemModel::data(int role) const
{
  switch(role) {
  case cntPicStatus:
    return picStatus();
  case cntName:
    return contactName();
  case cntJid:
    return contactJid();
  case cntResource:
    return contactResource();
  case cntTextStatus:
    return textStatus();
  case cntPicAvatar:
    return picAvatar();
  default:
    return QVariant();
  }
}
