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

class Mbox; class Mail; class Headers

class ContentType
	def self.parse (text)
		return text if text.is_a?(ContentType)

		return ContentType.new unless text && text.is_a?(String)

		stuff = text.gsub(/\n\r/, '').split(/\s*;\s*/)
		type  = stuff.shift

		ContentType.new(Hash[stuff.map {|s|
			s    = s.strip.split('=', 2)
			s[0] = s[0].to_sym

			if s[1][0] == '"' && s[1][s[1].length-1] == '"'
				s[1] = s[1][1, s[1].length-2]
			end

			s
		}].merge(mime: type))
	end

	attr_accessor :mime, :charset, :boundary

	def initialize (data = {})
		@mime     = data[:mime] || 'text/plain'
		@charset  = data[:charset]
		@boundary = data[:boundary]
	end

	def to_s
		"#{mime}#{"; charset=#{charset}" if charset}#{"; boundary=#{boundary}" if boundary}"
	end
end

end; end; end
