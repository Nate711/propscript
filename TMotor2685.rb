require_relative 'Propeller'
require_relative 'prop_constructors'
require_relative 'Prop_Math'

class TMotor2685 < Propeller

	#notes
=begin
geom data

35%, 14% is the peak = 17.5%
10%, 4% is where the hub end = 8
20%, 9% + 4% = 13
30%, 12% + 4% = 16.5
40%, 13% + 4.5% = 17.5
50%, 12% + 4.5% = 16.5
60%, 11% + 4% = 15
70%, 10% + 4% = 14
80%, 8% + 3% = 11
90%, 6% + 2% = 8
98%, 5% = 4

hub is 8% thick

=end

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
	def getHubFoil 
		hub = roundRect(20,4,true).clone
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
		if radius<0.15 && chord<30
			return 30.0
		end
		return chord
	end
end

