class Propeller
	@geom
	@airfoil

	@keyRadii

	@name

	@radius

	def initialize		
	end

	def translate radius
	end

	def rotate radius
		interpPointInSet(radius,[@geom[0],@geom[2]])# passing in radius and cloud of [radius,chord]
	end

	def scale radius
		interpPointInSet(radius,[@geom[0],@geom[1]])*@radius
	end

	def stiffness_modifier radius
		1.0
		#custom-ish for 3d printing
	end

	def getFoil radius # returns pt cloud [[x,y] x n]
		return translateShape(
			rotPoints(
				scaleShapeXY(@airfoil,scale(radius),scale(radius)*stiffness_modifier(radius)), #why so many f(radius)??
				rotate(radius)),
			translate(radius)[0],
			translate(radius)[1])
	end

	def writeXSections
		xSections = []
		count = 1
		@keyRadii.each do |radius| #because we are interpolating we don't really need to use the key radii
			foilWithZ = airfoilXYZ(radius)
			p foilWithZ
			writeSolidworksCurve("#{@name}/#{@name}_#{count}.sldcrv",foilWithZ[0],foilWithZ[1],foilWithZ[2])
			count+=1
		end
	end

	def airfoilXYZ radius #returns array in [all x, all y, all z]
		(getFoil(radius).map {|n| n<<radius*@radius}).transpose
	end
	def writeXSectionsToMacro
		xSections = []
		count = 1
		@keyRadii.each do |radius| #because we aren't interpolating we don't really need to use the key radii
			foilWithZ = airfoilXYZ(radius)
			xSections << foilWithZ
		end

		writeSolidworksMacro("#{@name}.txt",xSections)
	end

	def build
		#writeXSections
		writeXSectionsToMacro
	end
end