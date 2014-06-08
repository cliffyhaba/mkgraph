
a = A.new

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
    c = C.new
  end
end

class C
  def initialize
    d = A.new
    e = B.new
  end
end


class D
  def initialize
    c = E.new
  end
end
