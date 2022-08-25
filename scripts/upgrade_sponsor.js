/* global eters */
/* eslint prefer-const: "off" */

const diamondAddress = ``;  

(async () => {
    const { getSelectors, FacetCutAction } = require('./libraries/diamond.js')
    // REDEPLOY LIBRARIES WE DEPEED ON
    const HelpECDSA = await ethers.getContractFactory('HelpECDSA')
    const helpECDSA = await HelpECDSA.deploy()
    await helpECDSA.deployed()
    console.log('HelpECDSA deployed', helpECDSA.address)

    // REDEPLOY FACET
    const SponsorFacet = await ethers.getContractFactory('SponsorFacet', {
        libraries: {
            'HelpECDSA': helpECDSA.address
        }
    })
    const sponsorFacet = await SponsorFacet.deploy()
    await sponsorFacet.deployed()
    console.log('SponsorFacet deployed', sponsorFacet.address)

    // GET THE SELECTORS WE CARE ABOUT
    const selectors = getSelectors(SponsorFacet).get(['sponsor(uint256 , string memory, string memory)'])
    console.log(`selectors: ${JSON.stringify(selectors, null, 2)}`)

    // GET ADDRESS OF NEW FACET
    const newFacetAddress = sponsorFacet.address

    // CREATE CUT TRANSACTION
    const diamondCutFacet = await ethers.getContractAt('DiamondCutFacet', diamondAddress)
    const tx = await diamondCutFacet.diamondCut(
        [{
            facetAddress: newFacetAddress,
            action: FacetCutAction.Replace,
            functionSelectors: selectors
        }],
        ethers.constants.AddressZero, '0x', { gasLimit: 800000 })

    console.log(`waiting on tx...`)

    const receipt = await tx.wait()

    if (!receipt.status)
        throw Error(`Diamond upgrade failed: ${tx.hash}`)

    console.log(`success`)
})()