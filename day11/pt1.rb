map = Hash.new
ARGF.each do |line|
  device, outputs_str = line.split(": ")
  outputs = outputs_str.split
  map[device] = outputs
end

$count = 0
def dfs(map, node)
  map[node].each do |n|
    if n == "out"
      $count += 1
      return
    end
    dfs(map, n)
  end
end

dfs(map, "you")
puts $count
