import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { assert, expect } from 'chai';
import { network, deployments, ethers } from 'hardhat';
import { BigNumber, utils } from 'ethers';
import { Buffer } from 'buffer';
import { developmentChains, networkConfig } from '../helper-hardhat-config';
import { Punchathlon } from '../typechain';

const mintFee = ethers.utils.parseEther('0.01');

if (developmentChains.includes(network.name)) {
	describe('Punchathlon Unit tests', () => {
		let contract: Punchathlon;
		let player: SignerWithAddress;
		let accounts: SignerWithAddress[];

		beforeEach(async () => {
			[, player] = await ethers.getSigners();
			const contractFactory = await ethers.getContractFactory('Punchathlon');
			contract = (await contractFactory.deploy()) as Punchathlon;
		});

		describe.skip('constructor', async () => {
			it('should have the correct initial values', async () => {
				// Get the contract instance at the user's address
				const contractAtUserAddress = await ethers.getContractAt(
					'Punchathlon',
					contract.address,
					player
				);
			});
		});

		describe('constructor', async () => {
			it('initializes the Punchathlon correctly', async () => {
				const maxTokens = await contract.getMaxTokenIds();
				assert.equal(maxTokens.toString(), '1000', 'Max tokens should be 1000');
				const mintPrice = await contract.getMintPrice();
				assert.equal(mintPrice.toString(), '10000000000000000', 'Mint price should be 0.01 ETH');
				const tokenIdCount = await contract.getTokenId();
				assert.equal(tokenIdCount.toString(), '0', 'Tokens minted should be 0');

				assert.equal(
					String(await contract.getFighterClassBaseStats('JiuJitsu')),
					'60,60,60,0,0,0',
					'Invalid Base Stats for JiuJitsu Fighter'
				);
				// console.log(String(await contract.getFighterClassBaseStats('JiuJitsu')));
				// console.log(String(await contract.getFighterClassBaseStats('KickBoxing')));
				// console.log(String(await contract.getFighterClassBaseStats('Judo')));
				// console.log(String(await contract.getFighterClassBaseStats('Wrestling')));
				// console.log(String(await contract.getFighterClassBaseStats('MuayThai')));
				assert.equal(
					String(await contract.getFighterClassBaseStats('KickBoxing')),
					'80,60,40,0,1,0',
					'Invalid Base Stats for KickBoxing Fighter'
				);

				assert.equal(
					String(await contract.getFighterClassBaseStats('Judo')),
					'40,60,80,0,2,0',
					'Invalid Base Stats for Judo Fighter'
				);

				assert.equal(
					String(await contract.getFighterClassBaseStats('Wrestling')),
					'100,40,40,0,3,0',
					'Invalid Base Stats for Wrestling Fighter'
				);

				assert.equal(
					String(await contract.getFighterClassBaseStats('MuayThai')),
					'40,80,60,0,4,0',
					'Invalid Base Stats for MuayThai Fighter'
				);
				// const str = 'Rare';
				// const bytes = Buffer.from(str);
				// const encoded = utils.defaultAbiCoder.encode(['bytes'], [bytes]);
				console.log(
					String(
						await contract.getRarityAdjustment(
							utils.defaultAbiCoder.encode(['bytes'], [Buffer.from('Common')])
						)
					)
				);
				console.log(
					String(
						await contract.getRarityAdjustment(
							utils.defaultAbiCoder.encode(['bytes'], [Buffer.from('Uncommon')])
						)
					)
				);
				console.log(
					String(
						await contract.getRarityAdjustment(
							utils.defaultAbiCoder.encode(['bytes'], [Buffer.from('Rare')])
						)
					)
				);
				console.log(
					String(
						await contract.getRarityAdjustment(
							utils.defaultAbiCoder.encode(['bytes'], [Buffer.from('Legendary')])
						)
					)
				);
				console.log(
					String(
						await contract.getRarityAdjustment(
							utils.defaultAbiCoder.encode(['bytes'], [Buffer.from('jjhj')])
						)
					)
				);
			});
		});

		describe('mint', async () => {
			it('mints 5 nft correctly', async () => {
				const provider = ethers.getDefaultProvider();

				const block = await provider.getBlock('latest');
				const { timestamp } = block;
				console.log(timestamp);
				await contract.mint('JiuJitsu', 'test', { value: mintFee.toString() });
				await contract.mint('KickBoxing', 'test', { value: mintFee.toString() });
				await contract.mint('Judo', 'test', { value: mintFee.toString() });
				await contract.mint('Wrestling', 'test', { value: mintFee.toString() });
				await contract.mint('MuayThai', 'test', { value: mintFee.toString() });

				console.log(await contract.getFighterStats(1));
				console.log(await contract.getFighterStats(2));
				console.log(await contract.getFighterStats(3));
				console.log(await contract.getFighterStats(4));
				console.log(await contract.getFighterStats(5));
				console.log(await contract.getFighterStats(6));

			});
		});
	});
}
