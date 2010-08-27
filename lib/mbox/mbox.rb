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

require 'forwardable'

require 'mbox/mail'

class Mbox
    extend Forwardable

    attr_accessor :name

    def initialize (what, options={})
        @internal = []

        if what.is_a?(File)
            @stream = what.reopen(what, 'r+:ASCII-8BIT')
        elsif what.is_a?(String)
            @stream = StringIO.new(what, 'r+:ASCII-8BIT')
        else
            raise Error.new 'I do not know what to do.'
        end

        if options['parse'] != false
            self.parse(options)
        end
    end

    def self.open (name, box)
        begin
            mbox      = Mbox.new(File.new("#{box}/#{name}", 'r'))
            mbox.name = name

            return mbox
        rescue
            return nil
        end
    end

    def parse (options)
        Mbox.def_delegators :@internal, :[], :each, :length, :size, :first, :last

        while mail = Mail.parse(@stream, options)
            @internal << mail
        end
    end

    def [] (index, options={})
        Mail.seek(@stream, index)

        @internal[index] = Mail.parse(@stream)
    end

    def new?
        self.each {|mail|
            if mail.headers['Status'].new
                return true
            end
        }

        return false
    end
end
