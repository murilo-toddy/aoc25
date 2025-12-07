local input = io.read("*a")

local lines = {}
for str in string.gmatch(input, "([^\n]+)") do
	table.insert(lines, str)
end

local beams = {}

local gridwidth = #lines[1]
for i = 1, gridwidth do
	if lines[1]:sub(i, i) == "S" then
		beams[i] = true
	end
end

local split_count = 0
for i = 2, #lines do
	local to_delete = {}
	local to_add = {}
	for pos in pairs(beams) do
		local char = lines[i]:sub(pos, pos)
		-- split: remove beam from current position and add to prev and next
		if char == "^" then
			to_delete[pos] = true
			split_count = split_count + 1
			if pos - 1 >= 1 then
				to_add[pos - 1] = true
			end
			if pos + 1 <= gridwidth then
				to_add[pos + 1] = true
			end
		end
	end
	for pos in pairs(to_delete) do
		beams[pos] = nil
	end
	for pos in pairs(to_add) do
		beams[pos] = true
	end
end

print(split_count)
