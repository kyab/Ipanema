//
//  SoundDelegate.m
//  SinSynth
//
//  Created by 吉岡 紘二 on 11/12/17.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "SoundDelegate.h"
#import <MacRuby/MacRuby.h>
#include <math.h>


@implementation Synth

typedef std::multimap<Byte,Generator *>::iterator ite_type;
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
	Generator *generator = new TriangleGenerator(freq, 0.1f);
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

@implementation SoundDelegate

-(id)init{
	self = [super init];
	if (self != nil){
		//synth_ = new Synth();
		synth_ = [[Synth alloc] init];
	}
	return self;
}

-(void)midiReceived:(const MIDIPacketList *)packetList{
	NSLog(@"SoundDelegate now received MIDI Event");
	
	MIDIPacket *packet = (MIDIPacket *)&(packetList->packet[0]);
	for (int i = 0 ; i < packetList->numPackets; i++){
		Byte mes = packet->data[0] & 0xF0;
		Byte ch = packet->data[0] & 0x0F;
		
        if ((mes == 0x90) && (packet->data[2] != 0)) {
            NSLog(@"note on number = %2.2x / velocity = %2.2x / channel = %2.2x",
                  packet->data[1], packet->data[2], ch);
			
			Byte noteNumber = packet->data[1];
			Byte velocity = packet->data[2];
			if (velocity > 0){
				//synth_->noteOn(noteNumber, velocity);
				[synth_ noteOn:noteNumber velocity:velocity];
			}else{
				//synth_->noteOff(noteNumber);
				[synth_ noteOff:noteNumber];
			}
			
        } else if (mes == 0x80 || mes == 0x90) {
            NSLog(@"note off number = %2.2x / velocity = %2.2x / channel = %2.2x", 
                  packet->data[1], packet->data[2], ch);
			Byte noteNumber = packet->data[1];
			
			//synth_->noteOff(noteNumber);
			[synth_ noteOff:noteNumber];
        } else if (mes == 0xB0) {
            NSLog(@"cc number = %2.2x / data = %2.2x / channel = %2.2x", 
                  packet->data[1], packet->data[2], ch);
        } else {
            NSLog(@"etc");
        }
		
		packet = MIDIPacketNext(packet);
	}	
	
}

-(void)audioEngineBufferRequired:(UInt32)sampleNum left:(SInt16 *)pLeft right:(SInt16 *)pRight;
{

	for (UInt32 i = 0 ; i < sampleNum ; i++){
		//float val = synth_->gen();
		float val = [synth_ gen];
		SInt16 sint16val = val * SHRT_MAX;
		
		pLeft[i] = sint16val;
		pRight[i] = sint16val;
	}
	//synth_->removeEndNotes();
	[synth_ removeEndNotes];
}

-(Synth *)synth{
	return synth_;
}

@end
