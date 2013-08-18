#ifndef ROSTERITEMMODEL_H
#define ROSTERITEMMODEL_H

#include "listmodel.h"

#define ROSTER_ITEM_CONTACT 0
#define ROSTER_ITEM_MUC 1

class RosterItemModel : public ListItem
{
    Q_OBJECT

public:
    enum Roles {
        cntGroup = Qt::UserRole+1,
        cntPicStatus,
        cntName,
        cntJid,
        cntResource,
        cntTextStatus,
        cntPicAvatar,
        cntUnreadMsg,
        cntItemType
      };

public:
      RosterItemModel(QObject *parent = 0): ListItem(parent) {
          m_group = "";
          m_pic_status = "";
          m_name = "";
          m_jid = "";
          m_resource = "";
          m_text_status = "";
          m_avatar = "";
          m_unreadmsg = 0;
          m_item_type = 0;
      }
      explicit RosterItemModel( const QString &_contactGroup,
                                       const QString &_picStatus,
                                       const QString &_contactName,
                                       const QString &_contactJid,
                                       const QString &_contactResource,
                                       const QString &_contactTextStatus,
                                       const QString &_contactPicAvatar,
                                       const int _unreadMsg,
                                       const int _item_type = 0,
                                       QObject *parent = 0 );
      virtual QVariant data(int role) const;
      virtual QHash<int, QByteArray> roleNames() const;

      virtual QString id() const { return m_jid; }

      void setGroup( const QString &_contactGroup );
      void setPicStatus( const QString &_contactPicStatus );
      void setContactName( const QString &_contactName );
      void setJid( const QString &_contactJid );
      void setResource( const QString &_contactResource );
      void setTextStatus( const QString &_contactTextStatus );
      void setAvatar( const QString &_contactPicAvatar );
      void setUnreadMsg( const int _unreadMsg );
      void setItemType( const int _itemType );

      inline QString group() const { return m_group; }
      inline QString picStatus() const { return m_pic_status; }
      inline QString contactName() const { return m_name; }
      inline QString contactJid() const { return m_jid; }
      inline QString contactResource() const { return m_resource; }
      inline QString textStatus() const { return m_text_status; }
      inline QString picAvatar() const { return m_avatar; }
      inline int unreadMsg() const { return m_unreadmsg; }
      inline int itemType() const { return m_item_type; }

      void copy( const RosterItemModel* );

    private:
      QString m_group;
      QString m_pic_status;
      QString m_name;
      QString m_jid;
      QString m_resource;
      QString m_text_status;
      QString m_avatar;
      int m_unreadmsg;
      int m_item_type;
};

#endif // ROSTERITEMMODEL_H
