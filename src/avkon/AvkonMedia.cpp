// --------------------------------------------------------------------------
// SimpleAudioPlayer.cpp
//
// Copyright 2007, Symbian Press
// http://developer.nokia.com/community/wiki/Archived:Using_Symbian_C++_Audio_APIs_in_a_Qt_app
// --------------------------------------------------------------------------

#include "AvkonMedia.h"
#include <eikenv.h>
#include "aknnotewrappers.h"

// CONSTANTS
const TInt KOneSecond = 1000 * 1000; // 1 second in microseconds
const TInt KVolumeDenominator = 2;

AvkonMedia::AvkonMedia()
{
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

// End of File
