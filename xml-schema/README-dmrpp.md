
~~# DMR++ Documentation for the `dmrpp` Namespace

The DMR++ `dmrpp` XML namespace elements were added to provide a way to describe the organization of 'chunks' used by a
binary data format such as HDF5 to store the data values in an array. The DMR++ supports both HDF5 and HDF4 as of
January 2026. The elements in this `dmrpp` namespace can be added to a DAP4 DMR (Dataset Metadata Response) document
without affecting the XML parse of the elements in the DAP4 namespace.

There are three primary elements in the `dmrpp` namespace: `chunks`, `chunkDimensionSizes`, and `chunk`. While
not always true, in general, a `chunks` element encloses a set of `chunk` elements and a single `chunkDimensionSizes`
element. The `chunks` element provides information that can be applied to all the chunks that make up a variable.
The information in the `chunkDimensionSizes` element could have been encoded as an attribute of the `chunks` element.
The `chunk` elements hold information unique to each chunk that makes up the variable.

It is possible that a DMR++ document contains variables that have neither `chunks` nor `chunkDimensionSizes`
elements since some variables' data is stored in a single 'chunk' in the HDF5 file. If only the attributes defined
for `chunk` are needed, then that is the only element present. For example, HDF5 defines a storage class named
_CONTIGUOUS_ that can be represented as a single chunk.

## The dmrpp Namespace Elements

### dmrpp:chunks

The `dmrpp:chunks` element is always a child of a DAP/DMR variable element (e.g., `Float32`, `Int32`, etc.).
It describes how the variable’s data are stored on in an HDF5-like chunked layout. The element can
contain the following:

The DMR++ parser uses the information in the `dmrpp:chunks` element to build internal _Chunk_ objects. This
can include _Chunk_ objects that are not present in the data file/object because they consist solely of fill
values. In this case, the parser must synthesize these chunks itself using the value of the `fillValue` attribute.

#### Attributes of `dmrpp:chunks`

All attributes of the `dmrpp:chunks` element are optional.

* `compressionType`: a space separated list of filters, not limited to compression. Currently, DMR++ supports
  _shuffle_, _deflate_, and _fletcher32_. The deflate filter uses the standard Internet deflate algorithm and
  includes an associated compression level. The shuffle filter groups the high-order through low-order bytes of
  multibyte numerical types together to improve the effectiveness of the deflate algorithm. The fletcher32 filter
  provides a 32-bit hash of the data. *The order of the filters in the list is important.* The filters are listed in
  the order in which they were applied during data encoding and therefore must be applied in reverse order during
  decoding.
* `deflateLevel`: the numerical level of the deflate compression, used when the data in the chunk were
  compressed. The deflateLevel must be between 1 and 9. This is not needed to deflate the chunk, but it is
  necessary when other operations are applied.
* `byteOrder`: optional byte order information; one of `LE` or `BE` (little- or big-endian). Defaults to `BE`.
  Although `dmrpp:chunk` also includes a _byteOrder_ attribute, all the chunks inside a _dmrpp:chunks_ element
  must have the same byte order.
* `structOffset`: total size and offset information for a structure. In DMR++, only simple structures are supported;
  nested structures are not supported. This attribute is a space-separated list of numbers that encode the offsets,
  in bytes, from the start of the structure for all fields except the first, which must have an offset of zero
  bytes. In addition to the field offsets, the final element of the list specifies the total size of the structure
  in bytes.
* `fillValue`: the fill value used for chunks that have no data. In some cases, an array may contain regions with no
  data. For example, this can occur with satellite swath data stored using a map projection. In such cases, a format
  such as HDF5 may omit writing chunks that contain only fill values. Software that uses the DMR++ to read data must
  fill in the gaps left by these “phantom” chunks. Each member of a structure may have its own fill value; in that
  case, _fillValue_ is represented as a space-separated list of strings.
* `LBChunk`: boolean value indicting if this variable has linked blocks. Linked blocks are used by HDF4 when a '
  chunk' is not atomic but instead split into multiple regions within a single file. In this case, the 'linked blocks'
  are concatenated and then treated as 'chunk.' See the `dmrpp:block` element below.
* `DIO`: a boolean that indicates the chunks can be used for a particular I/O optimization. Direct IO (DIO) is a
  feature in the Hyrax software that improves performance by passing chunked data directly to the end user without
  applying any filtering operations (for example, without decompression). By default, the Hyrax data server uses DIO
  when writing NetCDF-4 files from HDF5 data described using DMR++, provided that certain conditions are met. This
  feature can be disabled. _**FIXME**_ _What are those conditions_?

#### Child elements of `dmrpp:chunks` 
  * Exactly one `dmrpp:chunkDimensionSizes` element, as defined below. This defines the logical organization
    Of the chunks/blocks that make up the variable.
  * and one of:
      * a list of individual `dmrpp:chunk` elements (this is the typical case for an HDF5/NetCDF4 file),
      * a list of `dmrpp:block` elements (linked-block storage), or
      * a “multi linked-block chunk” arrangement where `dmrpp:chunk` elements refer to multiple underlying _blocks_
        (this case deals with formats where _chunks_ are not always atomic such as HDF4).
      * A `dmrpp:chunks` element can contain, as child elements, either one or more `dmrpp:chunk` or `dmrpp:block`
        element(s), but not both.
      * 
---

### dmrpp:chunkDimensionSizes

The `dmrpp:chunkDimensionSizes` is a child of `dmrpp:chunks`.
It Contains a **whitespace separated list of chunk sizes**, one per array dimension (e.g., `"100 200"`). It is used
together with the array’s declared dimensions to compute the **logical number of chunks** and their shapes. It is also 
used in conjunction with the 0...N `dmrpp:chunk` elements (see below) to detect which logical chunks are not included 
in the data file/object (i.e., they contain only fill values). For an array stored as a number of discreet chunks, 
this element has to be present to tell the DMR++ interpreter how the information in the chunks is reassembled to make
the original array.

#### Attributes of `dmrpp:chunkDimensionSizes`

The `dmrpp:chunkDimensionSizes` element has no attributes.

#### Child elements of `dmrpp:chunkDimensionSizes`

The `dmrpp:chunkDimensionSizes` element has no child elements.
---

### dmrpp:chunk

Each `dmrpp:chunk` describes a single data chunk. The `dmrpp:chunk` element is usually a child of `dmrpp:chunks`, but is
sometimes a direct child of the variable element when all the data are held in a singe chunk (e.g., HDF5 contiguous
storage).

The software uses the `dmrpp:chunk` element to determine **where within the file or object to read data** and how to
reconstruct the chunk’s data. Each `dmrpp:chunk` element must include the `offset` and `size` attribute. For a variable
that contains more than one chunk, the `chunkPositionInArray` attribute must also be included.

The remain attributes are optional. If they are not used by a given `dmrpp:chunk` element, then the value is either
the default value (e.g., `fm`, see below) or an inherited value from some enclosing XML element. In version XXX of
the DMR++, the only elements that provide inherited attributes are the `dap:Dataset` and the `dmrpp:chunks` elements.
Using inherited XML attributes complicates parsing but can reduce XML document size when the number of `dmrpp:chunk`
elements is large.

#### Attributes of `dmrpp:chunk`

* `offset` and `nBytes`: byte offset and length in the underlying data resource (HDF5 file, etc.).
* `chunkPositionInArray`: space-separated integer indices of the chunk in chunk-space (e.g., `"[0,1,3]"`).
* `fm`: optional “filter mask” for per-chunk filter flags. This attribute applies only to HDF5. It is a 32-bit integer
  bit mask that should normally be zero. A non-zero value indicates that a filter failed and HDF5 retained the original,
  unfiltered data. When reading the data, this mask is used to determine that decompression should not be attempted for
  the affected chunk. This condition occurs rarely. With Direct I/O, this attribute becomes important, but only when the
  mask value is non-zero. The bit assignments are as follows: shuffle is bit 0, deflate is bit 1, and fletcher32 is bit 2.
  The default value of fm is 0.
* `href` and `trust` / `dmrpp:trust`: The `trust` attribute applies to the value of the `href` attribute. In systems
  such as NASA Earthdata Cloud (EDC), this allows authentication steps to be skipped by indicating to the DMR++ parser
  that the referenced `href` does not require authentication. It can be trusted because access to the DMR++ itself was
  already authenticated and authorized. When present, the values of `href` and `trust` override those specified in the
  `dap4:Dataset` element.
* `LinkedBlockIndex`: When multi-block chunks are used, this attribute groups multiple linked blocks into a single
  logical chunk.

#### Child elements of `dmrpp:chunk`

The `dmrpp:chunk` element has no child elements.

**_FIXME_** Maybe it can contain dmrpp:block elements?

---

### `dmrpp:block`

Child of `dmrpp:chunks` used for **linked-block storage**, non-contiguous pieces of a variable stored as blocks that 
are assembled into a single chunk.

#### Attributes of `dmrpp:block`

* `offset`, `nBytes`: byte location and size of a block.
* `href` and `trust` / `dmrpp:trust`: The `trust` attribute applies to the value of the `href` attribute. In systems
  such as NASA Earthdata Cloud (EDC), this allows authentication steps to be skipped by indicating to the DMR++ parser
  that the referenced `href` does not require authentication. It can be trusted because access to the DMR++ itself was
  already authenticated and authorized. When present, the values of `href` and `trust` override those specified in the
  `dap4:Dataset` element. 

**_FIXME_** Kent notes that the `href` and `trust` attributes might not be supported by the `drmpp:block` element.

The DMR++ interpreter groups multiple blocks into a single buffer in memory that is them treated as a 'chunk.'

#### Child elements of `dmrpp:block`

The `dmrpp:block` element has no child elements.

---

### `dmrpp:FixedLengthStringArray`

Child element of a DMR array variable element when that array is actually an **array of fixed-length strings** stored
as raw bytes.

The parser treats this as a marker that:

* indicates the base type is string-like but should be interpreted as **fixed-length strings**,

#### Attributes of `dmrpp:FixedLengthStringArray`

* attribute `string_length` (e.g., `"8"`) gives the per-string length in bytes,
* attribute `pad` describes how padding bytes are encoded (e.g., `"null"`, `"space"`, `"zero"`).

The software then slices the byte buffer into equal-sized string segments and de-pads each one appropriately, 
extracting an array of strings.

#### Child elements of `dmrpp:FixedLengthStringArray`

The `dmrpp:FixedLengthStringArray` element has no child elements.

---~~

### `dmrpp:compact`

Child element of a DMR variable element indicating **HDF5 COMPACT storage** — the data are stored inline in the DMR++ document, 
as **base64-encoded** values. This encoding provides a way to include binary data in an XML
document.

The interpreter:

* base64-decodes the contents,
* interprets them according to the variable’s DAP type (numeric, string, fixed-length string array, etc.),
* and populates the corresponding variable in memory without any external I/O.

This inline base64 encoding is only used for relatively small variables.

#### Attributes of `dmrpp:compact`

The `dmrpp:compact` element has no attributes.

#### Child elements of `dmrpp:compact`

The `dmrpp:compact` element has no child elements.

---

### `dmrpp:missingdata`

Child element of a DMR variable element containing **missing-data values** for an array (or a single unsigned byte scalar) as
base64-encoded bytes, optionally compressed.

The parser:

* base64-decodes the contents,
* inflates them with zlib if needed,
* and either:

    * copies directly into the variable (no projection), or
    * uses the variable’s projection (start/stop/stride) to create a subset buffer.

This is used as a special “all missing” data source (e.g., when some chunks are not present and are logically all
fill/missing).

---

### `dmrpp:specialstructuredata`

Child of a structure variable (or array of structures) that encodes the content of a **“special structure”** as base64.

The parser supports structures whose members are limited to:

* numeric scalars,
* numeric arrays,
* string scalars, and
* arrays of strings,

and decodes the flattened byte layout back into the structure (or array of structures), including embedded
base64-encoded strings separated by semicolons.

---

### `dmrpp` variable-length string array element (name from `DMRPP_VLSA_ELEMENT`)

There is also an element whose QName is whatever `DMRPP_VLSA_ELEMENT` expands to in `DmrppNames.h`. From the usage:

* It appears as a child of an **array of strings/URLs**.
* `DMZ::process_vlsa` passes that element to `vlsa::read(...)`, which fills a `std::vector<std::string>` and marks the
  array as a **variable-length string array (VLSA)**.

In the XSD below I’ll call this element `dmrpp:vlenStringArray` as a placeholder; you should rename it to match the
actual name used in your `DmrppNames.h`.

---

## 2. dmrpp attributes on the Dataset element

The parser also recognizes these **dmrpp attributes on the root `Dataset` element**:

* `dmrpp:href` – **required** in this implementation. A URL to the underlying data resource; used as the default data
  URL for all chunks and blocks that don’t specify their own `href`.
* `dmrpp:trust` – optional boolean (`"true"` / `"false"`). Signals whether the `dmrpp:href` is trusted as-is (controls
  how the URL is handled).
* `dmrpp:version` – optional string. Its presence switches off some legacy “emulate original filter order” behavior; if
  present and the `DMR` is actually a `DMRpp`, it’s stored in the DMRpp object.

I’ll expose these as an attributeGroup in the schema so the DMR schema can import/reuse them.

---

## 3. Example dmrpp.xsd (XSD 1.1)

Below is a standalone XSD 1.1 file for the `dmrpp` namespace, focused on what your parser actually uses.

### Notes before you drop this into your repo

* **Namespace URI**: I’ve used a placeholder `http://opendap.org/ns/dmrpp/1.0#`. Swap this for your actual dmrpp
  namespace URI.
* **VLSA element name**: I’ve chosen `vlenStringArray` for the variable-length string array element. Rename that element
  to whatever `DMRPP_VLSA_ELEMENT` is in your code.
* Types and constraints are conservative: they won’t enforce all your semantic rules, but they match what the code
  expects structurally.

> [!NOTE]
> The schema is in the file dmrpp.xsd

