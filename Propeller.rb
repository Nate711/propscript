require_relative 'Prop_Math'

class Propeller
	@@geom

	def translate radius
	end

	def rotate radius
		interpPointInSet(radius,[@@geom.transpose[0],@@geom.transpose[2]])# passing in radius and cloud of [radius,chord]
	end

	def scale radius
		interpPointInSet(radius,[@@geom.transpose[0],@@geom.transpose[1]])
	end

	def stiffness_modifier radius
		#custom-ish for 3d printing
	end
end