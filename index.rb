require 'rubygems'
require 'RMagick'
require 'tempfile'
include Magick

class BuildSet
  def initialize(dimension, colorArr = '')
    @dimension = dimension
    @colorArr = colorArr

    if colorArr.empty? || colorArr.length < 5
      @colorArr = ['#623f47', '#688292', '#b9743a', '#fba000', '#6a7139']
    end

    @imgArray = buildShapeSet
  end
  def img_array
    return @imgArray
  end
  def buildShapeSet
    shapeImage = []
    shapes = ['triangle', 'square', 'circle', 'diamond']

    # build random shape first. save variables for the duplicate
    randShape = random_shape
    randShape_color = randColor

    shapes.each do |shape|
      if(shape == randShape)
        2.times do
          shapeImage << BuildShape.new(@dimension, randShape_color, shape).response
        end
      else
        shapeImage << BuildShape.new(@dimension, randColor, shape).response
      end
    end

    shapeImage
  end
  def randColor
    corr_Num = rand(@colorArr.length)
    color = @colorArr[corr_Num]

    @colorArr.delete_at(corr_Num)

    color
  end
  def random_shape
    case rand(4) + 1
    when 1
      return 'triangle'
    when 2
      return 'square'
    when 3
      return 'diamond'
    when 4
      return 'circle'
    end
  end
end

class BuildShape
  def initialize(dimension, color = '', shape = '')
    @tmp_path = Tempfile.new(['image', '.png']).path
    @img = Image.new(dimension, dimension)
    @img.transparent_color = 'white'

    @shape = shape

    gc = Magick::Draw.new
    @color = color

    # need to return tmp_path
    #return Array[shape, build(shape, dimension)]
    build(dimension)
  end
  # created because I cannot return the path and shape type in the initialize func.
  def response
    Array[@tmp_path, @shape]
  end
  def build(dimension)
    @gc = Magick::Draw.new
    @gc.fill(@color)
    @gc.stroke('white')
    @gc.fill_opacity(1)

    shapeChoose(@shape, dimension)

    @gc.draw(@img)
    @img.transparent('white').write(@tmp_path)
  end
  def shapeChoose(shape, dimension)

    case shape
    when 'triangle'
      @gc.polygon(dimension/2, 0, dimension, dimension, 0, dimension)
    when 'square'
      @gc.rectangle(0, 0, dimension, dimension)
    when 'diamond'
      @gc.polygon(dimension/2, 0, dimension, dimension / 2, dimension / 2, dimension, 0, dimension / 2)
    when 'circle'
      @gc.circle(dimension / 2, dimension / 2, 0, dimension / 2)
    else # default to triangle
      @gc.polygon(dimension/2, 0, dimension, dimension, 0, dimension)
    end
  end
end

def test
  shapes_build = BuildSet.new(50).img_array;

  shapes_build.each do |shape|
    puts 'Shape section'
    shape.each do |properties|
      puts properties
    end
    puts 'End shape section'
    puts ''
  end
end 

test

=begin
require 'benchmark'

size = 1000
n = 1

Benchmark.bm do |x|
  x.report { for i in 1..n; test; end }
  x.report { 1.times do  ; test; end }
  x.report { 1.upto(n) do ; test; end }
end
=end 


sleep 300
