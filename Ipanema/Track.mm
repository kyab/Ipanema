

#import "Track.h"

@implementation Track

static Track *sharedTrack = nil;

//This class is Singleton
+(id)sharedTrack{
	if (sharedTrack == nil){
		sharedTrack = [[self alloc] init];
	}
	return sharedTrack;
}

-(id)init{
	self = [super init];
	if (self != nil){
		synth_ = [[Synth alloc] init];
	}
	return self;
}

-(void)noteOn:(int)noteNumber{
	[synth_ noteOn:noteNumber velocity:127];
}

-(void)noteOff:(int)noteNumber{
	[synth_ noteOff:noteNumber];
}

-(float)gen{
	return [synth_ gen];
}


-(Synth *)synth{
	return synth_;
}

-(void)audioEngineBufferRequired:(UInt32)sampleNum left:(SInt16 *)pLeft right:(SInt16 *)pRight;
{

	for (UInt32 i = 0 ; i < sampleNum ; i++){
		float val = [self gen];
		SInt16 sint16val = val * SHRT_MAX;
		
		pLeft[i] = sint16val;
		pRight[i] = sint16val;
	}
	[synth_ removeEndNotes];
}




@end
