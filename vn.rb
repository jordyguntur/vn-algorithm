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

    expr =  "#{v1} #{s.op} #{v2}"
    # puts "Merp: #{expr}"
    v3, found = vn_search_add( expr )

    if found then
      puts "#{expr} is redundant"
      @unneeded << s
    end
    @n2v[ s.lhs ] = v3

    if(s.op == "+" || s.op == "-" || s.op == "*" || s.op == "/" || s.op == "<<" || s.op == ">>")

      # Commutative Property
      if (s.op == "+" || s.op == "*")
        expr_comm = "#{v2} #{s.op} #{v1}"
        v4, found_comm = vn_search_add( expr_comm )
      end

      # Stewart Extensions:

      # Addition
      if (s.op == "+")
        # b = a - c
        expr_stew1 = "#{v3} - #{v2}"
        # puts "#{expr_stew1}"
        v5, found_stew1 = vn_search_add( expr_stew1 )

        # c = a - b
        expr_stew2 = "#{v3} - #{v1}"
        # puts "#{expr_stew2}"
        v6, found_stew2 = vn_search_add( expr_stew2 )
      end

      # Subtraction
      if (s.op == "-")
        # b = a + c
        expr_stew3 = "#{v3} + #{v2}"
        # puts "#{expr_stew3}"
        v5, found_stew3 = vn_search_add( expr_stew3 )

        # c = b - a
        expr_stew4 = "#{v1} - #{v3}"
        # puts "#{expr_stew4}"
        v6, found_stew4 = vn_search_add( expr_stew4 )
      end
      
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
