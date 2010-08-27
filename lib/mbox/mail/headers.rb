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

require 'mbox/mail/header'

class Mbox
    class Mail
        class Headers < Hash
            def initialize (headers={})
                self.merge!(headers)
            end

            def normalize
                status = Struct.new(:new, :old)

                if !self['Status']
                    self['Status'] = status.new(true, false)
                else
                    self['Status'] = status.new(!self['Status'].include?('R'), self['Status'].include?('O'))
                end
            end

            def inspect
                result = ''

                self.each {|name, value|
                    result << "#{name}: #{value}\n"
                }

                return result
            end
        end
    end
end
