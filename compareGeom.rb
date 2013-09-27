def getEdge name, rad #returns [radius,chord,twists]*n
  f = File.open(name)
  radius = []
  chord = []
  twist = []
  f.each_line do |s|
  	str = s.split

  	next if f.lineno < 2

  	radius<<(str[0].to_f*rad).round(5)
  	chord<<str[1].to_f*rad
  	twist<<str[2].to_f*Math::PI/180
  end

  return [radius,chord,twist].transpose
end

def difference name1, name2
  a1 = getEdge name1, 1
  a2 = getEdge name2, 1
  a3 = []
  for i in 0...a1.length
    a3<<[a1[i][0]-a2[i][0], a1[i][1]-a2[i][1], a1[i][2]-a2[i][2]]
  end
  return a3
end

diff = []
diff << (difference("apcsf_11x4.7_geom.txt", "apcsf_9x4.7_geom.txt"))
diff << (difference("apcsf_10x4.7_geom.txt", "apcsf_9x4.7_geom.txt"))
diff << (difference("apcsf_10x4.7_geom.txt", "apcsf_11x4.7_geom.txt"))

f = File.new("geom_comparison.txt","w+")
diff.each do |comp|
  comp = comp.transpose
  comp.each do |n|
    n.map! {|n| n.abs}
    f<< "11 and 9 #{n.inject(:+)/n.length}\n"
  end
  f<<"\n\n"
end

