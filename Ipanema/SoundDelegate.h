//
//  SoundDelegate.h
//  SinSynth
//
//  Created by 吉岡 紘二 on 11/12/17.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Synth.h"
#import "MyTrack.h"
#include <CoreMIDI/CoreMIDI.h>


@interface SoundDelegate : NSObject{
	MyTrack *track_;
}

-(MyTrack *)track;

//AudioOutputEngine delegation
-(void)audioEngineBufferRequired:(UInt32)sampleNum left:(SInt16 *)pLeft right:(SInt16 *)pRight;



@end
