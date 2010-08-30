#! /usr/bin/env ruby
require 'socket'
require 'json'
require 'festivaltts4r'

HOST = 'localhost'
PORT = 9001

EVERY = 120

while true
    socket = TCPSocket.new(HOST, PORT) rescue nil

    if !socket
        redo
    end

    socket.puts '* list unread'
    unread = JSON::parse(socket.gets)
    socket.close

    if !unread.empty?
        text = 'You got mail into '

        unread.each {|mbox|
            text << "#{mbox} and "
        }

        text[0, text.length - 4].to_speech
    end

    sleep EVERY
end
