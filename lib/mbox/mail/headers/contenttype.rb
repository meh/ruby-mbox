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

class Mbox
    class Mail
        class Headers < Hash
            class ContentType
                attr_accessor :mime, :charset, :boundary

                def self.parse (text)
                    stuff = text.split(/;\s*/)
                    type  = stuff.shift

                    ContentType.new(Hash[stuff.map {|stuff| stuff.split(/=/)}].merge({ :mime => type }))
                end

                def initialize (stuff={})
                    @mime     = stuff[:mime] || 'text/plain'
                    @charset  = stuff[:charset]
                    @boundary = stuff[:boundary]
                end

                def to_s
                    "#{self.mime}#{"; #{self.charset}" if self.charset}"
                end
            end
        end
    end
end
