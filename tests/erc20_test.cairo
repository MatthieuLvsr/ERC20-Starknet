// tests/erc20_test.cairo

use starknet::{syscalls::deploy_syscall, ContractAddress, contract_address_const};
use erc20::core::erc20::MockERC20;
use erc20::interfaces::erc20::{IERC20Dispatcher, IERC20DispatcherTrait};

fn deploy() -> (IERC20Dispatcher, ContractAddress) {
    let owner: ContractAddress = contract_address_const::<'OWNER'>();
    let name: felt252 = 'MockERC20';
    let symbol: felt252 = 'MERC';
    let decimals: u8 = 18;
    let initial_supply: u256 = 1000;
    let mut calldata = array![];
    calldata.append(owner);
    calldata.append(name);
    calldata.append(symbol);
    calldata.append(decimals.into());
    calldata.append(initial_supply.low());
    calldata.append(initial_supply.high());

    let (address, _) = deploy_syscall(
        MockERC20::TEST_CLASS_HASH.try_into().unwrap(),
        0,          
        calldata.span(),
        false,      
    )
    .unwrap();

    (IERC20Dispatcher { contract_address: address }, address)
}

#[test]
fn test_initial_storage() {
    let (mock, _) = deploy();
    assert_eq!(mock.get_name(), 0x4d6f636b4552433230); // "MockERC20"
    assert_eq!(mock.get_symbol(), 0x4d455243);         // "MERC"
    assert_eq!(mock.get_decimals(), 18);
    assert_eq!(mock.get_total_supply(), 1000);
    assert_eq!(mock.balance_of(contract_address_const::<'OWNER'>()), 1000);
}