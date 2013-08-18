#include "rosteritemmodel.h"


RosterItemModel::RosterItemModel(const QString &_contactGroup,
                                 const QString &_picStatus,
                                 const QString &_contactName,
                                 const QString &_contactJid,
                                 const QString &_contactResource,
                                 const QString &_contactTextStatus,
                                 const QString &_contactPicAvatar,
                                 const int _unreadMsg,
                                 const int _itemType,
                                 QObject *parent) :
  ListItem(parent),
    m_group(_contactGroup),
    m_pic_status(_picStatus),
    m_name(_contactName),
    m_jid(_contactJid),
    m_resource(_contactResource),
    m_text_status(_contactTextStatus),
    m_avatar(_contactPicAvatar),
    m_unreadmsg(_unreadMsg),
    m_item_type(_itemType)
{
}

void RosterItemModel::setGroup( const QString &_contactGroup)
{
  if(m_group != _contactGroup) {
    m_group = _contactGroup;
    emit dataChanged();
  }
}

void RosterItemModel::setPicStatus( const QString &_picStatus)
{
  if(m_pic_status != _picStatus) {
    m_pic_status = _picStatus;
    emit dataChanged();
  }
}

void RosterItemModel::setContactName( const QString &_contactName)
{
  if(m_name != _contactName) {
    m_name = _contactName;
    emit dataChanged();
  }
}

void RosterItemModel::setJid( const QString &_contactJid)
{
  if(m_jid != _contactJid) {
    m_jid = _contactJid;
    emit dataChanged();
  }
}

void RosterItemModel::setResource( const QString &_contactResource)
{
  if(m_resource != _contactResource) {
    m_resource = _contactResource;
    emit dataChanged();
  }
}

void RosterItemModel::setTextStatus( const QString &_contactTextStatus)
{
  if(m_text_status != _contactTextStatus) {
    m_text_status = _contactTextStatus;
    emit dataChanged();
  }
}

void RosterItemModel::setAvatar( const QString &_contactPicAvatar)
{
  if(m_avatar != _contactPicAvatar) {
    m_avatar = _contactPicAvatar;
    emit dataChanged();
  }
}

void RosterItemModel::setUnreadMsg( const int _unreadmsg)
{
  if(m_unreadmsg != _unreadmsg) {
    m_unreadmsg = _unreadmsg;
    emit dataChanged();
  }
}

void RosterItemModel::setItemType(const int _itemType)
{
  if(m_item_type != _itemType) {
    m_item_type = _itemType;
    emit dataChanged();
  }
}

QHash<int, QByteArray> RosterItemModel::roleNames() const
{
  QHash<int, QByteArray> names;
  names[cntGroup] = "contactGroup";
  names[cntPicStatus] = "contactPicStatus";
  names[cntName] = "contactName";
  names[cntJid] = "contactJid";
  names[cntResource] = "contactResource";
  names[cntTextStatus] = "contactTextStatus";
  names[cntPicAvatar] = "contactPicAvatar";
  names[cntUnreadMsg] = "contactUnreadMsg";
  names[cntItemType] = "contactItemType";
  return names;
}

QVariant RosterItemModel::data(int role) const
{
  switch(role) {
  case cntGroup:
    return group();
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
  case cntUnreadMsg:
    return unreadMsg();
  case cntItemType:
    return itemType();
  default:
    return QVariant();
  }
}

void RosterItemModel::copy( const RosterItemModel *item )
{
    m_group = item->group();
    m_pic_status = item->picStatus();
    m_name = item->contactName();
    m_jid = item->contactJid();
    m_resource = item->contactResource();
    m_text_status = item->textStatus();
    m_avatar = item->picAvatar();
    m_unreadmsg = item->unreadMsg();
    m_item_type = item->itemType();
}
