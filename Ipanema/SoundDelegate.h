//
//  SoundDelegate.h
//  SinSynth
//
//  Created by 吉岡 紘二 on 11/12/17.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <CoreMIDI/CoreMIDI.h>
#include <vector>
#include <math.h>

#include <map>
static const int SAMPLING_RATE = 44100;

class DownRamp{
public:
	DownRamp(float speed){		//sec
		speed_ = speed;
		frame_ = 0;
	}
	
	float gen(){
		float val = (float) (1.0 - (1 / speed_) * frame_/SAMPLING_RATE);
		frame_++;
		if (val < 0.0){
			return 0;
		}else{
			return val;
		}
	}
	
private:
	int frame_;
	float speed_;
};

class UpRamp{
public:
	UpRamp(float speed){
		speed_ = speed;
		frame_ = 0;
	}
	
	float gen(){
		float val = (float) ( (1/speed_) * frame_ / SAMPLING_RATE);
		frame_ ++;
		if (val > 1.0f){
			return 1.0f;
		}else{
			return val;
		}
	}
private:
	int frame_;
	float speed_;	

};

class Generator{
public:
	virtual float gen() = 0;
	virtual bool isOff() = 0;
	virtual void off() = 0;
	virtual bool isEnd() = 0;
};


class SinWaveGenerator : public Generator{
public:
	SinWaveGenerator(int freq, float gain) : upRamp_(0.002f), downRamp_(0.2f){
		freq_ = freq;
		gain_ = gain;
		frame_ = 0;
		
		isOff_ = false;
		isEnd_ = false;
	}
	
	float gen(){

		float current_sec = 1.0f * frame_ / SAMPLING_RATE;
		float omega = 2.0f * (float)M_PI * freq_;
		float val =(float) (gain_* cos( omega * current_sec));
		
		val *= upRamp_.gen();
		
		if (isOff_){
			float downRampval = downRamp_.gen();
			val *= downRampval;
			if (downRampval < 0.1){
				//NSLog(@"notes end");
				isEnd_ = true;
			}
		}
		
		frame_++;
		return val;
	}
	
	void off(){
		//note was offed
		isOff_ = true;
	}
	
	bool isOff(){
		return isOff_;
	}
	
	bool isEnd(){
		//is end over?
		return isEnd_;
	}
	
private:
	int frame_;
	int freq_;
	float gain_;
	
	bool isEnd_;
	
	bool isOff_;
	DownRamp downRamp_;
	UpRamp upRamp_;
};

class TriangleGenerator : public Generator{
public:
	TriangleGenerator(int freq, float gain) {
		freq_ = freq;
		gain_ = gain;
		frame_ = 0;
		off_ = false;
	}
	
	float gen(){
		float sec = 1.0f * frame_++ / SAMPLING_RATE;	//OK
		if (sec > 1/freq_) frame_ = 0 ;
		
		float val = gain_* freq_ * sec;
		return val;
	}
	
	bool isOff(){
		return off_;
	}
	
	void off(){
		off_ = true;
	}
	
	bool isEnd(){
		return off_;
	}

private:
	float gain_;
	float frame_;
	float freq_;
	
	bool off_;
};

class Synth{
private:
	std::multimap<Byte, Generator *> notes_;	//notes and sins pair
	typedef std::multimap<Byte,Generator *>::iterator ite_type;
	
public:
	Synth(){}
	~Synth(){}

	virtual float gen(){
		float val = 0.0f;
		
		for (ite_type ite = notes_.begin(); ite != notes_.end(); ++ite){
			val += (*ite).second->gen();
		}
		
		return val;
	}
	
	void noteOn(Byte noteNumber, Byte velocity){
		const float base = 440.0f;
		const float keisuu = 1.0594630943593f;
		float freq = (float) (base * pow(keisuu,noteNumber - 57));
		
		//Generator *generator = new SinWaveGenerator(freq, 0.1f);
		Generator *generator = new TriangleGenerator(freq, 0.1f);
		notes_.insert(std::make_pair(noteNumber, generator));
		
		
		//NSLog(@"notes count = %lu", notes_.size());
		
	}
	
	void noteOff(Byte noteNumber){

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
	
	void removeEndNotes(){
		
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
};

@interface SoundDelegate : NSObject{
	Synth *synth_;
	
}
-(Synth *)synth;

//MIDIServer delegation
-(void)midiReceived:(const MIDIPacketList *)packetList;

//AudioOutputEngine delegation
-(void)audioEngineBufferRequired:(UInt32)sampleNum left:(SInt16 *)pLeft right:(SInt16 *)pRight;



@end
