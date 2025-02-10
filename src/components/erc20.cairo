#[starknet::component]
pub mod erc20_component{
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
    #[derive(Drop, starknet::Event, Debug, PartialEq)]
    pub enum Event {
        Transfer:Transfer,
        Allowance:Allowance
    }

    #[derive(Drop, starknet::Event, Debug, PartialEq)]
    pub struct Transfer{
        #[key]
        pub from:ContractAddress,
        #[key]
        pub to:ContractAddress,
        #[key]
        pub amount:u256
    }

    #[derive(Drop, starknet::Event, Debug, PartialEq)]
    pub struct Allowance{
        #[key]
        pub owner:ContractAddress,
        #[key]
        pub spender:ContractAddress,
        #[key]
        pub amount:u256
    }
    
    #[embeddable_as(ERC20)]
    impl ERC20Impl<
        TContractState, +HasComponent<TContractState>,
    > of erc20::interfaces::erc20::IERC20<ComponentState<TContractState>> {

        fn get_name(self: @ComponentState<TContractState>) -> felt252{
            self.name.read()
        }
        fn get_symbol(self: @ComponentState<TContractState>) -> felt252{
            self.symbol.read()
        }
        fn get_decimals(self: @ComponentState<TContractState>) -> u8{
            self.decimals.read()
        }

        fn allowance(self:@ComponentState<TContractState>, owner: ContractAddress, spender: ContractAddress) -> u256 {
            self.allowances.entry((owner, spender)).read()
        }        

        fn balance_of(self:@ComponentState<TContractState>, address: ContractAddress) -> u256 {
            self.balances.entry(address).read()
        }

        fn get_total_supply(self: @ComponentState<TContractState>) -> u256 {
            self.supply.read()
        }

        fn approve(ref self:ComponentState<TContractState>, amount: u256, to: ContractAddress){
            let current = self.allowances.entry((get_caller_address(),to)).read();
            assert(self.balances.entry(get_caller_address()).read() >= current + amount, 'Not enough money in bank');
            self.allowances.entry((get_caller_address(),to)).write(current + amount);
            self.emit(Allowance{owner:get_caller_address(),spender:to,amount:amount});
        }

        fn transferFrom(ref self:ComponentState<TContractState>, from: ContractAddress, amount: u256, to: ContractAddress){
            assert(self.balances.entry(from).read() >= amount, 'Not enough money in bank');
            let current = self.allowances.entry((get_caller_address(),to)).read();
            assert(current >= amount, 'Not allowed');
            self.allowances.entry((get_caller_address(),to)).write(current - amount);
            self._transfer(from,amount,to);
        }

        fn transfer(ref self:ComponentState<TContractState>, amount: u256, to: ContractAddress){
            assert(self.balances.entry(get_caller_address()).read() >= amount, 'Not enough money in bank');
            self._transfer(get_caller_address(),amount,to);
        }   
    }

    #[generate_trait]
    pub impl ERC20Private<
        TContractState, +HasComponent<TContractState>,
    > of PrivateTrait<TContractState> {
        fn _transfer(ref self:ComponentState<TContractState>, from:ContractAddress, amount: u256, to: ContractAddress){
            let currentFrom:u256 = self.balances.entry(from).read();
            let currentTo:u256 = self.balances.entry(to).read();
            self.balances.entry(from).write(currentFrom - amount);
            self.balances.entry(to).write(currentTo + amount);
            self.emit(Transfer{from:from,to:to,amount:amount});
        }

        fn _init(ref self: ComponentState<TContractState>, owner: ContractAddress, name:felt252, symbol:felt252, decimals:u8, initial_supply:u256) {
            self.owner.write(owner);
            self.name.write(name);
            self.symbol.write(symbol);
            self.decimals.write(decimals);
            self.supply.write(initial_supply);
            self.balances.entry(owner).write(initial_supply);
        }
    }
}