

#-------------------DSL----------------------
def onTick(tick, &block)
	Player.addEvent(tick, block)
end

def mml(str)
	Player.parsemml(str)
end

def track(trackNumber, &block)
end

def chords(str)
	Player.parseChords(str)
end
#-------------------------------------------
	
	
$soundDelegate = SoundDelegate.new
$scheduler = MyScheduler.sharedMyScheduler
$scheduler.soundDelegate = $soundDelegate

Thread.abort_on_exception = true #currently does not make a sense due to MacRuby's bug

class Controller
	def awakeFromNib
		
		@audioEngine = AudioOutputEngine.new
		@audioEngine.initCoreAudio
		
		@soundDelegate = $soundDelegate
		@audioEngine.delegate = @soundDelegate
		
		@audioEngine.start()

	end
	
	def play(sender)
		Player::play
	end
end
