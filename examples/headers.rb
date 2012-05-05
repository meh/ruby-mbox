#! /usr/bin/env ruby
require 'mbox'

if ARGV.length < 1
	puts 'You have to pass the mbox.'

	exit 1
end

Mbox.open(ARGV.shift).each {|mail|
	puts mail.headers.inspect
	puts "----------------------------------------------------------"
}
