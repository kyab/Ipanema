

#-------------------DSL----------------------
def tempo(tempo)
	Player.instance.tempo = tempo
end

def onTick(tick, &block)
	Player.instance.addEvent(tick, block)
end

def mml(str)
	Player.instance.parseMML(str)
end

def track(trackNumber, &block)
end

def chords(str)
	Player.instance.parseChords(str)
end
#-------------------------------------------
	
$track1 = Track.new
$track1.synth.setGeneratorFactory(SinWaveGeneratorFactory.new)
MasterTrack.sharedMasterTrack.tracks.addObject($track1)


Thread.abort_on_exception = true #currently does not make a sense due to MacRuby's bug.
								 #so, exception in the thread does not raise until be joined. debug hell. oops!

class Controller
	def awakeFromNib
		
		@audioEngine = AudioOutputEngine.new
		@audioEngine.initCoreAudio
	
		@audioEngine.delegate = MasterTrack.sharedMasterTrack
		@audioEngine.start()

	end
	
	def play(sender)
		Player.instance.play
	end
end
