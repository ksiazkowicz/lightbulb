/********************************************************************

src/avkon/AvkonMedia.h
-- interface to native APIs, used to play sound notifications

Copyright (c) 2007 Symbian Press
http://developer.nokia.com/community/wiki/Archived:Using_Symbian_C++_Audio_APIs_in_a_Qt_app

This file is part of Lightbulb.

Lightbulb is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

*********************************************************************/

#ifndef AVKONMEDIA_H
#define AVKONMEDIA_H

#include <e32std.h>
#include <e32base.h>
#include <MdaAudioSamplePlayer.h>

#include <QSystemInfo>
#include <QSystemDeviceInfo>

using namespace QtMobility;

class AvkonMedia : public CBase, public MMdaAudioPlayerCallback
	{
public: // Constructors and destructor
	static AvkonMedia* NewL();
	static AvkonMedia* NewLC();
	~AvkonMedia();

public: // New methods
	void PlayL(const TDesC& aFileName);
	void Resume();
	void Pause();
	void Stop();
	void Rewind(TInt aIntervalInSeconds);
	void FastForward(TInt aIntervalInSeconds);

private:
	AvkonMedia();
	void ConstructL();

private:// From MMdaAudioPlayerCallback
	void MapcInitComplete(TInt aError,
			const TTimeIntervalMicroSeconds& aDuration);
	void MapcPlayComplete(TInt aError);

private: // Public methods
        void DisplayErrorMessage(TInt aError);

public: // Member variables
	CMdaAudioPlayerUtility* iPlayerUtility;
	TTimeIntervalMicroSeconds AudioTrackduration;

	QSystemDeviceInfo *deviceInfo;

	bool isInSilentMode();
};

#endif // AVKONMEDIA_H
