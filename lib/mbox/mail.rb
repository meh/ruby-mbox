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

		inside = {
			metadata: true,
			headers:  false,
			content:  false
		}

		last = {
			line:  '',
			stuff: ''
		}

		next until input.eof? || (line = input.readline).match(options[:separator])

		return if !line || line.empty?

		metadata.parse_from line

		until input.eof? || ((line = input.readline).match(options[:separator]) && last[:line].empty?)
			if inside[:metadata]
				if line.match(/^>+/)
					metadata.parse_from line
				else
					inside[:metadata]    = false
					inside[:headers] = true

					last[:line] = line.chomp

					next
				end
			elsif inside[:headers]
				if line.strip.empty?
					inside[:headers] = false
					inside[:content] = true

					headers.parse(last[:stuff])

					last[:line]  = line.chomp
					last[:stuff] = ''

					next
				end

				last[:stuff] << line
			elsif inside[:content]
				if options[:headers_only]
					last[:line] = line.chomp

					next
				end

				last[:stuff] << line
			end

			last[:line] = line.chomp
		end

		unless last[:stuff].empty?
			content.parse(last[:stuff])
		end

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
		"#<Mail:#{headers['From']}>"
	end
end

end
