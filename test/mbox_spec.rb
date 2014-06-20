#! /usr/bin/env ruby
require 'rubygems'
require 'mbox'

require 'pry-debugger'

describe Mbox do
	let :data do
		<<-EOF
From ecls-list-bounces@lists.sourceforge.net  Mon Apr  4 02:04:09 2011
Return-Path: <ecls-list-bounces@lists.sourceforge.net>
Delivered-To: meh@paranoici.org

test

From ecls-list-bounces@lists.sourceforge.net  Mon Apr  4 02:04:19 2011
>From meh  Mon Apr  4 02:04:19 2011
Return-Path: <ecls-list-bounces@lists.sourceforge.net>
Received: from mail.l.autistici.org [82.94.249.234]
	by internet with POP3 (fetchmail-6.3.21)
	for <meh@localhost> (single-drop); Fri, 06 Apr 2012 20:02:25 +0200 (CEST)


whattt

From ecls-list-bounces@lists.sourceforge.net  Mon Apr  4 02:04:19 2011
This: is a test
This: is a test for multiple headers with the same name
This: no, really

test

From ecls-list-bounces@lists.sourceforge.net  Mon Apr  4 02:04:19 2011
Received: from mail.l.autistici.org [82.94.249.234]
	by internet with POP3 (fetchmail-6.3.21)
	for <meh@localhost> (single-drop); Fri, 06 Apr 2012 20:02:25 +0200 (CEST)
Content-Type: multipart/alternative; boundary=047d7b5d5d7e4cbed804fae4837b

--047d7b5d5d7e4cbed804fae4837b
Content-Type: text/plain; charset=UTF-8

first message line 1

--047d7b5d5d7e4cbed804fae4837b
Content-Type: text/plain; charset=UTF-8

second message line 1
second message line 2

--047d7b5d5d7e4cbed804fae4837b--
		EOF
	end

	let :box do
		Mbox.new(data)
	end

	it 'finds two mails' do
		box.length.should == 4
	end

	it 'parses metadata properly' do
		box[0].metadata.from.first.name.should == 'ecls-list-bounces@lists.sourceforge.net'
	end

	it 'parses headers properly' do
		box[0].headers.length.should == 2
		box[1].headers.length.should == 2
	end

	it 'parses multiline headers properly' do
		box[1].headers[:received].should == 'from mail.l.autistici.org [82.94.249.234] by internet with POP3 (fetchmail-6.3.21) for <meh@localhost> (single-drop); Fri, 06 Apr 2012 20:02:25 +0200 (CEST)'
	end

	it 'parses multiple headers properly' do
		box[2].headers[:this].should == ['is a test', 'is a test for multiple headers with the same name', 'no, really']
	end

	it 'parses the content properly' do
		box[0].content.first.to_s.should == "test\n"
	end

	it 'parses the content properly when the first line is empty' do
		box[1].content.first.to_s.should == "\nwhattt\n"
	end

    it 'parses multipart text content properly' do
        box[3].content.length == 2;
        box[3].content[0].to_s.should == "first message line 1\n"
        box[3].content[1].to_s.should == "second message line 1\nsecond message line 2\n"
    end
end
