# Comparison of `dmrpp.xsd` and the DMZ DOM Parser

This compares [`xml-schema/dmrpp.xsd`](../xml-schema/dmrpp.xsd) with the C++ DOM parser in `bes/modules/dmrpp_module/DMZ.cc`, `DMZ.h`, and the parser helpers it delegates to. The C++ parser is treated as the source of truth.

## Short Answer

No, the schema and the parser do not match.

They describe overlapping vocabularies, but the schema is not an exact contract for what the parser accepts. The biggest mismatch is that `dmrpp.xsd` models real XML namespaces and XML Schema datatypes, while the parser treats names such as `dmrpp:chunks` as literal strings and implements several lexical formats by hand.

## Parser Facts

The DMZ parser uses `pugixml` and does not interpret XML namespaces. With `TREAT_NAMESPACES_AS_LITERALS` enabled, it matches the literal element or attribute name, including the `dmrpp:` prefix.

Important consequences:

- The parser expects names such as `dmrpp:href`, `dmrpp:chunks`, `dmrpp:chunk`, and `dmrpp:vlsa`.
- A document using the schema namespace URI but a different prefix would validate against the XSD but not be recognized by the parser.
- A document using the literal `dmrpp:` prefix with an old or wrong namespace URI may still be recognized by the parser.

## Major Mismatches

### Namespace Model

`dmrpp.xsd` declares a real namespace:

```xml
http://opendap.org/ns/dmrpp/1.0#
```

The parser does not compare that URI. It compares literal names like `dmrpp:chunks` and `dmrpp:href`.

This is the most important difference. The schema says the namespace URI is what matters; the parser says the literal prefix spelling is what matters.

### Dataset Attributes

The schema defines `DatasetExtensionAttributes` with unqualified attributes named `href`, `trust`, and `version`.

The parser reads `dmrpp:href`, `dmrpp:trust`, and `dmrpp:version` on the root `Dataset` element. It requires `dmrpp:href`; without it, `process_dataset()` throws.

So the parser contract is:

```xml
<Dataset dmrpp:href="..." dmrpp:trust="true" dmrpp:version="...">
```

not the unqualified attribute names modeled by the attribute group.

### `dmrpp:chunks`

The schema requires at least one `chunkDimensionSizes` child under `dmrpp:chunks`.

The parser explicitly allows `dmrpp:chunks` without `dmrpp:chunkDimensionSizes` for contiguous storage and fill-value cases. `process_chunks()` looks for the child but does not require it.

The schema permits arbitrary mixtures of `chunk` and `block` children after `chunkDimensionSizes`.

The parser treats `dmrpp:chunk` and `dmrpp:block` as mutually exclusive in normal `dmrpp:chunks` handling. If it sees any `dmrpp:chunk` and `LBChunk` is not true, it processes chunks and does not process blocks. If there are no chunks, it processes blocks. A single block is an error; more than one block is required for the linked-block path.

The schema defines a `DIO` attribute on `dmrpp:chunks`; the normal chunk-loading path does not process it. DIO is handled in the direct-I/O setup path, where only `DIO="off"` has special meaning.

### `dmrpp:chunkDimensionSizes`

The schema type is `IndexList`, an XML Schema list of unsigned integers. That allows normal XML whitespace-separated values.

The parser accepts only decimal digits and literal spaces. It rejects tabs, newlines, commas, brackets, and other XML whitespace. This is narrower than `xs:list`.

The parser also processes all `dmrpp:chunkDimensionSizes` siblings it finds and clears/replaces the stored sizes each time, so the effective value is the last matching child, not the first. The comment in the XSD says the implementation uses the first, but this parser path does not.

### `dmrpp:chunk`

The schema requires `offset`, `nBytes`, and `chunkPositionInArray`.

The parser requires only `offset` and `nBytes`. If `chunkPositionInArray` is absent, `process_chunk()` passes an empty string through; `Chunk::parse_chunk_position_in_array_string()` returns immediately for an empty value.

The schema defines `chunkPositionInArray` as `IndexList`, meaning whitespace-separated unsigned integers such as:

```xml
chunkPositionInArray="0 1 3"
```

The parser requires bracketed comma-separated values such as:

```xml
chunkPositionInArray="[0,1,3]"
```

This is a hard mismatch: schema-valid values fail in the parser, and parser-valid values fail against the schema.

The parser accepts either `trust` or `dmrpp:trust` on `dmrpp:chunk`; the schema defines only unqualified `trust`.

### `dmrpp:block`

The schema requires `offset` and `nBytes`, with optional `href` and `trust`.

The parser agrees on `offset` and `nBytes`, and accepts either `trust` or `dmrpp:trust`.

The parser imposes an additional semantic rule not represented in the schema: one block under `dmrpp:chunks` is an error; more than one block is required for linked-block storage.

### `dmrpp:FixedLengthStringArray`

The schema requires `string_length` and permits `pad` values `null_pad`, `null_term`, `space_pad`, and `not_set`.

The parser recognizes the same element and attributes, and the same `pad` values through `DmrppArray`.

However, the parser does not enforce that `string_length` is present at the element-parse point. If the attribute exists, it parses it with `stoull`; if it is absent, the array is still marked as a fixed-length string array and the default internal length remains whatever `DmrppArray` initializes.

The schema is stricter here than the parser.

### `dmrpp:compact`, `dmrpp:missingdata`, and `dmrpp:specialstructuredata`

The schema says these contain base64 text.

The parser recognizes all three as variable-level data-source elements. It also enforces runtime type rules that the schema does not express:

- `compact` is rejected for structures, sequences, and grids.
- `missingdata` is accepted only for arrays or a byte scalar.
- `specialstructuredata` is accepted only for supported structure or array-of-structure shapes.

The parser also optionally enforces that exactly one data-source element exists for a variable: `chunks`, direct `chunk`, `compact`, `vlsa`, `missingdata`, or `specialstructuredata`.

### `dmrpp:vlsa` and `v`

The schema defines `dmrpp:vlsa` with zero or more DMR++-namespace `v` children, each with optional `c`.

The parser recognizes literal `dmrpp:vlsa` but reads literal unprefixed `v` children. That means the schema's namespace-qualified local `v` model does not match the parser.

The parser also supports an additional optional `s` attribute on `v`. When `s` is present, the text is base64-encoded compressed data and `s` is the uncompressed string size. The schema does not define `s`.

## Where They Do Match

There is meaningful overlap:

- The main parser vocabulary includes `dmrpp:chunks`, `dmrpp:chunkDimensionSizes`, `dmrpp:chunk`, `dmrpp:block`, `dmrpp:FixedLengthStringArray`, `dmrpp:compact`, `dmrpp:missingdata`, `dmrpp:specialstructuredata`, and `dmrpp:vlsa`.
- `compressionType`, `deflateLevel`, `fillValue`, `byteOrder`, `structOffset`, and `LBChunk` are all recognized on `dmrpp:chunks`.
- `offset`, `nBytes`, `fm`, `href`, `trust`, and `LinkedBlockIndex` are recognized where expected.
- `byteOrder` accepts only `LE` and `BE`, matching the schema.
- Fixed-length string `pad` values match the schema.

## Recommended Schema Changes If DMZ Is SSOT

1. Model literal `dmrpp:` names only if this schema is intended to describe the current parser exactly. That is awkward in XML Schema; a better long-term fix is to make the parser namespace-aware.
2. Change dataset extension attributes to reflect `dmrpp:href`, `dmrpp:trust`, and `dmrpp:version`, or document that this attribute group is for another importing schema layer and does not describe DMZ's literal parse contract.
3. Allow `dmrpp:chunks` without `dmrpp:chunkDimensionSizes`.
4. Represent `chunk` and `block` as mutually exclusive parser modes, with `block` requiring at least two block children.
5. Change `chunkPositionInArray` from `IndexList` to a bracketed comma-list lexical type, and make it optional for direct parser compatibility.
6. Narrow `chunkDimensionSizes`, `deflateLevel`, and `structOffset` lexical descriptions to space-separated decimal numbers if matching the parser exactly.
7. Add `dmrpp:trust` as a tolerated chunk/block trust spelling, or explicitly mark it as parser compatibility behavior.
8. Add optional `s` to VLSA `v` values and make `v` unqualified if the parser remains the SSOT.
9. Document parser-only runtime constraints for `compact`, `missingdata`, `specialstructuredata`, fill values, linked blocks, and Direct I/O.

## Recommendation

Do not treat the current `dmrpp.xsd` as a validator for documents consumed by DMZ. It is useful as a vocabulary sketch, but it will reject some parser-valid DMR++ documents and accept some documents DMZ will not interpret correctly.

If the C++ parser is the source of truth, the schema needs another pass. The cleanest architectural choice would be to make DMZ namespace-aware and then update both the schema and examples to converge. If compatibility with existing literal-prefix documents is more important, then the schema should be explicitly documented as a parser-compatibility schema rather than a normal namespace-driven XML vocabulary.
