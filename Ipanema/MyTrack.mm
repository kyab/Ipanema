//
//  MyScheduler.m
//  ChordPlayer
//
//  Created by 吉岡 紘二 on 12/05/13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

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
	synth->noteOn(noteNumber, 127);
}

-(void)noteOff:(int)noteNumber{
	Synth *synth = [soundDelegate_ synth];
	synth->noteOff(noteNumber);
}

@end
