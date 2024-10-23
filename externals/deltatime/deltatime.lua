local last_time = 0
local dt = {}

function dt.getTime()
	local delta = 0

	if last_time == 0 then
		last_time = os.clock()
	else	
		local cur_time = os.clock()
		delta = cur_time - last_time
		last_time = cur_time
	end	

	return delta
end	

function dt.restart()
	last_time = 0
end	

return dt