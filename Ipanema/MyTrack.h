//
//  MyScheduler.h
//  ChordPlayer
//
//  Created by 吉岡 紘二 on 12/05/13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Synth.h"
//#import "SoundDelegate.h"

@interface MyTrack : NSObject{
	//id soundDelegate_;
	Synth *synth_;
}

//-(id)soundDelegate;
-(Synth *)synth;
-(float)gen;

@end
