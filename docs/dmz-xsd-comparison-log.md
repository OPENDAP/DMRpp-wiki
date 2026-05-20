# Comparison of `dmrpp.xsd` and the DMZ DOM Parser Log

## 2026-05-12 16:58:13 MDT

Prompt: "Compare the XML Schema in [dmrpp.xsd](xml-schema/dmrpp.xsd) with the C++ DOM tree parser in `DMZ.cc` and `DMZ.h`. Do they match? Assume the C++ code is the SSOT."

Read the local DMRpp wiki instructions and the BES `AGENTS.md` instructions because the comparison depends on source files in the BES repository. Inspected `xml-schema/dmrpp.xsd`, `DMZ.h`, `DMZ.cc`, `DmrppNames.h`, `DmrppCommon.cc`, `Chunk.cc`, `DmrppArray.cc`, and `vlsa_util.cc`.

Main finding: the schema and parser do not match. The parser treats prefixed names such as `dmrpp:chunks` as literal strings rather than XML namespace-qualified names. Additional mismatches include dataset attribute qualification, optional `chunkDimensionSizes`, `chunkPositionInArray` lexical format and requiredness, `chunk`/`block` mode semantics, VLSA `v` children and `s` attribute support, and runtime constraints for compact/missing/special-structure payloads.

## 2026-05-20 11:02:33 MDT

Prompt: "In 'Namespace Model' of [dmz-xsd-comparison.md](docs/dmz-xsd-comparison.md) how do I modify @xml-schema/dmrpp.xsd so that the comments are all addressed? I have already update the schema URI."

Reviewed the Namespace Model finding against the current `xml-schema/dmrpp.xsd`. The URI has already been updated to `http://xml.opendap.org/dap/dmrpp/1.0.0#`. The remaining namespace-model mismatch cannot be fully fixed in a normal namespace-aware XSD because XML Schema validates expanded names, not the literal prefix spelling used by the DMZ parser. The practical schema-side fix is to make DMR++ attributes namespace-qualified with global attribute declarations and references, while documenting that the parser's literal-prefix requirement remains a parser/schema compatibility gap unless the parser becomes namespace-aware.

## 2026-05-20 11:08:33 MDT

Prompt: "Apply this change to the 'dmrpp.xsd' document, preserving the documentation information I have added."

Changed `xml-schema/dmrpp.xsd` so `href`, `trust`, `version`, `s3`, and `s3credentials` are global attributes in the DMR++ target namespace, then changed `DatasetExtensionAttributes` to reference those attributes as `dmrpp:*`. Preserved the attribute documentation by moving the existing annotations from the local attribute declarations to the global declarations. This addresses the schema-side namespace issue for dataset extension attributes while keeping the parser's literal-prefix limitation as a separate implementation concern.

## 2026-05-20 11:33:39 MDT

Prompt: "Update the 'dmrpp.xsd' schema so that the 'chunks' and 'chunkDimensionSizes' elements are documented as requiring the 'dmrpp:' prefix."

Updated `xml-schema/dmrpp.xsd` documentation for `chunks` and `chunkDimensionSizes` to say that the elements are in the DMR++ namespace and are normally written with the `dmrpp:` prefix. Also documented the Hyrax DMZ parser deviation: it requires the literal `dmrpp:` prefix. Preserved the existing occurrence constraints and the explanatory documentation already added for `chunkDimensionSizes`.

## 2026-05-20 11:36:15 MDT

Prompt: "You cannot use the same scheme as with the attributes 'dmrpp:href', et cetera?"

Revised the `chunkDimensionSizes` model to use the same global declaration/reference pattern as the namespace-qualified attributes: the `ChunksType` content model now references `dmrpp:chunkDimensionSizes`, and the full documentation lives on the global `chunkDimensionSizes` element declaration. This is clearer than relying on a local qualified element declaration and avoids duplicating the prefix documentation.

## 2026-05-20 12:22:15 MDT

Prompt: "In practice, the 'chunk' and 'block' elements are mutually exclusive. How best to indicate that in the schema?"

Recommended modeling the mutually exclusive storage layouts as a choice between homogeneous repeated `chunk` elements and homogeneous repeated `block` elements, rather than the current repeated choice that permits arbitrary interleaving. Noted that if the schema must preserve linked-block mode, where blocks plus chunks may appear together, that mode needs a separate explicit branch or must remain documented as a Hyrax deviation because a strict two-branch choice would reject mixed linked-block documents.

## 2026-05-20 13:51:12 MDT

Prompt: "In the schema 'dmrpp.xsd' chunkPositionInArray is documented correctly ... but the type 'dmrppInedxList' is wrong. How would I define a correct type given that the attribute value is a string formatted ats, e.g., [1,0,0,0] ?"

Recommended defining a separate simple type for bracketed comma-separated chunk positions rather than reusing `IndexList`, because `IndexList` is an XSD list type for whitespace-separated unsigned integers. Suggested a string restriction with a pattern such as `\[[0-9]+(,[0-9]+)*\]`, then changing `chunkPositionInArray` to use that new type. Noted that XSD 1.0 can validate the lexical form but cannot enforce that the number of coordinates matches the number of dimensions listed in `chunkDimensionSizes`.

Wrote the comparison to `docs/dmz-xsd-comparison.md`.

## 2026-05-12 17:31:07 MDT

Prompt: "Update the [dmz-xsd-comparison.md](docs/dmz-xsd-comparison.md) based on inew information from vlsa_util.cc"

Reasoning: I compared the existing VLSA section against `/Users/jhrg/src/opendap/hyrax/bes/modules/dmrpp_module/vlsa_util.cc` and `DmrppNames.h`. The implementation shows that `c` is a run-length count emitted only for duplicate runs greater than one, while `s` is parser behavior missing from the schema for values over 512 bytes whose text is zlib-compressed and base64-encoded. I updated the comparison to distinguish literal string values from encoded compressed values and to keep the recommendation focused on the missing `s` attribute and unqualified `v` children.
