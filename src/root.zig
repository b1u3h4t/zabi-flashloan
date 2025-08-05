const std = @import("std");
const testing = std.testing;
const Allocator = std.mem.Allocator;

const eth = @import("zabi").types.ethereum;
const utils = @import("zabi").utils.utils;
const Address = eth.Address;

pub const Borrower = struct {
    address: Address,
    collateral: HashSet(Address),
    debt: HashSet(Address),
    allocator: Allocator,

    pub fn init(allocator: Allocator, address: Address) Borrower {
        return .{
            .address = address,
            .collateral = HashSet(Address).init(allocator),
            .debt = HashSet(Address).init(allocator),
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Borrower) void {
        self.collateral.deinit();
        self.debt.deinit();
    }

    pub fn parseJson(
        allocator: Allocator,
        json: []const u8,
    ) !Borrower {
        const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json, .{ .ignore_unknown_fields = true });
        defer parsed.deinit();

        return parseJsonValue(allocator, parsed.value);
    }

    pub fn parseJsonValue(
        allocator: Allocator,
        value: std.json.Value,
    ) !Borrower {
        const address_str = value.object.get("address").?.string;
        const address = try utils.addressToBytes(address_str);
        var collateral = HashSet(Address).init(allocator);
        var debt = HashSet(Address).init(allocator);

        if (value.object.get("collateral")) |collateral_array| {
            for (collateral_array.array.items) |item| {
                const addr = try utils.addressToBytes(item.string);
                try collateral.insert(addr);
            }
        }

        if (value.object.get("debt")) |debt_array| {
            for (debt_array.array.items) |item| {
                const addr = try utils.addressToBytes(item.string);
                try debt.insert(addr);
            }
        }

        return .{
            .address = address,
            .collateral = collateral,
            .debt = debt,
            .allocator = allocator,
        };
    }
};

pub const StateCache = struct {
    last_block_number: u64,
    borrowers: std.AutoHashMap(Address, Borrower),

    const Self = @This();

    pub fn init(allocator: Allocator, last_block_number: u64) Self {
        return .{
            .last_block_number = last_block_number,
            .borrowers = std.AutoHashMap(Address, Borrower).init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        var iterator = self.borrowers.iterator();
        while (iterator.next()) |entry| {
            entry.value_ptr.deinit();
        }
        self.borrowers.deinit();
    }

    pub fn insert(self: *Self, address: Address, collateral: ?Address, debt: ?Address) !void {
        if (!self.borrowers.contains(address)) {
            var borrower = Borrower.init(self.borrowers.allocator, address);
            if (collateral) |c| {
                try borrower.collateral.insert(c);
            }
            if (debt) |d| {
                try borrower.debt.insert(d);
            }
            try self.borrowers.put(address, borrower);
        } else {
            var borrower = self.borrowers.getPtr(address).?;
            if (collateral) |c| {
                try borrower.collateral.insert(c);
            }
            if (debt) |d| {
                try borrower.debt.insert(d);
            }
        }
    }

    pub fn remove(self: *Self, address: Address, collateral: ?Address, debt: ?Address) bool {
        var borrower = self.borrowers.getPtr(address) orelse return false;

        if (collateral) |c| {
            if (!borrower.collateral.remove(c)) {
                return false;
            }
        }
        if (debt) |d| {
            if (!borrower.debt.remove(d)) {
                return false;
            }
        }

        if (borrower.collateral.isEmpty() and borrower.debt.isEmpty()) {
            var removed_borrower = self.borrowers.fetchRemove(address).?.value;
            removed_borrower.deinit();
        }

        return true;
    }

    pub fn parseJson(
        allocator: Allocator,
        json: []const u8,
    ) !Self {
        const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json, .{ .ignore_unknown_fields = true });
        defer parsed.deinit();

        const last_block_number = if (parsed.value.object.get("last_block_number")) |num| @as(u64, @intCast(num.integer)) else 0;
        var state_cache = Self.init(allocator, last_block_number);

        if (parsed.value.object.get("borrowers")) |borrowers_object| {
            var iterator = borrowers_object.object.iterator();
            while (iterator.next()) |entry| {
                const borrower = try Borrower.parseJsonValue(allocator, entry.value_ptr.*);
                try state_cache.borrowers.put(borrower.address, borrower);
            }
        }

        return state_cache;
    }

    pub fn contains(self: *Self, address: Address) bool {
        return self.borrowers.contains(address);
    }
};

fn HashSet(comptime T: type) type {
    return struct {
        set: std.AutoHashMap(T, void),
        allocator: Allocator,
        mutex: std.Thread.Mutex,

        const Self = @This();

        pub fn init(allocator: Allocator) Self {
            return .{
                .set = std.AutoHashMap(T, void).init(allocator),
                .allocator = allocator,
                .mutex = .{},
            };
        }

        pub fn deinit(self: *Self) void {
            self.set.deinit();
        }

        pub fn insert(self: *Self, value: T) !void {
            self.mutex.lock();
            defer self.mutex.unlock();

            try self.set.put(value, {});
        }

        pub fn remove(self: *Self, value: T) bool {
            self.mutex.lock();
            defer self.mutex.unlock();

            return self.set.remove(value);
        }

        pub fn contains(self: *const Self, value: T) bool {
            return self.set.contains(value);
        }

        pub fn isEmpty(self: *const Self) bool {
            return self.set.count() == 0;
        }
    };
}
