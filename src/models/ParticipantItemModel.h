#ifndef PARTICIPANTITEMMODEL_H
#define PARTICIPANTITEMMODEL_H

#include "ListModel.h"
#include "QXmppMucManager.h"

class ParticipantItemModel : public ListItem
{
    Q_OBJECT

public:
    enum Roles {
        roleJid = Qt::UserRole+1,
        roleName,
        rolePresence,
        roleRole,
        roleAffiliation
      };

public:
      ParticipantItemModel(QObject *parent = 0): ListItem(parent) {
        partJid = "";
        partPresence = "offline";
        partName = "Mr Random";
        partAffilliation = QXmppMucItem::OutcastAffiliation;
        partRole = QXmppMucItem::VisitorRole;
      }
      explicit ParticipantItemModel( const QString &_jid,
                                       const QString &_name,
                                       const QXmppMucItem::Affiliation _affiliation,
                                       const QXmppMucItem::Role _role,
                                       QObject *parent = 0 ) : ListItem(parent),
          partJid(_jid),
          partName(_name),
          partRole(_role),
          partAffilliation(_affiliation)
      {
      }

      virtual QVariant data(int role) const {
        switch(role) {
        case roleJid:
          return getPartJid();
        case roleName:
          return getPartName();
        case rolePresence:
          return getPartPresence();
        case roleRole:
          return (int)getPartRole();
        case roleAffiliation:
          return (int)getPartAffilliation();
        default:
          return QVariant();
        }
      }
      virtual QHash<int, QByteArray> roleNames() const {
          QHash<int, QByteArray> names;
          names[roleJid] = "bareJid";
          names[roleName] = "name";
          names[rolePresence] = "presence";
          names[roleRole] = "role";
          names[roleAffiliation] = "affiliation";
          return names;
        }

      virtual QString id() const { return partJid; }

      void setPartJid( const QString &_partJid) {
        if (partJid != _partJid) {
            partJid = _partJid;
            emit dataChanged();
          }
      }
      void setPartPresence( const QString &_partPresence) {
        if (partPresence != _partPresence) {
            partPresence = _partPresence;
            emit dataChanged();
          }
      }
      void setPartName( const QString &_partName) {
        if (partName != _partName) {
            partName = _partName;
            emit dataChanged();
          }
      }
      void setPartAffilliation(const int &_partAffilliation) {
        if ((int)partAffilliation != _partAffilliation) {
            partAffilliation = (QXmppMucItem::Affiliation)_partAffilliation;
            emit dataChanged();
          }
      }
      void setPartRole(const int &_partRole) {
        if ((int)partRole != _partRole) {
            partRole = (QXmppMucItem::Role)_partRole;
            emit dataChanged();
          }
      }

      inline QString getPartJid() const { return partJid; }
      inline QString getPartPresence() const { return partPresence; }
      inline QString getPartName() const { return partName; }
      inline QXmppMucItem::Affiliation getPartAffilliation() const { return partAffilliation; }
      inline QXmppMucItem::Role getPartRole() const { return partRole; }

    private:
      QString partJid;
      QString partPresence;
      QString partName;
      QXmppMucItem::Affiliation partAffilliation;
      QXmppMucItem::Role partRole;
};

#endif // PARTICIPANTITEMMODEL_H
