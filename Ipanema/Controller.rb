

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
	
	
$track = MyTrack.sharedMyTrack
$track.soundDelegate =SoundDelegate.new

Thread.abort_on_exception = true #currently does not make a sense due to MacRuby's bug

class Controller
	def awakeFromNib
		
		@audioEngine = AudioOutputEngine.new
		@audioEngine.initCoreAudio
		
		@audioEngine.delegate = $track.soundDelegate		
		@audioEngine.start()

	end
	
	def play(sender)
		Player.instance.play
	end
end
