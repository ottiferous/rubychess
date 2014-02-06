
# encoding: UTF-8
class Board
  LETTERS = ("a".."h").to_a

  SYM_HASH = {
    :white_king   => "\u2654",
    :white_queen  => "\u2655",
    :white_rook   => "\u2656",
    :white_bishop => "\u2657",
    :white_knight  => "\u2658",
    :white_pawn   => "\u2659",

    :black_king   => "\u265A",
    :black_queen  => "\u265B",
    :black_rook   => "\u265C",
    :black_bishop => "\u265D",
    :black_knight => "\u265E",
    :black_pawn   => "\u265F"
  }

  #black moves up.
  attr_accessor :board
  def initialize(debug = false, board)
    @board = board = Array.new(8) { Array.new(8) { nil } }
    place_pieces unless debug == :debug

    nil
  end

  def dup
    duped_board = Board.new(:debug)

    (0...8).each do |row|
      (0...8).each do |col|
        unless self[[row,col]].nil?
          piece = self[[row,col]]
          duped_board[[row,col]] = self[[row,col]].class.new(
            piece.color,
            [row,col],
            duped_board,
            piece.symbol
          )
        end
      end
    end

    duped_board
  end

  def inspect
    draw_board
  end

  def [](pos)
    x, y = pos
    @board[y][x]
  end

  def []=(pos, piece)
    x, y = pos
    @board[y][x] = piece
  end

  def valid?(pos)
    x, y = pos
    (0...8).cover?(x) && (0...8).cover?(y)
  end

  def empty?(pos)
    x, y = pos
    @board[y][x].nil?
  end

  def place_pieces



    (0...8).to_a.each do |i|
      Pawn.new(:black, [i,6], self, SYM_HASH[:black_pawn])
      Pawn.new(:white, [i,1], self, SYM_HASH[:white_pawn])
    end

    Rook.new(:white, [7,0], self, SYM_HASH[:white_rook])
    Rook.new(:white, [0,0], self, SYM_HASH[:white_rook])
    Rook.new(:black, [0,7], self, SYM_HASH[:black_rook])
    Rook.new(:black, [7,7], self, SYM_HASH[:black_rook])

    Knight.new(:black, [1,7], self, SYM_HASH[:black_knight])
    Knight.new(:black, [6,7], self, SYM_HASH[:black_knight])
    Knight.new(:white, [1,0], self, SYM_HASH[:white_knight])
    Knight.new(:white, [6,0], self, SYM_HASH[:white_knight])

    Bishop.new(:white, [2,0], self, SYM_HASH[:white_bishop])
    Bishop.new(:white, [5,0], self, SYM_HASH[:white_bishop])
    Bishop.new(:black, [2,7], self, SYM_HASH[:black_bishop])
    Bishop.new(:black, [5,7], self, SYM_HASH[:black_bishop])

    Queen.new(:black, [4,7], self, SYM_HASH[:black_queen])
    Queen.new(:white, [4,0], self, SYM_HASH[:white_queen])

    King.new(:black, [3,7], self, SYM_HASH[:black_king])
    King.new(:white, [3,0], self, SYM_HASH[:white_king])

    nil
  end

  def draw_board
    # puts "\e[H\e[2J"
    print_letters

    @board.each_with_index do |row, index|
      print "#{8-index}  "
      row.each do |piece|
        if piece.nil?
          print "-"
        else
          print piece.symbol
        end
        print "."
      end
      print "  #{8-index}\n"
    end

    print_letters
    nil
  end

  def print_letters
    print "   "
    LETTERS.each do |i|
      print "#{i}."
    end
    print "\n"
  end

  def move(start_pos, end_pos)
    raise "No Start Piece" if self.empty?(start_pos)
    start_piece = self[start_pos]

    unless start_piece.valid_moves.include? end_pos
      raise "Invalid Move Location"
    end

    self[end_pos] = start_piece
    start_piece.pos = end_pos
    self[start_pos] = nil

    true
  end

  def move!(start_pos, end_pos)

    start_piece = self[start_pos]
    self[end_pos] = start_piece
    start_piece.pos = end_pos
    self[start_pos] = nil

    true
  end

  def in_check?(color)
    king_pos = all_pieces(color).select { |p| p.is_a? King }.first.pos

    all_pieces(enemy_color(color)).each do |piece|
      return true if piece.moves.include? king_pos
    end

    false
  end

  def checkmate?(color)
    done = false
    moves = []
    if in_check?(color)
      all_pieces(color).each do |piece|
        if !piece.valid_moves.empty?
          moves << {piece.symbol => piece.valid_moves}
          done = true
        end
      end
    end
    puts moves
    done
  end

  def enemy_color(color)
    return ( color == :black ? :white : :black )
  end

  def all_pieces(color)
    pieces = []

    @board.flatten.each do |position|
      unless position.nil?
        pieces << position if position.color == color
      end
    end

    pieces
  end
end
