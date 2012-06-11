

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

-(id)init{
	self = [super init];
	if (self != nil){
		synth_ = [[Synth alloc] init];
	}
	return self;
}

/*
-(void)setSoundDelegate : (SoundDelegate *)soundDelegate{
	soundDelegate_ = soundDelegate;
}
-(id)soundDelegate{
	return soundDelegate_;
}
*/

-(void)noteOn:(int)noteNumber{
	//Synth *synth = [soundDelegate_ synth];
	//synth->noteOn(noteNumber, 127);
	[synth_ noteOn:noteNumber velocity:127];
}

-(void)noteOff:(int)noteNumber{
	//Synth *synth = [soundDelegate_ synth];
	//synth->noteOff(noteNumber);
	[synth_ noteOff:noteNumber];
}

-(float)gen{
	return [synth_ gen];
}

-(Synth *)synth{
	return synth_;
}

@end
