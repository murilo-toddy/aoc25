map = Hash.new
ARGF.each do |line|
  device, outputs_str = line.split(": ")
  outputs = outputs_str.split
  map[device] = outputs
end

def dfs(map, node, dest, memo)
  if memo.include?(node)
    return memo[node]
  end
  if node == dest
    return 1
  end
  paths = 0
  if !map.include?(node)
    return 0
  end
  map[node].each do |n|
    paths += dfs(map, n, dest, memo)
  end
  memo[node] = paths
  return paths
end

# svr -> dac -> fft -> out
v1 = dfs(map, "svr", "dac", Hash.new) *
     dfs(map, "dac", "fft", Hash.new) *
     dfs(map, "fft", "out", Hash.new)

# svr -> fft -> dac -> out
v2 = dfs(map, "svr", "fft", Hash.new) *
     dfs(map, "fft", "dac", Hash.new) *
     dfs(map, "dac", "out", Hash.new)

puts v1 + v2
