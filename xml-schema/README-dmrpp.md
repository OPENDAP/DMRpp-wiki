
# DMR++ Documentation for the `dmrpp` Namespace

The DMR++ `dmrpp` elements were added to provide a way to describe the organization of 'chunks' used by an HDF5
to store the data values in an array. The elements in this namespace can be added to a DAP4 DMR (Dataset Metadata
Response) document without affecting the XML parse of the elements in the DAP4 namespace.

There are three primary elements in the `dmrpp` namespace: `chunks`, `chunkDimensionSizes`, and `chunk`. While
not always true, in general, a `chunks` element encloses a set of `chunk` elements and a single `chunkDimensionSizes`
element. The `chunks` element provides information that can be applied to all the chunks that make up a variable.
The information in the `chunkDimensionSizes` element could have been encoded as an attribute of the `chunks` element.
The `chunk` elements hold information unique to each chunk that makes up the variable.

It is possible that a DRM++ document contains variables that have neither `chunks` nor `chunkDimensionSizes`
elements since some variables' data is stored in a single 'chunk' in the HDF5 file. If only the attributes defined
for `chunk` are needed, then that is the only element present. For example, HDF5 defines a storage class named
_CONTIGUOUS_ that can be represented as a single chunk.

## 1. dmrpp namespace elements – short descriptions

### dmrpp:chunks

The `dmrpp:chunks` element is always a child of a DAP/DMR variable element (e.g., `Float32`, `Int32`, etc.).
It describes how the variable’s data are stored on in an HDF5-like chunked layout. The element can
contain the following:

The DMR++ parser uses the information in the `dmrpp:chunks` element to build internal _Chunk_ objects. This
can include _Chunk_ objects that are not present in the data file/object because they consist solely of fill
values. In this case, the parser must synthesize these chunks itself using the value of the `fillValue` attribute.

* Attributes (all optional) about the storage/filtering (`compressionType`, `deflateLevel`, `byteOrder`,
  `structOffset`, `LBChunk`, `fillValue`, and `DIO`)
  * `compressionType`: a space separated list of filters, not limited to compression. DMR++ supports _shuffle_, 
     _deflate_, and _fletcher32_.
     The deflate filter is the standard Internet deflate algorithm and has an associated compression level. The
     shuffle filter is used to group the high-order, ..., low-order bytes in multibyte numerical types together to improve
     the performance of the deflate algorithm. The fletcher32 filter is a 32-bit hash for the data. _The order of
     the filters in the list is important._ The order of the filters in this attribute is the order in which they
     were aplied when encoding data values, so they must be applied in reverse order.
  * `deflateLevel`: the numerical level of compression used when the data in the chunk were compressed. This is not
     needed to deflate the chunk, but it is needed when other operations are applied, particularly the direct I/O
     operations.
  * `byteOrder`: optional byte order information; one of `LE` or `BE` (little- or big-endian). Defaults to `BE`.
    Although `dmrpp:chunk` also includes a _byteOrder_ attribute, all the chunks inside a _dmrpp:chunks_ element 
    must have the same byte order.
  * `structOffset`:
  * `LBChunk`: boolean value indicting if this variable has linked blocks
  * `fillValue`: the fill value used for chunks that have no data. In some cases an array will have regions where
    there is no data. For example, satellite swath data stored as a map projection. In such a case, a format like
    HDF5 will not bother to write out a chunk that only has fill values. Software that uses the DMR++ to read data
    will need to fill in the gaps left by these 'phantom' chunks.
  * `DIO`: 

* Child elements; 
  * Exactly one `dmrpp:chunkDimensionSizes` element, as defined below. This defines the logical organization
    Of the chunks/blocks that make up the variable.
  * and one of:
      * a list of individual `dmrpp:chunk` elements (this is the typical case for an HDF5/NetCDF4 file),
      * a list of `dmrpp:block` elements (linked-block storage), or
      * a “multi linked-block chunk” arrangement where `dmrpp:chunk` elements refer to multiple underlying _blocks_
        (this case deals with formats where _chunks_ are not always atomic such as HDF4).


---

### dmrpp:chunkDimensionSizes

The `dmrpp:chunkDimensionSizes` is a child of `dmrpp:chunks`.
It Contains a **whitespace separated list of chunk sizes**, one per array dimension (e.g., `"100 200"`). It is used
together with the array’s declared dimensions to compute the **logical number of chunks** and their shapes. It is also 
used in conjuction with the 0..N `dmrpp:chunk` elements (see below) to detect which logical chunks are not included 
in the data file/object (i.e., they contain only fill values). For an array stored as a number of discreet chunks, 
this element has to be present to tell the DMR++ interpreter how the information in the chunks is reassembled to make
the original array.

---

### dmrpp:chunk

The `dmrpp:chunk` element is usually a child of `dmrpp:chunks`, but is sometimes a direct child of the
variable element for contiguous storage.

Each `dmrpp:chunk` describes a single data chunk (or a multi-block chunk–-see below) via attributes:

* `offset` and `nBytes`: byte offset and length in the underlying data resource (HDF5 file, etc.).
* `chunkPositionInArray`: space-separated integer indices of the chunk in chunk-space (e.g., `"[0,1,3]"`).
* `byteOrder`: THIS IS A MISTAKE jhrg 1/6/26 optional byte order information; one of `LE` or `BE` (little- or big-endian). Defaults to `BE`
* `fm`: optional “filter mask” for per-chunk filter flags. A 32-bit integer; bit mask; should always be zero; 
  indicates that a filter failed (hdf5 keeps the original data), when you read the data, use this mask to know to
  not try to decompress the data in the chunk. it rarely occurs. With Direct I/O, this becomes important. This only 
  matters when the mask value is non-zero. shuffle is bit 0, deflate is bit 1, fletcher32 is bit 2
* `href` and `trust`/`dmrpp:trust`: the 'trust' attribute applies to the value of the 'href' attribute. For systems
  like NASA Earthdata Cloud (EDC), this saves authentication steps by telling the DMR++ parser that this href does
  not need to be authenticated--it can be trusted because access to the DMR++ itself was authenticated/authorized.
  When present, the value(s) of 'href' and 'trust' override those given in the `dap4:Dataset` element.
* `LinkedBlockIndex`: when using multi-block chunks, groups several linked blocks into one logical chunk.

The parser uses this element to know **where within the file/object to read data** and how to reconstruct the data of
the chunk. For HDF5, each chunk carries byte order and filter mask information. The list of filters is stored in the
parent `chunks` element and the byte order information is also stored in the `chunks` element. _his duplication of
information was done to reduce the size of the `chunk` elements since there can be many of these for a given variable,
especially in older HDF5 files.

> [!NOTE]
> I'm not sure if chunks in an HDF5 file can have different filters or if the filters have to be uniform for
> a given variable. Similarly, I'm not sure how the _filter mask_ is actually used.

---

### `dmrpp:block`

Child of `dmrpp:chunks` used for **linked-block storage** (non-contiguous pieces of a variable stored as blocks).
Each `dmrpp:block` has:

* `offset`, `nBytes`: byte location and size of a block.
* `href`, `trust`/`dmrpp:trust`: as with 'href' and 'trust' for the `chunk` element above, this provies an optional
  overriding storage URL and trust flag.

The parser groups multiple blocks into a single buffer in memory.

A `dmrpp:chunks` element can contain either one or more `dmrpp:chunk` or `dmrpp:block` element(s), but not 
both.

---

### `dmrpp:FixedLengthStringArray`

Child of an array variable element when that array is actually an **array of fixed-length strings** stored as raw bytes.

The parser treats this as a marker that:

* the base type is string-ish but should be interpreted as **fixed-length strings**,
* attribute `string_length` (e.g., `"8"`) gives the per-string length in bytes,
* attribute `pad` describes how padding bytes are encoded (e.g., `"null"`, `"space"`, `"zero"`).

The handler then slices the byte buffer into equal-sized string segments and de-pads each one appropriately.

---

### `dmrpp:compact`

Child of the variable element indicating **HDF5 COMPACT storage** — the data are stored inline in the DMR++ document, 
as **base64-encoded** values. This encoding, while somewhat gross, provides a way to include binary data in an XML
document. For encode values that take more than NNN FIXME bytes, the encode values are compressed using XYZ FIXME.

> [!NOTE]
> Get the correct information from the code.

The parser:

* base64-decodes the contents,
* interprets them according to the variable’s DAP type (numeric, string, fixed-length string array, etc.),
* and populates the corresponding variable in memory without any external I/O.

This inline base64 encoding is only used for relatively small variables.

---

### `dmrpp:missingdata`

Child of the variable element containing **missing-data values** for an array (or a single unsigned byte scalar) as
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

