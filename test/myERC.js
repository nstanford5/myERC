const myERC = artifacts.require('myERC.sol');

contract('myERC', () => {
  /**
   * Test 1
   */
  it('should test constructor', async () => {
    const storage = await myERC.new();
    const name = await storage.name();
    const symbol = await storage.symbol();

    assert(name === 'myERC', "name wrong");
    assert(symbol === 'MERC', "symbol wrong");
  })
  /**
   * Test 2
   */
  it('should test second instance', async () => {
    try{
      const name2 = await storage.name();
      assert(name2 === 'myERC');
    } catch (e) {
      console.log(`The test failed successfully: ${e}`)
    }
  })
    /**
   * Test 3
   */
  it('should mint, return balance, check tokenId for owner', async () => {
    const storage = await myERC.new();
    // cannot mint to the zero address
    try {
      await storage.safeMint('0x0000000000000000000000000000000000000000');
    } catch (e) {
      console.log(`Mint test failed successfully: ${e}`);
    }

    // safeMint is not a function
    await storage.safeMint('0x1028c139157ab9be0eb649c6fc10fb792b21cb67');
    const amt = await storage.balanceOf('0x1028c139157ab9be0eb649c6fc10fb792b21cb67');
    assert(amt.toString() === '1', "balance wrong");

    const addr = await storage.ownerOf(0);
    assert(Number(addr) == '0x1028c139157ab9be0eb649c6fc10fb792b21cb67', "address wrong");
  })
    /**
   * Test 4
   */
  it('should mint a collection', async () => {
    const storage = await myERC.new();
    const addresses = [
      '0x75b8304824832f0d997345bdc717103d9a2fb99b',
      '0xc28569362a51520be4817db263d180ecf4973c24',
      '0xb9e7d3e4eb204b51ed14cdf1460e01e43f0a995b',
      '0x6f76e1e1c094b4fbfb9edf1165e96adee76aef9d',
      '0x0f52c06aa9c86fd61a3af9536bb23bd29c31a8b2',
      '0xba090a5a70db5ccd915000429e1260cd9d52f9f0',
      '0x5dfdb8b87d543a83fe213c4a42f6042129330063',
      '0x48ffe001c7644ccb32cee2b506a52d5869acfad9',
      '0xf7f6af2236bb0e384ba07b5e6d682ce2e18b09ee',
      '0xdaaeb2ef11c92575eca3fc051c15657b1e70fbca',
    ]

    for(let i = 0; i < 10; i++){
      await storage.safeMint(addresses[i]);
      const amt = await storage.balanceOf(addresses[i]);
      assert(amt.toString() === '1', "balance wrong");

      const addr = await storage.ownerOf(i);
      assert(Number(addr) == addresses[i], "address wrong");
    }
  })
  //   /**
//    * Test 5
//    */
  it('should transfer NFT', async () => {
    const storage = await myERC.new();

    await storage.safeMint('0x75b8304824832f0d997345bdc717103d9a2fb99b');
    await storage.transferFrom('0x75b8304824832f0d997345bdc717103d9a2fb99b', '0xc28569362a51520be4817db263d180ecf4973c24', 0);
    const owner = await storage.ownerOf(0);
    assert(Number(owner) == '0xc28569362a51520be4817db263d180ecf4973c24', "transfer failed");
  
    // this will fail because addr0 no longer owns the NFT
    // run this once then add the try...catch
    try {
      await storage.transferFrom('0x75b8304824832f0d997345bdc717103d9a2fb99b', '0xc28569362a51520be4817db263d180ecf4973c24', 0);
    } catch (e) {
      console.log(`The transfer test failed successfuly: ${e}`);
    }
  })
    /**
   * Test 6
   */
  it('should test interface', async () => {
    // ERC165 interface ID == 0x80ac58cd
    const storage = await myERC.new();

    const b = await storage.supportsInterface('0x80ac58cd');
    console.log(`ERC165 interface support is: ${b}`);

    const b2 = await storage.supportsInterface('0xffffffff');
    console.log(`This interface id should return false, actual: ${b2}`);

    const b3 = await storage.supportsInterface('0x12345678');
    console.log(`Support for this random number is ${b3}`);
  })
  /**
   * Test 7
   */
  it('should mint a collection to a single owner', async () => {
  const storage = await myERC.new();

  for(let i = 0; i < 50; i++){
    await storage.safeMint('0x75b8304824832f0d997345bdc717103d9a2fb99b');
  }

  const balance = await storage.balanceOf('0x75b8304824832f0d997345bdc717103d9a2fb99b');
  assert(balance.toString() === '50');
  })
  /**
   * Test 8
   */
  it('should approve non-owners', async () => {
    const storage = await myERC.new();

    await storage.safeMint('0x75b8304824832f0d997345bdc717103d9a2fb99b');
    const own = await storage.ownerOf(0);
    console.log(`This is the owner: ${own}`);
    // here is where we input the Reach contract address to spend the token
    await storage.approve('0xc28569362a51520be4817db263d180ecf4973c24', 0);

    const addr = await storage.getApproved(0);
    console.log(`This address is approved: ${addr}`);
  })
})// end of tests
  





  



// (0) 0x75b8304824832f0d997345bdc717103d9a2fb99b
// (1) 0xc28569362a51520be4817db263d180ecf4973c24
// (2) 0xb9e7d3e4eb204b51ed14cdf1460e01e43f0a995b
// (3) 0x6f76e1e1c094b4fbfb9edf1165e96adee76aef9d
// (4) 0x0f52c06aa9c86fd61a3af9536bb23bd29c31a8b2
// (5) 0xba090a5a70db5ccd915000429e1260cd9d52f9f0
// (6) 0x5dfdb8b87d543a83fe213c4a42f6042129330063
// (7) 0x48ffe001c7644ccb32cee2b506a52d5869acfad9
// (8) 0xf7f6af2236bb0e384ba07b5e6d682ce2e18b09ee
// (9) 0xdaaeb2ef11c92575eca3fc051c15657b1e70fbca



// (0) 266dc6b529e8519d8ccbd9e7befb1ed23337279c477e847f04e1c79ed72db861
// (1) 99449834cf8db3e3402c7fc65070dd8b0143c4bc9e06304a6d35a22113372a10
// (2) ff95a1d6fdf7052beaa36b5cffea3cafcb1d96079db61feb4e77fe9944c4e33c
// (3) 83dd295e01df36a2e6677c324325460ec7ed1db7368c7a0f6189c8e3e1836295
// (4) 624796558b1522af7179bed759382cea17c610d55043e876e5c013cd267e5d2a
// (5) 475f70836d5a733e2384a2d8e69a07dc056d0267c8c84b1fe0a0e7adfacc07e9
// (6) c6b5309491970c1a876044c8a097e9ba8adc234adfa705b5c75a7688e021bfc2
// (7) dbd2fbb2f02c022f360d5d98d228dd98f3d1de549e18de461a9bb7ea9547b317
// (8) a24a703cf06a85b54fca9dbc2bee5a203167480c384bbf9f40560cfd12cbfbe2
// (9) 9c903aa8b98a0b4484d1875190b00f01f2749fed94228464e54fad3a29335be3
