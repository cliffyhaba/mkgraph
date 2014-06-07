#!/usr/bin/ruby -W0

require 'rubygems'
require 'test/unit'
require 'mkgraph'

$LOAD_PATH <<'.'<<'lib'


me = File::basename($0)

if ARGV.size > 0
  file_pattern = ARGV[0]
  if file_pattern == "me"
    file_pattern = me
    me = "XXXXX"
    print "me = " + me
  else
	if ! File.exist?(ARGV[0])
	  print "Cannot find file " + ARGV[0] + "\n"
	  exit 1
	end
  end
else
  file_pattern = "**/*.rb"
end

# print "File pattern is " + file_pattern + "\n"
a = Mkgraph.new file_pattern

a.run

a.make_image

exit 0

