require_relative 'Propeller'
require_relative 'prop_constructors'
require_relative 'Prop_Math'

class TMotor1861 < Propeller
	def name
		return @name
	end
	def initialize 
		super
		@name = "TMotor1861"
		@geom = parseGeomData('tmotor2685_geom.txt')#geom = [all radii, all chord, all twist] -- probably similar to 2685 geom
		@airfoil = parseAirfoil('naca6412_cad.dat') #foil = [[x,y] x n]
		@keyRadii = @geom[0]
		@radius = 229.0
	end
	def translate radius
		return [(-0.1*(radius-0.3)**3+0.035)*@radius,0] # basically translates the tip of the rotor, graph looks like ------\ -0.1*(radius-0.3)**3
	end
	def getHubFoil 
		getFlatHub()
	end
	def stiffness_modifier radius, chord #note this returns what the new chord will be, not a scalefactore
		if radius<0.15 && chord<30
			return 30.0
		end
		return chord
	end
end

