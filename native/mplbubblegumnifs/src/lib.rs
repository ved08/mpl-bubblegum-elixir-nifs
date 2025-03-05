use base64;
use mpl_bubblegum::{
    instructions::{
        CreateTreeConfig, CreateTreeConfigInstructionArgs, MintV1, MintV1InstructionArgs,
        TransferBuilder,
    },
    types::{Creator, LeafSchema, MetadataArgs, TokenProgramVersion, TokenStandard},
    utils::get_asset_id,
};
use solana_client::rpc_client::RpcClient;
use solana_program::pubkey::Pubkey;
use solana_sdk::{
    bs58,
    instruction::{AccountMeta, Instruction},
    pubkey,
    signature::Keypair,
    signer::Signer,
    system_instruction, system_program,
    transaction::Transaction,
};
use spl_account_compression::{state::CONCURRENT_MERKLE_TREE_HEADER_SIZE_V1, ConcurrentMerkleTree};

#[rustler::nif]
fn add(a: i64, b: i64) -> i64 {
    a + b
}

#[rustler::nif(schedule = "DirtyIo")]
fn create_tree_config_builder(payer_secret_key: String) -> String {
    const MAX_DEPTH: usize = 14;
    const MAX_BUFFER_SIZE: usize = 64;
    let secret_key_bytes = bs58::decode(payer_secret_key)
        .into_vec()
        .expect("Failed to decode secret key");
    let payer = Keypair::from_bytes(&secret_key_bytes).expect("Not a valid secret key");
    let merkle_tree = Keypair::new();
    let (tree_config, _) = Pubkey::find_program_address(
        &[merkle_tree.pubkey().as_array()],
        &pubkey!("BGUMAp9Gq7iTEuizy4pqaxsTyUCBK68MDfK752saRPUY"),
    );
    let rpc_url = "https://api.devnet.solana.com".to_string();
    let client = RpcClient::new(rpc_url);
    let size = CONCURRENT_MERKLE_TREE_HEADER_SIZE_V1
        + std::mem::size_of::<ConcurrentMerkleTree<MAX_DEPTH, MAX_BUFFER_SIZE>>();
    let rent = client.get_minimum_balance_for_rent_exemption(size).unwrap();
    let create_merkle_ix: Instruction = system_instruction::create_account(
        &payer.pubkey().to_bytes().into(),
        &merkle_tree.pubkey().to_bytes().into(),
        rent,
        size as u64,
        &spl_account_compression::ID.to_bytes().into(),
    );
    let create_tree_accounts = CreateTreeConfigInstructionArgs {
        max_depth: MAX_DEPTH as u32,
        max_buffer_size: MAX_BUFFER_SIZE as u32,
        public: Some(false),
    };
    let create_config_ix = CreateTreeConfig {
        tree_config: tree_config.to_bytes().into(),
        merkle_tree: merkle_tree.pubkey().to_bytes().into(),
        payer: payer.pubkey().to_bytes().into(),
        tree_creator: payer.pubkey().to_bytes().into(),
        log_wrapper: pubkey!("noopb9bkMVfRPU8AsbpTUg8AQkHtKwMYZiFUjNRtMmV")
            .to_bytes()
            .into(),
        compression_program: spl_account_compression::ID.to_bytes().into(),
        system_program: system_program::ID.to_bytes().into(),
    }
    .instruction(create_tree_accounts);
    let create_config_ix: Instruction = Instruction {
        program_id: create_config_ix.program_id.to_bytes().into(),
        accounts: create_config_ix
            .accounts
            .iter()
            .map(|meta| AccountMeta {
                pubkey: meta.pubkey.to_bytes().into(),
                is_signer: meta.is_signer,
                is_writable: meta.is_writable,
            })
            .collect(),
        data: create_config_ix.data,
    };
    let recent_blockhash = client.get_latest_blockhash().unwrap();
    let tx = Transaction::new_signed_with_payer(
        &[create_merkle_ix, create_config_ix],
        Some(&payer.pubkey()),
        &[&merkle_tree, &payer],
        recent_blockhash.to_bytes().into(),
    );
    let serialized_tx = bincode::serialize(&tx).expect("Failed to serialize transaction");
    base64::encode(serialized_tx)
}

#[rustler::nif(schedule = "DirtyIo")]
fn mint_v1_builder(payer_secret_key: String, merkle_tree: String) -> String {
    let rpc_url = "https://api.devnet.solana.com".to_string();
    let client = RpcClient::new(rpc_url);
    let secret_key_bytes = bs58::decode(payer_secret_key)
        .into_vec()
        .expect("Failed to decode secret key");
    let payer = Keypair::from_bytes(&secret_key_bytes).expect("Not a valid secret key");
    let merkle_tree = Pubkey::from_str_const(&merkle_tree);
    let (tree_config, _) = Pubkey::find_program_address(
        &[merkle_tree.as_array()],
        &pubkey!("BGUMAp9Gq7iTEuizy4pqaxsTyUCBK68MDfK752saRPUY"),
    );
    let mint_ix_accounts = MetadataArgs {
        name: "Hello NIFs".to_string(),
        symbol: "NIF".to_string(),
        uri: "https://arweave.net/sUEsfmH7DzhI8AmCnozxcTIcGYDZsPv1gupPbw4551E".to_string(),
        seller_fee_basis_points: 100,
        primary_sale_happened: false,
        is_mutable: false,
        edition_nonce: None,
        token_standard: Some(TokenStandard::NonFungible),
        collection: None,
        uses: None,
        token_program_version: TokenProgramVersion::Original,
        creators: vec![Creator {
            address: payer.pubkey().to_bytes().into(),
            verified: true,
            share: 100,
        }],
    };

    let mint_ix = MintV1 {
        tree_config: tree_config.to_bytes().into(),
        leaf_owner: payer.pubkey().to_bytes().into(),
        leaf_delegate: payer.pubkey().to_bytes().into(),
        merkle_tree: merkle_tree.to_bytes().into(),
        payer: payer.pubkey().to_bytes().into(),
        tree_creator_or_delegate: payer.pubkey().to_bytes().into(),
        log_wrapper: pubkey!("noopb9bkMVfRPU8AsbpTUg8AQkHtKwMYZiFUjNRtMmV")
            .to_bytes()
            .into(),
        compression_program: spl_account_compression::ID.to_bytes().into(),
        system_program: system_program::ID.to_bytes().into(),
    };
    let mint_ix = mint_ix.instruction(MintV1InstructionArgs {
        metadata: mint_ix_accounts,
    });
    let mint_ix = Instruction {
        program_id: mint_ix.program_id.to_bytes().into(),
        accounts: mint_ix
            .accounts
            .iter()
            .map(|meta| AccountMeta {
                pubkey: meta.pubkey.to_bytes().into(),
                is_signer: meta.is_signer,
                is_writable: meta.is_writable,
            })
            .collect(),
        data: mint_ix.data,
    };
    let recent_blockhash = client.get_latest_blockhash().unwrap();
    let tx = Transaction::new_signed_with_payer(
        &[mint_ix],
        Some(&payer.pubkey()),
        &[&payer],
        recent_blockhash.to_bytes().into(),
    );
    let serialized_tx = bincode::serialize(&tx).expect("Failed to serialize transaction");
    base64::encode(serialized_tx)
}
#[rustler::nif(schedule = "DirtyIo")]
fn transfer_builder(
    payer_secret_key: String,
    to_address: String,
    asset_id: String,
    owner: String,
    nonce: u64,
    data_hash: String,
    creator_hash: String,
    root: String,
    proof: String,
    merkle_tree: String,
) -> String {
    let rpc_url = "https://api.devnet.solana.com".to_string();
    let client = RpcClient::new(rpc_url);
    let secret_key_bytes = bs58::decode(payer_secret_key)
        .into_vec()
        .expect("Failed to decode secret key");
    let payer = Keypair::from_bytes(&secret_key_bytes).expect("Not a valid secret key");

    let to_address = Pubkey::from_str_const(&to_address);
    let asset_id = Pubkey::from_str_const(&asset_id);
    let owner = Pubkey::from_str_const(&owner);
    let merkle_tree = Pubkey::from_str_const(&merkle_tree);
    let (tree_config, _) = Pubkey::find_program_address(
        &[merkle_tree.as_array()],
        &pubkey!("BGUMAp9Gq7iTEuizy4pqaxsTyUCBK68MDfK752saRPUY"),
    );
    let data_hash = base64::decode(data_hash).expect("Error while decoding data hash");
    let creator_hash = base64::decode(creator_hash).expect("Error while decoding creator hash");
    let root = base64::decode(root).expect("Error while decoding root hash");
    let proof = base64::decode(proof).expect("Error while decoding root hash");

    let transfer_ix = TransferBuilder::new()
        .leaf_delegate(payer.pubkey().to_bytes().into(), false)
        .leaf_owner(payer.pubkey().to_bytes().into(), true)
        .merkle_tree(merkle_tree.to_bytes().into())
        .tree_config(tree_config.to_bytes().into())
        .new_leaf_owner(to_address.to_bytes().into())
        .root(root.try_into().expect("slice with incorrect length"))
        .nonce(nonce)
        .creator_hash(
            creator_hash
                .try_into()
                .expect("slice with incorrect length"),
        )
        .data_hash(data_hash.try_into().expect("slice with incorrect length"))
        .index(nonce as u32)
        .add_remaining_accounts(todo!())
        .instruction();
}

rustler::init!("Elixir.MplBubblegumNifs");
