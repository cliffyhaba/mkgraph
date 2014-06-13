
a = A.new
E.new

class E
  def initialize
  end
end

class A
  def initialize
  end

  def m1
    d = D.new  
    E.new
  end

  def m2
    b = B.new
  end
end

class B
  def initialize
  end

  def m1
    A.new
  end

  def m2
    C.new
  end
end

class C
  def initialize
    A.new
    B.new
  end
end


class D
  def initialize
    # E.new
  end
end

class l
  def initialize
  end
end

=begin
class p
  def initialize
  end
end  
=end