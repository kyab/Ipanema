

class Note 
	attr_accessor :noteNumber , :length , :startTick
	def initialize(noteNumber,length, startTick)
		@noteNumber = noteNumber
		@length = length
		@startTick = startTick
	end
end

class Event
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
