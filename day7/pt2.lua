local input = io.read("*a")

local lines = {}
for str in string.gmatch(input, "([^\n]+)") do
	table.insert(lines, str)
end

local beams = {}

local gridwidth = #lines[1]
for i = 1, gridwidth do
	if lines[1]:sub(i, i) == "S" then
		beams[i] = 1
	end
end

for i = 2, #lines do
	local to_add = {}
	local to_delete = {}
	for pos in pairs(beams) do
		local char = lines[i]:sub(pos, pos)
		-- beam split
		if char == "^" then
			if pos - 1 >= 1 then
				to_add[pos - 1] = (to_add[pos - 1] or 0) + beams[pos]
			end
			if pos + 1 <= gridwidth then
				to_add[pos + 1] = (to_add[pos + 1] or 0) + beams[pos]
			end
			to_delete[pos] = true
		end
	end
	for pos in pairs(to_delete) do
		beams[pos] = nil
	end
	for pos, value in pairs(to_add) do
		beams[pos] = (beams[pos] or 0) + value
	end
end

local c = 0
for k, v in pairs(beams) do
	print("k:" .. k .. " v:" .. v)
	c = c + v
end
print(c)
