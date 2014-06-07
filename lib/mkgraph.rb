
#
## $Author :: Cliff
## $Version:: 1v0
##
##
#

require 'rubygems'
require 'graphviz'
require 'tree'
require 'logger'
require 'yaml'

#
# Example  : Mkgraph#new <ruby.rb> - initialise 
#            Mkgraph#run           - process file
#            Mkgraph#make_image    - create the image file
#            Mkgraph#show_image    - display the image file
#
# Arguments: The file to be visualised when creating a new instance
#
# Note     : A valid mgopts.yml must be in the working directory.
# ==           You could copy a template file from the gem installation directory.
#  

class Mkgraph

  #
  # Initialise 
  #
  # Params: The name of the file to be processed
  #
  def initialize pattern

    begin
      $yml = YAML.load_file 'mgopts.yml'
    rescue Exception => e
      print e.message + "\n"
      print "You could use the default \'mgopts.yml\' file in the installation\n"
      print "directory as a template.\n"
      print "Example:\n"

      tip = <<-EOS
        Log Options:
          format: brief   # brief or full
          output: stderr  # stderr, stdout or file name
          level: WARN     # INFO, WARN or FATAL
        Labels:
          root: Entry Point
          root comment: The Root Comment
        Output:
          image name: view.png      
      EOS

      puts "#{tip}"
      exit 1
    end

    # puts $yml['sectionA']['user'] + "**************\n"
    # puts $yml['sectionB']['file'] + "**************\n"
    log_fmt = $yml['Log Options']['format']

    log_opt = $yml['Log Options']['output']
    case log_opt
    when 'stderr'
      log_op = $stderr
    when 'stdout'
      log_op = $stdout
    else
      log_op = log_opt
    end

    loglev = $yml['Log Options']['level']
    case loglev
    when 'INFO'
      ll = Logger::INFO
    when 'WARN'
      ll = Logger::WARN
    else
      ll = Logger::FATAL
    end

    @file_pattern = pattern

    $LOG = Logger.new(log_op).tap do |log|
      log.progname = 'mkgraph'
      log.level = ll # Logger::INFO # $yml['Log Options']['level']
      if log_fmt == 'brief'
        log.formatter = proc do |severity, datetime, progname, msg|
          "#{progname}: #{msg}\n"
        end
      end
    end

    $LOG.info "Pattern: " + @file_pattern
    # Rough test for OS TODO
    if RUBY_PLATFORM.include?("linux") == false
      $windows = true
    else
      $windows = false
    end
  end

  #
  # Does the work.
  # Params: None
  #
  def run
    end_count           = 0
    end_expected        = 0            # how many ends before class end
    class_end_expected  = 0            # how many class ends we expect (internal definitions)
    cname               = ""
    in_class            = false
    parent_class_name   = nil
    print_parent        = true

    $iname = $yml['Output']['image name']

    $root_node = Tree::TreeNode.new($yml['Labels']['root'], $yml['Labels']['root comment'])
    tnode = $root_node

    # Process all file matching @file_pattern
    Dir.glob(@file_pattern) do |file|

      $LOG.info "Looking at file - " + file
      ignore = false

      next if file == '.' or file == '..'

      # Process each line in the file
      File.open(file) do |f|
        f.each_line do |line|

          # Ignore =begin/=end blocks
          if line.match(/^=end/) != nil
            ignore = false
          elsif line.match(/^=begin/) != nil
            ignore = true
          else
            nil
          end

          next if ignore == true

          # Process the line read from file
          case line
          when /^\s*#/
            nil
          when /\s*when.*new/     # only to avoid this situation HERE
            nil
          when /\'\.new/          # only to avoid the situation in line.split('.new')
            nil
          when /\.new/
            name = line.split('.new')
            cname = name[0].split.last
            if in_class == true
              $LOG.debug "NEW INSTANCE OF CLASS = [" + cname + "] created in class " + parent_class_name
              tnode = proc_node tnode, parent_class_name, cname, false, false
            else
              if true == print_parent
                $LOG.debug "NEW INSTANCE OF CLASS = [" + cname + "] created outside any parent class"
                tnode = proc_node tnode, parent_class_name, cname, true, true
              end
            end
          when /^\s*elsif/
            nil
          when /^\s*class[\s]+/
            parent_class_name = line.split(' ')[1]
            class_end_expected += 1
            in_class = true
            if print_parent == true
              $LOG.info "Start of class " + parent_class_name
            end
            tnode = proc_node tnode, $root_node.name, parent_class_name, true, false
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
                if print_parent == true && parent_class_name != nil
                  $LOG.info "End of class " + parent_class_name
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
  end

  private
  # Recursive method used to find a name (ID) in the Tree object
  def find_leaf root, sname

    $LOG.debug "find_leaf searching for: [" + sname + "] This Root is " + root.name
    r = root

    if root != nil && root.name != sname
      root.children { |child|
        r = find_leaf child, sname
        break if r.name == sname
      }
    else
      $LOG.info "NIL OR FOUND [" + root.name + "]"
      r = root
    end
    $LOG.info "find_leaf returning: [" + r.name + "]"
    r
  end

  # Process a line of interest i.e. when a class is being
  # defined or instanciated etc. Called from the 'run' method
  def proc_node root, par, child, join_to_root, used
    begin
      if join_to_root == true
        if true == used
           $root_node << Tree::TreeNode.new(child, "child")
        else
           $root_node << Tree::TreeNode.new(child, "orphan")
        end
      else
        $LOG.info "NEED TO ATTACH " + child + " TO: " + par
        r = find_leaf root, par
        $LOG.info "AFTER FIND_LEAF: " + r.name
        r << Tree::TreeNode.new(child, "used")
      end
    rescue Exception => e
      $LOG.info e.message
      $LOG.info "***** Processing node " + "None" + " --> " + child.to_s
    end
    # $root_node.printTree

    root
  end

  # Recursive method to add elements from the Tree to the GraphViz Tree
  def add_element g, root
    if root.hasChildren? == true
      root.children { |child|
        add_element g, child
      }
    end

    if root.isRoot?
      g.add_node root.name, {:label => "{{" + root.name + "|" + root.content + "}|" + "Root}", :style => "filled", :fillcolor => "lightblue", :shape => "record", :color =>"black"}
    else
      g.add_node root.name , {:shape => "egg", :color =>"violet"}
    end

    if ! root.isRoot?
      # Add an edge to the parent
      if root.content == "orphan"
        g.add_edge(root.parent.name, root.name, :label => root.parent.name + " contains " + root.name, :color => "red", :fontcolor => "red")
      else
        g.add_edge(root.parent.name, root.name, :label => root.parent.name + " uses " + root.name, :color => "blue", :fontcolor => "blue")
      end

    end
    g
  end

  public
  # Use Graphviz to create the image file
  def make_image 
    g = GraphViz.new( :G, :rankdir => "TB", :type => :digraph, :bgcolor => "lightgrey", :nodesep => 0.85, :normalize => true, :concentrate => true)
    root = $root_node
    g = add_element g, root
    if $windows != true
      res = system("rm " + $iname + " > /dev/null")
    end
    begin
      g.output( :png => $iname)
    rescue Exception => e
      $LOG.warn e.message + "\n"
    end
  end

  # Display the image file
  def show_image 
    begin
      if $windows != true
        res = system("pkill eog; " + $yml['Osdep']['viewer'] + " " + $iname + " > /dev/null 2>&1")
      else
        res = system("call " + $yml['Osdep']['viewer'] + " " + $iname)
      end
      if res == false
        raise "Bad Command"
      end
    rescue Exception => e
      $LOG.info e.message
    end
  end    
end
