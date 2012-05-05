#--
# Copyleft meh. [http://meh.doesntexist.org | meh@paranoici.org]
#
# This file is part of ruby-mbox.
#
# ruby-mbox is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ruby-mbox is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with ruby-mbox. If not, see <http://www.gnu.org/licenses/>.
#++

require 'stringio'

require 'mbox/mail/headers/status'
require 'mbox/mail/headers/content_type'

class Mbox; class Mail

class Headers
	def self.name_to_symbol (name)
		return name if name.is_a? Symbol

		name = name.to_s.downcase.gsub('-', '_').to_sym

		if name.empty?
			raise ArgumentError, 'cannot pass empty name'
		end

		name
	end

	def self.symbol_to_name (name)
		name.to_s.downcase.gsub('_', '-').gsub(/(\A|-)(.)/) {|match|
			match.upcase
		}
	end

	def self.parse (input)
		new.parse(input)
	end

	include Enumerable

	def initialize (start = {})
		@data = {}

		merge! start
	end

	def each (&block)
		@data.each(&block)
	end

	def [] (name)
		@data[Headers.name_to_symbol(name)]
	end

	def []= (name, value)
		name = Headers.name_to_symbol(name)

		value = case name
			when :status       then Status.parse(value)
			when :content_type then ContentType.parse(value)
			else                    value
		end

		if tmp = @data[name] && !tmp.is_a?(Array)
			@data[name] = [tmp]
		end

		if @data[name].is_a?(Array)
			@data[name] << value
		else
			@data[name] = value
		end
	end

	def delete (name)
		@data.delete(Headers.name_to_symbol(name))
	end

	def merge! (other)
		other.each {|name, value|
			self[name] = value
		}

		self
	end

	def merge (other)
		clone.merge!(other)
	end

	def parse (input)
		input = if input.respond_to? :to_io
			input.to_io
		elsif input.is_a? String
			StringIO.new(input)
		else
			raise ArgumentError, 'I do not know what to do.'
		end

		last = nil

		until input.eof? || (line = input.readline).chomp.empty?
			if !line.match(/^\s/)
				next unless matches = line.match(/^([^:]+):\s*(.+)$/)

				whole, name, value = matches.to_a

				self[name] = value
				last       = name
			elsif self[last]
				if self[last].is_a?(String)
					self[last] << " #{line}"
				elsif self[last].is_a?(Array)
					self[last].last << " #{line}"
				end
			end
		end

		self
	end

	def to_s
		result = ''

		each {|name, values|
			[values].flatten.each {|value|
				result << "#{Headers.symbol_to_name(name)}: #{value}\n"
			}
		}

		result
	end
end
    end
end
