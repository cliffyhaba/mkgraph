#!/usr/bin/ruby

require 'rubygems'
require 'ruby-graphviz'
require 'tree'

begin
  file_pattern = ARGV[0]
rescue
file_pattern = "**/*.rb"
# file_pattern = "test.rb"
end

me = File::basename($0)

# Get all files in CWD and below that match
# pattern, store class names.
# First parse to get the class names
# PUT THIS IN A CLASS

end_count = 0
end_expected = 0                  # how many ends before class end
class_end_expected = 0            # how many class ends we expect (internal definitions)


$root_node = Tree::TreeNode.new("Entry Point", "The calling program")
tnode = $root_node

cname = ""
in_class = false
SPACE = "\t\t\t"
parent_class_name = nil
print_parent = true

def find_leaf root, sname
  
  print "find_leaf searching for: [" + sname + "] This Root is " + root.name + "\n"
  r = root
  
  if root != nil && root.name != sname
    root.children { |child|    
      r = find_leaf child, sname
      break if r.name == sname  
    }
  else
    print "NIL OR FOUND [" + root.name + "]\n"
    r = root  
  end
  print "find_leaf returning: [" + r.name + "]\n"
  r
end

def proc_node root, par, child, join_to_root
  begin
    if join_to_root == true
      $root_node << Tree::TreeNode.new(child, "*Child*")
    else
      print "NEED TO ATTACH " + child + " TO: " + par + "\n"
      r = find_leaf root, par
      print "AFTER FIND_LEAF: " + r.name + "\n"
      r << Tree::TreeNode.new(child, "*Child*")
    end
  rescue Exception => e
    print e.message + "\n"
    print "***** Processing node " + "None" + " --> " + child.to_s + "\n"    
  end
  # $root_node.printTree
  root
end

Dir.glob(file_pattern) do |file| # note one extra "*" for recursion

  next if file == '.' or file == '..' or file == me

  File.open(file) do |f|
    f.each_line do |line|

      case line
      when /^\s*#/
        nil
      when /\.new/
        name = line.split('.new')
        cname = name[0].split.last
        if in_class == true
          # print "NEW INSTANCE OF CLASS = [" + cname + "] created in class " + parent_class_name + "\n"        
          tnode = proc_node tnode, parent_class_name, cname, false
        else
          if true == print_parent
            # print "NEW INSTANCE OF CLASS = [" + cname + "] created outside any parent class\n"                  
            tnode = proc_node tnode, parent_class_name, cname, true
          end
        end
      when /^\s*elsif/
        nil
      when /^\s*class[\s]+/
        parent_class_name = line.split(' ')[1]
        class_end_expected += 1
        in_class = true
        if print_parent == true
          print "Start of class " + parent_class_name + "\n"
        end
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
            if print_parent == true
              print "End of class " + parent_class_name + "\n"
            end
            parent_class_name = nil
          end
        else
          end_expected -= 1
        end
      end      # case
    end
  end
end

def make_g g, root
  if root.hasChildren? == true
    root.children { |child|      
      make_g g, child
    }
  end
  g.add_node root.name
  if ! root.isRoot?
    # Add an edge to the parent
    g.add_edge(root.parent.name, root.name, :label => root.parent.name + " uses " + root.name, :color => "blue")    
  end
  g
end

begin  #make a dot file

  g = GraphViz.new( :G, :type => :digraph)

  root = $root_node
  
  # Add root and then recursively add all children of the root node
  g.add_node(root.name)
  g = make_g g, root
    
  g.output( :png => "prog.png")

end

