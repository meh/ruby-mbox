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
		raw = line
		metadata.parse_from line

		until input.eof? || (line = input.readline).match(options[:separator])
			break unless line.match(/^>+/)
			raw << line
			metadata.parse_from line
		end

		# headers parsing
		current = ''
		begin
			break if line.strip.empty?

			current << line
			if line[0..12] == "Delivered-To:"
				metadata.parse_to line
				next
			end
			if line[0..7] == "Subject:"
				metadata.parse_subject line
			end
			if line[0..10] == "Message-ID:"
				metadata.parse_id line
			end
		end until input.eof? || (line = input.readline).match(options[:separator])
		headers.parse(current)

		raw << current

		# content parsing
		current = ''
		until input.eof? || (line = input.readline).match(options[:separator])
			next if options[:headers_only]

			current << line
		end

		raw << current

		unless options[:headers_only]
			content.parse(current.chomp)
		end

		# put the last separator back in its place
		if !input.eof? && line
			input.seek(-line.length, IO::SEEK_CUR)
		end

		Mail.new(metadata, headers, content, raw)
	end

	attr_reader :metadata, :headers, :content, :raw

	def initialize (metadata, headers, content, raw)
		@metadata = metadata
		@headers  = headers
		@content  = content
    @raw      = raw
	end

	def from
		metadata.from.first.name
	end

	def date
		metadata.from.first.date
	end

	def to
		metadata.to.first
	end

	def subject
		metadata.subject.first
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
