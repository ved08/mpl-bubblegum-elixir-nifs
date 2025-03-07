defmodule MplBubblegumTest do
  use ExUnit.Case
  # doctest MplBubblegum

  test "creates a new merkle tree" do
    MplBubblegum.Connection.create_connection(
      "UpTcTstVRrUTHQHdxsy84yUTKXp4CCg2dfNP6XVZJ4gUtp4uCCa849rkiWaDHfobtdrxj3KzE8t2zK2tUgrhSdG",
      "https://devnet.helius-rpc.com/?api-key=53da17ee-6973-4f78-ab61-fd7a59f1cc80"
    )

    IO.puts(MplBubblegum.create_tree_config())
  end
end

# name: "Hello NIFs".to_string(),
#         symbol: "NIF".to_string(),
#         uri: "https://arweave.net/sUEsfmH7DzhI8AmCnozxcTIcGYDZsPv1gupPbw4551E".to_string(),
#         seller_fee_basis_points: 100,
#         primary_sale_happened: false,
#         is_mutable: false,
#         edition_nonce: None,
#         token_standard: Some(TokenStandard::NonFungible),
#         collection: None,
#         uses: None,
#         token_program_version: TokenProgramVersion::Original,
#         creators: vec![Creator {
#             address: payer.pubkey().to_bytes().into(),
#             verified: true,
#             share,
#         }],
