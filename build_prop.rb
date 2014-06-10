require 'sinatra'

require_relative 'TMotor2685'
require_relative 'TMotor155'
require_relative 'Propeller'
require_relative 'prop_constructors'
require_relative 'Prop_Math'

tprop2685 = TMotor2685.new
tprop155 = TMotor155.new

code2865 = writeSolidworksMacro("#{tprop2685.name}.txt",tprop2685.getXSections,:string)
writeSolidworksMacro("#{tprop155.name}.txt",tprop155.getXSections,:file)

#p roundRect(20,10)
print "success\n"

get '/' do
	'propeller creator!'
end

get '/form' do
	erb :form
end

post '/form' do
	erb :post
end

not_found do
	halt 404, 'Sorry! Page not found'
end

=begin
use below for getting additional url
get '/hello/:name' do
	params[:name]
end
=end
