#! /usr/bin/env ruby
require 'mbox'

if ARGV.length < 1
	abort 'You have to pass the mbox.'
end

Mbox.open(ARGV.shift).each {|mail|
	puts mail.headers.inspect
	puts "----------------------------------------------------------"
}
