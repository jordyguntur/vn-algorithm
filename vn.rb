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

    puts "v1:   #{v1}"
    puts "v2:   #{v2}"
    puts "v3:   #{v3}"

    if((s.op == "+" || s.op == "-" || s.op == "*" || s.op == "/" || s.op == "<<" || s.op == ">>")) 
      # Commutative Property
      if (s.op == "+" || s.op == "*")
        expr_comm = "#{v2} #{s.op} #{v1}"
        v4, found_comm = vn_search_add( expr_comm )
      end

      # Stewart Extensions:

      # Addition
      if (s.op == "+")
        puts "Stewart Addition"
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
        puts "Stewart Subtraction"
        # b = a + c
        expr_stew3 = "#{v3} + #{v2}"
        # puts "#{expr_stew3}"
        v5, found_stew3 = vn_search_add( expr_stew3 )

        # c = b - a
        expr_stew4 = "#{v1} - #{v3}"
        v6, found_stew4 = vn_search_add( expr_stew4 )

      end

      # Multiplication
      if (s.op == "*")
        puts "Stewart Multiplication"
        # b = a / c
        expr_stew5 = "#{v3} / #{v2}"
        # puts "#{expr_stew5}"
        v7, found_stew5 = vn_search_add( expr_stew5 )

        # c = a / b
        expr_stew6 = "#{v3} / #{v1}"
        # puts "#{expr_stew6}"
        v8, found_stew6 = vn_search_add( expr_stew6 )
      end

      # Division
      if (s.op == "/")
        puts "Stewart Division"
        # b = a * c
        expr_stew7 = "#{v3} * #{v2}"
        # puts "#{expr_stew5}"
        v9, found_stew7 = vn_search_add( expr_stew7 )

        # c = b / a
        expr_stew8 = "#{v1} / #{v3}"
        # puts "#{expr_stew6}"
        v10, found_stew8 = vn_search_add( expr_stew8 )
      end

      # Left Shift Operator
      if (s.op == "<<")
        puts "Stewart Left Shift"
        # b = a >> c
        expr_stew9 = "#{v3} >> #{v2}"
        v11, found_stew9 = vn_search_add( expr_stew9 )

        # c = a >> b
        expr_stew10 = "#{v3} >> #{v1}"
        v12, found_stew10 = vn_search_add( expr_stew10 )
      end

      # Right Shift Operator
      if (s.op == ">>")
        puts "Stewart Right Shift"
        # b = a << c
        expr_stew11 = "#{v3} << #{v2}"
        v13, found_stew11 = vn_search_add( expr_stew11 )

        # c = a << b
        expr_stew12 = "#{v3} << #{v1}"
        v14, found_stew12 = vn_search_add( expr_stew12 )
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
