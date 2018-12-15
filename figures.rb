
class Empty
  def intersectTo f
    self
  end

  def intersectToPoints v
    Empty.new
  end

  def intersectToRay v
    Empty.new
  end

  def intersectToSegment v
    Empty.new
  end
end

class Points
  attr_reader :points

  def initialize array
    @points = array
  end

  def intersectTo f
    f.intersectToPoints self
  end

  def intersectToPoints v
    res = @points & v.points
    res.any? ? Points.new(res) : Empty.new
  end

  def intersectToSegment v
    selected = @points.select { |item| item >= v.left &&  item <= v.right }
    selected.nil? ? Empty.new : Points.new(selected)
  end

  def intersectToRay v
    selected = @points.select { |item| (item >= v.center &&  v.dir > 0) || (item <= v.center &&  v.dir < 0)}
    selected.nil? ? Empty.new : Points.new(selected)
  end
end

class Segment

  attr_reader :right, :left

  def initialize left, right
    @left = left
    @right = right
  end

  def intersectTo f
    f.intersectToSegment self
  end

  def intersectToPoints v
    v.intersectToSegment(self)
  end

  def intersectToSegment v
    check = (v.left - @right) * (v.right - @left)
    if check > 0
      Empty.new
    elsif check == 0
      Points.new([v.left == @right ? @right : @left])
    else
      Segment.new([@left, v.left].max, [@right, v.right].min)
    end
  end

  def intersectToRay v
    if v.center < @left
      v.dir > 0 ? Segment.new(@left, @right) : Empty.new
    elsif v.center > @right
      v.dir > 0 ? Empty.new : Segment.new(@left, @right)
    else
      v.dir > 0 ? Segment.new(v.center, @right) : Segment.new(@left, v.center)
    end
  end
end

class Ray

  attr_reader :dir, :center

  def initialize center, dir
    @center = center
    @dir = dir
  end

  def intersectTo f
    f.intersectToRay self
  end

  def intersectToPoints v
    v.intersectToRay(self)
  end

  def intersectToSegment v
    v.intersectToRay(self)
  end

  def intersectToRay v
    if @dir == v.dir
      Ray.new((@center - v.center) * @dir > 0 ? @center : v.center, @dir)
    elsif @center == v.center
      Points.new([@center])
    elsif (@center - v.center) * @dir < 0
      Segment.new(@center, v.center)
    else
      Empty.new
    end
  end
end


class Testing
  def self.eval figures
    figures.inject { |result, x| result.intersectTo x }
  end
end

# Some tests are already done for you
# Do not forget to add more tests especially for corner cases

res = Testing.eval([Points.new([3, 1, 2]), Points.new([2, 3, 4])])
if not (res.is_a? Points and res.points == [2, 3])
  puts "Test1 failed!"
end

res = Testing.eval([Points.new([1]), Points.new([0])])
if not (res.is_a? Empty)
  puts "Test2 failed!"
end

res = Testing.eval([Segment.new(1, 2), Points.new([1])])
if not (res.is_a? Points and res.points == [1])
  puts "Test3 failed!"
end

res = Testing.eval([Ray.new(1, -1), Points.new([0])])
if not (res.is_a? Points and res.points == [0])
  puts "Test4 failed!"
end

res = Testing.eval([Segment.new(0, 1), Segment.new(-1, 2)])
if not (res.is_a? Segment and res.left == 0 and res.right == 1)
  puts "Test5 failed!"
end

res = Testing.eval([Segment.new(0, 1), Segment.new(1, 2)])
if not (res.is_a? Points and res.points == [1])
  puts "Test6 failed!"
end

res = Testing.eval([Segment.new(0, 1), Ray.new(-1, 1)])
if not (res.is_a? Segment and res.left == 0 and res.right == 1)
  puts "Test7 failed!"
end

res = Testing.eval([Ray.new(-1, -1), Ray.new(-1, 1)])
if not (res.is_a? Points and res.points == [-1])
  puts "Test8 failed!"
end

res = Testing.eval([Ray.new(2, -1), Ray.new(-1, 1)])
if not (res.is_a? Segment and res.left == -1 and res.right == 2)
  puts "Test9 failed!"
end