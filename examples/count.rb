#! /usr/bin/env ruby
require 'mbox'

if ARGV.length < 1
	abort 'You have to pass the mbox.'
end

puts Mbox.open(ARGV.shift).length
