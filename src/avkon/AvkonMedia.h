#ifndef AVKONMEDIA_H
#define AVKONMEDIA_H

#include <e32std.h>
#include <e32base.h>
#include <MdaAudioSamplePlayer.h>

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


	};

#endif // AVKONMEDIA_H
