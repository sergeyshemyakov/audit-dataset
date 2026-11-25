# Audit export

`audit-index.json` and `audit-objects.json.zst` at the repository root are the dataset's public interface. Everything else (summaries, manifests, `audited-sources/`, the package) is internal and may change as long as the export keeps its shape.

Consumers read both files pinned to a dataset commit:

```
https://raw.githubusercontent.com/<owner>/audit-dataset/<commit>/audit-index.json
https://raw.githubusercontent.com/<owner>/audit-dataset/<commit>/audit-objects.json.zst
```

The export says where audited code lives, who audited it, which major findings were open there, what the report says about code it does not list, and what the audited code was. Comparing it with deployed code is the consumer's job.

## `audit-index.json`

```ts
type AuditIndex = {
  schema_version: '2.0.0'
  collections: Record<CollectionId, Collection>
  reports: Record<ReportId, Report>
  repositories: Record<RepositoryId, Record<Commit, Snapshot>>
}

type Collection = {
  name: string                // display name, e.g. "OpenZeppelin", "Safe"
  kind: 'project' | 'library' // 'library' exactly for the ids under "_libs/"
}

type Report = {
  collections: CollectionId[] // the collections the report belongs to, sorted
  title: string               // without the auditor's name
  auditor: string
  date: string | null         // YYYY-MM-DD
  document: string            // dataset path of the report's original document
  evm_scope: 'none' | 'unpinned' | 'partial' | 'full'
  unlisted: 'not_mentioned' | 'excluded' | null
  dependencies: 'included' | 'excluded' | null
}

// One repository at one commit.
type Snapshot = {
  timestamp: number                  // committer date, unix seconds
  files: Record<Path, ObjectId>      // every exported file of this repository at this commit
  audits: Record<ReportId, Audit>    // empty for a snapshot that exists only as a dependency
  mounts?: Record<Path, Mount>       // submodules the audited code imports from
  imports?: Record<Path, Record<ImportString, Path | null>>
}

type Mount = { repository: RepositoryId; commit: Commit }

// What one report says about this snapshot. Every key but `listed` is a sorted
// list of paths and is omitted when empty.
type Audit = {
  listed: Record<Path, FindingId[]>  // scoped path (file or directory) -> major findings open there
  partial?: Path[]                   // listed paths the report reviewed only in part
  excluded?: Path[]                  // paths the report says it did not review
  implied?: Path[]                   // unmentioned files that audited code imports
  included?: Path[]                  // dependency files a statement of the report covers
  visible?: Path[]                   // unmentioned files reachable only through excluded or partial files
  external?: Path[]                  // which of the paths above are third-party dependency code
}

type CollectionId = string // collection directory: an L2BEAT project id, or "_libs/<vendor>"
type ReportId = string     // unique across the dataset
type RepositoryId = string // "owner/repo", "gist/owner/id" or "<host>/<path>"; it determines the URL
type Commit = string       // full lowercase hex commit id
type ObjectId = string     // first 12 hex characters of the git blob id of the contents
type Path = string         // POSIX, relative to the repository root, no leading or trailing "/"
type ImportString = string // the import as written in the source
type FindingId = string    // as printed in the report
```

### Collections and reports

A `project` collection holds the audits of one L2BEAT project, and its id is that project's L2BEAT id. A `library` collection, under `_libs/`, holds the audits of code that many projects reuse. Names come from `collections.json`.

`reports` lists every relevant report of every collection. A report in several collections is listed once.

- `document` is the file the report was published as, a path relative to the dataset root. It can be linked as `https://github.com/<owner>/audit-dataset/blob/<commit>/<document>`.
- `evm_scope` says how far the report's review of EVM code is pinned down:
  - `none`: it scopes no EVM code.
  - `unpinned`: nothing it audited is pinned to a full commit.
  - `partial`: pinned, but reviewed only in part (fix reviews, diffs).
  - `full`: at least one path audited in full at a full commit.
- `unlisted` is what the report says about code of the audited repository that it does not list: `excluded` when it says in words that everything else was not reviewed, `not_mentioned` when it is silent, `null` when the report has not been read for this yet.
- `dependencies` is a general statement of the report about third-party code, or `null` when it makes none.

### What a report lists

A file is listed by a report when one of the report's `listed` paths is the file itself or a directory above it: `src` covers `src/Vault.sol`, `src/Vault` does not. A directory is written once under its own path. A directory scope covers no tests, mocks or deployment scripts, and nothing under a path the report excludes.

`listed[path]` holds the Major/Critical findings the report left open in that path at that commit, in report order, or `[]`.

`excluded` holds the paths the report says it did not review. They apply at every commit of the repository, may be directories, and need not be exported files.

### What a report reaches

For a report with `unlisted` set, the dataset follows the imports of the files it audited in full and labels every file reached:

- `implied`: the report does not mention the file, and audited code imports it. This needs `unlisted: "not_mentioned"`.
- `included`: dependency code that a statement of the report covers. This needs `dependencies: "included"`.
- `excluded`: the report excludes the file, in a listing or by a general statement.
- `visible`: the report does not mention the file, and it is reachable only through an excluded or partially audited file. The dataset gives no verdict on it: the consumer decides whether audited code actually uses it.

Nothing is followed from an excluded or partially audited file when deciding what is implied. The export still reads on through such files, so that every file the audited code can name is available.

A strict reading of a report counts only `listed`. A relaxed reading adds `implied` and `included`.

### Mounts and imports

`mounts` maps a path of the snapshot to the submodule checked out there at that commit. A path below a mount names a file in the mounted repository's snapshot, relative to its root: with `lib/forge-std` mounted, `lib/forge-std/src/Vm.sol` is `src/Vm.sol` in that snapshot's `files`. Mounts can nest. The paths in `implied`, `included`, `visible` and `external` may lie below a mount; every one of them resolves to an exported file.

`imports` gives, for every file the expansion read, each import string and the path it resolved to, or `null` when it led to no exported file.

### Repository URLs

URLs are not exported, because the id determines them:

- an id whose first segment contains a dot is `<host>/<path>`, at `https://<host>/<path>`;
- `gist/<owner>/<id>` is at `https://gist.github.com/<owner>/<id>`;
- every other id is `<owner>/<repo>`, at `https://github.com/<owner>/<repo>`.

## `audit-objects.json.zst`

One zstd frame (level 19, long-distance matching with a 128 MiB window, content checksum) holding a compact JSON object with sorted keys, from object id to the file's contents. Every file is stored once under its object id, however many snapshots contain it.

An object's full id is the SHA-1 git blob id of its UTF-8 contents, `sha1("blob " + byteLength + "\0" + bytes)`. Every object is a committed blob of this repository, so `GET https://api.github.com/repos/<owner>/audit-dataset/git/blobs/<blobId>` returns it alone.

## Rules

1. **Stored bytes.** Contents are the file at the audited commit, formatted by the `format` command with the config in `foundry.toml`. Object ids are therefore not upstream blob ids for files the formatter changed.
2. **Content addressed.** The git blob id of the contents starts with the object id. Two different contents sharing an object id fail the export.
3. **Solidity only.** Only files ending in `.sol` are exported.
4. **Only what was audited or reached.** Snapshots hold only code pinned to a full commit. Every file of a snapshot is listed by, or reached from, one of its audits, or is the target of a mount path of another snapshot. Every object is used by at least one file.
5. **Ids and paths.** One report id naming two different documents, titles, auditors, dates or scope statements fails the export. Repository ids are canonical. Paths never end with `/`.
6. **Collections.** Only collections whose summary is on the latest summary schema are exported. `collections.json` must name exactly the dataset's collections, exported or not.
7. **Timestamps.** Every snapshot has the committer date of its commit.
8. **Deterministic.** Keys are sorted, except that the commits of a repository are ordered by timestamp, then commit id. The same dataset produces byte-identical files.
9. **Committed blobs.** Every object is committed in this repository as a blob with exactly its bytes.

## Regenerating and checking

`python3 -m audit_dataset export` validates every summary, verifies every stored file against its manifest, builds the export, checks it against the rules above and only then writes both files. `pipeline` runs it as its last step. Commit both files together with the collection change.

`python3 -m audit_dataset export --check` writes nothing. It rebuilds the export and fails if the committed files differ from it. It reads the git index, so run it on a clean checkout or after `git add`.

Both commands print a warning, and still succeed, for:

- a collection whose summary is on an older schema: it is left out of the export until its reports are re-read;
- a collection on the latest schema with relevant reports not yet read for scope statements: nothing is derived from the imports of those reports;
- a collection fetched before dependencies were followed: it is exported with what its manifest has, until `fetch` is run on it.
