#!/usr/bin/ruby

require 'ruby-graphviz'

# Hold a list of classes
class MakeArray
  def initialize
    @ary = Array.new
  end

  def add cls, fname
    # print "Adding: " + cls + " " + fname + "\n"
    @ary << cls
  end

  def list
    @ary.each { |i|
      print i + "\n"
    }
  end

end

# The array to contain the class list
mk_ary = MakeArray.new

# Get all files in CWD and below that match
# pattern, store class names.
# First parse to get the class names
# PUT THIS IN A CLASS

end_count = 0
end_expected = 0                  # how many ends before class end
class_end_expected = 0            # how many class ends we expect (internal definitions)

Dir.glob("**/*.rb") do |file| # note one extra "*" for recursion

  next if file == '.' or file == '..'

  # puts "working on: #{file}..."
  File.open(file) do |f|
    f.each_line do |line|
      # print "cee = " + class_end_expected.to_s + " ee " + end_expected.to_s + "\n"
      case line
      when /^\s*#/
        nil
      when /^\s*elsif/
        nil
      when /^\s*class[\s]+/
        mk_ary.add line.split(' ')[1], file
        class_end_expected += 1
        # print "class LINE: cee = " + class_end_expected.to_s + " ce = " + end_expected.to_s + " line = " + line
      when /^\s*begin/
        # print "begin\n"
        end_expected += 1
      when /^.*if /
        # print "if\n"
        end_expected += 1
      when /^\s*def /
        end_expected += 1
        # print "def cee = " + class_end_expected.to_s + "  " + "ce = " + end_expected.to_s + "\n"
      when /^.* do/
        # print "do - " + line + "\n"
        end_expected += 1
      when /^\s*case/
        # print "case\n"
        end_expected += 1
      when /^\s*end[\s.]/
        # print "An End " + line
        if end_expected == 0
          if class_end_expected > 0
            class_end_expected -= 1
            mk_ary.add "End", file
            # print "END OF CLASS LINE:: " + line
          end
        else
          end_expected -= 1
        end
        # print "END: cee = " + class_end_expected.to_s + " ce = " + end_expected.to_s + " line = " + line
      end      # case
    end
  end
end

# Print the list of classes
mk_ary.list


# sort_ary ary
# make_dot ary
# make file
# call dot filename


