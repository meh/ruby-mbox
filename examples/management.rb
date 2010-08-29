#! /usr/bin/env ruby
require 'thread'
require 'socket'
require 'json'

require 'mbox'

LISTEN = 'localhost'
PORT   = 9001

MAILDIR   = "#{ENV['HOME']}/mail"
MAILBOXES = ['inbox', 'tracemonkey', 'mozilla']
EVERY     = 120

DATA = {
    :mboxes => {}
}

Thread.new {
    server = TCPServer.new(LISTEN, PORT)

    while socket = server.accept
        command = socket.readline

        if !(matches = command.match(/^(\w+)\s*(.*)$/))
            socket.close
            next
        end

        command = matches[2]

        case matches[1]

        when 'get'
            if !(matches = command.match(/^(\w+)\s*(.*)$/))
                socket.close
                next
            end

            command = matches[2]

            case matches[1]

            when 'unread'
                if command == 'list'
                    socket.write(DATA[:mboxes].map {|mbox| mbox[0] if mbox[1].has_unread?}.compact.to_json)
                end

            end

        end


        socket.close
    end
}

last = Time.now - EVERY - 1

while true
    if (last + EVERY) < Time.now
        `fetchmail &> /dev/null`
        last = Time.now
    end

    sleep 3

    MAILBOXES.each {|mailbox|
        if mbox = DATA[:mboxes][mailbox]
            if mbox.at > File.ctime("#{MAILDIR}/#{mailbox}")
                next
            end
        end

        DATA[:mboxes][mailbox] = Mbox.open(mailbox, MAILDIR, { :headersOnly => true })
    }
end
