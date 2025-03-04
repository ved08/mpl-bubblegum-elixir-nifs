use mpl_bubblegum::instructions::CreateTreeConfigBuilder;
use solana_program::pubkey::pubkey;
use solana_pubkey::pubkey as solanapubkey;
use solana_sdk::{pubkey::Pubkey, signature::Keypair, signer::Signer, system_instruction};

#[rustler::nif]
fn add(a: i64, b: i64) -> i64 {
    a + b
}

#[rustler::nif]
fn test(lamports: u64, space: u64, max_depth: usize, max_buffer: usize) {
    let payer = Keypair::new();
    let mpl_bubblegum_id = pubkey!("BGUMAp9Gq7iTEuizy4pqaxsTyUCBK68MDfK752saRPUY");
    let merkle_tree = Keypair::new();
    let (tree_config, _) =
        Pubkey::find_program_address(&[merkle_tree.pubkey().as_array()], &mpl_bubblegum_id);
    let create_merkle_ix = system_instruction::create_account(
        &payer.pubkey(),
        &merkle_tree.pubkey(),
        lamports,
        space,
        &payer.pubkey(),
    );

    let create_config_ix = CreateTreeConfigBuilder::new()
        .tree_config(tree_config.to_bytes().into())
        .merkle_tree(merkle_tree.pubkey().to_bytes().into())
        .payer(payer.pubkey().to_bytes().into())
        .tree_creator(payer.pubkey().to_bytes().into())
        .max_depth(max_depth as u32)
        .max_buffer_size(max_buffer as u32)
        .instruction();
}
rustler::init!("Elixir.MplBubblegumNifs");
