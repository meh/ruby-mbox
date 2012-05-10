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

require 'mbox/mail/metadata'
require 'mbox/mail/headers'
require 'mbox/mail/content'

class Mbox

class Mail
	def self.parse (input, options = {})
		metadata = Mbox::Mail::Metadata.new
		headers  = Mbox::Mail::Headers.new
		content  = Mbox::Mail::Content.new(headers)

		next until input.eof? || (line = input.readline).match(options[:separator])

		return if !line || line.empty?

		# metadata parsing
		metadata.parse_from line
		until input.eof? || (line = input.readline).match(options[:separator])
			break unless line.match(/^>+/)

			metadata.parse_from line
		end

		# headers parsing
		current = ''
		begin
			break if line.strip.empty?

			current << line
		end until input.eof? || (line = input.readline).match(options[:separator])
		headers.parse(current)

		# content parsing
		current = ''
		until input.eof? || (line = input.readline).match(options[:separator])
			next if options[:headers_only]

			current << line
		end

		unless options[:headers_only]
			content.parse(current.chomp)
		end

		# put the last separator back in its place
		if !input.eof? && line
			input.seek(-line.length, IO::SEEK_CUR)
		end

		Mail.new(metadata, headers, content)
	end

	attr_reader :metadata, :headers, :content

	def initialize (metadata, headers, content)
		@metadata = metadata
		@headers  = headers
		@content  = content
	end

	def from
		metadata.from.first.name
	end

	def save_to (path)
		File.open(path, 'w') {|f|
			f.write to_s
		}
	end

	def unread?
		!headers[:status].read? rescue true
	end

	def to_s
		"#{headers}\n#{content}"
	end

	def inspect
		"#<Mail:#{from}>"
	end
end

end
