#[starknet::contract]
pub mod MockERC20{
    use starknet::{ContractAddress};
    use erc20::components::erc20::erc20_component;

    component!(path: erc20_component, storage: erc20, event: ERC20Event);

    #[abi(embed_v0)]
    impl ERC20Impl = erc20_component::ERC20<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc20: erc20_component::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event, Debug, PartialEq)]
    pub enum Event {
        ERC20Event: erc20_component::Event,
    }

    impl ERC20Private = erc20_component::ERC20Private<ContractState>;

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress, name:felt252, symbol:felt252, decimals:u8, initial_supply:u256) {
        self.erc20._init(owner, name, symbol, decimals, initial_supply);
    }
}