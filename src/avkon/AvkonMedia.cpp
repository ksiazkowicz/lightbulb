/********************************************************************

src/avkon/AvkonMedia.cpp
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

#include "AvkonMedia.h"
#include <eikenv.h>
#include <QSystemInfo>
#include <QSystemDeviceInfo>
#include "aknnotewrappers.h"

// CONSTANTS
const TInt KOneSecond = 1000 * 1000; // 1 second in microseconds
const TInt KVolumeDenominator = 2;

using namespace QtMobility;

AvkonMedia::AvkonMedia()
{
  deviceInfo = new QSystemDeviceInfo();
}

AvkonMedia::~AvkonMedia()
	{
	delete iPlayerUtility;
	}

AvkonMedia* AvkonMedia::NewLC()
	{
	AvkonMedia* self = new (ELeave) AvkonMedia();
	CleanupStack::PushL(self);
	self->ConstructL();
	return self;
	}

AvkonMedia* AvkonMedia::NewL()
	{
	AvkonMedia* self = AvkonMedia::NewLC();
	CleanupStack::Pop(self);
	return self;
	}

void AvkonMedia::ConstructL()
	{
	iPlayerUtility = CMdaAudioPlayerUtility::NewL(*this);
	}

void AvkonMedia::PlayL(const TDesC& aFileName)
	{
	iPlayerUtility->Close();
	iPlayerUtility->SetVolume(iPlayerUtility->MaxVolume());
	iPlayerUtility->OpenFileL(aFileName);
	}

void AvkonMedia::Pause()
	{
	iPlayerUtility->Pause();
	}

void AvkonMedia::Resume()
	{
	iPlayerUtility->Play();
	}

void AvkonMedia::Stop()
	{
	iPlayerUtility->Stop();
	}

void AvkonMedia::Rewind(TInt aIntervalInSeconds)
	{
	iPlayerUtility->Pause();

	// Get the current position of the playback.
	TTimeIntervalMicroSeconds position;
	iPlayerUtility->GetPosition(position);

	// Add the interval to the current position.
	position = position.Int64() - aIntervalInSeconds * KOneSecond;

	// Set the new position.
	iPlayerUtility->SetPosition(position);
	iPlayerUtility->Play();
	}

void AvkonMedia::FastForward(TInt aIntervalInSeconds)
	{
	iPlayerUtility->Pause();

	// Get the current position of the playback.
	TTimeIntervalMicroSeconds position;
	iPlayerUtility->GetPosition(position);

	// Subtract the interval from the current position.
	position = position.Int64() + aIntervalInSeconds * KOneSecond;

	// Set the new position.
	iPlayerUtility->SetPosition(position);
	iPlayerUtility->Play();
	}

void AvkonMedia::MapcInitComplete(TInt aError,
		const TTimeIntervalMicroSeconds& aDuration)
	{
	AudioTrackduration = aDuration;

	if (KErrNone == aError)
		{
		//iPlayerUtility->SetVolume(
			//	iPlayerUtility->MaxVolume() );// / KVolumeDenominator);
		iPlayerUtility->Play();
		}
	else
		{
		iPlayerUtility->Close();

		// Do something when an error happens.
		//DisplayErrorMessage(aError);
		}
	}

void AvkonMedia::MapcPlayComplete(TInt aError)
	{
	if (KErrNone == aError)
		{
		}
	else
		{
		// Do something when an error happens.
		//DisplayErrorMessage(aError);
		}
	}

void AvkonMedia::DisplayErrorMessage(TInt aError)
	{
	const TInt KMaxBuffer = 15;
	_LIT(KErrorMessage, "Error: %d");
	TBuf<KMaxBuffer> buffer;
	buffer.AppendFormat(KErrorMessage, aError);
	TRAP_IGNORE(CEikonEnv::Static()->InfoWinL(KNullDesC, buffer));
	}

bool AvkonMedia::isInSilentMode() {
  return (QSystemDeviceInfo::Profile)deviceInfo->currentProfile() == QSystemDeviceInfo::SilentProfile;
}

// End of File
