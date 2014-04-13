require_relative 'TMotor2685'
require_relative 'Propeller'
require_relative 'prop_constructors'
require_relative 'Prop_Math'
require 'gnuplot'

geom = parseGeomData('apcsf_11x4.7_geom.txt')


xmin = -30
xmax = 15
ymin = -2
ymax = 10
if true
  Gnuplot.open do |gp|
    Gnuplot::Plot.new( gp ) do |plot|

      plot.xrange "[#{xmin}:#{xmax}]"
      plot.yrange "[#{ymin}:#{ymax}]"
      plot.title "All Slices"

      
      #for i in (0...sl.length)
        plot.data << Gnuplot::DataSet.new([geom[0],geom[2]]) do |ds|
          ds.with = "lines"
          ds.linewidth = 3
        end
      #end
    end
  end
end