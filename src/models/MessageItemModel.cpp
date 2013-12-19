#include "MessageItemModel.h"


MsgItemModel::MsgItemModel( const QString _msgId,
                            const QString &_msgResource,
                            const QString &_msgDateTime,
                            const QString &_msgText,
                            const bool &_msgDlr,
                            const bool &_msgMy,
                            const int &_msgType,
                            QObject *parent ) :
    ListItem(parent),
      m_id(_msgId),
      m_resource(_msgResource),
      m_datetime(_msgDateTime),
      m_text(_msgText),
      m_dlr(_msgDlr),
      m_myMsg(_msgMy),
      m_type(_msgType)
  {
  }


void MsgItemModel::setMsgId(QString &_id)
{
  if(m_id != _id) {
    m_id = _id;
    emit dataChanged();
  }
}

void MsgItemModel::setResource(QString &_resource)
{
  if(m_resource != _resource) {
    m_resource = _resource;
    emit dataChanged();
  }
}


void MsgItemModel::setMsgDateTime(QString &_msgDateTime)
{
  if(m_datetime != _msgDateTime) {
    m_datetime = _msgDateTime;
    emit dataChanged();
  }
}


void MsgItemModel::setMsgText(QString &_msgText)
{
  if(m_text != _msgText) {
    m_text = _msgText;
    emit dataChanged();
  }
}


void MsgItemModel::setMsgDlr(bool _msgDlr)
{
  if(m_dlr != _msgDlr) {
    m_dlr = _msgDlr;
    emit dataChanged();
  }
}

void MsgItemModel::setMsgMy(bool _msgMy)
{
  if(m_myMsg != _msgMy) {
    m_myMsg = _msgMy;
    emit dataChanged();
  }
}


void MsgItemModel::setMsgType(int _msgType)
{
  if(m_type != _msgType) {
    m_type = _msgType;
    emit dataChanged();
  }
}


QHash<int, QByteArray> MsgItemModel::roleNames() const
{
  QHash<int, QByteArray> names;
  names[ r_msgId ] = "msgId";
  names[ r_msgResource ] = "msgResource";
  names[ r_msgDateTime ] = "msgDateTime";
  names[ r_msgText ] = "msgText";
  names[ r_msgDlr ] = "msgDlr";
  names[ r_msgMy ] = "msgMy";
  names[ r_msgType ] = "msgType";
  return names;
}

QVariant MsgItemModel::data(int role) const
{
  switch(role) {
  case r_msgId:
    return msgId();
  case r_msgResource:
    return msgResource();
  case r_msgDateTime:
    return msgDateTime();
  case r_msgText:
    return msgText();
  case r_msgDlr:
    return msgDlr();
  case r_msgMy:
    return msgMy();
  case r_msgType:
    return msgType();
  default:
    return QVariant();
  }
}


