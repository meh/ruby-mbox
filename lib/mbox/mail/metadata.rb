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

class Mbox; class Mail

class Metadata
	attr_reader :from, :to, :subject, :id

	def initialize
		@from = []
		@to = []
		@subject = []
    @id = []
    @raw = []
	end

	def parse_from (line)
		line.match /^>*From ([^\s]+) (.{24})/ do |m|
			@from << Struct.new(:name, :date).new(m[1], m[2])
		end
	end
	def parse_to (line)
		line.match /Delivered-To: (.*)/ do |m|
			@to << m[1]
		end
	end
	def parse_subject (line)
		line.match /Subject: (.*)/ do |m|
			@subject << m[1]
		end
	end
	def parse_id (line)
		line.match /Message-ID: (.*)/ do |m|
			@id << m[1]
		end
	end
end

end; end
