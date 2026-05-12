# Work Log

## 2026-05-12 16:58:13 MDT

Prompt: "Compare the XML Schema in [dmrpp.xsd](xml-schema/dmrpp.xsd) with the C++ DOM tree parser in `DMZ.cc` and `DMZ.h`. Do they match? Assume the C++ code is the SSOT."

Read the local DMRpp wiki instructions and the BES `AGENTS.md` instructions because the comparison depends on source files in the BES repository. Inspected `xml-schema/dmrpp.xsd`, `DMZ.h`, `DMZ.cc`, `DmrppNames.h`, `DmrppCommon.cc`, `Chunk.cc`, `DmrppArray.cc`, and `vlsa_util.cc`.

Main finding: the schema and parser do not match. The parser treats prefixed names such as `dmrpp:chunks` as literal strings rather than XML namespace-qualified names. Additional mismatches include dataset attribute qualification, optional `chunkDimensionSizes`, `chunkPositionInArray` lexical format and requiredness, `chunk`/`block` mode semantics, VLSA `v` children and `s` attribute support, and runtime constraints for compact/missing/special-structure payloads.

Wrote the comparison to `docs/dmz-xsd-comparison.md`.
