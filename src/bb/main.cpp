/* Copyright (c) 2012, 2013  BlackBerry Limited.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "applicationui.hpp"
#include <bb/cascades/Application>

#include <bb/platform/Notification>
#include <bb/platform/NotificationDialog>
#include <bb/platform/NotificationError>
#include <bb/platform/NotificationResult>

#include <bb/system/SystemUiButton>

#include "../xmpp/MyXmppClient.h"

#include "../models/AccountsListModel.h"
#include "../models/RosterItemFilter.h"
#include "../models/MsgListModel.h"
#include "../models/NetworkCfgListModel.h"
#include "../models/ParticipantListModel.h"
#include "../models/EventListModel.h"
#include "../models/ServiceListModel.h"
#include "AbstractItemModel.hpp"

#include "../cache/QMLVCard.h"
#include "../database/Settings.h"

#include "../database/DatabaseManager.h"
#include "../xmpp/XmppConnectivity.h"
#include "../EmoticonParser.h"
#include "../UpdateManager.h"
#include "../avkon/NetworkManager.h"
#include "../database/MigrationManager.h"
#include "../xmpp/EventsManager.h"

#include "../FluorescentLogger.h"

using namespace bb::cascades;

FluorescentLogger debugger;

void debug(QtMsgType type, const char *msg) {
  debugger.debug(type,msg);
}

Q_DECL_EXPORT int main(int argc, char **argv)
{
  // get debugger to work
  debugger.start();
  debugger.initLog();
  qInstallMsgHandler(debug);

  Application app(argc, argv);

  // initialize settings
  Settings settings;

  // expose C++ classes to QML
  qmlRegisterType<Settings>("lightbulb", 1, 0, "Settings" );
  qmlRegisterType<QMLVCard>("lightbulb", 1, 0, "XmppVCard" );
  qmlRegisterType<NetworkManager>("lightbulb", 1, 0, "NetworkManager" );

  qmlRegisterUncreatableType<SqlQueryModel>("lightbulb", 1, 0, "SqlQuery", "");
  qmlRegisterUncreatableType<AccountsListModel>("lightbulb", 1, 0, "AccountsList", "Use settings.accounts instead");
  qmlRegisterUncreatableType<RosterItemFilter>("lightbulb",1,0,"RosterModel","");
  qmlRegisterUncreatableType<NetworkCfgListModel>("lightbulb",1,0,"NetworkCfgListModel","just use NetworkManager.connections");
  qmlRegisterUncreatableType<ParticipantListModel>("lightbulb",1,0,"ParticipantListModel","just use NetworkManager.connections");
  qmlRegisterUncreatableType<ChatsListModel>("lightbulb",1,0,"ChatsModel","because I say so, who cares?");
  qmlRegisterUncreatableType<MsgListModel>("lightbulb", 1, 0, "MsgModel", "because sliced bread is awesome");
  qmlRegisterUncreatableType<EventListModel>("lightbulb",1,0,"EventModel","anyone actually reads that stuff?");
  qmlRegisterUncreatableType<ServiceListModel>("lightbulb",1,0,"ServiceModel","while (true) this->getHype();");
  qmlRegisterUncreatableType<MyXmppClient>("lightbulb", 1, 0, "XmppClient", "Use XmppConnectivity.useClient(accountId) instead" );
  qmlRegisterUncreatableType<EventsManager>("lightbulb", 1, 0, "EventsManager", "Use XmppConnectivity.events" );

  // Abstract Item Model adapter
  // from https://github.com/tokoe/cascades
  qmlRegisterType<QAbstractItemModel>();
  qmlRegisterType<AbstractItemModel>("lightbulb", 1, 0, "AbstractItemModel");

  EmoticonParser parser;
  UpdateManager updater;
  XmppConnectivity xmpp;

  // Create the Application UI object, this is where the main.qml file
  // is loaded and the application scene is set.
  ApplicationUI *appui = new ApplicationUI(&xmpp,&settings,&updater,&parser);

  return Application::exec();
}
