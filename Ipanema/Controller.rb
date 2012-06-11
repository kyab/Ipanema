

#-------------------DSL----------------------
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
	
	
class MasterTrack < MyTrack
	attr_accessor :tracks
end
	
$track = MyTrack.sharedMyTrack
$track.synth.setGeneratorFactory(SinWaveGeneratorFactory.new)

Thread.abort_on_exception = true #currently does not make a sense due to MacRuby's bug.
								 #so, exception in the thread does not raise until be joined. debug hell. oops!

class Controller
	def awakeFromNib
		
		@audioEngine = AudioOutputEngine.new
		@audioEngine.initCoreAudio
		
		@audioEngine.delegate = SoundDelegate.new	
		@audioEngine.start()

	end
	
	def play(sender)
		Player.instance.play
	end
end
