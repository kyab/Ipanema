require "ChordParser.rb"
require "BaseClasses.rb"
require "singleton"

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


class Player
	include Singleton
	
	attr_accessor :tempo
	
	def initialize
		@notes = []
		@events = []
	end
	def play
		renderNotes2events
		sortEvents
		startPlay
	end
	
	def startPlay		
		Thread.new do
			p "thread started"
			thread_func
			p "thread ended"
		end
	end
	
	def thread_func
		Thread.current.priority = 40
		t = Time.now
		
		i = 0
		lastNoteNumber = -1
		while (i < @events.size)
			elapsed_second = (Time.now - t)
			elapsed_tick = elapsed_second  * @tempo/60 * 96
			while(i < @events.size)
				if @events[i].tick < elapsed_tick

					case @events[i]
					when NoteEvent
						if @events[i].type == :noteOn
							$track.noteOn(@events[i].noteNumber)
						else #:noteOff
							$track.noteOff(@events[i].noteNumber)
						end
					when ProcEvent
						@events[i].block.call
					end
					i += 1
				else
					break
				end
			end
			
			sleep(0.0025)
		end
	end
	
	def renderNotes2events
		@notes.each do |note|
			if (note.noteNumber >= 0)
				@events << NoteEvent.new(note.noteNumber, :noteOn, note.startTick)
				@events << NoteEvent.new(note.noteNumber, :noteOff, note.startTick + note.length)
			end
		end
	end

	def addEvent(tick,block)
		@events << ProcEvent.new(tick, block)
	end

	def parseChords(str)
		chords = ChordsExtractor.new(str).chords
		@notes += chords2Notes(chords)
	end
	
	def parseMML(str)
		puts "hello"
		@notes += MMLParser.new(str).notes
	end
	
	def sortEvents
		p @events.sort!	
	end
end	
