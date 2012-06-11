

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
		GeneratorFactory *factory = [[SinWaveGeneratorFactory alloc] init];
		[synth_ setGeneratorFactory :factory ];
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
