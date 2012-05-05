#! /usr/bin/env ruby
require 'mbox'

if ARGV.length < 1
	puts 'You have to pass the mbox.'

	exit 1
end

puts Mbox.open(ARGV.shift).length
