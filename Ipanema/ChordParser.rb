require "BaseClasses.rb"


def chords2Notes(chords)

	notes = []
	tick = 0
	chords.each do |chord|
		chord.noteNumbers.each do |noteNumber|
			length = chord.duration * 96
			n = Note.new(noteNumber, length, tick)
			notes << n
		end
		
		tick += chord.duration * 96 
	end
	notes
end

class ChordSyntaxError < StandardError; end

def baseName2NoteNumber(baseName)
	case baseName
	when "E"
		64
	when "F"
		65
	when "F#","Gb"
		66
	when "G"
		67
	when "G#", "Ab"
		68
	when "A"
		69
	when "A#","Bb"
		70
	when "B"
		71
	when "C"
		72
	when "C#", "Db"
		73
	when "D", "D"
		74
	when "D#", "Eb"
		75
	else
		raise "#{baseName} can't be recognized as base note name."
	end - 12
end

class Chord
	attr_accessor :noteNumbers, :duration
	attr_accessor :base_str, :on_str, :subpart_str
	
	def initialize(base_str, on_str, subpart_str, duration = 4)
		puts "new Chord #{base_str},#{subpart_str},/#{on_str},duration = #{duration}"
		
		@base_str = base_str
		@on_str = on_str
		@subpart_str = subpart_str
		@duration = duration
		parse
	end

	def parse
		@noteNumbers = []
		if (!on_str.empty?)
			@noteNumbers << baseName2NoteNumber(@on_str)
		else
			@noteNumbers << baseName2NoteNumber(@base_str)
		end
		
		relatives = case @subpart_str		#you shold have knowledge to understand this!
		when ""
			[4,7]
		when "7"
			[4,7,10]
		when "m"
			[3,7]
		when "m7"
			[3,7,10]
		when "m7(9)"
			[3,7,10,14]
		when "m7b5"
			[3,6,10]
		when "dim", "dim7"
			[3,6,9]
		when "m6"
			[3,7,9]
		when "m9"
			[3,7,14]
		when "M7","M"
			[4,7,11]
		when "6"
			[4,9]
		when "69"
			[4,9,14]
		when "7b5"
			[4,6,10]
		when "9"
			[4,7,14]
		when "7(9)"
			[4,7,10,14]
		when "7+9"
			[4,7,10,15]
		when "7-9"
			[4,7,10,13]
		when "7(13)", "(13)"
			[4,7,10,21]
		when "7(-13)"
			[4,7,10,20]
		when "7(+13)"
			[4,7,10,22]
		else
			raise "\"#{@subpart_str}\"not supported"
		end
		
		relatives.each do |r|
			@noteNumbers << baseName2NoteNumber(@base_str) + r
		end		
	end

	def to_s
		ret = case @duration 
		when 1
			""
		when 2
			" "
		when 4
			"  "
		end
		ret << "#{@base_str}#{@subpart_str}"
		ret << "/#{@on_str}" unless @on_str.empty?
		ret << case @duration
		when 1
			""
		when 2
			" "
		when 4
			"  "
		end
		ret
	end
	
	def transpose!(num)
		@duration = @duration
		@base_str = transpose(@base_str, num)
		@on_str = transpose(@on_str, num) unless @on_str.empty?
		@subpart_str = @subpart_str
		parse
		#more to be done...
		self
	end
end

#TODO: Consider this to be singleton class
class ChordsExtractor
	attr_reader :chords
	
	def initialize(str)
		@chords = []
		parse(str)
	end
	
private
	def parse(str)
		str.each_line.each_with_index do |line, lineNo|
			begin
				parseLine line.gsub("　"," ")
			rescue =>e
				p e
				raise ChordSyntaxError,"(parse) syntax error at line:#{lineNo + 1},:#{line}"
			end
		end
	end	
	
	def parseLine(line)
		#sanitize
		line = line.lstrip.gsub("\n","")
		
		i = 0
		state  = :none #:none,:after_base

		while(true)
			if (i >= line.size)
				break if state == :none
			end
			
			case state
			when :none
				currentBase = ""
				case line[i..-1]
				when /(Ab|A#|A|Bb|B|C#|C|Db|D#|D|Eb|E|F#|F|Gb|G#|G)(.*)/
					currentBase = $1
					state = :after_base
					i += $1.size
				else
					raise "base can't recognized:#{line[i..-1]}"
				end
				
			when :after_base
				nextCode_index = i
				while(true)
					break if (nextCode_index > line.size)
					if line[nextCode_index] =~/(Ab|A#|A|Bb|B|C#|C|Db|D#|D|Eb|E|F#|F|Gb|G#|G)(.*)/
						if (line[nextCode_index-1] == "/")			#on code
							puts "on code detected"
							nextCode_index += $1.size
							next
						else
							break
						end
					end
					nextCode_index += 1
				end
				
				subpart_and_duration = line[i..nextCode_index-1]
				subpart = ""
				duration = " "
				if (subpart_and_duration =~ /([^ -]*)(.*)/)
					subpart = $1
					if ($2.include?("-9") || $2.include?("-13"))
						if ($2[1..$2.size-1] =~ /([^ -]*).*/)
							subpart << "-" << $1
						end
					end
					duration = subpart_and_duration[subpart.size..-1]
				end
				
				if (duration =~ /([ ]*).*/)
					duration  = case $1.size
					when 2
						4
					when 1
						2
					when 0
						1
					end
				end

				p subpart
				p duration
				
				if (subpart =~ /(.*)\/(.*)/)
					on = $2
					onIgai = $1
				else
					on = ""
					onIgai = subpart
				end
				c = Chord.new(currentBase, on, onIgai, duration)
				@chords << c
				
				i = nextCode_index
				state = :none
			end
		end
	end
end







