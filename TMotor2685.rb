require_relative 'Propeller'
require_relative 'propcreator_dev'

class TMotor2685 < Propeller
	@@geom = parseGeomData('tmotor2685_geom.txt')

	def translate radius
		return [0,0]
	end

	def stiff radius
		return 1
	end

	def rotate radius
		interpPointInSet(radius,[@@geom.transpose[0],@@geom.transpose[2]])# passing in radius and cloud of [radius,chord]
	end

	def scale radius
		interpPointInSet(radius,[@@geom.transpose[0],@@geom.transpose[1]])
	end

end

