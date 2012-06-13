

#import "Track.h"

@implementation Track

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

@end


static MasterTrack *sharedMasterTrack = nil;


@implementation MasterTrack

//This class is Singleton
+(id)sharedMasterTrack{
	if (sharedMasterTrack == nil){
		sharedMasterTrack = [[self alloc] init];
	}
	return sharedMasterTrack;
}

-(id)init{
	self = [super init];
	if (self != nil){
		tracks_ = [[NSMutableArray alloc] init];
	}
	return self;
}



-(void)audioEngineBufferRequired:(UInt32)sampleNum left:(SInt16 *)pLeft right:(SInt16 *)pRight;
{
	for (UInt32 i = 0 ; i < sampleNum; i++){
		float val = 0 ;
		for (id track in tracks_){
			val += [track gen];
		}
		SInt16 sint16val = val * SHRT_MAX;
		pLeft[i] = sint16val;
		pRight[i] = sint16val;
	}
	
	for (id track in tracks_){
		[[track synth] removeEndNotes];
	}
}

-(NSMutableArray *)tracks{
	return tracks_;
}

@end

