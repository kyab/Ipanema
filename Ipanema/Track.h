//
//  MyScheduler.h
//  ChordPlayer
//
//  Created by 吉岡 紘二 on 12/05/13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Synth.h"

@interface Track : NSObject{
	Synth *synth_;
}

-(Synth *)synth;
-(float)gen;

//AudioOutputEngine delegation
-(void)audioEngineBufferRequired:(UInt32)sampleNum left:(SInt16 *)pLeft right:(SInt16 *)pRight;
@end
