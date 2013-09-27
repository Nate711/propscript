require 'gnuplot' #for debugging really
require_relative 'Prop_Math' #includes point rotations and stuff

PROPNAME = "11x4.7" #name of files to be written (ie 9x4.7_0.sldcrv)
GEOMNAME = "9x4.7" #name of the geometry file (ie apcsf_9x4.7_geom), the geometry is practically the same for all APC
PROPRAD = 139.7 #radius of the propeller. MUST BE MANUALLY SET!
PROPTYPE = "APC" #not really used

puts "!!! propeller specs: propname #{PROPNAME}, GEOMNAME #{GEOMNAME}, PROPRAD #{PROPRAD}mm #{PROPRAD/25.4}\", PROPTYPE #{PROPTYPE}"

DEBUG = false

#getEdge returns an array containing the information inside the propeller geometry file (ie apcsf_9x4.7_geom)
def getEdge name, rad #returns [radius,chord,twists]*n, ie [[20.32, 13.716, .44], ...n times...]
  f = File.open(name)

  #arrays
  radius = []
  chord = []
  twist = []
  f.each_line do |s| #reads each line
  	str = s.split #splits the line into array by spaces

  	next if f.lineno < 2 #skip line 1

  	radius<<(str[0].to_f*rad).round(5) #multiply the radius by the actual propeller radius and round
  	chord<<str[1].to_f*rad #multiply the chord by the radius
  	twist<<str[2].to_f*Math::PI/180 #convert the twist into radians
  end

  return [radius,chord,twist].transpose #transpose switches the rows and columns
end

def getAirfoil str #returns airfoil coordinates (ie, [0.9500, 0.0147],...)
  f = File.open(str)
  result = []
  f.each_line do |line|
    next if f.lineno===1
    #parses the line
    result<<[1-line.chomp.split[0].to_f,line.chomp.split[1].to_f] #1-(the x coordinate) b/c need to flip the prop across the y axis
  end
  return result
end

def createCurve name, *axes #outputs a point cloud
  n = File.new(name,'w+')

  for i in 0...axes[0].length
    n<<"#{axes[0][i]} #{axes[1][i]} #{axes[2][i]}\n" #writes the info in *axes to the text file
  end
end

def sliceAirfoil airfoilName, edgeName, rad, #returns slices in form [[x,y,slice_z]*numpoints]*numslices
  airfoil = getAirfoil(airfoilName) #gets the airfoil data
  edge = getEdge(edgeName,rad) #gets the edge data (remember, big array of data)

  slices = []

  max_chord = edge.transpose[1].max #finds the maximum chord length
  
  puts "max chord is #{max_chord}" if DEBUG

  edge.each do |radius,chord,twist| #goes through each subarray in the edge array

    puts "\nradius #{radius} per_radius #{radius/PROPRAD}" if DEBUG

    x = radius/PROPRAD #normalizes the radius (ie 76.2 -> 0.75)

    if x<0.55 #about halfway down the prop
      #this next line is important
      n = mapValue(x,0.15,0.5,0,1)
      yscale = 25*(1-n) + n*max_chord #in the beginning, the yscale goes from 25 to max_chord linearly
      #it is a lot thicker than what is specified in the geom file so it could affect he performance negatively
    else
      yscale = chord #when you're past the midpoint, just use the default chord length
    end

    $yscales<<yscale #for debug
    $chords<<chord #for debug

    puts "yscale is: #{yscale}, xscale is: #{chord}" if DEBUG

    #next lines are  major!
    af = scaleShapeXY(airfoil,chord,yscale) #scales the airfoil according chord and yscale
    af = rotPoints(af,twist) #twists the airfoil.

    xshift = xCurve(radius) #gets the shift value along the x-axis according to the function
    yshift = yCurve(radius) #same deal with y

    af = translateShape(af,xshift,yshift) #translates the airofil. the airfoil is now adjusted properly

    xvals,yvals = af.transpose

    slices<<[xvals,yvals,[radius]*xvals.length].transpose #puts it into an array (ie, [[0.5,0.6,0.1],...])
  end
  return slices #returns full array
end

def writeSlices airfoil, geom, pr #writes the slice data into a file
  slices = sliceAirfoil(airfoil, geom,pr) #slices
  #p slices
  slices.each_with_index do |slice,index|
    #this whole deal with transposing is confusing and not needed I think
    x,y,z = slice.transpose #x, y, z are arrays
    createCurve("#{PROPNAME}/#{PROPNAME}_#{index}.sldcrv",x,y,z) #writes to file
  end
  puts "WRITE SUCCESSFUL (or maybe not, who knows?)"
  return slices
end

def xCurve radius #this function determines the x offset of each slice
  #so the point is fixed, i might want to make it relative to PROPRAD
  return quadraticWithVertexPoint(PROPRAD,-25.0,PROPRAD*0.11,0,radius) #vertex: (PROPRAD*0.11, 0) point: (PROPRAD, -25.0) value to evaluate: radius
end

def yCurve radius #this function determines the height of each slice
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
  
$yscales = [] #debug
$chords = [] #debug

#the all important line
sl = writeSlices('naca4412_for_cad.dat', "apcsf_#{GEOMNAME}_geom.txt",PROPRAD)


#all this below is debug, you don't need it

xmin = -30
xmax = 15
ymin = -2
ymax = 10
if true && DEBUG
  Gnuplot.open do |gp|
    Gnuplot::Plot.new( gp ) do |plot|

      plot.xrange "[#{xmin}:#{xmax}]"
      plot.yrange "[#{ymin}:#{ymax}]"
      plot.title  "All Slices"

      
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
af = af.transpose
if false && DEBUG
  Gnuplot.open do |gp|
    Gnuplot::Plot.new( gp ) do |plot|

      plot.xrange "[0:1]"
      plot.yrange "[-0.4:1.2]"
      plot.title  "Airfoil Data"
      plot.data << Gnuplot::DataSet.new(af) do |ds|
        ds.with = "lines"
        ds.linewidth = 3
      end
    end
  end
end

if true && DEBUG
  xRange = (0...$yscales.length).to_a.map{ |e| e/20.0 + 0.15}
  Gnuplot.open do |gp|
    Gnuplot::Plot.new( gp ) do |plot|

      plot.xrange "[0:1.05]"
      plot.yrange "[0:45]"
      plot.title  "Chord Lengths"
      plot.data << Gnuplot::DataSet.new([xRange,$yscales]) do |ds|
        ds.with = "lines"
        ds.linewidth = 6
        ds.title = "Adjusted Chord Length"
      end
      plot.data << Gnuplot::DataSet.new([xRange,$chords]) do |ds|
        ds.with = "lines"
        ds.linewidth = 3
        ds.title = "Chord Length"
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

if false && DEBUG
  Gnuplot.open do |gp|
    Gnuplot::Plot.new( gp ) do |plot|

      plot.xrange "[0:114]"
      plot.yrange "[-1:10]"
      plot.title  "Y Curve"

      
      plot.data << Gnuplot::DataSet.new([x,y]) do |ds|
        ds.with = "lines"
        ds.linewidth = 3
      end
    end
  end
end
