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

#ifndef SERVICEITEMFILTER_H
#define SERVICEITEMFILTER_H

#include <QSortFilterProxyModel>
#include "ServiceItemModel.h"

class ServiceItemFilter : public QSortFilterProxyModel
{
    Q_OBJECT

public:
    ServiceItemFilter(QObject* parent = 0);

private:
    bool filterAcceptsRow(int, const QModelIndex&) const;
};

#endif // SERVICEITEMFILTER_H
