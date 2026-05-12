# AGENTS.md

## Scope

These instructions apply to the entire `DMRpp-wiki` repository.

## Communication

- State what you validated and what you could not validate.
- If you change publishing or CI behavior, call that out explicitly.
- If a request appears to depend on archived material in `retired/`, confirm that intent before treating it as the source of truth.
- Talk to me directly
- Be concise and to the point
- Be critical of my requests and your own work

## Writing Documents

- Do each of the following for every request unless explicitly told otherwise.
- For all documents you write, use markdown and store them in the `docs` directory
- For all work, unless told otherwise, write a log. When writing a document, title the log <doc-title>-log.md
- For all work, write a log entry explaining your reasoning unless explicitly told otherwise
- In the work log, start each new set of entries with a date/time stamp
- In the work log, include the query/prompt leading to the work
- For a plan, write the plan to a markdown document 

## Project Context

- This repository contains the source for the published DMR++ documentation site and related schema/reference material.
- The primary active documentation sources are `DMRpp.adoc`, `README.md`, and the material under `xml-schema/`.
- The `images/` directory contains assets used by the published documentation.
- The `retired/` directory contains archived material. Do not treat it as active source unless the user explicitly asks to work there.
- Prefer small, reviewable edits that preserve the current structure, voice, and examples unless a larger reorganization is requested.

## Active Areas

- Treat `DMRpp.adoc` as the main published guide. Most documentation changes should land there unless the request is specifically about repository-level contribution guidance or XML schema reference material.
- Treat `xml-schema/README-dmrpp.md` and `xml-schema/dmrpp.xsd` as the active DMR++ namespace reference and schema materials.
- Treat `README.md` as contributor-facing repository guidance.
- Treat `.travis.yml` and `travis/deploy_to_gh_pages.sh` as the active CI/CD and publishing workflow.

## Change Discipline

- Keep diffs tightly scoped to the user request.
- Do not rewrite large sections for style alone.
- Preserve existing terminology such as `DMR++`, `DMRpp`, `Hyrax`, `DAP4`, and related domain-specific names exactly where that wording matters.
- Be careful when editing command examples, version numbers, URLs, XML snippets, and file suffixes; documentation accuracy matters more than stylistic cleanup.
- Do not revert unrelated local changes in a dirty worktree.
- If you encounter conflicting edits in a file you need to change, stop and ask before overwriting them.
- Prefer working on a branch rather than directly on `main`.

## Documentation Guidance

- Match the style already used in the touched file. `DMRpp.adoc` is the canonical style reference for the main guide.
- Preserve existing AsciiDoc structure, anchors, cross-references, callouts, and image references unless the task requires changing them.
- When updating examples, keep them realistic and internally consistent with the surrounding explanation.
- If a change affects both the main guide and schema/reference material, update both when that materially improves accuracy.
- Keep historical or archival context in `README.md` and `retired/` intact unless the task is specifically to revise that history.

## AsciiDoc And Markdown Conventions

- Prefer existing AsciiDoc patterns in `DMRpp.adoc` over introducing new formatting styles.
- Keep section IDs, anchors, and image paths stable when possible because the published HTML may depend on them.
- For Markdown files under `xml-schema/`, preserve the current explanatory tone and technical precision.
- Do not rename generated output files such as `DMRpp.html` or change publish paths unless the task explicitly requires a publishing change.

## CI/CD And Publishing

- Travis CI is the active publishing workflow in `.travis.yml`.
- CI builds `DMRpp.adoc` to HTML and PDF using the `asciidoctor/docker-asciidoctor` container and writes artifacts to `output/`.
- `travis/deploy_to_gh_pages.sh` prepares the GitHub Pages content, copies `images/`, injects analytics into `DMRpp.html`, and force-pushes the result to the `gh-pages` branch.
- Be careful when editing `.travis.yml`, `travis/deploy_to_gh_pages.sh`, `VERSION`, output filenames, or image paths because small changes there can break publication.

## Validation

For content changes, prefer the smallest relevant validation from the repo root:

```sh
asciidoctor DMRpp.adoc
```

If Docker-based parity with CI is needed, use the same general flow as Travis:

```sh
mkdir -p output
docker run -v "$PWD":/documents/ --rm asciidoctor/docker-asciidoctor asciidoctor -D /documents/output DMRpp.adoc
docker run -v "$PWD":/documents/ --rm asciidoctor/docker-asciidoctor asciidoctor-pdf -D /documents/output DMRpp.adoc
```

Notes:

- If local AsciiDoctor or Docker is unavailable, say so clearly in the summary.
- When changing schema or XML namespace documentation, also sanity-check examples against `xml-schema/dmrpp.xsd` when relevant.
- Do not commit generated output under `output/` unless the user explicitly asks for that.

## Review Priorities

When reviewing or self-checking changes, prioritize:

1. Technical accuracy of DMR++ behavior, schema semantics, commands, and examples
2. Broken AsciiDoc structure, anchors, image references, links, or publish paths
3. CI/CD regressions in `.travis.yml` or `travis/deploy_to_gh_pages.sh`
4. Inconsistencies between `DMRpp.adoc`, `README.md`, and `xml-schema/` reference material
5. Accidental edits to retired or archival content
