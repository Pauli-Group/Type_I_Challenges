/* global eters */
/* eslint prefer-const: "off" */

const diamondAddress = ``;

(async () => {
    const { getSelectors, FacetCutAction } = require('./libraries/diamond.js')
    // REDEPLOY FACET
    const SearchTokensFacet = await ethers.getContractFactory('SearchTokensFacet', {
    })
    const searchTokensFacet = await SearchTokensFacet.deploy()
    await searchTokensFacet.deployed()
    console.log('searchTokensFacet deployed', searchTokensFacet.address)

    // GET THE SELECTORS WE CARE ABOUT
    const selectors = getSelectors(SearchTokensFacet).get(['get_max_challenge_index()'])
    console.log(`selectors: ${JSON.stringify(selectors, null, 2)}`)

    // GET ADDRESS OF NEW FACET
    const newFacetAddress = searchTokensFacet.address

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