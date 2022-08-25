/* global ethers */
/* eslint prefer-const: "off" */

const { getSelectors, FacetCutAction } = require('./libraries/diamond.js')

async function deployDiamond() {
  const accounts = await ethers.getSigners()
  const contractOwner = accounts[0]

  const HelpECDSA = await ethers.getContractFactory('HelpECDSA')
  const helpECDSA = await HelpECDSA.deploy()
  await helpECDSA.deployed()
  console.log('HelpECDSA deployed', helpECDSA.address)

  const StringHelper = await ethers.getContractFactory('StringHelper')
  const stringHelper = await StringHelper.deploy()
  await stringHelper.deployed()
  console.log('StringHelper deployed', stringHelper.address)

  const ChallengeManagerFacet = await ethers.getContractFactory('ChallengeManagerFacet', {
    libraries: {
      'StringHelper': stringHelper.address,
      'HelpECDSA': helpECDSA.address
    }
  })
  const challengeManagerFacet = await ChallengeManagerFacet.deploy()
  await challengeManagerFacet.deployed()
  console.log('ChallengeManagerFacet deployed', challengeManagerFacet.address)

  // deploy mint facet 
  const MintFacet = await ethers.getContractFactory('MintFacet', {
    libraries: {
      'StringHelper': stringHelper.address,
      'HelpECDSA': helpECDSA.address
    }
  })
  const mintFacet = await MintFacet.deploy()
  await mintFacet.deployed()
  console.log('MintFacet deployed', mintFacet.address)

  // deploy svg facet 
  const SvgFacet = await ethers.getContractFactory('SvgFacet', {
    libraries: {
      'StringHelper': stringHelper.address,
    }
  })
  const svgFacet = await SvgFacet.deploy()
  await svgFacet.deployed()
  console.log('SvgFacet deployed', svgFacet.address)


  // deploy svg facet 
  const TokenURIFacet = await ethers.getContractFactory('TokenURIFacet', {
    libraries: {
      'StringHelper': stringHelper.address,
    }
  })
  const tokenURIFacet = await TokenURIFacet.deploy()
  await tokenURIFacet.deployed()
  console.log('TokenURIFacet deployed', tokenURIFacet.address)


  // deploy sponsor facet
  const SponsorFacet = await ethers.getContractFactory('SponsorFacet', {
    libraries: {
      // 'StringHelper': stringHelper.address,
      'HelpECDSA': helpECDSA.address
    }
  })
  const sponsorFacet = await SponsorFacet.deploy()
  await sponsorFacet.deployed()
  console.log('SponsorFacet deployed', sponsorFacet.address)

  // deploy DiamondCutFacet
  const DiamondCutFacet = await ethers.getContractFactory('DiamondCutFacet')
  const diamondCutFacet = await DiamondCutFacet.deploy()
  await diamondCutFacet.deployed()
  console.log('DiamondCutFacet deployed:', diamondCutFacet.address)

  // deploy Diamond
  const Diamond = await ethers.getContractFactory('Diamond')
  const diamond = await Diamond.deploy(contractOwner.address, diamondCutFacet.address)
  // const diamond = await Diamond.deploy(contractOwner.address, diamondCutFacet.address, {       deterministicDeployment: "0x1234",})
  await diamond.deployed()
  console.log('Diamond deployed:', diamond.address)

  // deploy DiamondInit
  // DiamondInit provides a function that is called when the diamond is upgraded to initialize state variables
  // Read about how the diamondCut function works here: https://eips.ethereum.org/EIPS/eip-2535#addingreplacingremoving-functions
  const DiamondInit = await ethers.getContractFactory('DiamondInit')
  const diamondInit = await DiamondInit.deploy()
  await diamondInit.deployed()
  console.log('DiamondInit deployed:', diamondInit.address)

  // deploy facets
  console.log('\nDeploying facets')
  const FacetNames = [
    'DiamondLoupeFacet',
    'OwnershipFacet',
    'BroadcastFacet',
    'ScoreboardFacet',
    'RoyaltiesFacet',
    'TokenInfoFacet',
    'SearchTokensFacet',
    'AdminFacet',
  ]
  const cut = []

  cut.push({
    facetAddress: challengeManagerFacet.address,
    action: FacetCutAction.Add,
    functionSelectors: getSelectors(challengeManagerFacet)
  })

  cut.push({
    facetAddress: mintFacet.address,
    action: FacetCutAction.Add,
    functionSelectors: getSelectors(mintFacet)
  })

  cut.push({
    facetAddress: sponsorFacet.address,
    action: FacetCutAction.Add,
    functionSelectors: getSelectors(sponsorFacet)
  })

  cut.push({
    facetAddress: svgFacet.address,
    action: FacetCutAction.Add,
    functionSelectors: getSelectors(svgFacet)
  })

  cut.push({
    facetAddress: tokenURIFacet.address,
    action: FacetCutAction.Add,
    functionSelectors: getSelectors(tokenURIFacet)
  })


  for (const FacetName of FacetNames) {
    const Facet = await ethers.getContractFactory(FacetName,
      //   {
      //   libraries: {
      //     StringHelper: stringHelper.address
      //   } 
      // }
    )
    const facet = await Facet.deploy()
    await facet.deployed()
    console.log(`${FacetName} deployed: ${facet.address}`)
    cut.push({
      facetAddress: facet.address,
      action: FacetCutAction.Add,
      functionSelectors: getSelectors(facet)
    })
  }

  // upgrade diamond with facets
  console.log('')
  console.log('Diamond Cut:', cut)
  const diamondCut = await ethers.getContractAt('IDiamondCut', diamond.address)
  let tx
  let receipt
  // call to init function
  let functionCall = diamondInit.interface.encodeFunctionData('init')
  tx = await diamondCut.diamondCut(cut, diamondInit.address, functionCall)
  console.log('Diamond cut tx: ', tx.hash)
  receipt = await tx.wait()
  if (!receipt.status) {
    throw Error(`Diamond upgrade failed: ${tx.hash}`)
  }
  // console.log('Completed diamond cut')
  // console.log(`address of diamond: "${diamond.address}", or --> `, diamond.address)
  process.stdout.write(`@@@${diamond.address}`) 
  return diamond.address
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
if (require.main === module) {
  deployDiamond()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error)
      process.exit(1)
    })
}

exports.deployDiamond = deployDiamond
