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

require 'mbox/mail/file'

class Mbox; class Mail

class Content < Array
	attr_reader :headers, :attachments

	def initialize (headers, content = [], attachments = [])
		@headers     = headers
		@attachments = attachments

		push *content
	end

	def parse (text, headers = {})
		headers = @headers.merge(headers)
		type    = headers[:content_type]

		if type && type.mime && type.boundary && matches = type.mime.match(%r{multipart/(\w+)})
			text.sub(/^.*?--#{type.boundary}\n/m, '').sub(/--#{type.boundary}--$/m, '').split("--#{type.boundary}\n").each {|part|
				stream = StringIO.new(part)

				headers = ''
				until stream.eof? || (line = stream.readline).chomp.empty?
					headers << line
				end
				headers = Headers.parse(headers)

				content = !stream.eof? ? stream.readline : ''
				until stream.eof? || line = stream.readline
					content << line
				end
				content.chomp!

				file = File.new(headers, content)

				if (headers[:content_disposition] || '').match(/^attachment/)
					attachments << file
				else
					self << file
				end
			}
		else
			self << File.new(headers, text)
		end

		self
	end
end

end; end
