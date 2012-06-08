require "strscan"
require "BaseClasses"

class MMLParser
	attr_accessor :notes
	
	def initialize(str)
		@notes = []
		parsemml(str)
	end
  
  
	def parsemml(str)
    
  		s = StringScanner.new(str)

  		mode = :none
  		currentNoteBase = 60
  		currentDefaultLength = 96
  		currentNote = nil
  		currentTick = 0
  		lastSlurLen = 0

  		while !s.eos?
  			#p s.rest
  			case 
  			when s.scan( /(\s+)/ )
  				#do nothing
  			when s.scan (/(a#|a-|a|b-|b|c#|c|d-|d#|d|e-|e#|e|f#|f|g-|g#|g)/)
  				case mode 
  				when :after_note, :after_dot, :after_length, :none, :after_slur

  					if (@notes.empty?)
  						currentTick = 0
  					else
  						currentTick += @notes[-1].length
  					end
  					currentNote = Note.new(Util::noteName2NoteNumber(currentNoteBase, s[0]), currentDefaultLength, currentTick)

  					#この時点でpushしちゃう
  					@notes << currentNote
  					mode = :after_note
  				end
  			when s.scan(/(r)/)	
  				case mode
  				when :after_note, :after_dot, :after_length, :none, :after_slur

  					if @notes.empty?
  						currentTick = 0
  					else
  						currentTick += $notes[-1].length
  					end
  					currentNote = Note.new(-1, currentDefaultLength, currentTick)
  					@notes << currentNote
  					mode = :after_note
  				end

  			when s.scan(/(\^)/)
  				case mode 
  				when :after_note, :after_length, :after_dot,:after_slur
  					lastSlurLen = currentDefaultLength	
  					currentNote.length += lastSlurLen
  				else
  					raise ParseError, s.rest
  				end
  				mode = :after_slur

  			when s.scan(/(o(1|2|3|4|5|6|7|8|9))/)
  				case mode 
  				when :after_note, :after_length, :after_dot, :none, :after_slur
  					currentNoteBase = 12 * s[2].to_i
  				end
  				mode = :none

  			when s.scan(/(l(16|1|2|4|8))/)
  				case mode 
  				when :after_note, :after_length, :after_dot, :none, after_slur

  					currentDefaultLength = case s[2].to_i
  						when 1
  							96 * 4
  						when 2
  							96 * 2
  						when 4
  							96
  						when 8
  							96 / 2
  						when 16
  							96 / 4
  						else
  							raise "something is going wrong!"
  					end
  				end
  				mode = :none

  			when s.scan (/(16|1|2|4|8)/)
  				case mode
  				when :after_length, :after_dot, :none
  					raise  ParseError　"there are no notes indicated"

  				when :after_slur
  					currentNote.length -= lastSlurLen		#^が現れた時点での長さは一旦捨てる
  					lastSlurLen  = case s[0].to_i
  						when 1
  							96 * 4
  						when 2
  							96 * 2
  						when 4
  							96
  						when 8
  							96 / 2
  						when 16
  							96 / 4
  						else
  							raise ParseError "something is going wrong!"
  					end	
  					currentNote.length += lastSlurLen

  				when :after_note
  					currentNote.length = case s[0].to_i
  						when 1
  							96 * 4
  						when 2
  							96 * 2
  						when 4
  							96
  						when 8
  							96 / 2
  						when 16
  							96 / 4
  						else
  							raise "something is going wrong!"
  						end
  				end
  				mode = :after_length

  			when s.scan (/(\.)/)
  				case mode
  				when :after_length, :after_note 
  					currentNote.length += currentNote.length/2
  					mode = :after_dot
  				when :after_slur
  					currentNote.length += lastSlurLen/2
  					mode = :after_dot
  				end

  			when s.scan (/(<|>)/)
  				puts "octave up or down"
  				if s[0] == ">"
  					currentNoteBase += 12
  				else
  					currentNoteBase -= 12
  				end
  				mode = :none

  			else 
  				raise ParseError, "parse error at:\"#{s.rest}\""
  			end
  		end
  		@notes.each do |n|
  			p n
  		end
  	end	
end

    
    
  
  