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

require 'mbox/mail/meta'
require 'mbox/mail/headers'
require 'mbox/mail/content'

class Mbox
    class Mail
        # Parse an email and get meta attributes, headers and content.
        def self.parse (stream, options={})
            if stream.eof?
                return nil
            end

            last = {
                :line => '',
                :stuff => ''
            }

            meta    = Mbox::Mail::Meta.new
            headers = Mbox::Mail::Headers.new
            content = Mbox::Mail::Content.new(headers)

            inside = {
                :meta    => true,
                :headers => false,
                :content => false
            }

            line = stream.readline

            if !stream.eof? && !line.match(/^From [^\s]+ .{24}/)
                while !stream.eof? && !(line = stream.readline).match(/^From [^\s]+ .{24}/)
                end
            end

            meta.from << line

            if line.empty?
              return
            end

            while !stream.eof? && !((line = stream.readline).match(/^From [^\s]+ .{24}/) && last[:line].empty?)
                if inside[:meta]
                    if line.match(/^>+/)
                        meta.from << line
                    else
                        inside[:meta]    = false
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
                    if options[:headersOnly]
                        last[:line] = line.chomp
                        next
                    end

                    last[:stuff] << line
                end

                last[:line] = line.chomp
            end

            if !last[:stuff].empty?
                content.parse(last[:stuff])
            end

            if !stream.eof? && line
                stream.seek(-line.length, IO::SEEK_CUR)
            end

            return Mail.new(meta, headers, content)
        end

        # Seek to the given email in the stream.
        def self.seek (stream, to, whence=IO::SEEK_SET)
            if whence == IO::SEEK_SET
                stream.seek(0)
            end

            last   = ''
            index  = -1
            
            while line = stream.readline rescue nil
                if line.match(/^From [^\s]+ .{24}/) && last.chomp.empty?
                    index += 1

                    if index >= to
                        stream.seek(-line.length, IO::SEEK_CUR)
                        break
                    end
                end

                last = line
            end
        end

        # Count the emails in the stream.
        def self.count (stream)
            last   = ''
            length = 0
            
            while line = stream.readline rescue nil
                if line.match(/^From [^\s]+ .{24}/) && last.chomp.empty?
                    length += 1
                end

                last = line
            end

            return length
        end

        attr_reader :meta, :headers, :content

        private
        
        def initialize (meta, headers, content) # :nodoc:
            @meta    = meta
            @headers = headers
            @content = content

            @meta.normalize
            @headers.normalize
            @content.normalize
        end

        public

        def save (path)
            file = File.new(path, 'w')
            file.write(self.to_s)
            file.close
        end

        # True if the email is unread, false otherwise.
        def unread?
            !self.headers['Status'].read rescue true
        end

        def to_s
            "#{self.headers}\n#{self.content}"
        end

        def inspect # :nodoc:
            "#<Mail:#{self.headers['From']}>"
        end
    end
end
