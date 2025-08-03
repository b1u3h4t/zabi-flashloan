# Zabi Flashloan - Avalanche ERC-20 Demo

A demonstration project showcasing ERC-20 token interactions on the Avalanche C-Chain using the Zig programming language and a custom fork of the [zabi](https://github.com/Raiden1411/zabi) library with Avalanche support.

## 🌟 Features

- **Avalanche C-Chain Support**: Full integration with Avalanche network through custom zabi fork
- **ERC-20 Token Operations**: Transfer tokens and query balances
- **Human-Readable ABI**: Parse contract ABIs using human-readable format
- **Transaction Management**: Send transactions and wait for receipts
- **Type-Safe JSON Parsing**: Handle Avalanche-specific block fields with custom JSON parsing

## 🛠️ Technical Highlights

This project demonstrates several advanced features:

- **Custom Zabi Fork**: Uses a modified version of zabi that includes:

  - `AvalancheBlock` struct with Avalanche-specific fields
  - Support for odd-length hexadecimal string parsing
  - Enhanced JSON parsing for Avalanche RPC responses
  - Backward compatibility with standard Ethereum operations

- **Zig Integration**: Written in Zig 0.14.1+ with modern package management
- **Network Flexibility**: Configurable RPC endpoints via command-line arguments

## 📋 Prerequisites

- [Zig](https://ziglang.org/) 0.14.1 or later
- Access to an Avalanche C-Chain RPC endpoint
- A wallet private key for transaction signing
- ERC-20 tokens on Avalanche network for testing

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone <your-repo-url>
cd zabi-flashloan
```

### 2. Build the Project

```bash
zig build
```

### 3. Run the Demo

```bash
./zig-out/bin/zabi_flashloan --priv_key=<your-private-key-hex> --url=<avalanche-rpc-url>
```

**Example:**

```bash
./zig-out/bin/zabi_flashloan \
  --priv_key=0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef \
  --url=https://api.avax-test.network/ext/bc/C/rpc
```

### 4. Run Tests

Test the Avalanche integration:

```bash
zig build run-test_avalanche
```

## 📁 Project Structure

```
zabi-flashloan/
├── build.zig              # Build configuration
├── build.zig.zon          # Package dependencies
├── src/
│   ├── main.zig           # Main ERC-20 demo application
│   ├── root.zig           # Project root module
│   └── test_avalanche.zig # Avalanche integration tests
└── README.md              # This file
```

## 🔧 Configuration

### Command Line Arguments

- `--priv_key`: Your wallet private key (64-character hex string)
- `--url`: Avalanche C-Chain RPC endpoint URL

### Supported Networks

- **Avalanche Mainnet**: `https://api.avax.network/ext/bc/C/rpc`
- **Avalanche Testnet (Fuji)**: `https://api.avax-test.network/ext/bc/C/rpc`
- **Local Network**: Your local Avalanche node endpoint

## 💡 What the Demo Does

1. **Connect to Avalanche**: Establishes connection to the specified RPC endpoint
2. **Parse ERC-20 ABI**: Uses human-readable ABI format for contract interaction
3. **Execute Transfer**: Sends a token transfer transaction (0 amount to self)
4. **Wait for Receipt**: Monitors transaction confirmation
5. **Check Balance**: Queries the wallet's token balance

### Sample Output

```
Transfer function: transfer
debug(provider): Preparing to send request body: {"jsonrpc":"2.0","method":"eth_getTransactionCount"...
Transaction receipt: 0x586a97ddccfadc5321eaa6b02c0e90a3918b3da4c99db49e729c3403417d5691
BALANCE: 15415667
```

## 🧪 Testing

The project includes comprehensive tests for Avalanche integration:

```bash
# Test Avalanche block type support
zig build run-test_avalanche

# Build and run main demo
zig build run
```

## 🔗 Dependencies

- **Custom Zabi Fork**: [b1u3h4t/zabi](https://github.com/b1u3h4t/zabi)
  - Based on the original [zabi library](https://github.com/Raiden1411/zabi)
  - Enhanced with Avalanche-specific features
  - Maintains full backward compatibility

## 🛠️ Development

### Building from Source

````bash
# Fetch dependencies
zig build --fetch

# Build the project
zig build

# Run with arguments
```bash
# Run with arguments
zig build run -- --priv_key=<key> --url=<url>
````

````

### Code Structure

- **`main.zig`**: Main application demonstrating ERC-20 operations
- **`test_avalanche.zig`**: Test suite verifying Avalanche integration
- **`root.zig`**: Module exports and project structure

## 🐛 Troubleshooting

### Common Issues

1. **Invalid Private Key**: Ensure your private key is a 64-character hex string
2. **Network Connection**: Verify the RPC URL is accessible and correct
3. **Insufficient Funds**: Make sure your wallet has enough AVAX for gas fees

### Debug Mode

Enable debug logging to see detailed RPC interactions:

```bash
# The application includes built-in debug logging for provider requests
````

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is provided as-is for educational and demonstration purposes.

## 🙏 Acknowledgments

- [Raiden1411](https://github.com/Raiden1411) for the original zabi library
- The Zig community for the excellent tooling
- Avalanche team for the robust C-Chain infrastructure

---

**Note**: This is a demonstration project. Always use proper security practices when handling private keys and conducting real transactions.
