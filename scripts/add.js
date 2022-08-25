/* global eters */
/* eslint prefer-const: "off" */

const diamondAddress = ``;

(async () => {
    const { getSelectors, FacetCutAction } = require('./libraries/diamond.js')
    // REDEPLOY LIBRARIES WE DEPEED ON
    const StringHelper = await ethers.getContractFactory('StringHelper')
    const stringHelper = await StringHelper.deploy()
    await stringHelper.deployed()
    console.log('StringHelper deployed', stringHelper.address)

    // REDEPLOY FACET
    const TokenURIFacet = await ethers.getContractFactory('TokenURIFacet', {
        libraries: {
            'StringHelper': stringHelper.address,
        }
    })
    const tokenURIFacet = await TokenURIFacet.deploy()
    await tokenURIFacet.deployed()
    console.log('TokenURIFacet deployed', tokenURIFacet.address)

    // GET THE SELECTORS WE CARE ABOUT
    const selectors = getSelectors(TokenURIFacet).get(['setBaseURI(string memory)'])
    console.log(`selectors: ${JSON.stringify(selectors, null, 2)}`)

    // GET ADDRESS OF NEW FACET
    const newFacetAddress = tokenURIFacet.address

    // CREATE CUT TRANSACTION
    const diamondCutFacet = await ethers.getContractAt('DiamondCutFacet', diamondAddress)
    const tx = await diamondCutFacet.diamondCut(
        [{
            facetAddress: newFacetAddress,
            action: FacetCutAction.Add,
            functionSelectors: selectors
        }],
        ethers.constants.AddressZero, '0x', { gasLimit: 800000 })

    console.log(`waiting on tx...`)

    const receipt = await tx.wait()

    if (!receipt.status)
        throw Error(`Diamond upgrade failed: ${tx.hash}`)

    console.log(`success`)
})()