require_relative 'Propeller'
require_relative 'prop_constructors'
require_relative 'Prop_Math'

class TMotor2685 < Propeller
	def initialize 
		super

		@name = "apc_10x4.7"
		@geom = parseGeomData('apcsf_10x4.7_geom.txt')#geom = [all radii, all chord, all twist]
		@airfoil = parseAirfoil('naca4412_cad.dat') #foil = [[x,y] x n]
		@keyRadii = @geom[0]
		@radius = 127.0
	end

	def translate radius
		return [0,0]
	end

	def stiff radius
		return 1
	end
end

