use starknet::ContractAddress;

#[starknet::interface]
pub trait IERC20<TContractState> {
    fn get_name(self: @TContractState) -> felt252;
    fn get_symbol(self: @TContractState) -> felt252;
    fn get_decimals(self: @TContractState) -> u8;
    fn get_total_supply(self: @TContractState) -> u256;
    fn balance_of(self: @TContractState, address:ContractAddress) -> u256;
    fn allowance(self : @TContractState, owner: ContractAddress, spender: ContractAddress) -> u256;
    fn approve(ref self: TContractState, amount: u256, to: ContractAddress);
    fn transferFrom(ref self: TContractState, from: ContractAddress, amount: u256, to: ContractAddress);
    fn transfer(ref self: TContractState, amount: u256, to: ContractAddress);
}