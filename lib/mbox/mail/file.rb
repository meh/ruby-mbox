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

require 'base64'

class Mbox; class Mail

class File
	attr_reader :name, :headers, :content

	def initialize (headers, content)
		if headers[:content_type].charset
			content.force_encoding headers['Content-Type'].charset rescue nil
		end

		if headers[:content_transfer_encoding] == 'base64'
			content = Base64.decode64(content)
		end

		if matches = headers[:content_disposition].match(/filename="(.*?)"/) rescue nil
			@name = matches[1]
		end

		@headers = headers
		@content = content
	end

	def to_s
		@content
	end

	alias to_str to_s

	def inspect
		"#<File:#{name}>"
	end
end

end; end
