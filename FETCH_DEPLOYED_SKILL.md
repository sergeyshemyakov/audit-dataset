---
name: fetch-deployed
description: Locate and copy all the source code relevant for a given L2BEAT project's security. This covers critical contracts and zk-related sources.
---

Your goal is to create `deployed-contracts` directory for a given project and populate it with the critical source code that is currently deployed onchain. Critical sources consist of the smart contracts that are considered critical by `fetch_deployed.py` script and the sources of all zk-relevant systems: verifiers and zk programs, if there are any. You shoud receive the project name / proejct names from the user as a part of the prompt.

## Repos and paths

- `audit-dataset` repo is the location where the source code should be placed. In this repo `<project>/` (e.g. `tornado-cash/`, `scroll/`, `unichain/`) directory contains all information relevant for a single project. `deployed-contracts` should be located in `<project>/deployed-contracts`.
- Note that `deployed-contracts/` is gitignored in this repo, the deployed sources should live only locally and not be pushed to the remote repo.
- `l2beat` repo is the main place to fetch info about the deployed projects. Check `~/Documents/l2beat`, if this is not the correct path, ask the user about the location of `l2beat` repo.

## Fetching smart contract sources

- `fetch_deployed.py` script already does the heavy-lifting for fetching flattened sources for the deployed contracts from `l2beat`. By default only contracts marked `"critical": true` in `discovered.json` are exported; pass `--all-contracts` to export every contract, which also happens automatically when the project has no critical contracts. 
- Before running the script, make sure to fetch the latest deployed sources by using l2beat discovery. Run `l2b discover <project> --dev` from `l2beat/packages/config` to fetch the fresh sources. Run `fetch_deployed.py` afterwards. Ignore discovery errors, in the worst case you will get slightly stale sources, but that's fine, do not spend time debuggin disco.

## Fetching zk code

- If a project uses a zk proving system, it could have two types of relevant zk sources: zk verifier sources and possibly zk program sources. For both of them you don't need to fetch anything deployed onchain, but search zk catalog entries for the original sources on github.
- The source of truth on which verifiers and zk programs are used by the project, is the `contracts` entry in its `<project>.ts` file in `l2beat/packages/config`. `zkVerifiers` entry corresponds to zk verifiers, `programHashes` to zk and other program sources.
- Link to the sources of zk verifier could be found in `zkCatalogInfo.verifierHashes`. It should have an entry `knownDeployments` with an address that matches the verified address from discovery (could be read out of `discovered.json`) and `sourceLink` that points to the exact source. That is the link that you need.
- Link to the sources of zk program could be found in `programHashes.ts`. The hash should match what you extact from the `discovered.json` based on project's `programHashes`, and its `programUrl` is the link you need.
- If a project does not configure `zkVerifiers` or `programHashes`, or the entry in zk catalog or `programHashes.ts` does not contain a link, then ignore these sources. 
- For all the links that you have collected (all verifiers and all zk programs), fetch their sources from the links and place them in `<project>/deployed-contracts/_zk` in `audit-dataset` repo.
- In the `_zk` dir write `zk-sources.json` file that has an entry for each fetched source. It should contain github link, commit, verifier / zk program, and the deployment address if applicable.
### `zk-sources.json` schema

```json
[
  {
    "type": "verifier | program",
    "name": "<name from zkCatalogInfo.verifierHashes or programHashes.ts>",
    "link": "<github link the sources were fetched from>",
    "commit": "<full commit hash of the fetched revision>",
    "address": "<chain-specific deployment address, e.g. eth:0x..., only for verifiers>",
    "path": "<directory inside _zk where the sources were placed>"
  }
]
```
