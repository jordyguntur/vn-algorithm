class Stmt
  attr_reader :lhs, :op1, :op, :op2

  def initialize( lhs, op1, op=nil, op2=nil )
    @lhs, @op1, @op, @op2 = lhs, op1, op, op2
    return self
  end

  def to_s
    return "#{@lhs} = #{@op1}" if @op==nil
    return "#{@lhs} = #{@op1} #{@op} #{@op2}"
  end

  alias_method :gen_code, :to_s

  def ==(t)
    return to_s == t.to_s
  end
end

class Block
  attr_reader :code

  def initialize( name = "" )
    @name = name
    @code = Array.new
    yield self
  end
    
  def to_s
    block = '// ' + "code block #{@name}\n" + @code.inject(""){ |blk, stmt| blk += stmt.to_s + "\n" }
    return block
  end

  alias_method :gen_code, :to_s

end
