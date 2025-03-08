# MplBubblegumNifs

A library in Elixir for handling compressed NFTs (cNFTs) on Solana.

## Installation

Add `mpl_bubblegum` to your list of dependencies in `mix.exs`:

```elixir
  def deps do
    [
      {:mpl_bubblegum_nifs, "~> 0.1.0"}
    ]
  end
```

Then run:

```sh
mix deps.get
```

---

## Usage

### 1. Initialize Connection
Before using the library, establish a connection to Solana RPC. **Use a Helius RPC URL, as native Solana RPC does not support DAS API.**

```elixir
MplBubblegum.Connection.create_connection(secret_key, rpc_url)
```

---

### 2. Create a Merkle Tree
This function initializes a new Merkle tree, which is required for minting compressed NFTs.

```elixir
merkle_tree = MplBubblegum.create_tree_config()
IO.puts("Tree created at: #{merkle_tree}")
```

---

### 3. Mint a Compressed NFT
To mint a cNFT, provide the Merkle tree address and metadata details.

```elixir
tx = MplBubblegum.mint_v1(
  "9ppyWc9LjccAJPchEoPYatZQgk5PwJgUhZi3rTd8skcE", # Merkle tree address
  "Hello NIFs",    # NFT Name
  "NIF",           # Symbol
  "https://metadata-uri.json", # Metadata URI
  100,             # Seller Fee Basis Points
  100              # Creator Share
)

IO.puts("Minted cNFT, tx: #{tx}")
```

---

### 4. Transfer a cNFT
To transfer ownership of a compressed NFT, provide the asset ID and recipient's address.

```elixir
tx = MplBubblegum.transfer(
  "6pfiemDtGpzFTWmT2rfNmvMAdPzvYcdzXJXquwjbB97q", # Asset ID
  "6hxBtjckJxUf9FM8V9dDq1Wux5azG2a64osiNwP1KwDN" # Recipient Address
)

IO.puts("Transferred cNFT, tx: #{tx}")
```

---

## License

This project is licensed under the MIT License.

