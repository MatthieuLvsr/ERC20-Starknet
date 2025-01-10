#[starknet::contract]
mod ERC20{
    use starknet::{ContractAddress, get_caller_address};
    use starknet::storage::{Map, StorageMapReadAccess, StorageMapWriteAccess, StoragePathEntry};

    #[storage]
    struct Storage{
        owner: ContractAddress,
        pub name:felt252,
        pub symbol:felt252,
        pub decimals:u8,
        pub supply:u256,
        pub balances: Map::<ContractAddress, u256>
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Transfer:Transfer
    }

    #[derive(Drop, starknet::Event)]
    struct Transfer{
        #[key]
        from:ContractAddress,
        #[key]
        to:ContractAddress,
        #[key]
        amount:u256
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress, name:felt252, symbol:felt252, decimals:u8, initial_supply:u256) {
        self.owner.write(owner);
        self.name.write(name);
        self.symbol.write(symbol);
        self.decimals.write(decimals);
        self.supply.write(initial_supply);
        self.balances.entry(owner).write(initial_supply);
    }
    
    #[abi(embed_v0)]
    impl ERC20Impl of erc20::interfaces::erc20::IERC20<ContractState>{
        fn balanceOf(self:@ContractState, address: ContractAddress) -> u256 {
            self.balances.entry(address).read()
        }

        fn totalSupply(self: @ContractState) -> u256 {
            self.supply.read()
        }

        fn transfer(ref self:ContractState, amount: u256, to: ContractAddress){
            assert(self.balances.entry(get_caller_address()).read() >= amount, 'Not enough money in bank');
            // assert(to != 0x0, 'Wrong address');
            let currentFrom:u256 = self.balances.entry(get_caller_address()).read();
            let currentTo:u256 = self.balances.entry(to).read();
            self.balances.entry(get_caller_address()).write(currentFrom - amount);
            self.balances.entry(to).write(currentTo + amount);
            self.emit(Transfer{from:get_caller_address(),to:to,amount:amount});
        }
    }
}