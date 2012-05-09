#! /usr/bin/env ruby
require 'rubygems'
require 'mbox'

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

		EOF
	end

	let :box do
		Mbox.new(data)
	end

	it 'finds two mails' do
		box.length.should == 2
	end

	it 'parses headers properly' do
		box[0].headers.length.should == 2
		box[1].headers.length.should == 2
	end

	it 'parses multiline headers properly' do
		box[1].headers[:received].should == 'from mail.l.autistici.org [82.94.249.234] by internet with POP3 (fetchmail-6.3.21) for <meh@localhost> (single-drop); Fri, 06 Apr 2012 20:02:25 +0200 (CEST)'
	end

	it 'parses the content properly' do
		box[0].content.first.to_s.should == 'test'
		box[1].content.first.to_s.should == 'whattt'
	end
end
