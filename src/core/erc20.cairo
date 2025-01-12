#[starknet::contract]
mod ERC20{
    use starknet::{ContractAddress, get_caller_address};
    use starknet::storage::{Map, StoragePathEntry};

    #[storage]
    struct Storage{
        owner: ContractAddress,
        pub name:felt252,
        pub symbol:felt252,
        pub decimals:u8,
        pub supply:u256,
        pub balances: Map::<ContractAddress, u256>,
        pub allowances: Map::<(ContractAddress,ContractAddress),u256>
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Transfer:Transfer,
        Allowance:Allowance
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

    #[derive(Drop, starknet::Event)]
    struct Allowance{
        #[key]
        owner:ContractAddress,
        #[key]
        spender:ContractAddress,
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

        fn get_name(self: @ContractState) -> felt252{
            self.name.read()
        }
        fn get_symbol(self: @ContractState) -> felt252{
            self.symbol.read()
        }
        fn get_decimals(self: @ContractState) -> u8{
            self.decimals.read()
        }

        fn allowance(self:@ContractState, owner: ContractAddress, spender: ContractAddress) -> u256 {
            self.allowances.entry((owner, spender)).read()
        }        

        fn balance_of(self:@ContractState, address: ContractAddress) -> u256 {
            self.balances.entry(address).read()
        }

        fn get_total_supply(self: @ContractState) -> u256 {
            self.supply.read()
        }

        fn approve(ref self:ContractState, amount: u256, to: ContractAddress){
            let current = self.allowances.entry((get_caller_address(),to)).read();
            assert(self.balances.entry(get_caller_address()).read() >= current + amount, 'Not enough money in bank');
            self.allowances.entry((get_caller_address(),to)).write(current + amount);
            self.emit(Allowance{owner:get_caller_address(),spender:to,amount:amount});
        }

        fn transferFrom(ref self:ContractState, from: ContractAddress, amount: u256, to: ContractAddress){
            assert(self.balances.entry(from).read() >= amount, 'Not enough money in bank');
            let current = self.allowances.entry((get_caller_address(),to)).read();
            assert(current >= amount, 'Not allowed');
            self.allowances.entry((get_caller_address(),to)).write(current - amount);
            self._transfer(from,amount,to);
        }

        fn transfer(ref self:ContractState, amount: u256, to: ContractAddress){
            assert(self.balances.entry(get_caller_address()).read() >= amount, 'Not enough money in bank');
            self._transfer(get_caller_address(),amount,to);
        }

        
    }

    #[generate_trait]
    impl Private of PrivateTrait {
        fn _transfer(ref self:ContractState, from:ContractAddress, amount: u256, to: ContractAddress){
            let currentFrom:u256 = self.balances.entry(from).read();
            let currentTo:u256 = self.balances.entry(to).read();
            self.balances.entry(from).write(currentFrom - amount);
            self.balances.entry(to).write(currentTo + amount);
            self.emit(Transfer{from:from,to:to,amount:amount});
        }
    }
}