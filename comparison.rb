f1 = IO.readlines('9x4.7_10_test.sldcrv')
f2 = IO.readlines('9x4.7_10.sldcrv')
def test(f1,f2)
	difference = []
	for i in 0...f1.length 
		if f1[i]===f2[i]
		else
			difference<<"#{f1[i].chomp} is not #{f2[i].chomp}"
		end
	end
	if difference != []
		return difference
	else
		return "same"
	end
end
puts test(f1,f2)