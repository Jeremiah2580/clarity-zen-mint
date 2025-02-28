import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Can create new NFT",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet1 = accounts.get('wallet_1')!;
    
    let block = chain.mineBlock([
      Tx.contractCall('zen-mint', 'create-nft',
        [types.ascii("Test NFT"), types.ascii("Test Description"), types.uint(1000)],
        wallet1.address
      )
    ]);
    
    block.receipts[0].result.expectOk().expectUint(1);
    
    let nftData = chain.callReadOnlyFn('zen-mint', 'get-nft-data', [types.uint(1)], wallet1.address);
    assertEquals(nftData.result.expectOk().expectSome().data.title, "Test NFT");
  }
});

Clarinet.test({
  name: "Can start and participate in auction",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet1 = accounts.get('wallet_1')!;
    const wallet2 = accounts.get('wallet_2')!;
    
    // Create NFT
    let block = chain.mineBlock([
      Tx.contractCall('zen-mint', 'create-nft',
        [types.ascii("Auction NFT"), types.ascii("Test Description"), types.uint(1000)],
        wallet1.address
      )
    ]);
    
    // Start auction
    block = chain.mineBlock([
      Tx.contractCall('zen-mint', 'start-auction',
        [types.uint(1), types.uint(1000), types.uint(100)],
        wallet1.address
      )
    ]);
    block.receipts[0].result.expectOk().expectBool(true);
    
    // Place bid
    block = chain.mineBlock([
      Tx.contractCall('zen-mint', 'place-bid',
        [types.uint(1), types.uint(1500)],
        wallet2.address
      )
    ]);
    block.receipts[0].result.expectOk().expectBool(true);
    
    // Advance blocks and claim
    chain.mineEmptyBlockUntil(200);
    
    block = chain.mineBlock([
      Tx.contractCall('zen-mint', 'claim-auction',
        [types.uint(1)],
        wallet2.address
      )
    ]);
    block.receipts[0].result.expectOk().expectBool(true);
  }
});
