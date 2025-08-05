const abi = @import("zabi").abi.abitypes;
const args_parser = @import("zabi").utils.args;
const clients = @import("zabi").clients;
const human = @import("zabi").human_readable.parsing;
const std = @import("std");
const utils = @import("zabi").utils.utils;

const Abi = abi.Abi;
const Contract = clients.Wallet;
const Provider = clients.Provider;

const CliOptions = struct {
    priv_key: [32]u8,
    url: []const u8,
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var iter = try std.process.argsWithAllocator(gpa.allocator());
    defer iter.deinit();

    const parsed = args_parser.parseArgs(CliOptions, gpa.allocator(), &iter);

    const uri = try std.Uri.parse(parsed.url);

    const slice =
        \\  function transfer(address to, uint256 amount) external returns (bool)
        \\  function approve(address operator, uint256 size) external returns (bool)
        \\  function balanceOf(address owner) public view returns (uint256)
    ;
    var abi_parsed = try human.parseHumanReadable(gpa.allocator(), slice);
    defer abi_parsed.deinit();

    var provider = try Provider.HttpProvider.init(.{
        .allocator = gpa.allocator(),
        .network_config = .{
            .endpoint = .{
                .uri = uri,
            },
            .chain_id = .avalanche,
        },
    });
    defer provider.deinit();

    var contract = try Contract.init(
        parsed.priv_key,
        gpa.allocator(),
        &provider.provider,
        false,
    );
    defer contract.deinit();

    const transfer_func = switch (abi_parsed.value[0]) {
        .abiFunction => |func| func,
        else => unreachable,
    };
    std.debug.print("Transfer function: {s}\n", .{transfer_func.name});

    const data = try transfer_func.encodeFromReflection(gpa.allocator(), .{ contract.getWalletAddress(), 0 });
    std.debug.print("data len: {d}\n", .{data.len});
    defer gpa.allocator().free(data);

    const tx_envelope = try contract.prepareTransaction(.{
        .type = .london,
        .data = data,
        .to = try utils.addressToBytes("0xB97EF9Ef8734C71904D8002F8b6Bc66Dd9c48a6E"),
    });
    std.debug.print("Gas used: {d}\n", .{tx_envelope.london.gas});

    const transfer = contract.writeContractFunction(transfer_func, .{ contract.getWalletAddress(), 0 }, .{
        .type = .london,
        .gas = tx_envelope.london.gas,
        .to = try utils.addressToBytes("0xB97EF9Ef8734C71904D8002F8b6Bc66Dd9c48a6E"),
    }) catch |err| {
        std.debug.print("Error in writeContractFunction: {}\n", .{err});
        return err;
    };
    defer transfer.deinit();

    var receipt = try provider.provider.waitForTransactionReceipt(transfer.response, 0);
    defer receipt.deinit();

    const hash = switch (receipt.response) {
        inline else => |tx_receipt| tx_receipt.transactionHash,
    };

    std.debug.print("Transaction receipt: 0x{s}\n", .{std.fmt.bytesToHex(hash, .lower)});

    const balance_func = switch (abi_parsed.value[2]) {
        .abiFunction => |func| func,
        else => unreachable,
    };
    const balance = try contract.readContractFunction(u256, balance_func, .{contract.getWalletAddress()}, .{
        .london = .{
            .to = try utils.addressToBytes("0xB97EF9Ef8734C71904D8002F8b6Bc66Dd9c48a6E"),
        },
    });
    defer balance.deinit();

    std.debug.print("BALANCE: {d}\n", .{balance.result});
}
