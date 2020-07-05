# University of Washington, Programming Languages, Homework 7, hw7.rb
# (See also ML code)

# a little language for 2D geometry objects

# each subclass of GeometryExpression, including subclasses of GeometryValue,
#  needs to respond to messages preprocess_prog and eval_prog
#
# each subclass of GeometryValue additionally needs:
#   * shift
#   * intersect, which uses the double-dispatch pattern
#   * intersectPoint, intersectLine, and intersectVerticalLine for
#       for being called by intersect of appropriate clases and doing
#       the correct intersection calculuation
#   * (We would need intersectNoPoints and intersectLineSegment, but these
#      are provided by GeometryValue and should not be overridden.)
#   *  intersectWithSegmentAsLineResult, which is used by
#      intersectLineSegment as described in the assignment
#
# you can define other helper methods, but will not find much need to

# Note: geometry objects should be immutable: assign to fields only during
#       object construction

# Note: For eval_prog, represent environments as arrays of 2-element arrays
# as described in the assignment

class GeometryExpression
  # do *not* change this class definition
  Epsilon = 0.00001
end

class GeometryValue
  # do *not* change methods in this class definition
  # you can add methods if you wish

  private

  # some helper methods that may be generally useful
  def real_close(r1, r2)
    (r1 - r2).abs < GeometryExpression::Epsilon
  end

  def real_close_point(x1, y1, x2, y2)
    real_close(x1, x2) && real_close(y1, y2)
  end

  # two_points_to_line could return a Line or a VerticalLine
  def two_points_to_line(x1, y1, x2, y2)
    if real_close(x1, x2)
      VerticalLine.new x1
    else
      m = (y2 - y1).to_f / (x2 - x1)
      b = y1 - m * x1
      Line.new(m, b)
    end
  end

  public

  # we put this in this class so all subclasses can inherit it:
  # the intersection of self with a NoPoints is a NoPoints object
  def intersectNoPoints np
    np # could also have NoPoints.new here instead
  end

  # we put this in this class so all subclasses can inhert it:
  # the intersection of self with a LineSegment is computed by
  # first intersecting with the line containing the segment and then
  # calling the result's intersectWithSegmentAsLineResult with the segment
  def intersectLineSegment seg
    line_result = intersect(two_points_to_line(seg.x1, seg.y1, seg.x2, seg.y2))
    line_result.intersectWithSegmentAsLineResult seg
  end
end

class NoPoints < GeometryValue
  # do *not* change this class definition: everything is done for you
  # (although this is the easiest class, it shows what methods every subclass
  # of geometry values needs)
  # However, you *may* move methods from here to a superclass if you wish to

  # Note: no initialize method only because there is nothing it needs to do
  def eval_prog env
    self # all values evaluate to self
  end

  def preprocess_prog
    self # no pre-processing to do here
  end

  def shift(dx, dy)
    self # shifting no-points is no-points
  end

  def intersect other
    other.intersectNoPoints self # will be NoPoints but follow double-dispatch
  end

  def intersectPoint p
    self # intersection with point and no-points is no-points
  end

  def intersectLine line
    self # intersection with line and no-points is no-points
  end

  def intersectVerticalLine vline
    self # intersection with line and no-points is no-points
  end

  # if self is the intersection of (1) some shape s and (2)
  # the line containing seg, then we return the intersection of the
  # shape s and the seg.  seg is an instance of LineSegment
  def intersectWithSegmentAsLineResult seg
    self
  end
end


class Point < GeometryValue
  # *add* methods to this class -- do *not* change given code and do not
  # override any methods

  # Note: You may want a private helper method like the local
  # helper function inbetween in the ML code
  attr_reader :x, :y

  def initialize(x, y)
    @x = x
    @y = y
  end

  def eval_prog(env)
    self
  end

  def preprocess_prog
    self
  end

  def shift(x, y)
    Point.new(self.x + x, self.y + y)
  end

  def intersect(other)
    other.intersectPoint self
  end

  def intersectPoint point
    if real_close_point(point.x, point.y, x, y)
      point
    else
      NoPoints.new
    end
  end

  def intersectLine(line)
    self
  end

  def intersectVerticalLine(vline)
    self
  end

  def intersectWithSegmentAsLineResult seg
    if inbetween(x, seg.x1, seg.x2) && inbetween(y, seg.y1, seg.y2)
      Point.new(x, y)
    else
      NoPoints.new
    end
  end

  def inbetween(v, end1, end2)
    (end1 - GeometryExpression::Epsilon <= v && v <= end2 + GeometryExpression::Epsilon) ||
        (end2 - GeometryExpression::Epsilon <= v && v <= end1 + GeometryExpression::Epsilon)
  end
end

class Line < GeometryValue
  # *add* methods to this class -- do *not* change given code and do not
  # override any methods
  attr_reader :m, :b

  def initialize(m, b)
    @m = m
    @b = b
  end

  def eval_prog(env)
    self
  end

  def preprocess_prog
    self
  end

  def shift(x, y)
    Line.new(m, b + y - m * x)
  end

  def intersect(other)
    other.intersectLine self
  end

  def intersectPoint(point)
    if real_close(point.y, m * point.x + b)
      point
    else
      NoPoints.new
    end
  end

  def intersectLine(line)
    if real_close(line.m, m)
      if real_close(line.b, b)
        line
      else
        NoPoints.new
      end
    else
      x = (b - line.b) / (line.m - m)
      y = line.m * x + line.b
      Point.new(x, y)
    end
  end

  def intersectVerticalLine(vline)
    self
  end

  def intersectWithSegmentAsLineResult(seg)
    seg
  end
end

class VerticalLine < GeometryValue
  # *add* methods to this class -- do *not* change given code and do not
  # override any methods
  attr_reader :x

  def initialize x
    @x = x
  end

  def eval_prog(env)
    self
  end

  def preprocess_prog
    self
  end

  def shift(x, y)
    VerticalLine.new(self.x + x)
  end

  def intersect(other)
    other.intersectVerticalLine self
  end

  def intersectPoint(point)
    self
  end

  def intersectLine(line)
    self
  end

  def intersectVerticalLine(vline)
    if real_close(vline.x, x)
      vline
    else
      NoPoints.new
    end
  end

  def intersectWithSegmentAsLineResult(seg)
    self
  end
end

class LineSegment < GeometryValue
  # *add* methods to this class -- do *not* change given code and do not
  # override any methods
  # Note: This is the most difficult class.  In the sample solution,
  #  preprocess_prog is about 15 lines long and
  # intersectWithSegmentAsLineResult is about 40 lines long
  attr_reader :x1, :y1, :x2, :y2

  def initialize(x1, y1, x2, y2)
    @x1 = x1
    @y1 = y1
    @x2 = x2
    @y2 = y2
  end

  def eval_prog(env)
    self
  end

  def preprocess_prog
    if real_close(x1, x2)
      if real_close(y1, y2)
        Point.new(x1, y1)
      elsif y1 > y2
        LineSegment.new(x2, y2, x1, y1)
      else
        self
      end
    elsif x1 > x2
      LineSegment.new(x2, y2, x1, y1)
    else
      self
    end
  end

  def shift(x, y)
    LineSegment.new(x1 + x, y1 + y, x2 + x, y2 + y)
  end

  def intersect(other)
    other.intersectLineSegment self
  end

  def intersectPoint(point)
    self
  end

  def intersectLine(line)
    self
  end

  def intersectVerticalLine(vline)
    self
  end

  def intersectWithSegmentAsLineResult(seg)
    if real_close(x1, y1)
      if y1 < seg.y1
        aSeg = self
        bSeg = seg
      else
        aSeg = seg
        bSeg = self
      end
      if real_close(aSeg.y2, bSeg.y1)
        Point.new(aSeg.x2, aSeg.y2)
      elsif aSeg.y2 < bSeg.y1
        NoPoints.new
      elsif aSeg.y2 > bSeg.y2
        LineSegment.new(bSeg.x1, bSeg.y1, bSeg.x2, bSeg.y2)
      else
        LineSegment.new(bSeg.x1, bSeg.y1, aSeg.x2, aSeg.y2)
      end
    else
      if x1 < seg.x1
        aSeg = self
        bSeg = seg
      else
        aSeg = seg
        bSeg = self
      end
      if real_close(aSeg.x2, bSeg.x1)
        Point.new(aSeg.x2, aSeg.y2)
      elsif aSeg.x2 < bSeg.x1
        NoPoints.new
      elsif aSeg.x2 > bSeg.x2
        LineSegment.new(bSeg.x1, bSeg.y1, bSeg.x2, bSeg.y2)
      else
        LineSegment.new(bSeg.x1, bSeg.y1, aSeg.x2, aSeg.y2)
      end
    end
  end
end

# Note: there is no need for getter methods for the non-value classes

class Intersect < GeometryExpression
  # *add* methods to this class -- do *not* change given code and do not
  # override any methods
  def initialize(e1, e2)
    @e1 = e1
    @e2 = e2
  end

  def preprocess_prog
    @e1 = @e1.preprocess_prog
    @e2 = @e2.preprocess_prog
  end

  def eval_prog env
    @e1.intersect @e2
  end
end

class Let < GeometryExpression
  # *add* methods to this class -- do *not* change given code and do not
  # override any methods
  # Note: Look at Var to guide how you implement Let
  def initialize(s, e1, e2)
    @s = s
    @e1 = e1
    @e2 = e2
  end
end

class Var < GeometryExpression
  # *add* methods to this class -- do *not* change given code and do not
  # override any methods
  def initialize s
    @s = s
  end

  def eval_prog env # remember: do not change this method
    pr = env.assoc @s
    raise "undefined variable" if pr.nil?
    pr[1]
  end
end

class Shift < GeometryExpression
  # *add* methods to this class -- do *not* change given code and do not
  # override any methods
  def initialize(dx, dy, e)
    @dx = dx
    @dy = dy
    @e = e
  end
end
