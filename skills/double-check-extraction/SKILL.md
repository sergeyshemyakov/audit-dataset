---
name: double-check-extraction
description: Rerun the audit extraction for a given collection independently and compare your results with the current version of the audit extraction.
---

In this repo I have extracted exact file versions that are covered by project audits. This is done with an AI agent that could possibly make mistakes, so your job is to independently double check its work and report on the differences. Before you execute this skill, you have to clearly understand which collection you are working with. If the user did not provide this info, ask for it.

`skills/audit-extract/SKILL.md` explains the methodology of extracting information from audits. Read it and then do the following:

## Independent audit data extraction

1. Copy the reports directory of the collection into a scratchpad directory outside of this repo, laid out as `<scratchpad>/<collection>/reports` (for a library collection such as `_libs/safe`, `<scratchpad>/_libs/safe/reports`). Scratchpad has to either be in /tmp dir, or you have to delete it after you are done with the work. You MUST NOT read the contents of audit-summary.json or .md of the collection inside the repo.

2. Read the audit reports in the scratchpad and extract `<scratchpad>/<collection>/audit-summary.json` according to the audit-extract skill, including the `kind` of every scoped path.

3. Validate it and generate audit-summary.md from the .json that you wrote, running from the root of this repo: `python3 -m audit_dataset --dataset-root <scratchpad> render <collection>`. Fix every validation problem it reports before continuing.

## Difference analysis

1. Highlight any disagreements between you and the repo on which reports should be considered irrelevant and explain your position.

2. Analyze the difference between the audit-summary.md that you got and the audit-summary.md for the collection present in the repo, only at this step you can read the collection's audit-summary.md in the repo. Ideally, both .md files should mention the same paths, on the same commits, in the same repos. If there are differences, inspect the audit report text to establish the reason for a difference. If the report is ambiguous on the audited path, it's fine, but if one of the audit-summary.md clearly contradicts the content of audit report, it must be highlighted together with comments on the origin of inaccuracy.

3. Programmatically scan both audit-summary.json to compare the versions with major findings. Paths with major findings should ideally be identical in both files, with the same `major_finding_ids`. A difference is allowed when the audit is not explicit enough, but all clear contradictions between audit-summary.json and the audit text on the topic of major findings should be highlighted with explanations of the error.

4. Programmatically compare the `kind` of every path present in both files. Only `evm` paths are fetched and exported, so a path that one file marks `evm` and the other `zk`, `cairo` or `other` either hides audited EVM code or stores code that is not EVM; highlight every such disagreement and say which kind the report supports.

5. Do not check the correctness of metadata extracted from audits, it is not relevant.

Prepare a report of your findings.
