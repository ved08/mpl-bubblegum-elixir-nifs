use mpl_bubblegum::{
    accounts::TreeConfig, instructions::CreateTreeConfigBuilder, programs::MPL_BUBBLEGUM_ID,
};

use solana_program::pubkey::Pubkey;
use solana_sdk::{signature::Keypair, signer::Signer, signers::Signers};

#[rustler::nif]
fn add(a: i64, b: i64) -> i64 {
    a + b
}

fn test() {
    let merkle_tree = Keypair::new();
    let merkle_pubkey = &Pubkey::new_from_array(merkle_tree.pubkey().to_bytes());
    let mpl_bubblegum_id = Pubkey::from_str_const("BGUMAp9Gq7iTEuizy4pqaxsTyUCBK68MDfK752saRPUY");
    let payer = Keypair::new();
    let (tree_config, _) =
        Pubkey::find_program_address(&[merkle_pubkey.as_array()], &mpl_bubblegum_id);
    // let create_tree_ix = CreateTreeConfigBuilder {
    //     tree_config,
    //     merkle_tree,
    //     payer,
    //     tree_creator: todo!(),
    // };
}

rustler::init!("Elixir.MplBubblegumNifs");
