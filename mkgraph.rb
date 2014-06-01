#!/usr/bin/ruby

require 'rubygems'
require 'ruby-graphviz'
require 'tree'

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

me = File::basename($0)
# t = Tree
# The array to contain the class list
mk_ary = MakeArray.new

# Get all files in CWD and below that match
# pattern, store class names.
# First parse to get the class names
# PUT THIS IN A CLASS

end_count = 0
end_expected = 0                  # how many ends before class end
class_end_expected = 0            # how many class ends we expect (internal definitions)


#######################
root_node = Tree::TreeNode.new("START", "The calling program")

=begin
begin
  # ..... Now insert the child nodes.  Note that you can "chain" the child insertions for a given path to any depth.
  root_node << Tree::TreeNode.new("CHILD1", "Child1 Content abc ") << Tree::TreeNode.new("GRANDCHILD1", "GrandChild1 Content")
  root_node << Tree::TreeNode.new("CHILD2", "Child2 Content def ")
rescue Exception => e
  # print e.message + "\n"
  nil
end
grand_child1 = root_node["CHILD1"]["GRANDCHILD1"]
child2 = root_node["CHILD2"]

grand_child1 << Tree::TreeNode.new("abcdef", "abc")
grand_child1 << Tree::TreeNode.new("ghijkl", "abc") << Tree::TreeNode.new("ghijkl", "abc")
child2 << Tree::TreeNode.new("abcdef", "abc")
root_node.print_tree

exit 0
=end

#######################

cname = ""
in_class = false

Dir.glob("**/*.rb") do |file| # note one extra "*" for recursion

  next if file == '.' or file == '..' or file == me

  File.open(file) do |f|
    f.each_line do |line|

      case line
      when /\.new/
        name = line.split('.')
        cname = name[0]
        print "cname = " + cname + "\n"
        if name[0] != nil
          print "Class Instance " + name[0] + "\n"
        end
      when /^\s*#/
        nil
      when /^\s*elsif/
        nil
      when /^\s*class[\s]+/
        cname = line.split(' ')[1]
        mk_ary.add cname, file
        class_end_expected += 1
        in_class = true
        print "Start of class " + cname + "\n"
      when /^\s*begin/
        end_expected += 1
      when /^.*if /
        end_expected += 1
      when /^\s*def /
        end_expected += 1
      when /^.* do/
        end_expected += 1
      when /^\s*case/
        end_expected += 1
      when /^\s*end[\s.]/
        if end_expected == 0
          if class_end_expected > 0
            class_end_expected -= 1
            in_class = false
            print "End of class " + cname + "\n"
          end
        else
          end_expected -= 1
        end
      end      # case
    end
  end
end

# Print the list of classes
# mk_ary.list




# sort_ary ary
# make_dot ary
# make file
# call dot filename


