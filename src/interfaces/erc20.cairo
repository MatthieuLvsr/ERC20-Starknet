use starknet::ContractAddress;

#[starknet::interface]
pub trait IERC20<TContractState> {
    fn balanceOf(self: @TContractState, address:ContractAddress) -> u256;
    fn transfer(ref self: TContractState, amount: u256, to: ContractAddress);
    fn totalSupply(self: @TContractState) -> u256;
}