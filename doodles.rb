require_relative 'TMotor2685'
require_relative 'Propeller'
require_relative 'prop_constructors'
require_relative 'Prop_Math'
require 'gnuplot'

geom = parseGeomData('apcsf_11x4.7_geom.txt')
geom2 = parseGeomData('TMotor2685_geom.txt')
geom3 = parseGeomData('gwsdd_9x5_geom.txt')
arctan = []
arctan2 = []
geom[0].each do |radius|
	arctan << Math::atan(4.7/(11*Math::PI*radius))
	
end
geom2[0].each do |radius|
	arctan2 << Math::atan(8.5/(26*Math::PI*radius))
end


xmin = 0.05
xmax = 1.05
ymin = -0.2
ymax = 0.8
if false
  Gnuplot.open do |gp|
    Gnuplot::Plot.new( gp ) do |plot|

      plot.xrange "[#{xmin}:#{xmax}]"
      plot.yrange "[#{ymin}:#{ymax}]"
      plot.title "All Slices"

      


		#for i in (0...sl.length)
		plot.data << Gnuplot::DataSet.new([geom[0],geom[2]]) do |ds|
		  ds.with = "lines"
		  ds.linewidth = 0
		  ds.title = "apc geom"
		end

		plot.data << Gnuplot::DataSet.new([geom[0],arctan]) do |ds|
			ds.with = "lines"
			ds.linewidth = 0
			ds.title = "apc vs atan"
		end

		plot.data << Gnuplot::DataSet.new([geom2[0],arctan2]) do |ds|
			ds.with = "lines"
			ds.linewidth = 0
			ds.title = "tmotor vs atan"
		end
		 plot.data << Gnuplot::DataSet.new([geom2[0],geom2[2]]) do |ds|
		  ds.with = "lines"
		  ds.linewidth = 3
		  ds.title = "tmotor geom"
		end

      #end
    end
  end
end

xmin = 0.05
xmax = 1.05
ymin = 0
ymax = 0.4
if true
  Gnuplot.open do |gp|
    Gnuplot::Plot.new( gp ) do |plot|

      plot.xrange "[#{xmin}:#{xmax}]"
      plot.yrange "[#{ymin}:#{ymax}]"
      plot.title "All Slices"

		#for i in (0...sl.length)
		plot.data << Gnuplot::DataSet.new([geom[0],geom[1]]) do |ds|
		  ds.with = "lines"
		  ds.linewidth = 0
		  ds.title = "apc geom"
		end

		 plot.data << Gnuplot::DataSet.new([geom2[0],geom2[1]]) do |ds|
		  ds.with = "lines"
		  ds.linewidth = 3
		  ds.title = "tmotor geom"
		end

		plot.data << Gnuplot::DataSet.new([geom3[0],geom3[1]]) do |ds|
		  ds.with = "lines"
		  ds.linewidth = 3
		  ds.title = "gws geom"
		end
		
      #end
    end
  end
end