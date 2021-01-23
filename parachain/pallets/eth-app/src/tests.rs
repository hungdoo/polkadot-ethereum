use crate::mock::{new_tester, AccountId, Origin, MockEvent, MockRuntime, System, Asset, ETH};
use frame_support::{assert_ok};
use frame_system as system;
use sp_keyring::AccountKeyring as Keyring;
use sp_core::H160;
use hex_literal::hex;
use codec::Decode;
use crate::{RawEvent, make_proxy};

use artemis_core::{SingleAsset, ChannelId};
use artemis_core::registry::make_registry;

use crate::payload::InboundPayload;

fn last_event() -> MockEvent {
	System::events().pop().expect("Event expected").event
}

const RECIPIENT_ADDR_BYTES: [u8; 32] = hex!["8eaf04151687736326c9fea17e25fc5287613693c912909cb226aa4794f26a48"];

type TestAccountId = <MockRuntime as system::Config>::AccountId;

#[test]
fn mints_after_handling_ethereum_event() {
	new_tester().execute_with(|| {
		let bob: AccountId = Keyring::Bob.into();

		let recipient_addr = TestAccountId::decode(&mut &RECIPIENT_ADDR_BYTES[..]).unwrap();
		let payload: InboundPayload<TestAccountId> = InboundPayload {
			sender_addr: hex!["cffeaaf7681c89285d65cfbe808b80e502696573"].into(),
			recipient_addr,
			amount: 10.into(),
		};

		assert_ok!(ETH::handle_payload(&payload));
		assert_eq!(Asset::balance(&bob), 10.into());
	});
}

#[test]
fn burn_should_emit_bridge_event() {
	new_tester().execute_with(|| {
		let recipient = H160::repeat_byte(2);
		let bob: AccountId = Keyring::Bob.into();
		Asset::deposit(&bob, 500.into()).unwrap();

		assert_ok!(ETH::burn(
			Origin::signed(bob.clone()),
			ChannelId::Incentivized,
			recipient,
			20.into()));

		assert_eq!(
			MockEvent::test_events(RawEvent::Burned(bob, 20.into())),
			last_event()
		);
	});
}

#[test]
fn test_make_proxy() {
	let proxy = make_proxy::<MockRuntime>();
	let mut registry = make_registry();

	registry.insert(H160::repeat_byte(1), proxy);

	let foo = registry.get(&H160::repeat_byte(1)).unwrap();

	assert!(foo.handle(&vec![0, 1, 2]).is_err())
}
