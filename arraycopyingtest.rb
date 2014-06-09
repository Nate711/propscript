my_array = [[0,1,2],[3,4,5],[6,7,8]]

p my_array

new_array = my_array.map { |e| e.clone }


my_array[0][0] = 12041

p my_array
p new_array