
class Note 
	attr_accessor :noteNumber , :length , :startTick
	def initialize(noteNumber,length, startTick)
		@noteNumber = noteNumber
		@length = length
		@startTick = startTick
	end
end

class Event
	#attr_accessor :tick
	
	def <=>(other)
		self.tick <=>other.tick
	end
end

class NoteEvent < Event
	attr_accessor :noteNumber, :type ,:tick
	def initialize (noteNumber, type, tick)
		@noteNumber = noteNumber
		@type = type
		@tick = tick
	end
end

class ProcEvent < Event
	attr_accessor :tick, :block
	def initialize (tick, block)
		@block = block
		@tick = tick
	end
end

class Util
	def self.noteName2NoteNumber(base, noteName)
		base + case noteName
		when "c"
			0
		when "c#","d-"
			1
		when "d"
			2
		when "d#", "e-"
			3
		when "e"
			4
		when "f"
			5
		when "f#","g-"
			6
		when "g"
			7
		when "g#", "a-"
			8
		when "a"
			9
		when "a#","b-"
			10
		when "b"
			11
		end
	end
end



class ParseError < StandardError; end
$notes = []
$events = []


class Player
	def self.play
		render2events
		sortEvents
		startPlay
	end
	
	def self.sortEvents
		p $events.sort!	
	end
	
	def self.startPlay		
		Thread.new do
			p "thread started"
			thread_func
			p "thread ended"
		end
	end
	
	def self.thread_func
		Thread.current.priority = 40
		t = Time.now
		
		i = 0
		lastNoteNumber = -1
		while (i < $events.size)
			elapsed_tick = (Time.now - t)* 96 * 2.0
			while(i < $events.size)
				if $events[i].tick < elapsed_tick

					case $events[i]
					when NoteEvent
						if $events[i].type == :noteOn
							$scheduler.noteOn($events[i].noteNumber)
						else #:noteOff
							$scheduler.noteOff($events[i].noteNumber)
						end
					when ProcEvent
						$events[i].block.call
					end
					i += 1
				else
					break
				end
			end
			
			sleep(0.0025)
		end
	end
	
	def self.render2events
		$notes.each do |note|
			if (note.noteNumber >= 0)
				$events << NoteEvent.new(note.noteNumber, :noteOn, note.startTick)
				$events << NoteEvent.new(note.noteNumber, :noteOff, note.startTick + note.length)
			end
		end
	end


	def self.addEvent(tick,block)
		$events << ProcEvent.new(tick, block)
	end
	
	#super long and ugly function! REFACTOR ME!!!!!!
	def self.parsemml(str)
		require "strscan"
		s = StringScanner.new(str)
		
		mode = :none
		currentNoteBase = 60
		currentDefaultLength = 96
		currentNote = nil
		currentTick = 0
		lastSlurLen = 0
		$notes = []
		
		while !s.eos?
			#p s.rest
			case 
			when s.scan( /(\s+)/ )
				#do nothing
				puts "empty"
			when s.scan (/(a#|a-|a|b-|b|c#|c|d-|d#|d|e-|e#|e|f#|f|g-|g#|g)/)
				case mode 
				when :after_note, :after_dot, :after_length, :none, :after_slur
						
					if ($notes.empty?)
						currentTick = 0
					else
						currentTick += $notes[-1].length
					end
					currentNote = Note.new(Util::noteName2NoteNumber(currentNoteBase, s[0]), currentDefaultLength, currentTick)
					
					#この時点でpushしちゃう
					$notes << currentNote
					mode = :after_note
				end
			when s.scan(/(r)/)	
				case mode
				when :after_note, :after_dot, :after_length, :none, :after_slur
				
					if ($notes.empty?)
						currentTick = 0
					else
						currentTick += $notes[-1].length
					end
					currentNote = Note.new(-1, currentDefaultLength, currentTick)
					$notes << currentNote
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
		$notes.each do |n|
			p n
		end
	end	
	
end
