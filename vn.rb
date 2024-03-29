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

    v00, found_ident0 = vn_search_add("0")
    v01, found_ident1 = vn_search_add("1")

    # Zero Identity
    expr_ident0 = "#{v} + #{v00}"
    v011, found_ident0 = vn_search_add( expr_ident0 )
    expr_ident1 = "#{v00} + #{v}"
    v012, found_ident1 = vn_search_add( expr_ident1 )

    # One Identity
    expr_ident2 = "#{v} * #{v01}"
    v013, found_ident2 = vn_search_add( expr_ident2 )
    expr_ident3 = "#{v01} * #{v}"
    v014, found_ident3 = vn_search_add( expr_ident3 )
 end
    
  def vn_expr_stmt( s )
    # s.lhs = s.op1 s.op s.op2

    # Constants
    v00, found_ident0 = vn_search_add("0")
    v01, found_ident1 = vn_search_add("1")
    v02, found_ident2 = vn_search_add("2")

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

    if((s.op == "+" || s.op == "-" || s.op == "*" || s.op == "/" || s.op == "<<" || s.op == ">>")) 
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
        v6, found_stew4 = vn_search_add( expr_stew4 )

      end

      # Multiplication
      if (s.op == "*")

        # a = 2 * b
        if (s.op1 == "2")
          expr_ident2 = "#{v2} + #{v2}"
          v021, found_ident2 = vn_search_add( expr_ident2 )

          expr_lshift = "#{v2} << #{v01}"
          v023, found_ident2 = vn_search_add( expr_lshift )
        elsif (s.op2 == "2")
          expr_ident3 = "#{v1} + #{v1}"
          v022, found_ident3 = vn_search_add( expr_ident3 )

          expr_lshift = "#{v2} << #{v01}"
          v023, found_ident2 = vn_search_add( expr_lshift )
        end

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
        # b = a >> c
        expr_stew9 = "#{v3} >> #{v2}"
        v11, found_stew9 = vn_search_add( expr_stew9 )

        # c = a >> b
        expr_stew10 = "#{v3} >> #{v1}"
        v12, found_stew10 = vn_search_add( expr_stew10 )
      end

      # Right Shift Operator
      if (s.op == ">>")
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
