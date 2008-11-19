#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../lib/registermachine'
require 'optparse'

trace = false
registerc = nil
register = nil
ARGV.options do |o|
  o.banner = "#{File.basename $0} [-t] [-c COUNT] [-a LIST] <file>\n"
  o.separator('')

  o.on('-t', '--trace', 'trace commands') do |t|
    trace = t
  end
  
  o.on('-cCOUNT', '--count COUNT', Integer, 'register count') do |t|
    registerc = t
  end
  
  o.on('-a', '--assignment ASSIGNMENT', Array, 'register assignment, format is: 1,2,3') do |a|
    register = a.map { |e| Integer(e) }
  end
end

begin
  ARGV.parse!
rescue OptionParser::InvalidOption, OptionParser::InvalidArgument => e
  STDERR.puts e, ''
  STDERR.puts ARGV.options.to_s  
  exit 1
end

if ARGV.size < 1
  STDERR.puts 'not enough arguments', ''
  STDERR.puts ARGV.options.to_s  
  exit 1
end
file = ARGV.shift

if registerc
  if register
    rm = Registermachine.new(registerc, register)
  else
    rm = Registermachine.new(registerc)
  end
else
  rm = Registermachine.new
 end
rm.execute(File.read(file), trace)
