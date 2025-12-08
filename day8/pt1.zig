const std = @import("std");

const Point = struct { x: i64, y: i64, z: i64 };
const PointsDist = struct { dist: i64, p1: Point, p2: Point };

fn biggest_dist(_: void, pd1: PointsDist, pd2: PointsDist) bool {
    return pd1.dist > pd2.dist;
}

fn biggest_count(
    _: void,
    map1: std.AutoHashMap(Point, void),
    map2: std.AutoHashMap(Point, void),
) bool {
    return map1.count() > map2.count();
}

fn square(v: i64) i64 {
    return std.math.pow(i64, v, 2);
}

fn distanceSquared(p1: Point, p2: Point) i64 {
    return square(p1.x - p2.x) + square(p1.y - p2.y) + square(p1.z - p2.z);
}

fn nextAsInt(it: *std.mem.SplitIterator(u8, std.mem.DelimiterType.scalar)) anyerror!i64 {
    if (it.next()) |next| {
        return try std.fmt.parseInt(i64, next, 10);
    } else {
        unreachable;
    }
}

fn parseLine(line: []u8) anyerror!Point {
    var it = std.mem.splitScalar(u8, line, ',');
    return .{
        .x = try nextAsInt(&it),
        .y = try nextAsInt(&it),
        .z = try nextAsInt(&it),
    };
}

fn connect(
    da: std.mem.Allocator,
    circuits: *std.ArrayList(std.AutoHashMap(Point, void)),
    connection: PointsDist,
) anyerror!void {
    std.debug.print("connecting {any} with {any}\n", .{ connection.p1, connection.p2 });

    // find circuit that containts p1
    for (circuits.items, 0..) |circuit1, i| {
        if (circuit1.contains(connection.p1)) {
            std.debug.print("found circuit containing p1: {any}\n", .{circuit1.count()});
            if (circuit1.contains(connection.p2)) {
                std.debug.print("circuit with p1 also contains p2\n\n", .{});
                return;
            }

            // should always be re-added at the second for loop
            var circuit1_removed = circuits.swapRemove(i);
            for (circuits.items, 0..) |circuit2, j| {
                if (circuit2.contains(connection.p2)) {
                    std.debug.print("found circuit containing p2: {any}\n\n", .{circuit2.count()});
                    var new_circuit = std.AutoHashMap(Point, void).init(da);
                    var it1 = circuit1.iterator();
                    while (it1.next()) |p| {
                        try new_circuit.put(p.key_ptr.*, {});
                    }
                    var it2 = circuit2.iterator();
                    while (it2.next()) |p| {
                        try new_circuit.put(p.key_ptr.*, {});
                    }
                    std.debug.print("created new circuit: {any}\n\n", .{new_circuit.count()});

                    var circuit2_removed = circuits.swapRemove(j);
                    circuit1_removed.deinit();
                    circuit2_removed.deinit();

                    try circuits.append(da, new_circuit);
                    return;
                }
            }
        }
    }
    unreachable;
}

pub fn main() !void {
    var buf: [1024]u8 = undefined;
    var stdin = std.fs.File.stdin();
    var stdin_reader = stdin.reader(&buf);
    const stdin_io_reader = &stdin_reader.interface;

    var alloc = std.heap.DebugAllocator(.{}).init;
    defer _ = alloc.deinit();
    const da = alloc.allocator();

    var allocating_writer = std.Io.Writer.Allocating.init(da);
    defer allocating_writer.deinit();

    var points = std.ArrayList(Point).empty;
    defer points.deinit(da);

    while (stdin_io_reader.streamDelimiter(&allocating_writer.writer, '\n')) |_| {
        const line = allocating_writer.written();
        try points.append(da, parseLine(line) catch |err| {
            std.debug.print("failed to parse line into point: {any}", .{err});
            return err;
        });
        allocating_writer.clearRetainingCapacity();
        stdin_io_reader.toss(1); // skip '\n'
    } else |err| {
        if (err != std.io.Reader.Error.EndOfStream) {
            std.debug.print("failed to read input: {any}\n", .{err});
        }
    }

    var distances = std.ArrayList(PointsDist).empty;
    defer distances.deinit(da);

    for (0..points.items.len) |i| {
        const p1 = points.items[i];
        for (i + 1..points.items.len) |j| {
            const p2 = points.items[j];
            try distances.append(da, .{ .dist = distanceSquared(p1, p2), .p1 = p1, .p2 = p2 });
        }
    }
    // sort desc so we can just 'pop()' to get closest
    std.mem.sort(PointsDist, distances.items, {}, biggest_dist);

    // circuits is list[set[points]]
    var circuits = std.ArrayList(std.AutoHashMap(Point, void)).empty;
    defer circuits.deinit(da);
    for (points.items) |point| {
        // leaking memory
        var map = std.AutoHashMap(Point, void).init(da);
        try map.put(point, {});
        try circuits.append(da, map);
    }

    const connections = 1000;
    for (0..connections) |_| {
        const connection = distances.pop().?;
        try connect(da, &circuits, connection);
    }

    std.mem.sort(std.AutoHashMap(Point, void), circuits.items, {}, biggest_count);
    var accum: usize = 1;
    for (0..3) |j| {
        accum *= circuits.items[j].count();
    }
    std.debug.print("final result: {any}\n", .{accum});

    for (0..circuits.items.len) |i| {
        circuits.items[i].deinit();
    }
}
