

#import "MyTrack.h"

@implementation MyTrack

static MyTrack *sharedMyTrack = nil;

//This class is Singleton
+(id)sharedMyTrack{
	if (sharedMyTrack == nil){
		sharedMyTrack = [[self alloc] init];
	}
	return sharedMyTrack;
}

-(void)setSoundDelegate : (SoundDelegate *)soundDelegate{
	soundDelegate_ = soundDelegate;
}
-(id)soundDelegate{
	return soundDelegate_;
}

-(void)noteOn:(int)noteNumber{
	Synth *synth = [soundDelegate_ synth];
	//synth->noteOn(noteNumber, 127);
	[synth noteOn:noteNumber velocity:127];
}

-(void)noteOff:(int)noteNumber{
	Synth *synth = [soundDelegate_ synth];
	//synth->noteOff(noteNumber);
	[synth noteOff:noteNumber];
}

@end
