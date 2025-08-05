const std = @import("std");
const StateCache = @import("zabi_flashloan_lib").StateCache;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        if (gpa.deinit() == .leak) {
            std.debug.print("Memory leak detected!\n", .{});
        }
    }
    const allocator = gpa.allocator();

    const file = try std.fs.cwd().openFile("borrowers_example.json", .{});
    defer file.close();

    const json = try file.readToEndAlloc(allocator, 100 * 1024 * 1024);
    defer allocator.free(json);

    var state_cache = try StateCache.parseJson(allocator, json);
    defer state_cache.deinit();

    std.debug.print("Successfully parsed JSON!\n", .{});
    std.debug.print("Last block number: {}\n", .{state_cache.last_block_number});
    std.debug.print("Number of borrowers: {}\n", .{state_cache.borrowers.count()});

    var iterator = state_cache.borrowers.iterator();
    while (iterator.next()) |entry| {
        const address = entry.key_ptr.*;
        const borrower = entry.value_ptr.*;
        std.debug.print("Borrower: {any}\n", .{address});
        std.debug.print("  Collateral count: {}\n", .{borrower.collateral.set.count()});
        std.debug.print("  Debt count: {}\n", .{borrower.debt.set.count()});
    }
}
