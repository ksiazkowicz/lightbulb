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

#ifndef ROSTERITEMFILTER_H
#define ROSTERITEMFILTER_H

#include <QSortFilterProxyModel>
#include "RosterItemModel.h"

class RosterItemFilter : public QSortFilterProxyModel
{
    Q_OBJECT

public:
    RosterItemFilter(QObject* parent = 0);

public slots:
    void setShowOfflineContacts(bool);

private:
    bool filterAcceptsRow(int, const QModelIndex&) const;

    bool m_showOfflineContacts;
};

#endif // ROSTERITEMFILTER_H
