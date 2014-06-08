require_relative 'Propeller'
require_relative 'prop_constructors'
require_relative 'Prop_Math'

class TMotor155 < Propeller
	def name
		return @name
	end
	def initialize 
		super
		@name = "TMotor155"
		@geom = parseGeomData('tmotor2685_geom.txt')#geom = [all radii, all chord, all twist] -- probably similar to 2685 geom
		@airfoil = parseAirfoil('naca6412_cad.dat') #foil = [[x,y] x n]
		@keyRadii = @geom[0]
		@radius = 190.5
	end
	def translate radius
		return [(-0.1*(radius-0.3)**3+0.035)*@radius,0]
	end
	def getHubFoil 
		hub = roundRect(10,3,true).clone
		hub1 = Marshal.load(Marshal.dump(hub))
		first = airfoilXYZ(hub,0)
		second = airfoilXYZ(hub1,0.06)
		ret = [first,second]
		#p first, second
		#p ret
		print "\n\n\n\n"
		return ret #,airfoilXYZ(hub.dup,0.1)]
	end
	def stiffness_modifier radius, chord #note this returns what the new chord will be, not a scalefactore
		if radius<0.15 && chord<20
			return 20.0
		end
		return chord
	end
end

