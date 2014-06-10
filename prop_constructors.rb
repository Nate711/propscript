#require 'gnuplot'

def roundRect(width,height, startleft=true)
	radius = height/2.0
	straight = width-radius
	points = []
	
	points.concat(arc(-straight/2.0,0,radius,-Math::PI/2.0,Math::PI/2.0,-1))
	points.concat(line(-straight/2.0,height/2.0,straight/2.0,height/2.0))
	points.concat(arc(straight/2.0,0,radius,Math::PI/2.0,-Math::PI/2.0,1))
	points.concat(line(straight/2.0,-height/2.0,-straight/2.0,-height/2.0))
	if startleft
		points = points.rotate(5)
	end
	points << points[0].clone
	
	#print "#{points} \n\n#{points[0]}"
	return points
	
	#(x-x0)**2 + (y-y0)**2 = radius**2
	# y= sqrt(radius^2-(x-x0)^2)+y0
end
	
def arc(x0,y0,radius,startAngle,endAngle,direction = 1,precision = 10)#direction 1 = cc, dicteion -1 = c
	points = []
	t = startAngle
	inc = (endAngle-startAngle)/precision
	for i in 0...precision
		points << [x0+Math.cos(t)*radius,y0+Math.sin(t)*radius]
		t = t+direction*inc
	end
	return points
end

def line(x0,y0,x1,y1,precision = 10.0)
	points = []
	for i in 0...precision
		points << [x0+(x1-x0)*i/precision,y0+(y1-y0)*i/precision]
	end
	return points
end
	
def cirlce(x0,y0,radius,x)
	return sqrt(radius**2-(x0-x)**2)+y0
end

def parseGeomData(filename, cc = true) # [all radius, all chord, all beta]
	f = File.open(filename)

	geom_data = [[],[],[]] # format is radius, chord, twist
	f.each_line do |s|
		next if f.lineno < 2
		geom = s.split

		geom_data[0] << geom[0].to_f.round(5)
		geom_data[1] <<	geom[1].to_f
		geom_data[2] <<	geom[2].to_f*Math::PI/180
	end

	return geom_data
end


def parseAirfoil(filename, cc = true)
	f = File.open(filename)
	result = []
	f.each_line do |line|
		next if f.lineno === 1
		result << [-line.chomp.split[0].to_f,line.chomp.split[1].to_f]
	end
	return result
end

def writeSolidworksCurve filename, *axes
	n = File.new(filename,'w+')

	for i in 0...axes[0].length
		n << "#{axes[0][i]} #{axes[1][i]} #{axes[2][i]}\n"
	end
end

def writeSolidworksMacro filename, xsections, saveType=:file
	macrofile = File.new(filename,'w+')

	n = ""
	n << "Dim swApp As Object\nDim Part As Object\nDim boolstatus As Boolean\nDim longstatus As Long, longwarnings As Long\nSub main()\nSet swApp = _\nApplication.SldWorks\nSet Part = swApp.ActiveDoc\n"


	xsections.each_with_index  do |section,index|
		n << "Part.InsertCurveFileBegin\n"
		for i in 0...section[0].length
			n << "boolstatus = Part.InsertCurveFilePoint(#{(section[0][i]/1000).round(6)}, #{(section[1][i]/1000).round(6)}, #{(section[2][i]/1000).round(6)})\n"
		end
		n << "boolstatus = Part.InsertCurveFileEnd()\n"
		n << "boolstatus = Part.SelectedFeatureProperties(0, 0, 0, 0, 0, 0, 0, 1, 0, \"Curve#{index+1}\")\n"
	end

	n << "Part.ClearSelection2 True\n"
	for i in (1..xsections.length)
		n << "boolstatus = Part.Extension.SelectByID2(\"Curve#{i}\", \"REFERENCECURVES\", #{xsections[i-1][0][0]/1000}, #{xsections[i-1][1][0]/1000}, #{xsections[i-1][2][0]/1000}, #{i==1?"False":"True"}, 1, Nothing,0)\n"
	end
	n <<"Part.FeatureManager.InsertProtrusionBlend False, True, False, 1, 6, 6, 1, 1, True, True, False, 0, 0, 0, True, True, True\n"

	n << "End Sub\n"

	if saveType==:file
		macrofile<<n
		return ""
	elsif saveType==:string
		return n
	else
		raise "unacceptable saveType"
	end
end