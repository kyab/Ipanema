require "Controller.rb"
require "Player.rb"

#----------------------The Main Script goes here-----------------------
#tempo(120)

# テキスト音楽「サクラ」のMML
mml ("o5l4 e4. c#8 c# <b8 >e2 c#8 c# <b4" <<
		"o5l4 e4. c#8 c# <b8 >e2 c#8 c#4 <b4" <<
		">d4. <b8 b4 a8 >c#2 <a4 a4 g8 a8^1^1" << 
		">d1^8 d#4 d8 c8 d4 c8 <a#4. >c8^1." << 
		"f1^8 f#4 f8 d#8 f4 d#8 c#4. d#8^1." ) 

	
#TODO:
chords <<-END
	C#m7 - Am7
END
	
onTick(1000) do 
	puts "current Tick = 1000"
end

onTick(2000) do 
	puts "currentTick = 2000"
end


#-----------------------------------------------------------------------
