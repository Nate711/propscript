require 'gnuplot'
require_relative 'Prop_Math'

PROPNAME = "8x3.8"
GEOMNAME = "9x4.7"
PROPRAD = 101.6
PROPTYPE = "APC"

puts "!!! propeller specs: propname #{PROPNAME}, GEOMNAME #{GEOMNAME}, PROPRAD #{PROPRAD}, PROPTYPE #{PROPTYPE}"


def getEdge name, rad #returns [radius,chord,twists]*n
  f = File.open(name)
  radius = []
  chord = []
  twist = []
  f.each_line do |s|
  	str = s.split

  	next if f.lineno < 2

  	radius<<(str[0].to_f*rad).round(5)
  	chord<<str[1].to_f*rad
  	twist<<str[2].to_f*Math::PI/180
  end

  return [radius,chord,twist].transpose
end

def getAirfoil str #returns airfoil coordinates
  f = File.open(str)
  result = []
  f.each_line do |line|
    next if f.lineno===1
    result<<[1-line.chomp.split[0].to_f,line.chomp.split[1].to_f] #1-blah b/c need to flip the prop
  end
  return result
end

def createCurve name, *axes #outputs a point cloud SUPER IMPORTANT: I delete the last point to make the end sharp and add the first point to the end
  n = File.new(name,'w+')
  unless axes[0] && axes[1]
    raise "need at least x and y values to create a curve dumbass"
  end
  
  unless axes[2]
    axes[2] = [0]*axes[0].length
  end

  for i in 0...axes[0].length #airfiol data needs to be a closed shape
    n<<"#{axes[0][i]} #{axes[1][i]} #{axes[2][i]}\n"
  end
end

def scaleShape shape, scale
  shape.map {|x,y| [x*scale,y*scale]}
end

def scaleShapeXY shape, scaleX, scaleY
  shape.map {|x,y| [x*scaleX,y*scaleY]}
end

def translateShape shape, x, y
  shape.map {|a,b| [a+x,b+y]}
end

def sliceAirfoil airfoilName, edgeName, rad, #returns slices in form [[x,y,slice_z]*numpoints]*numslices
  airfoil = getAirfoil(airfoilName) #one airfoil
  edge = getEdge(edgeName,rad) #edge has lots of arrays

  slices = []

  chords = edge.transpose[1]
  p chords
  max_chord = chords.max

  edge.each do |radius,chord,twist|

    cutoff = 20
    middle = 0.5*PROPRAD

    puts "\nradius #{radius} per_radius #{radius/PROPRAD}"

    #GOAL: beginning is thick, middle is thickenough, end is thin
=begin
    if chord <= cutoff 
      if radius <= middle#beginning
        puts "begin"

        yscale = lowpass(cutoff,chord,0)

      else radius >= middle #ends/tips
        puts "tip"

        yscale = lowpass(cutoff,chord,0.2)
      end
    else
      puts "chord is bigger than cutoff"
      yscale = lowpass(cutoff,chord,0.2)
    end
=end

    x = radius/PROPRAD
=begin
    yscale = 25-4*x-8*(x**7)
=end
    if x<0.55
      yscale = (-5)*(x-0.55) + max_chord
    else
      yscale = chord
    end

    $yscales<<yscale
    $chords<<chord

    puts "yscale is: #{yscale}, xscale is: #{chord}"
    af = scaleShapeXY(airfoil,chord,yscale)
    af = rotPoints(af,twist) #af is now scaled and twisted airfoil

    xshift = xCurve(radius)

    yshift = yCurve(radius)
    af = translateShape(af,xshift,yshift)
    xvals,yvals = af.transpose
    slices<<[xvals,yvals,[radius]*xvals.length].transpose
  end
  return slices
end

def writeSlices airfoil, geom, pr
  slices = sliceAirfoil(airfoil, geom,pr)
  #p slices
  slices.each_with_index do |slice,index|
    x,y,z = slice.transpose
    #createCurve("#{PROPNAME}/#{PROPNAME}_#{index}.sldcrv",x,y,z)
  end
  return slices
end

def xCurve radius
  return quadraticWithVertexPoint(PROPRAD,-25.0,PROPRAD*0.11,0,radius)
end

def yCurve radius
  short = PROPRAD*0.15748
  long = short*2
  if radius <= short
    return quadraticWithVertexPoint(0.0,3.0,short,1.5,radius)
  elsif radius < long && radius > short
    return quadraticWithVertexPoint(long,0.0,short,1.5,radius)
  elsif radius >=long
    return lineWithPoints(long,0.0,PROPRAD,3,radius)
  end
end
  
$yscales = []
$chords = []

sl = writeSlices('naca4412.dat', "apcsf_#{GEOMNAME}_geom.txt",PROPRAD)

xmin = -30
xmax = 15
ymin = -2
ymax = 10
if false
  Gnuplot.open do |gp|
    Gnuplot::Plot.new( gp ) do |plot|

      plot.xrange "[#{xmin}:#{xmax}]"
      plot.yrange "[#{ymin}:#{ymax}]"
      plot.title  "1"

      
      for i in (0...sl.length)
        plot.data << Gnuplot::DataSet.new([sl[i].transpose[0],sl[i].transpose[1]]) do |ds|
          ds.with = "lines"
          ds.linewidth = 3
        end
      end
    end
  end
end


af = getAirfoil 'naca4412.dat'
af = scaleShapeXY(af,1,1.83)
af = af.transpose
if false
  Gnuplot.open do |gp|
    Gnuplot::Plot.new( gp ) do |plot|

      plot.xrange "[0:1]"
      plot.yrange "[-0.4:1.2]"
      plot.title  "1"
      plot.data << Gnuplot::DataSet.new(af) do |ds|
        ds.with = "lines"
        ds.linewidth = 3
      end
    end
  end
end

if true
  xRange = (0...$yscales.length).to_a.map{ |e| e/20.0 + 0.15}
  Gnuplot.open do |gp|
    Gnuplot::Plot.new( gp ) do |plot|

      plot.xrange "[0:1.05]"
      plot.yrange "[0:30]"
      plot.title  "chord lengths"
      plot.data << Gnuplot::DataSet.new([xRange,$yscales]) do |ds|
        ds.with = "lines"
        ds.linewidth = 5
      end
      plot.data << Gnuplot::DataSet.new([xRange,$chords]) do |ds|
        ds.with = "lines"
        ds.linewidth = 3
      end
    end
  end
end


x = []
y = []
for i in 0...114
  x<<i
  y<<yCurve(i)
end

if false
  Gnuplot.open do |gp|
    Gnuplot::Plot.new( gp ) do |plot|

      plot.xrange "[0:114]"
      plot.yrange "[-1:10]"
      plot.title  "1"

      
      plot.data << Gnuplot::DataSet.new([x,y]) do |ds|
        ds.with = "lines"
        ds.linewidth = 3
      end
    end
  end
end
