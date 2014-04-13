require_relative 'TMotor2685'
require_relative 'Propeller'
require_relative 'prop_constructors'
require_relative 'Prop_Math'

tprop2685 = TMotor2685.new

writeSolidworksMacro("#{@name}.txt",tprop2685.getXSections)

#p roundRect(20,10)
print "success\n"