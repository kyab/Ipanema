require "Controller.rb"
require "Player.rb"

#----------------------The Main Script goes here-----------------------
tempo(150)

#track(1) do 

# テキスト音楽「サクラ」のMML
mml ("o5l4 e4. c#8 c# <b8 >e2 c#8 c# <b4" <<
	 "o5l4 e4. c#8 c# <b8 >e2 c#8 c#4 <b4" <<
	">d4. <b8 b4 a8 >c#2 <a4 a4 g8 a1^1" << 
	"o5l4 e4. c#8 c# <b8 >e2 c#8 c# <b4" <<
	 "o5l4 e4. c#8 c# <b8 >e2 c#8 c#4 <b4" <<
	 ">d4. <b8 b4 a8 >c#2 <a4 a4 g8 a1^1" << 		
		
	">d1^8 d#4 d8 c8 d4 c8 <a#4. >c8^1." << 
	"f1^8 f#4 f8 d#8 f4 d#8 c#4. d#8^1." ) 

#end

#track(2) do
chords <<-END
	D69  -  D69  -  E7(9)  -  E7(9)  
	Em7(9)  -  A7(13)  -  D69  -  Eb7(9)  
	D69  -  D69  -  E7(9)  -  E7(9)  
	Em7(9)  -  A7(13)  -  D69  -  Eb7(9)  
	
	EbM7  -  EbM7  -  Ab7(13)  -  Ab7(13)  
	GbM7/Bb  -  GbM7/Bb  -  B7(13)  -  B7(13)  
	
	END

#end

onTick(0) do 
	puts "song started"
end
	
onTick(1000) do 
	puts "current Tick = 1000"
end

onTick(2000) do 
	puts "current Tick = 2000"
end


#-----------------------------------------------------------------------
