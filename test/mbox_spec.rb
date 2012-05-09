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
	end

	it 'parses the content properly' do
		box[0].content.first.to_s.should == 'test'
		box[1].content.first.to_s.should == 'whattt'
	end
end
