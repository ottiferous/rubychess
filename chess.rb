
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

  def valid_moves
    puts "valid moves"
    x = self.moves.reject { |move| move_into_check?(self.pos, move) }
    puts x
    x
  end

  def vector(vect_a, vect_b)
    x = vect_a[0] + vect_b[0]
    y = vect_a[1] + vect_b[1]
    [x, y]
  end

  def move_into_check?(start_pos, end_pos)

    trial_board = @board.dup

    trial_board.move!(start_pos, end_pos)

    if trial_board.in_check?(self.color)
      return true
    end

    false
  end

end

class SlidingPiece < Piece

  HORIZONTAL = [[1,0], [0,1], [-1,0], [0,-1]]
  DIAG       = [[1,1], [-1,-1], [1,-1], [-1,1]]


  def moves
    #return all valid moves
    possible_moves = []

    self.move_dirs.each do |dir|
      test_space = vector(dir, test_space)

      while @board.valid?(test_space)
        ttest_space = vector(dir, test_space

        tile = @board.empty?(test_space)


        if @board.empty?(test_space)
          possible_moves << test_space
        elsif test_space == self.pos
          next
        elsif enemy_at?(test_space)
          possible_moves << test_space
          break
        else
          break
        end
      end

    end
    possible_moves.uniq
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
    @first_pos = pos
  end


  def move_dirs

    arr = PAWN.dup

    if self.pos == @first_pos
      arr << [0,2]
      p arr
    end

    # Black always moves up
    if self.color == :black
      return arr.map{|move| move.map{|x| x*-1}}
    else
      return arr
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
