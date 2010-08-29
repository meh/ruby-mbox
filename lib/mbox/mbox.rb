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

    def self.open (name, box, options={})
        begin
            mbox      = Mbox.new(File.new("#{box}/#{name}", 'r'))
            mbox.name = name

            return mbox
        rescue
            puts $!
            return nil
        end
    end

    attr_accessor :name, :at

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

    def parse (options)
        Mbox.def_delegators :@internal, :[], :each, :length, :size, :first, :last, :all?, :any?, :chunk, :collect, :count, :cycle, :detect, :entries, :find, :find_all, :grep, :group_by, :include?, :map, :max, :max_by, :member?, :min, :min_by, :none?, :one?, :reject, :reverse_each, :select, :sort, :sort_by, :take, :to_a, :zip

        while mail = Mail.parse(@stream, options)
            @internal << mail
        end

        @at = Time.now
    end

    def [] (index, options={})
        Mail.seek(@stream, index)

        @internal[index] = Mail.parse(@stream)
    end

    def has_unread?
        self.each {|mail|
            if !mail.headers['Status'].read
                return true
            end
        }

        return false
    end
end
