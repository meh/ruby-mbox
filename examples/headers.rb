#! /usr/bin/env ruby
require 'mbox'

if ARGV.length < 1
    puts "You have to pass the mbox."
    exit
end

mbox = Mbox.new(File.new(ARGV.shift))

mbox.each {|mail|
    puts mail.headers.inspect
    puts "----------------------------------------------------------"
}
