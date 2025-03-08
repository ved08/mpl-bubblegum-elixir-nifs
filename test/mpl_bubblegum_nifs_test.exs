defmodule MplBubblegumTest do
  use ExUnit.Case, async: false
  doctest MplBubblegum

  def generate_random_metadata(uris) do
    Enum.map(uris, fn uri ->
      %{
        name: "Hello NIFs",
        symbol: "NIF",
        uri: uri,
        seller_fee_basis_points: 100,
        primary_sale_happened: false,
        is_mutable: false,
        edition_nonce: nil,
        token_standard: :non_fungible,
        collection: nil,
        uses: nil,
        token_program_version: :original,
        creators: [
          %{
            address: "payer_pubkey_here",
            verified: true,
            share: 100
          }
        ]
      }
    end)
  end

  setup_all do
    case MplBubblegum.Connection.create_connection(
           "UpTcTstVRrUTHQHdxsy84yUTKXp4CCg2dfNP6XVZJ4gUtp4uCCa849rkiWaDHfobtdrxj3KzE8t2zK2tUgrhSdG",
           "https://devnet.helius-rpc.com/?api-key=53da17ee-6973-4f78-ab61-fd7a59f1cc80"
         ) do
      {:ok, _pid} -> :ok
      # This ensures setup_all fails if the connection fails
      error -> error
    end
  end

  test "creates a new merkle tree" do
    merkle_tree = MplBubblegum.create_tree_config()
    IO.puts("Tree created at: #{merkle_tree}")
  end

  test "mint cNFTs" do
    # Replace this with your merkle tree address
    merkle_tree = "9ppyWc9LjccAJPchEoPYatZQgk5PwJgUhZi3rTd8skcE"

    metadata_uris = [
      "https://bafybeih7oz5pds33io34ud5ut4fd5a2jj74zoduiec2fw4oz24yqfo4aey.ipfs.w3s.link/1864.json",
      "https://bafybeih7oz5pds33io34ud5ut4fd5a2jj74zoduiec2fw4oz24yqfo4aey.ipfs.w3s.link/346.json",
      "https://bafybeih7oz5pds33io34ud5ut4fd5a2jj74zoduiec2fw4oz24yqfo4aey.ipfs.w3s.link/1738.json",
      "https://bafybeih7oz5pds33io34ud5ut4fd5a2jj74zoduiec2fw4oz24yqfo4aey.ipfs.w3s.link/353.json",
      "https://bafybeih7oz5pds33io34ud5ut4fd5a2jj74zoduiec2fw4oz24yqfo4aey.ipfs.w3s.link/971.json"
    ]

    metadata_args = generate_random_metadata(metadata_uris)

    Enum.each(metadata_args, fn metadata ->
      name = metadata[:name]
      symbol = metadata[:symbol]
      uri = metadata[:uri]
      seller_fee_basis_points = metadata[:seller_fee_basis_points]

      Enum.each(metadata[:creators], fn creator ->
        share = creator[:share]

        tx =
          MplBubblegum.mint_v1(
            merkle_tree,
            name,
            symbol,
            uri,
            seller_fee_basis_points,
            share
          )

        IO.puts("Minted cNft, tx: #{tx}")
      end)
    end)
  end

  test "transfer cNFT" do
    # Replace this with mint address
    asset_id = "6pfiemDtGpzFTWmT2rfNmvMAdPzvYcdzXJXquwjbB97q"
    # Replace this with reciever address
    reciever = "6hxBtjckJxUf9FM8V9dDq1Wux5azG2a64osiNwP1KwDN"
    tx = MplBubblegum.transfer(asset_id, reciever)
    IO.puts("Transferred, tx: #{tx}")
  end
end
