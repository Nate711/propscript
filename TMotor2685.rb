require_relative 'Propeller'
require_relative 'prop_constructors'
require_relative 'Prop_Math'

class TMotor2685 < Propeller
	def initialize 
		super

		@name = "TMotor2685"
		@geom = parseGeomData('tmotor2685_geom.txt')#geom = [all radii, all chord, all twist]
		@airfoil = parseAirfoil('naca6412_cad.dat') #foil = [[x,y] x n]
		@keyRadii = @geom[0]
		@radius = 330.0
	end
	def translate radius
		return [(-0.1*(radius-0.3)**3+0.035)*@radius,0]
	end

	def stiff radius
		return 1
	end
end

