
class A
  def initialize
  end

  def m1
  end

  def m2
  end
end

class B
  def initialize
  end

  def m1
    A.new
  end

  def m2
  end
end

class C
  def initialize
    d = A.new
    e = B.new
  end
end
