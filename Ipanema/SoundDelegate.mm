//
//  SoundDelegate.m
//  SinSynth
//
//  Created by 吉岡 紘二 on 11/12/17.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "SoundDelegate.h"
#import <MacRuby/MacRuby.h>


@implementation SoundDelegate

-(id)init{
	self = [super init];
	if (self != nil){
		//synth_ = new Synth();
		track_ = [MyTrack sharedMyTrack];
	}
	return self;
}

-(void)audioEngineBufferRequired:(UInt32)sampleNum left:(SInt16 *)pLeft right:(SInt16 *)pRight;
{

	for (UInt32 i = 0 ; i < sampleNum ; i++){
		float val = [track_ gen];
		SInt16 sint16val = val * SHRT_MAX;
		
		pLeft[i] = sint16val;
		pRight[i] = sint16val;
	}
	[[track_ synth] removeEndNotes];
}

-(MyTrack *)track{
	return track_;
}

@end
