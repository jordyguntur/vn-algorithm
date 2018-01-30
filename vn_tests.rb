require_relative 'block.rb'
require_relative 'vn.rb'

module TestProgs
  def progs_n_answers
    @answers = Hash.new{ |hash, key| hash[key] = Array.new }

    @trivial = Block.new( "trivial" ) do |b|
      s1 = Stmt.new( "a", "b", "+", "c" )
      s2 = Stmt.new( "a", "b", "+", "c" )
      b.code << s1 << s2
      @answers[b] << s2
    end

    @cocke_allen = Block.new( "Cocke Allen 1971" ) do |b|
      s1 = Stmt.new( "x", "a", "*", "b" )
      s2 = Stmt.new( "c", "a" )
      s3 = Stmt.new( "y", "c", "*", "b" )
      b.code << s1 << s2 << s3
      @answers[b] << s3
    end

    @tricky = Block.new( "tricky" ) do |b|
      s1 = Stmt.new( "a", "b", "+", "c" )
      s2 = Stmt.new( "a", "c", "+", "b" )
      b.code << s1 << s2
      @answers[b] << s2 
    end

    @intricate = Block.new( "stewart" ) do |b|
      s1 = Stmt.new( "e", "f", "+", "g" )
      s2 = Stmt.new( "h", "e", "-", "f" )
      b.code << s1 << s2
      @answers[b] << s2
    end

    @intricate2 = Block.new( "stewart2" ) do |b|
      s1 = Stmt.new( "e", "f", "+", "g" )
      s2 = Stmt.new( "x", "e", "-", "g" )
      s3 = Stmt.new( "z", "e", "-", "f" )
      b.code << s1 << s2 << s3
      @answers[b] << s2 << s3
    end

    @intricate3 = Block.new( "stewart3" ) do |b|
      s1 = Stmt.new( "a", "b", "-", "c" )
      s2 = Stmt.new( "x", "a", "+", "c" )
      s3 = Stmt.new( "z", "b", "-", "a" )
      b.code << s1 << s2 << s3
      @answers[b] << s2 << s3
    end

    @intricate4 = Block.new( "stewart4" ) do |b|
      s1 = Stmt.new( "a", "b", "*", "c" )
      s2 = Stmt.new( "x", "a", "/", "c" )
      s3 = Stmt.new( "z", "a", "/", "b" )
      b.code << s1 << s2 << s3
      @answers[b] << s2 << s3
    end

    @intricate5 = Block.new( "stewart5" ) do |b|
      s1 = Stmt.new( "a", "b", "/", "c" )
      s2 = Stmt.new( "x", "a", "*", "c" )
      s3 = Stmt.new( "z", "b", "/", "a" )
      b.code << s1 << s2 << s3
      @answers[b] << s2 << s3
    end

    @intricate6 = Block.new( "stewart6" ) do |b|
      s1 = Stmt.new( "a", "b", "<<", "c" )
      s2 = Stmt.new( "x", "a", ">>", "c" )
      s3 = Stmt.new( "z", "a", ">>", "b" )
      b.code << s1 << s2 << s3
      @answers[b] << s2 << s3
    end

    @intricate7 = Block.new( "stewart7" ) do |b|
      s1 = Stmt.new( "a", "b", ">>", "c" )
      s2 = Stmt.new( "x", "a", "<<", "c" )
      s3 = Stmt.new( "z", "a", "<<", "b" )
      b.code << s1 << s2 << s3
      @answers[b] << s2 << s3
    end

    @intricate8 = Block.new( "stewart8" ) do |b|
      s1 = Stmt.new( "a", "b", "+", "c" )
      s2 = Stmt.new( "e", "a" )
      s3 = Stmt.new( "d", "e", "-", "b" )
      b.code << s1 << s2 << s3
      @answers[b] << s3
    end

    @constant = Block.new( "constant" ) do |b|
      s1 = Stmt.new( "a", "2", "*", "b" )
      s2 = Stmt.new( "c", "b", "+", "b" )
      b.code << s1 << s2
      @answers[b] << s2
    end

    @constant2 = Block.new( "constant2" ) do |b|
      s1 = Stmt.new( "a", "b" )
      s2 = Stmt.new( "c", "b", "+", "0" )
      s3 = Stmt.new( "d", "0", "+", "b" )
      b.code << s1 << s2 << s3
      @answers[b] << s2 << s3
    end

    @constant3 = Block.new( "constant3" ) do |b|
      s1 = Stmt.new( "a", "b" )
      s2 = Stmt.new( "c", "b", "*", "1" )
      s3 = Stmt.new( "d", "1", "*", "b" )
      b.code << s1 << s2 << s3
      @answers[b] << s2 << s3
    end

    @shift = Block.new( "shift" ) do |b|
      s1 = Stmt.new( "a", "2", "*", "b")
      s2 = Stmt.new( "d", "b", "<<", "1")
      b.code << s1 << s2
      @answers[b] << s2
    end
  end
end

describe LVN do
  include TestProgs

  before do
    progs_n_answers
  end

  it "trivial case" do
    expect( LVN.new( @trivial ).unneeded ).to eq( @answers[@trivial] )
  end

  it "cocke-allen 1971" do
    expect( LVN.new( @cocke_allen ).unneeded ).to eq( @answers[@cocke_allen] )
  end

  it "tricky" do
    expect( LVN.new( @tricky ).unneeded ).to eq( @answers[@tricky] )
  end

  it "Christopher Charles Stewart" do
    expect( LVN.new( @intricate ).unneeded ).to eq( @answers[@intricate] )
  end

  it "Stewart Extension (Addition)" do
    expect( LVN.new( @intricate2 ).unneeded ).to eq( @answers[@intricate2] )
  end

  it "Stewart Extension (Subtraction)" do
    expect( LVN.new( @intricate3 ).unneeded ).to eq( @answers[@intricate3] )
  end

  it "Stewart Extension (Multiplication)" do
    expect( LVN.new( @intricate4 ).unneeded ).to eq( @answers[@intricate4] )
  end

  it "Stewart Extension (Division)" do
    expect( LVN.new( @intricate5 ).unneeded ).to eq( @answers[@intricate5] )
  end

  it "Stewart Extension (Left Shift)" do
    expect( LVN.new( @intricate6 ).unneeded ).to eq( @answers[@intricate6] )
  end

  it "Stewart Extension (Right Shift)" do
    expect( LVN.new( @intricate7 ).unneeded ).to eq( @answers[@intricate7] )
  end

  it "Stewart Extension (Note 2 Test)" do
    expect( LVN.new( @intricate8 ).unneeded ).to eq( @answers[@intricate8] )
  end

  it "constant" do
    expect( LVN.new( @constant ).unneeded ).to eq( @answers[@constant] )
  end

  it "constant (with 0)" do
    expect( LVN.new( @constant2 ).unneeded ).to eq( @answers[@constant2] )
  end

  it "constant (with 1)" do
    expect( LVN.new( @constant3 ).unneeded ).to eq( @answers[@constant3] )
  end

  it "shift" do
    expect( LVN.new( @shift ).unneeded ).to eq( @answers[@shift] )
  end
end


