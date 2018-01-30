require './block'

class LVN
  attr_reader :orig, :unneeded

  def initialize(stmts)
    @n2v, @orig = Hash.new, stmts
    @last_vn = 1
    @unneeded = [ ]
    run_lvn
  end

  private
  def vn_search_add( str )
    return @n2v[str], true if @n2v[str] != nil
    @last_vn = @last_vn + 1
    @n2v[str] =  @last_vn
    return @last_vn, false
  end

  def vn_copy_stmt( s )
    # s.lhs = s.op1
    v, found = vn_search_add( s.op1 )
    @n2v[ s.lhs ] = v
 end
    
  def vn_expr_stmt( s )
    # s.lhs = s.op1 s.op s.op2
    v1, found = vn_search_add( s.op1 )
    v2, found = vn_search_add( s.op2 )

    # Commutative Property Check
    if (s.op == "+" || s.op == "*") 
      expr =  "#{v1} #{s.op} #{v2}"
      v3, found = vn_search_add( expr )

      expr_comm = "#{v2} #{s.op} #{v1}"
      v4, found_comm = vn_search_add( expr_comm )

      # if (s.op == "+")
      #   expr_stew1 = ""
      # end


      if found then
        puts "#{expr} is redundant"
        @unneeded << s
      end
      @n2v[ s.lhs ] = v3

    else 
      expr =  "#{v1} #{s.op} #{v2}"
      v3, found = vn_search_add( expr )

      if found then
        puts "#{expr} is redundant"
        @unneeded << s
      end
      @n2v[ s.lhs ] = v3  
    end
  end

  def run_lvn
    @orig.code.each do |s|
      puts "analyze #{s}"
      if s.op == nil
        vn_copy_stmt( s )
      else
        vn_expr_stmt( s )
      end
    end
  end

end
