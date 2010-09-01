#--
# Copyleft meh. [http://meh.doesntexist.org | meh.ffff@gmail.com]
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

class Mbox
    class Mail
        class File
            attr_reader :name, :headers, :content

            def initialize (headers, content)
                headers.normalize

                if headers['Content-Type'].charset
                    content.force_encoding headers['Content-Type'].charset rescue nil
                end

                if headers['Content-Transfer-Encoding'] == 'base64'
                    content = Base64.decode64(content)
                end

                if matches = headers['Content-Disposition'].match(/filename="(.*?)"/) rescue nil
                    @name = matches[1]
                end

                @headers = headers
                @content = content
            end

            def to_s
                @content
            end

            def inspect
                "#<File:#{self.name}>"
            end
        end
    end
end
