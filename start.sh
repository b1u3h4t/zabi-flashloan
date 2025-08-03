#!/bin/bash

# Zabi Flashloan Demo Runner
# This script builds and runs the Avalanche ERC-20 demo

set -e

echo "🏗️  Building zabi-flashloan..."
zig build

echo ""
echo "🚀 Running Avalanche ERC-20 demo..."
echo "📝 Note: Make sure to set your private key and RPC URL"
echo ""

# Example command (you need to replace with actual values)
echo "Example usage:"
echo "./zig-out/bin/zabi_flashloan \\"
echo "  --priv_key=0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef \\"
echo "  --url=https://api.avax-test.network/ext/bc/C/rpc"
echo ""

# If environment variables are set, use them
if [[ -n "$PRIVATE_KEY" && -n "$RPC_URL" ]]; then
    echo "🔑 Using environment variables..."
    ./zig-out/bin/zabi_flashloan --priv_key="$PRIVATE_KEY" --url="$RPC_URL"
else
    echo "💡 Set PRIVATE_KEY and RPC_URL environment variables to run automatically"
    echo "   Example:"
    echo "   export PRIVATE_KEY=0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"
    echo "   export RPC_URL=https://api.avax-test.network/ext/bc/C/rpc"
    echo "   ./start.sh"
fi
