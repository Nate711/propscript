#the names are self-explanatory

def quadraticWithVertexPointEQ vx,vy,px,py
	quad = Proc.new do |n|
		((py-vy)/((px-vx)**2))*((n-vx)**2) + vy
	end
	return quad
end

def quadraticWithVertexPoint vx,vy,px,py, n
	((py-vy)/((px-vx)**2))*((n-vx)**2) + vy
end

def lineWithPoints ax,ay,bx,by, n
	slope = (by-ay).to_f/(bx-ax).to_f
	return slope*(n-ax)+ay
end

def rotPointAroundPoint x,y,theta,pointx,pointy #returns the rotated point
  resultx,resulty = rotPoint(x-pointx,y-pointy,theta)
  resultx+=pointx
  resulty+=pointy
  return [resultx,resulty]
end

def rotPoint x,y,theta,precision=5 #returns the rotated point
  return [(x*Math.cos(theta) - y*Math.sin(theta)).round(precision), 
    (x*Math.sin(theta) + y*Math.cos(theta)).round(precision)]
end

def rotPoints airfoil, theta, pointx=0,pointy=0 #returns a rotated airfoil
  result = []
  airfoil.each do |point|
    result<<rotPointAroundPoint(point[0], point[1], theta, pointx,pointy)
  end
  return result
end

def scaleShape shape, scale
  shape.map {|x,y| [x*scale,y*scale]}
end

def scaleShapeXY shape, scaleX, scaleY
  shape.map {|x,y| [x*scaleX,y*scaleY]}
end

def translateShape shape, x, y
  shape.map {|a,b| [a+x,b+y]}
end

def mapValue(x, in_min, in_max, out_min, out_max)
  return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end

def interpPointInSet(x, set) # could i make a custom lambda i pass out?
  # find two closest x values
  # first one: use normal set
  # second: delete first, repeat
  # map value using x and corresponding y
  x_values = set.transpose[0]
  x1 = x_values.min{|a,b| (x-a).abs <=> (x-b).abs}
  y1 = (set.detect {|n| n[0] == x1})[1]
  x_values.delete(x1)
  x2 = x_values.min{|a,b| (x-a).abs <=> (x-b).abs}
  y2 = (set.detect {|n| n[0] == x2})[1]
  return mapValue(x,x1,x2,y1,y2)
end