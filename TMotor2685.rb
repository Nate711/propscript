require_relative 'Propeller'
require_relative 'prop_constructors'

class TMotor2685 < Propeller
	@@geom = parseGeomData('tmotor2685_geom.txt')

	def translate radius
		return [0,0]
	end

	def stiff radius
		return 1
	end
end

