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

require 'mbox/mail/file'

require 'base64'

class Mbox
    class Mail
        class Content < Array
            attr_reader :attachments

            def initialize (content=[])
                self.insert(-1, *content)

                @attachments = []
            end

            def parse (headers, text)
                headers.normalize

                type = headers['Content-Type']

                if matches = type.mime.match(%r{multipart/(\w+)})
                    text.sub(/^.*?--#{type.boundary}\n/m, '').sub(/--#{type.boundary}--$/m, '').split("--#{type.boundary}\n").each {|part|
                        stream = StringIO.new(part)

                        headers = ''
                        while !stream.eof? && !(line = stream.readline).chomp.empty?
                            headers << line
                        end
                        headers = Headers.new.parse(headers)

                        content = !stream.eof? ? stream.readline : ''
                        while !stream.eof? && line = stream.readline
                            content << line
                        end
                        content.chomp!

                        puts content.length

                        file = File.new(headers, content)

                        if (headers['Content-Disposition'] || '').match(/^attachment/)
                            self.attachments << file
                        else
                            self << file
                        end
                    }
                else
                    stream = StringIO.new(text)

                    content = !stream.eof? ? stream.readline : ''
                    while !stream.eof? && line = stream.readline
                        content << line
                    end
                    content.chomp!

                    self << File.new(Headers.new, content)
                end

                return self
            end

            def normalize
            end
        end
    end
end
