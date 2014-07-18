#ifndef NETWORKCFGITEMMODEL_H
#define NETWORKCFGITEMMODEL_H

#include "ListModel.h"

class NetworkCfgItemModel : public ListItem
{
    Q_OBJECT

public:
    enum Roles {
        roleID = Qt::UserRole+1,
        roleName,
        roleBearer
      };

public:
      NetworkCfgItemModel(QObject *parent = 0): ListItem(parent) {
          cfgName= "";
          cfgBearer = "";
          cfgId = 0;
      }
      explicit NetworkCfgItemModel( const QString &_cfgName,
                                       const QString &_cfgBearer,
                                       const int _cfgId,
                                       QObject *parent = 0 ) : ListItem(parent),
          cfgName(_cfgName),
          cfgBearer(_cfgBearer),
          cfgId(_cfgId)
      {
      }

      virtual QVariant data(int role) const {
        switch(role) {
        case roleID:
          return getCfgId();
        case roleName:
          return getCfgName();
        case roleBearer:
          return getCfgBearer();
        default:
          return QVariant();
        }
      }
      virtual QHash<int, QByteArray> roleNames() const {
          QHash<int, QByteArray> names;
          names[roleID] = "id";
          names[roleName] = "name";
          names[roleBearer] = "bearer";
          return names;
        }


      virtual QString id() const { return QString::number(cfgId); }

      void setCfgBearer( const QString &_cfgBearer) {
        if (cfgBearer != _cfgBearer) {
            cfgBearer = _cfgBearer; emit dataChanged();
          }
      }

      void setCfgName( const QString &_cfgName) {
        if (cfgName != _cfgName) {
            cfgName = _cfgName; emit dataChanged();
          }
      }

      void setCfgId( const int _cfgId )  {
          if(cfgId != _cfgId) {
            cfgId = _cfgId;
            emit dataChanged();
          }
      }

      inline int getCfgId() const { return cfgId; }
      inline QString getCfgName() const { return cfgName; }
      inline QString getCfgBearer() const { return cfgBearer; }

    private:
      int cfgId;
      QString cfgName;
      QString cfgBearer;
};

#endif // NETWORKCFGITEMMODEL_H
