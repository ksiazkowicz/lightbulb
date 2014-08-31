/*
 * Copyright (C) 2008-2014 The QXmpp developers
 * Copyright (C) 2014 Lightbulb
 *
 * Author:
 *	Manjeet Dahiya
 *      Maciej Janiszewski
 *
 * Source:
 *	https://github.com/qxmpp-project/qxmpp
 *
 * This file is part of Lightbulb.
 *
 * Lightbulb is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.

 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#include "RosterItemFilter.h"
#include <QDebug>

RosterItemFilter::RosterItemFilter(QObject* parent):
  QSortFilterProxyModel(parent),
  m_showOfflineContacts(true)
{
  setDynamicSortFilter(true);
  setFilterRole(Qt::DisplayRole);
  setFilterCaseSensitivity(Qt::CaseInsensitive);
}

bool RosterItemFilter::filterAcceptsRow(int source_row, const QModelIndex& source_parent) const {
  QModelIndex index = sourceModel()->index(source_row, 0, source_parent);

  if(!filterRegExp().isEmpty()) {
      QString name = sourceModel()->data(index, RosterItemModel::Name).toString();
      return name.contains(filterRegExp().pattern(),Qt::CaseInsensitive);
    }

  if(m_showOfflineContacts || sourceModel()->data(index, RosterItemModel::IsFavorite).toBool())
    return true;

  QString presenceType = sourceModel()->data(index, RosterItemModel::Presence).toString();

  return presenceType != "qrc:/presence/offline";
}

void RosterItemFilter::setShowOfflineContacts(bool showOfflineContacts)
{
  m_showOfflineContacts = showOfflineContacts;
  invalidateFilter();
}
