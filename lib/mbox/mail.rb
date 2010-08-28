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

require 'mbox/mail/meta'
require 'mbox/mail/headers'
require 'mbox/mail/content'

class Mbox
    class Mail
        attr_reader :meta, :headers, :content

        def self.parse (stream, options={})
            if stream.eof?
                return nil
            end

            last = {
                :line   => '',
                :header => ''
            }

            meta    = Mbox::Mail::Meta.new
            headers = Mbox::Mail::Headers.new
            content = Mbox::Mail::Content.new

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

            while !stream.eof? && !((line = stream.readline).match(/^From [^\s]+ .{24}/) && last[:line].empty?)
                if inside[:meta]
                    if line.match(/^>+/)
                        meta.from << line
                    else
                        inside[:meta]    = false
                        inside[:headers] = true
                        next
                    end
                elsif inside[:headers]
                    if line.strip.empty?
                        inside[:headers] = false
                        inside[:content] = true
                        next
                    end

                    if !line.match(/^\s/)
                        matches = line.match(/^([^:]*):\s*(.*)$/)

                        if !matches
                            next
                        end

                        name  = matches[1]
                        value = matches[2]

                        if headers[name]
                            if headers[name].is_a?(String)
                                headers[name] = [headers[name]]
                            end

                            if headers[name].is_a?(Array)
                                headers[name] << value
                            end
                        else
                            headers[name] = value
                        end

                        last[:headers] = name
                    else
                        if headers[last[:headers]]
                            if headers[last[:headers]].is_a?(String)
                                headers[last[:headers]] << " #{line.strip}"
                            elsif headers[last[:headers]].is_a?(Array)
                                headers[last[:headers]].last << " #{line.strip}"
                            end
                        end
                    end
                elsif inside[:content]
                
                end

                last[:line] = line.strip
            end

            if !stream.eof? && line
                stream.seek(-line.length, IO::SEEK_CUR)
            end

            return Mail.new(meta, headers, content)
        end

        def self.seek (stream, to, at=nil)
            if !at
                stream.seek(0)
            end

            last   = ''
            index  = -1
            
            while line = stream.readline rescue nil
                if line.match(/^From [^\s]+ .{24}/) && last.empty?
                    index += 1

                    if index >= to
                        line.seek(-line.length, IO::SEEK_CUR)
                        break
                    end
                end
            end
        end

        def unread?
            !self.headers['Status'].read rescue true
        end

        private

        def initialize (meta, headers, content)
            @meta    = meta
            @headers = headers
            @content = content

            @meta.normalize
            @headers.normalize
            @content.normalize
        end
    end
end
