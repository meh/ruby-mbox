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

class Mbox
    class Mail
        class Meta
            attr_reader :from

            def initialize
                @from = []
            end

            def normalize
#                if matches = line.match(/^>*From ([^\s]+) (.{24})/)
#                    @from << Struct.new(:name, :date).new(matches[1], matches[2])
#                end
            end
        end
    end
end
