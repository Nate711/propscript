class Propeller
	@geom
	@airfoil

	@keyRadii

	@name

	@radius

	@hubFoil
	
	def initialize	
		
	end

	def translate radius
	end
	def getHubFoil
		xFactor = @radius*0.08
		yFactor = @radius*0.2
		airfoilXYZ(translateShape(scaleShapeXY(@airfoil,xFactor,yFactor),xFactor/2.0,0),0)
	end
	def rotate radius
		r =  @geom[2][@geom[0].find_index(radius)]#interpPointInSet(radius,[@geom[0],@geom[2]])# passing in radius and cloud of [radius,chord]
		#p r
		return r
	end

	def scale radius
		#index = @
		#print "index #{@geom[0].find_index(radius)}, radius #{radius}\n"
		a = @geom[1][@geom[0].find_index(radius)]
		return a*@radius
		#interpPointInSet(radius,[@geom[0],@geom[1]])*@radius
	end

	def stiffness_modifier radius, chord
		1.0
		#custom-ish for 3d printing
	end

	def getFoil radius # returns pt cloud [[x,y] x n]
		scaleFactor = scale(radius)
		#p translate(radius)
		return translateShape(
			rotPoints(
				scaleShapeXY(@airfoil,scaleFactor,stiffness_modifier(radius,scaleFactor)), #why so many f(radius)??
				rotate(radius)),
			translate(radius)[0],
			translate(radius)[1])
	end

	def writeXSections
		xSections = []
		count = 1
		@keyRadii.each do |radius| #because we are interpolating we don't really need to use the key radii
			foilWithZ = airfoilXYZ(radius)
			#p foilWithZ
			writeSolidworksCurve("#{@name}/#{@name}_#{count}.sldcrv",foilWithZ[0],foilWithZ[1],foilWithZ[2])
			count+=1
		end
	end

	def airfoilXYZ airfoil1,radius #returns array in [all x, all y, all z]
		#print "\n\n"
		return ((airfoil1.map {|n| n<<radius*@radius}).transpose).dup
	end
	def writeXSectionsToMacro
		xSections = getHubFoil() #gethubfoil = [foil1, foil2]
		@keyRadii.each do |radius| #because we aren't interpolating we don't really need to use the key radii
			foilWithZ = airfoilXYZ(getFoil(radius),radius)
			xSections << foilWithZ
		end

		writeSolidworksMacro("#{@name}.txt",xSections)
	end

	def build
		#writeXSections
		writeXSectionsToMacro
	end
end