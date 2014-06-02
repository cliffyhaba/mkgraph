#!/usr/bin/ruby

# Author:: Cliff
# Version:: 1v0

require 'logger'
require 'toc'
require 'part'

# =A template FileSystem class
# - Can derive from this to implement file systems in RAM, flash etc.
class FileSystem

  # do any parent initialising
  def initialize size
    # print "Parent of " + self.class.name + " Initialising...\n"
  end

  def format
    @toc.reset
    @part.get_part.fill(0xff)
  end
  
  # Read a file from FS
  def readFile name
  end

  # Write a file to FS
  def writeFile name, data
  end
  
  # print table of contents in hex
  def dump_toc
  end

  # print data portion of disk in hex
  def dump_data
  end

  # print all disk partition in hex
  def dump_all
  end
end

# =A specific FileSystem class, uses RAM as disk
class MemFileSystem < FileSystem

  private
  attr_accessor :toc, :part
  
  public
  
  def initialize size
    # print "Initialising child\n"
    if 0 != size % 64
      raise "Please use a size which is a multiple of 16" + " - " + __FILE__ + " " + __LINE__.to_s
    elsif size < 128
      raise "Minimum disk size is 128 bytes" + " - " + __FILE__ + " " + __LINE__.to_s
    else
      super
      @size = size
      @toc = Toc.new @size / 4
      @part = Partition.new (@size / 4) * 3
    end
    $LOG.info "Initialised MemFileSystem Instance"
  end

  # Format the media
  def format
    @toc.reset
    @part.get_part.fill(0xff)
  end
  
  def readFile name
    offset = @toc.get_offset name
    length = @toc.get_length name
    if nil == offset || nil == length
      raise "File Not Found" + " - " + __FILE__ + " " + __LINE__.to_s
    else
      @part.take offset, length
    end
  end
  
  def writeFile name, data
    # Add name to TOC
    req = data.length
    rem = @part.get_rem
    if req > rem
      raise "Out of Disk Space" + " - " + __FILE__ + " " + __LINE__.to_s
    end
    
    @toc.get_toc.each { |i|
      print "!!!!! get_toc " + i.get_fname + "\n"
      if i.get_fname == name
        raise "File Already Exists: " + name + " - " + __FILE__ + " " + __LINE__.to_s
      end      
    }
    
    # Check we have the space available
    offset = @toc.add name, req
    print "WRITE] size available is: " + rem.to_s + "\n"
    print "WRITE] size required  is: " + req.to_s + "\n"
        
    # Shove it in, we know it will fit ;-o oooooh!!
    # @toc.insert st,data
    # @part.insert st, data
    
    if offset != -1
      @part.add data, offset
    else 
      raise "Cannot write TOC" + " - " + __FILE__ + " " + __LINE__.to_s
    end
  end

  def delFile name
    @toc.del name
  end

  def lst
    @toc.list.each { |l|
      print l + "\n"
    }    
  end
  
  # Display Table of Contents in hex
  def dump_toc
    print "\n***** TOC"
    @toc.get_toc.each { |t|
      dump t.get_byte_rec
    }    
  end

  # Display data in hex
  def dump_part
    dump @part.get_part
  end

  # Return all disk as binary array
  def get_byte_disk
    ary = Array.new
    @toc.get_toc.each { |t|
      ary << t.get_byte_rec
    }
    ary << @part.get_part    
    ary.flatten
  end
  
  private

end
