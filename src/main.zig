const std = @import("std");
const ray = @import("raylib.zig");
const SCREEN_HEIGHT = 450;
const SCREEN_WIDTH = 800;

// App state
var index: c_int = 0;
var data: [80]u32 = undefined;
var sorted = 0;

// generate 80 value for arr
fn init() void {
    var prng = std.rand.DefaultPrng.init(blk: {
        const seed: u64 = 102333;
        break :blk seed;
    });
    const rand = prng.random();
    for (0..data.len) |i| {
        data[i] = rand.int(u32) % 450;
    }
}

pub fn main() !void {
    init();
    try ray_main();
    try old_main(); // remove this if you don't need it
    // try hints();
}

fn ray_main() !void {
    const monitor = ray.GetCurrentMonitor();
    const width = ray.GetMonitorWidth(monitor);
    const height = ray.GetMonitorHeight(monitor);
    std.debug.print("Info: screen w:{d}, h:{d}", .{ width, height });

    ray.SetConfigFlags(ray.FLAG_MSAA_4X_HINT | ray.FLAG_VSYNC_HINT);
    ray.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "8 sort algorithms");
    defer ray.CloseWindow();

    var gpa = std.heap.GeneralPurposeAllocator(.{ .stack_trace_frames = 8 }){};
    //const allocator = gpa.allocator();
    defer {
        switch (gpa.deinit()) {
            .leak => @panic("leaked memory"),
            else => {},
        }
    }

    const colors = [_]ray.Color{ ray.GRAY, ray.RED, ray.GOLD, ray.LIME, ray.BLUE, ray.VIOLET, ray.BROWN };
    while (!ray.WindowShouldClose()) {
        // draw
        {
            ray.BeginDrawing();
            defer ray.EndDrawing();

            ray.ClearBackground(colors[@intCast(2)]);

            // simple_sort();
            // bubble_sort();
            // selection_sort();
            // insertion_sort();
            // quick_sort(&data, data.len/2, data.len/2);
            bubble_sort();

            draw_list();
            std.time.sleep(1_00_000_000);
        }
    }
}

fn bucket_sort() void {
    const length = data.len;
    const bucket_count = 10; // Number of buckets
    var buckets: [bucket_count][]u32 = undefined; // Array of buckets

    // Initialize buckets
    for (0..bucket_count) |iIndex| {
        buckets[iIndex] = &[_]u32{}; // Create an empty bucket
    }

    // Distribute input array values into bucketsj
    for (0..length) |j| {
        const index_bucket: usize = @intCast(10 * data[j]); // Determine bucket index
        if (index_bucket < bucket_count) {
            buckets[index_bucket] = buckets[index_bucket] ++ data[j]; // Append to the bucket
        }
    }

    // Sort each bucket and concatenate the results
    var k: usize = 0;
    for (0..bucket_count) |i| {
        // Sort the current bucket using a simple sort (insertion sort for example)
        const sorted_bucket = std.sort.sort(u32, buckets[i]);
        for (0..sorted_bucket) |j| {
            data[k] = sorted_bucket[j];
            k += 1;
        }
    }
}

fn insertion_sort() void {
    const length = data.len;

    for (0..length) |i| {
        const tmp = data[i];
        var min_index = i;

        while (min_index > 0 and tmp < data[min_index - 1]) {
            data[min_index] = data[min_index - 1];
            min_index -= 1;
            break;
        }
        data[min_index] = tmp;
    }
}

fn partition(data_arr: *[*]u32, left: usize, right: usize) usize {
    const pivot = data_arr[left];
    var leftIndex = left + 1;
    var rightIndex = right;

    while (true) {
        while (leftIndex <= rightIndex and data_arr[leftIndex] <= pivot) {
            leftIndex += 1;
        }
        while (rightIndex >= leftIndex and data_arr[rightIndex] >= pivot) {
            rightIndex -= 1;
        }
        if (rightIndex <= leftIndex) {
            break;
        }
        // Swap data[leftIndex] and data[rightIndex]
        const temp = data_arr[leftIndex];
        data_arr[leftIndex] = data_arr[rightIndex];
        data_arr[rightIndex] = temp;
        break;
    }

    // Swap pivot with data[rightIndex]
    const temp = data_arr[left];
    data_arr[left] = data_arr[rightIndex];
    data_arr[rightIndex] = temp;
    return rightIndex;
}

fn quick_sort(data_arr: []u32, left: usize, right: usize) void {
    if (right <= left) {
        return;
    } else {
        const pivot = partition(data_arr, left, right);
        quick_sort(data_arr, left, pivot - 1);
        quick_sort(data_arr, pivot + 1, right);
    }
}

fn bubble_sort() void {
    const length = data.len;
    for (0..length) |i| {
        var swapped = false;
        for (0..(length - i - 1)) |j| {
            if (data[j] > data[j + 1]) {
                // Swap the elements
                const temp = data[j];
                data[j] = data[j + 1];
                data[j + 1] = temp;
                swapped = true;
                break;
            }
        }
    }
}

//Simple sort
fn simple_sort() void {
    for (data, 0..) |item, i| {
        if (i < (data.len - 1)) {
            if (item > data[i + 1]) {
                const tmp = item;
                data[i] = data[i + 1];
                data[i + 1] = tmp;
                break;
            }
        }
    }
}

fn selection_sort() void {
    const length = data.len;

    for (0..length) |i| {
        var minIndex = i;

        for (i..length) |j| {
            if (data[j] < data[minIndex]) {
                minIndex = j;
            }
        }

        if (minIndex != i) {
            // Swap the elements
            const temp = data[i];
            data[i] = data[minIndex];
            data[minIndex] = temp;
            break;
            // Print the current state of the array
            // std.debug.print("Current state: ", .{});
            // for (data) |value| {
            //     std.debug.print("{} ", .{value});
            // }
            // std.debug.print("\n", .{});
        }
    }
}

fn draw_list() void {
    for (data, 0..) |he, x| {
        draw_bar(he, x);
    }
}

fn draw_bar(he: u32, x: usize) void {
    const bar_width = 10;
    const bar_margin = 1;
    const xx: c_int = @intCast(x * bar_width + x * bar_margin);
    // std.debug.print("fmt {d}", .{ xx });
    ray.DrawRectangle(xx, @intCast(SCREEN_HEIGHT - he), bar_width, @intCast(he), ray.BLUE);
}

// remove this function if you don't need it
fn old_main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try bw.flush(); // don't forget to flush!
}

// fn hints() !void {
//     const stdout_file = std.io.getStdOut().writer();
//     var bw = std.io.bufferedWriter(stdout_file);
//     const stdout = bw.writer();

//     try stdout.print("\n⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯\n", .{});
//     try stdout.print("Here are some hints:\n", .{});
//     try stdout.print("Run `zig build --help` to see all the options\n", .{});
//     try stdout.print("Run `zig build -Doptimize=ReleaseSmall` for a small release build\n", .{});
//     try stdout.print("Run `zig build -Doptimize=ReleaseSmall -Dstrip=true` for a smaller release build, that strips symbols\n", .{});
//     try stdout.print("Run `zig build -Draylib-optimize=ReleaseFast` for a debug build of your application, that uses a fast release of raylib (if you are only debugging your code)\n", .{});

//     try bw.flush(); // don't forget to flush!
// }

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
