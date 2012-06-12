//
//  Synth.m
//  Ipanema
//
//  Created by 吉岡 紘二 on 12/06/11.
//  Copyright (c) 2012年 kyab soft. All rights reserved.
//

#import "Synth.h"
#include <math.h>


@implementation GeneratorFactory
/*
-(Generator *)create :(int)freq gain:(float)gain{
	return new Generator(freq, gain);
}*/
@end

@implementation SinWaveGeneratorFactory
-(Generator *)create :(int)freq gain:(float)gain{
	return new SinWaveGenerator(freq, gain);
}
@end

@implementation TriangleGeneratorFactory
-(Generator *)create :(int)freq gain:(float)gain{
	return new TriangleGenerator(freq, gain);
}
@end



@implementation Synth

typedef std::multimap<Byte,Generator *>::iterator ite_type;


-(void)setGeneratorFactory:(GeneratorFactory *)generatorFactory{
	generatorFactory_ = generatorFactory;
}

-(float)gen{
	float val = 0.0f;
	
	for (ite_type ite = notes_.begin(); ite != notes_.end(); ++ite){
		val += (*ite).second->gen();
	}
	
	return val;
}
-(void)noteOn:(Byte) noteNumber velocity:(Byte)velocity{
	const float base = 440.0f;
	const float keisuu = 1.0594630943593f;
	float freq = (float) (base * pow(keisuu,noteNumber - 57));
	
	//Generator *generator = new SinWaveGenerator(freq, 0.1f);
	//Generator *generator = new TriangleGenerator(freq, 0.1f);
	Generator *generator = [generatorFactory_ create:freq gain:0.1f];
	notes_.insert(std::make_pair(noteNumber, generator));
	
	//NSLog(@"notes count = %lu", notes_.size());
}

-(void)noteOff:(Byte) noteNumber{
	//同じnoteNumberを持つノートのうち、まだNoteOffされていなくて、かつ一番古いものから
	//offしていく。
	std::pair< ite_type, ite_type> rangePair = notes_.equal_range(noteNumber);
	for (ite_type ite = rangePair.first; ite != rangePair.second; ++ite){ 
		Generator *generator = (*ite).second;
		if (!generator->isOff()){
			generator->off();
			break;
		}
	}
	
	//NSLog(@"notes count = %lu", notes_.size());	
}

-(void)removeEndNotes{
	for (ite_type it = notes_.begin(); it != notes_.end();){
		Generator *generator = (*it).second;
		if (generator->isEnd()){
			//NSLog(@"detects dead note.");
			delete generator;
			notes_.erase(it++);
			
		}else{
			++it;
		}
	}
}
@end
