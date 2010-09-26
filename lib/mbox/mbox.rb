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

require 'forwardable'

require 'mbox/mail'

class Mbox
    # Open a mbox by its name and the directory where the mbox is.
    def self.open (name, box, options={})
        mbox      = Mbox.new(File.new("#{box}/#{name}", 'r'), options)
        mbox.name = name

        return mbox
    end

    extend Forwardable

    attr_accessor :name, :at

    # Create a mbox from a File or String object
    def initialize (what, options={})
        @internal = []

        if what.is_a?(File)
            @stream = what.reopen(what, 'r+:ASCII-8BIT')
            @name   = File.basename(what.path)
        elsif what.is_a?(String)
            @stream = StringIO.new(what, 'r+:ASCII-8BIT')
        else
            raise Error.new 'I do not know what to do.'
        end

        if options[:parse] != false
            self.parse(options)
        end
    end

    # Parse the mbox.
    #
    # The whole stream gets read, so bigger the mbox slower the process, you can use some
    # stuff even if you don't parse the whole mbox.
    #
    # When parsed most Array methods gets forwarded to the Mbox instance.
    def parse (options={})
        if @parsed
            return false
        end

        @parsed = true
        counter = 0

        while true
            if @internal[counter]
                Mail.seek(@stream, 1, IO::SEEK_CUR)
                next
            end

            if mail = Mail.parse(@stream, options)
              @internal[counter]  = mail
              counter            += 1
            end

            if @stream.eof?
                break
            end
        end

        @internal.compact!

        @at = Time.now

        Mbox.def_delegators :@internal, :[], :each, :length, :size, :first, :last, :all?, :any?, :chunk, :collect, :count, :cycle, :detect, :entries, :find, :find_all, :grep, :group_by, :include?, :map, :max, :max_by, :member?, :min, :min_by, :none?, :one?, :reject, :reverse_each, :select, :sort, :sort_by, :take, :to_a, :zip

        return true
    end

    # Access the Mail in that position without parsing everything.
    def [] (index, options={})
        if @internal[index]
            return @internal[index]
        end

        Mail.seek(@stream, index)

        @internal[index] = Mail.parse(@stream)
    end

    # Count the number of emails in the inbox without parsing everything.
    def length
        if @count
            return @count
        end

        @stream.seek(0)

        @count = Mail.count(@stream)
    end

    alias size length

    # Returns true if some emails are unread. 
    def has_unread?
        self.parse

        self.each {|mail|
            if !mail.headers['Status'].read
                return true
            end
        }

        return false
    end

    def inspect # :nodoc:
        "#<Mbox:#{@name} length=#{self.length}>"
    end
end
