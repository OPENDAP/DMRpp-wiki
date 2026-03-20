# DMR++ Slide Deck

## `dmrpp:chunks` and `dmrpp:chunk` Attributes

- Based on the current repo content in `xml-schema/README-dmrpp.md` and `xml-schema/dmrpp.xsd`
- Focus: what the attributes mean, when they are used, and what they control

---

## Where These Elements Fit

- `dmrpp:chunks` is a child of a DAP variable element and carries metadata shared by a chunked variable
- `dmrpp:chunk` usually appears inside `dmrpp:chunks` and describes one logical chunk of data
- Together they tell a reader:
  - how chunked data are encoded
  - where chunk bytes live in the data source
  - how to rebuild the variable from chunk storage

---

## `dmrpp:chunks`: Big Picture

- The element describes chunk-level context for an array or other variable stored in chunked form
- In the repo documentation, all `dmrpp:chunks` attributes are optional
- Its child content normally includes:
  - one `dmrpp:chunkDimensionSizes`
  - one or more `dmrpp:chunk` elements, or linked-block information
- The attributes on `dmrpp:chunks` apply across the set of enclosed chunks

---

## `dmrpp:chunks` Attributes: Filters And Encoding

- `compressionType`
  - Optional
  - Space-separated filter list, not limited to compression
  - Current repo text calls out `shuffle`, `deflate`, and `fletcher32`
  - Filter order matters: decode applies them in reverse order
  - `deflate` may appear more than once.

- `deflateLevel`
  - Optional
  - Deflate compression level metadata
  - README says values should be between `1` and `9`
  - XSD types it as `dmrpp:DeflateLevelList`

- `byteOrder`
  - Optional
  - Declares endianness for the enclosed chunk data
  - Allowed values in the schema: `LE` or `BE`
  - If not present, assume `LE`

---

## `dmrpp:chunks` Attributes: Layout And Fill Semantics

- `structOffset`
  - Optional
  - Space-separated offsets for structure fields
  - Final value is the total structure size in bytes
  - Used for simple structures; nested structures are not supported in the README text

- `fillValue`
  - Optional
  - Fill value to synthesize chunks that are logically present but absent from the data object
  - Important for "phantom" chunks that contain only fill values
  - For structures, the value may be represented as a space-separated list

---

## `dmrpp:chunks` Attributes: Storage And I/O Hints

- `LBChunk`
  - Optional boolean
  - Indicates HDF4 linked-block chunk storage
  - Signals that a logical chunk may be assembled from multiple regions

- `DIO`
  - Optional
  - Direct I/O control hint used by Hyrax
  - Intended to help decide whether chunk bytes can be passed through without filter processing
  - The XSD comment notes that the implementation looks for `DIO="off"`

---

## `dmrpp:chunk`: Big Picture

- `dmrpp:chunk` identifies one logical chunk and where its bytes can be found
- It is usually a child of `dmrpp:chunks`
- The README also notes that it can appear directly under a variable when the variable is effectively stored as one chunk
- `dmrpp:chunk` has no child elements; its meaning is carried entirely by attributes

---

## `dmrpp:chunk` Required Attributes

- `offset`
  - Required in the XSD
  - Byte offset of the chunk in the underlying file or object

- `nBytes`
  - Required in the XSD
  - Number of bytes to read for the chunk

- `chunkPositionInArray`
  - Required in the XSD
  - Identifies the chunk's logical position in chunk-space
  - README explains this is especially needed when a variable has more than one chunk

---

## `dmrpp:chunk` Optional Attributes

- `fm`
  - Optional filter mask
  - HDF5-specific per-chunk flag field
  - Default is `0`
  - README maps bits as: shuffle `0`, deflate `1`, fletcher32 `2`
  - Non-zero can mean the stored bytes should not be decompressed as usual

- `href`
  - Optional URI to the resource holding this chunk's bytes
  - Can override the dataset-level data location

- `trust`
  - Optional boolean associated with `href`
  - Used to indicate that the referenced resource can be treated as already trusted for access

- `LinkedBlockIndex`
  - Optional unsigned integer
  - Used when one logical chunk is related to multiple linked blocks

---

## Example From `DMRpp.adoc`

```xml
<dmrpp:chunks compressionType="deflate" deflateLevel="4"
              fillValue="0" byteOrder="LE">
  <dmrpp:chunkDimensionSizes>400</dmrpp:chunkDimensionSizes>
  <dmrpp:chunk offset="5435" nBytes="636" chunkPositionInArray="[0]"
               href="file:///usr/share/hyrax/3B42.20190110.06.7.HDF_mvs.h5" />
</dmrpp:chunks>
```

- `dmrpp:chunks` carries the shared encoding metadata
- `dmrpp:chunk` points at the actual bytes for one chunk
- `href` overrides the dataset-level data location for this chunk

---

## Repo Notes And Current Caveats

- The correct element name in the schema is `dmrpp:chunks`
- The README prose refers to `offset` and `size`, but the XSD attribute name is `nBytes`
- The README mentions a `byteOrder` attribute on `dmrpp:chunk`, but the current XSD defines `byteOrder` only on `dmrpp:chunks`
- The XSD types `chunkPositionInArray` as `dmrpp:IndexList`, while examples/comments in the repo show bracketed forms such as `[0]`
- The XSD currently allows more than one `chunkDimensionSizes` element, but its own comment says the intended model is exactly one

---

## Takeaways

- Use `dmrpp:chunks` for attributes shared across a variable's chunk set
- Use `dmrpp:chunk` for the per-chunk location and per-chunk override metadata
- For slide narration, the cleanest split is:
  - shared encoding and storage policy on `dmrpp:chunks`
  - physical chunk location and chunk-specific overrides on `dmrpp:chunk`
- If the deck becomes formal reference material, the schema/prose mismatches in the repo should be resolved first
