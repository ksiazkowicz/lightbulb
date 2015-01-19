/*
 * Copyright (c) 2011-2014 BlackBerry Limited.
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

#ifndef ApplicationUI_HPP_
#define ApplicationUI_HPP_

#include <QObject>
#include <bb/cascades/QmlDocument>
#include "../database/Settings.h"
#include "../xmpp/XmppConnectivity.h"
#include "../EmoticonParser.h"
#include "../UpdateManager.h"

namespace bb
{
    namespace cascades
    {
        class LocaleHandler;
    }
}

class QTranslator;

/*!
 * @brief Application UI object
 *
 * Use this object to create and init app UI, to create context objects, to register the new meta types etc.
 */

using namespace bb::cascades;

class ApplicationUI : public QObject
{
    Q_OBJECT
public:
    ApplicationUI(XmppConnectivity *xmpp, Settings *settings, UpdateManager *updater, EmoticonParser *emoticon);
    virtual ~ApplicationUI() {}
private slots:
    void onSystemLanguageChanged();
private:
    QTranslator* m_pTranslator;
    bb::cascades::LocaleHandler* m_pLocaleHandler;
    QmlDocument *qml;
};

#endif /* ApplicationUI_HPP_ */
