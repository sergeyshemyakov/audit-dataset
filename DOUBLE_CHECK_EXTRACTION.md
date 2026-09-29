---
name: double-check-extraction
description: Rerun the audit extraction pipeline for a given project independently and compare your results with the current version of the audit extraction.
---

In this repo I have extracted exact file versions that are covered by project audits. This is done with an AI agent that could possibly make mistakes, so your job is to independently double check its work and report on the differences. Before you execute this skill, you have to clearly understand which project you are working with. If the user did not provide this info, ask for it.

The AUDIT_EXTRACT_SKILL.md explains the methodology of extracting information from audits. Read it and then do the following:

## Independent audit data extraction

1. Copy the reports directory of the project into a scratchpad directory outside of this repo. Scratchpad has to either be in /tmp dir, or you have to delete it after you are done with the work. You MUST NOT read the contents of audit-summary.json or .md of the project inside the repo.

2. Read the audit reports in the scratchpad and extract audit-summary.json according to the AUDIT_EXTRACT_SKILL.md.

3. Generate audit-summary.md from the .json that you wrote.

## Difference analysis

1. Highlight any disagreements between you and the repo on which reports should be considered irrelevant and explain your position.

2. Analyze the difference between the audit-summary.md that you got and the audit-summary.md for the project present in the repo, only at this step you can read the project's audit-summary.md in the repo. Ideally, both .md files should mention the same paths, on the same commits, in the same repos. If there are differences, inspect the audit report text to establish the reason for a difference. If the report is ambiguous on the audited path, it's fine, but if one of the audit-summary.md clearly contradicts the content of audit report, it must be highlighted together with comments on the origin of inaccuracy.

3. Programmatically scan both audit-summary.json to check contracts with major findings. Again, paths with major findings should ideally be identical in both audit-summary.json files, count of major findings should be equal. A difference is allowed when audit is not explicit enough, but all clear contradictions between audit-summary.json and audit text on the topic of major findings should be highlighted with explanations of the error.

4. Do not check the correctness of metadata extracted from audits, it is not relevant. 

Prepare a report of your findings.