require 'gnuplot'

def parseGeomData(filename)
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


def parseAirfoil(filename)
	f = File.open(filename)
	result = []
	f.each_line do |line|
		next if f.lineno === 1
		result << [1-line.chomp.split[0].to_f,line.chomp.split[1].to_f]
	end
	return result
end

def writeSolidworksCurve filename, *axes
	n = File.new(filename,'w+')

	for i in 0...axes[0].length
		n << "#{axes[0][i]} #{axes[1][i]} #{axes[2][i]}\n"
	end
end

def writeSolidworksMacro filename, xsections
	n = File.new(filename,'w+')
	n << "Dim swApp As Object\nDim Part As Object\nDim boolstatus As Boolean\nDim longstatus As Long, longwarnings As Long\nSub main()\nSet swApp = _\nApplication.SldWorks\nSet Part = swApp.ActiveDoc\n"


	xsections.each  do |section|
		n << "Part.InsertCurveFileBegin\n"
		for i in 0...section[0].length
			n << "boolstatus = Part.InsertCurveFilePoint(#{(section[0][i]/1000).round(6)}, #{(section[1][i]/1000).round(6)}, #{(section[2][i]/1000).round(6)})\n"
		end
		n << "boolstatus = Part.InsertCurveFileEnd()\n"
	end

	n << "Part.ClearSelection2 True\n"
	for i in (1..xsections.length)
		n << "boolstatus = Part.Extension.SelectByID2(\"Curve#{i}\", \"REFERENCECURVES\", #{xsections[i-1][0][0]/1000}, #{xsections[i-1][1][0]/1000}, #{xsections[i-1][2][0]/1000}, #{i==1?"False":"True"}, 1, Nothing,0)\n"
	end
	n << "Part.FeatureManager.InsertProtrusionBlend False, True, False, 1, 6, 6, 1, 1, True, True, False, 0, 0, 0, True, True, True\n"

	n << "End Sub\n"
end