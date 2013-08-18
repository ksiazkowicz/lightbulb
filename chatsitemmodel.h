#ifndef CHATSITEMMODEL_H
#define CHATSITEMMODEL_H

#include "listmodel.h"

class ChatsItemModel : public ListItem
{
    Q_OBJECT

public:
    enum Roles {
        cntPicStatus = Qt::UserRole+1,
        cntName,
        cntJid,
        cntResource,
        cntTextStatus,
        cntPicAvatar
      };

public:
      ChatsItemModel(QObject *parent = 0): ListItem(parent) {}
      explicit ChatsItemModel( const QString &_picStatus,
                                       const QString &_contactName,
                                       const QString &_contactJid,
                                       const QString &_contactResource,
                                       const QString &_contactTextStatus,
                                       const QString &_contactPicAvatar,
                                       QObject *parent = 0 );
      virtual QVariant data(int role) const;
      virtual QHash<int, QByteArray> roleNames() const;
      virtual QString id() const { return m_jid; }

      void setPicStatus( QString &_contactPicStatus );
      void setContactName( QString &_contactName );
      void setJid( QString &_contactJid );
      void setResource( QString &_contactResource );
      void setTextStatus( QString &_contactTextStatus );
      void setAvatar( QString &_contactPicAvatar );

      inline QString picStatus() const { return m_pic_status; }
      inline QString contactName() const { return m_name; }
      inline QString contactJid() const { return m_jid; }
      inline QString contactResource() const { return m_resource; }
      inline QString textStatus() const { return m_text_status; }
      inline QString picAvatar() const { return m_avatar; }

    private:
      QString m_pic_status;
      QString m_name;
      QString m_jid;
      QString m_resource;
      QString m_text_status;
      QString m_avatar;
};

#endif // CHATSITEMMODEL_H
