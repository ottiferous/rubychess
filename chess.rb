require './board.rb'

class Piece

  attr_accessor :color, :pos, :board, :symbol

  def initialize(color, pos, board, symbol)
    @color, @pos, @board = color, pos, board
    @board[pos] = self
    @symbol = symbol
  end

  def enemy_at?(pos)
    piece = @board[pos] if @board.valid?(pos)
    return false if piece == nil
    piece.color != self.color
  end
end

class SlidingPiece < Piece

  HORIZONTAL = [[1,0], [0,1], [-1,0], [0,-1]]
  DIAG       = [[1,1], [-1,-1], [1,-1], [-1,1]]


  def moves
    #return all valid moves
    possible_moves = []

    self.move_dirs.each do |dir|
      test_space = self.pos

      while @board.valid?(test_space)
        i, j = dir
        x, y = test_space

        if @board.empty?(test_space)
          possible_moves << test_space unless possible_moves.include? test_space
          test_space = [x+i, y+j]
        elsif test_space == self.pos
          test_space = [x+i, y+j]
        elsif enemy_at?(test_space)
          possible_moves << test_space unless possible_moves.include? test_space
          test_space = [x+i, y+j]
          break
        else
          break
        end
      end

    end
    possible_moves
  end


end

class SteppingPiece < Piece
  KING = [[1,1], [1,0], [1,-1], [0,-1], [-1,-1], [-1,0], [-1,1], [0,1]]
  KNIGHT = [[1,2], [2,1], [-1,2], [2,-1], [-2,1], [1, -2], [-1,-2], [-2,-1]]

  def moves
    possible_moves = []
    self.move_dirs.each do |dir|
      i,j = dir
      x,y = self.pos
      test_space = [x+i, y+j]
      if @board.valid?(test_space) && ( @board.empty?(test_space) || enemy_at?(test_space) )
        possible_moves << test_space
      end
    end
    possible_moves
  end
end


class Rook < SlidingPiece

  def move_dirs
    SlidingPiece::HORIZONTAL
  end

end
class Bishop < SlidingPiece

  def move_dirs
    SlidingPiece::DIAG
  end

end
class Queen < SlidingPiece

  def move_dirs
    SlidingPiece::DIAG + SlidingPiece::HORIZONTAL
  end

end

class King < SteppingPiece
  def move_dirs
    SteppingPiece::KING
  end

  def moves
    possible_moves = super

    color = ( self.color == :black ? :white : :black )

    enemy_array = @board.all_pieces(color)
    enemy_moves = []

    puts"Enemy_array: #{enemy_array}"
    enemy_array.each do |enemy|
      enemy_moves += enemy.moves
    end
    puts "Enemy_moves #{enemy_moves}"
    possible_moves.reject! { |move| enemy_moves.include? move }


  end
end

class Knight < SteppingPiece
  def move_dirs
    SteppingPiece::KNIGHT
  end
end

class Pawn < Piece

  PAWN = [[0,1], [1,1], [-1,1]]

  def initialize(color, pos, board, symbol)
    super
    @first_move = true

  end


  def move_dirs
    # Black always moves up
    if self.color == :black
      return PAWN.map{|move| move.map{|x| x*-1}}
    else
      return PAWN
    end
  end

  def moves
    possible_moves = []
    test_spaces = []

    move_dirs.each do |dirs|
      i,j = dirs
      x,y = self.pos
      test_spaces << [x+i, y+j]
    end

    #Move ahead
    test = test_spaces.shift
    possible_moves << test if @board.valid?(test) && @board.empty?(test)

    #Take a piece
    test_spaces.each do |space|
      possible_moves << space if enemy_at?(space)
    end

    possible_moves
  end

end