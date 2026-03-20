
# DMR++ Documentation for the `dmrpp` Namespace

The DMR++ `dmrpp` XML namespace elements were added to the DMR++ provide a way
to describe the organization of 'chunks' used by a binary data format such as
HDF5 to store the data values in an array. DMR++ supports both HDF5. HDF4 and
HDFEOS2 as of January 2026. The elements in the `dmrpp` namespace can be added
to a DAP4 DMR (Dataset Metadata Response) document without affecting the XML
parsing of the elements in the DAP4 namespace.

There are three primary elements in the `dmrpp` namespace: `chunks`,
`chunkDimensionSizes`, and `chunk`. In general, a `chunks` element encloses a
set of `chunk` elements and a single `chunkDimensionSizes` element. The `chunks`
element provides information that applies to all the chunks that hold the data
values of a variable. The `chunkDimensionSizes` element holds a space separated
list of integer values that are the dimensions of each chunk. The `chunk`
elements hold information unique to each chunk that makes up the variable.

While the most variables in a dataset describe by a DMR++ document will contain
 `chunks`, `chunkDimensionSizes` and `chink` elements, it is possible for a
DMR++ document to contain variables that have neither `chunks` nor
`chunkDimensionSizes` elements. Some variables' data is stored in a single
place in the HDF5 file. If only the attributes defined for `chunk` are needed,
then that is the only element present. For example, HDF5 defines a storage class
named _CONTIGUOUS_ that can be represented as a single chunk (even though it is
technically not an HDF5 'chunk').

Other elements in the `dmrpp` namespace address data organization techniques
that the supported formats _can_ use, but generally do so sparingly. The entire
namespace is documented here. Of particular note are variables that do not use
'chunked storage' or variables that contain various subtypes of string data.


## 1. The dmrpp Namespace Elements

### Element `dmrpp:chunks`

The `dmrpp:chunks` element is always a child of a DAP/DMR variable element
(e.g., `Float32`, `Int32`, etc.). It describes how the variable’s data are
stored in an HDF5-like chunked layout. The element can contain the following:

The DMR++ parser uses the information in the `dmrpp:chunks` element to build
internal _Chunk_ objects. This can include _Chunk_ objects that are not present
in the data file/object because they consist solely of fill values. In this
case, the parser must synthesize these chunks itself using the value of the
`fillValue` attribute.

#### Attributes of `dmrpp:chunks`

All attributes of the `dmrpp:chunks` element are optional. When used, the
value(s) of these attributes apply equally to all of the `dmrpp:chunk` elements
contained by the `dmrpp:chunks` element.

* `compressionType`: a space-separated list of filters, not limited to
  compression. Currently, DMR++ supports _shuffle_, _deflate_, and _fletcher32_.
  The deflate filter uses the standard Internet deflate algorithm and includes
  an associated compression level. The shuffle filter groups the high-order
  through low-order bytes of multibyte numerical types together to improve the
  effectiveness of the deflate algorithm. The fletcher32 filter provides a
  32-bit hash of the data. *The order of the filters in the list is important.*
  The filters are listed in the order in which they were applied during data
  encoding and therefore must be applied in reverse order during decoding.

* `deflateLevel`: the numerical level of the deflate compression, used when the
  data in the chunk were compressed. The deflateLevel must be between 1 and 9.
  This is not needed to deflate the chunk, but it is necessary when other
  operations are applied. If the 'deflate' filter is applied more than once,
  this attribute is a list of the deflate levels used for each call of the
  filter.

* `byteOrder`: optional byte order information; one of `LE` or `BE` (little- or
  big-endian). Defaults to `BE`. Although `dmrpp:chunk` also includes a
  _byteOrder_ attribute, all the chunks inside a _dmrpp:chunks_ element must
  have the same byte order.

* `structOffset`: total size and offset information for a structure. In DMR++,
  only simple structures are supported; nested structures are not supported.
  This attribute is a space-separated list of numbers that encode the offsets,
  in bytes, from the start of the structure for all fields except the first,
  which must have an offset of zero bytes. In addition to the field offsets, the
  final element of the list specifies the total size of the structure in bytes.

* `fillValue`: the fill value used for chunks that have no data. In some cases,
  an array may contain regions with no data. For example, this can occur with
  satellite swath data stored using a map projection. In such cases, a format
  such as HDF5 may omit writing chunks that contain only fill values. Software
  that uses the DMR++ to read data must fill in the gaps left by these “phantom”
  chunks. Each member of a structure may have its own fill value; in that case,
  _fillValue_ is represented as a space-separated list of strings.

* `LBChunk`: boolean value indicating whether this variable has linked block chunks.
  Linked blocks are used by HDF4 when a 'chunk' is not atomic but instead split
  into multiple regions within a single file. In this case, the 'linked blocks'
  are concatenated and then treated as a 'chunk.' Note that these linked blocks
  are not teh same as data describe by teh `dmrpp:block` element (see below). The
  purpose of this attribute is to provide a hint to the DMR++ interpreter that 
  it needs to check for this kind of chunk as it parses each `dmrpp:chunk` element
  or that it can safely ignore this corner case for this variable's `dmrpp:chunk`
  elements. 

* `DIO`: a boolean that indicates the chunks can be used for a particular I/O
  optimization. Direct IO (DIO) is a feature in the Hyrax software that improves
  performance by passing chunked data directly to the end user without applying
  any filtering operations (for example, without decompression). By default, the
  Hyrax data server uses DIO when writing NetCDF-4 files from HDF5 data
  described using DMR++, provided that certain conditions are met. This feature
  can be disabled. The attribute is used to indicate that a given variable cannot
  take advantage of this optimization.
  
  > [!NOTE]
  > The `DIO` attribute used to control the Direct I/O optimization of Hyrax. It
  > is not really a feature of the data reader, but instead an optimization for
  > a common _output_ operation of the OPeNDAP NASA runs.

#### Child elements of `dmrpp:chunks`
  * Exactly one `dmrpp:chunkDimensionSizes` element, as defined below. This
    defines the logical organization of the chunks/blocks that make up the
    variable.

  * and one of:
    * a list of individual `dmrpp:chunk` elements (this is the typical case
      for an HDF5/NetCDF4 file),

    * a list of `dmrpp:block` elements (e.g., HDF4 block storage), or

    * a “multi linked-block chunk” arrangement where `dmrpp:chunk` elements
      refer to multiple underlying _blocks_ (this case deals with formats
      where _chunks_ are not always atomic, such as HDF4).

  A `dmrpp:chunks` element can contain, as child elements, either one or more
  `dmrpp:chunk` elements or one or more `dmrpp:block` elements, but not both.
  If it contains `dmrpp:chunk` elements, some may be linked block chunks, but 
  the `dmrpp:chunks` attribute `LBChunk` must be true.

---

### Element `dmrpp:chunkDimensionSizes`

The `dmrpp:chunkDimensionSizes` element is a child of `dmrpp:chunks`. It contains a
**whitespace separated list of chunk sizes**, one per array dimension (e.g.,
`"100 200"`). It is used together with the array’s declared dimensions to
compute the **logical number of chunks** and their shapes. It is also used in
conjunction with the 0...N `dmrpp:chunk` elements (see below) to detect which
logical chunks are not included in the data file/object (i.e., they contain only
fill values). For an array stored as a number of discreet chunks, this element
has to be present to tell the DMR++ interpreter how the information in the
chunks is reassembled to make the original array.

#### Attributes of `dmrpp:chunkDimensionSizes`

The `dmrpp:chunkDimensionSizes` element has no attributes.

#### Child elements of `dmrpp:chunkDimensionSizes`

The `dmrpp:chunkDimensionSizes` element has no child elements.

---

### Element `dmrpp:chunk`

Each `dmrpp:chunk` describes a single data chunk. The `dmrpp:chunk` element is
usually a child of `dmrpp:chunks`, but is sometimes a direct child of the
variable element when all the data are held in a single chunk (e.g., HDF5
contiguous storage).

The software uses the `dmrpp:chunk` element to determine **where within the file
or object to read data** and how to reconstruct the chunk’s data. Each
`dmrpp:chunk` element must include the `offset` and `size` attribute. For a
variable that contains more than one chunk, the `chunkPositionInArray` attribute
must also be included.

The remaining attributes are optional. If they are not used by a given
`dmrpp:chunk` element, then the value is either the default value (e.g., `fm`,
see below) or an inherited value from some enclosing XML element. In version XXX
of DMR++, the only elements that provide inherited attributes are the
`dap:Dataset` and the `dmrpp:chunks` elements. Using inherited XML attributes
complicates parsing, but can reduce XML document size when the number of
`dmrpp:chunk` elements is large.

#### Attributes of `dmrpp:chunk`

* `offset` and `nBytes`: byte offset and length in the underlying data resource
  (HDF5 file, etc.).
* `chunkPositionInArray`: space-separated integer indices of the chunk in
  chunk-space (e.g., `"[0,1,3]"`).
* `fm`: optional “filter mask” for per-chunk filter flags. This attribute
  applies only to HDF5. It is a 32-bit integer bit mask that should normally be
  zero. A non-zero value indicates that a filter failed and HDF5 retained the
  original, unfiltered data. When reading the data, this mask is used to
  determine that decompression should not be attempted for the affected chunk.
  This condition occurs rarely. With Direct I/O, this attribute becomes
  important, but only when the mask value is non-zero. The bit assignments are
  as follows: shuffle is bit 0, deflate is bit 1, and fletcher32 is bit 2. The
  default value of fm is 0.
* `href` and `trust` / `dmrpp:trust`: The `trust` attribute applies to the value
  of the `href` attribute. In systems such as NASA Earthdata Cloud (EDC), this
  allows authentication steps to be skipped by indicating to the DMR++ parser
  that the referenced `href` does not require authentication. It can be trusted
  because access to the DMR++ itself was already authenticated and authorized.
  When present, the values of `href` and `trust` override those specified in the
  `dap4:Dataset` element.
* `LinkedBlockIndex`: When multi-block chunks are used, this attribute groups
  multiple linked blocks into a single logical chunk.

#### Child elements of `dmrpp:chunk`

The `dmrpp:chunk` element has no child elements.

---

_Example 1. A Float32 100 x 100 array with four 50 x 50 element chunks_
```xml
<?xml version='1.0' encoding='UTF-8'?>
<Dataset 
    xmlns="http://xml.opendap.org/ns/DAP/4.0#" 
    xmlns:dmrpp="http://xml.opendap.org/dap/dmrpp/1.0.0#"
    dapVersion="4.0" 
    dmrVersion="1.0" 
    name="chunked_twoD.h5">
  <Float32 name="d_4_chunks">
    <Dim size="100"/>
    <Dim size="100"/>
    <dmrpp:chunks>
      <dmrpp:chunkDimensionSizes>50 50</dmrpp:chunkDimensionSizes>
      <dmrpp:chunk nBytes="10000" offset="4016" chunkPositionInArray="[0,0]"   href="data/dmrpp/chunked_twoD.h5" />
      <dmrpp:chunk nBytes="10000" offset="14016" chunkPositionInArray="[0,50]"   href="data/dmrpp/chunked_twoD.h5" />
      <dmrpp:chunk nBytes="10000" offset="24016" chunkPositionInArray="[50,0]"   href="data/dmrpp/chunked_twoD.h5" />
      <dmrpp:chunk nBytes="10000" offset="34016" chunkPositionInArray="[50,50]"   href="data/dmrpp/chunked_twoD.h5" />
    </dmrpp:chunks>
  </Float32>
</Dataset>
```

In Example 1., the DMR \<Datase\t> element lacks the `dmrpp:href` attribute but
the `dmrpp:chunk` elements supply the needed information using that elements
_optional_ `href` attribute. In this example, all the chunks use the same
object/file, but the idea of providing `href` at the `dmrpp:chunk` level is to
support Virtual datasets - different chunks from different sources.

_Example 2. This dataset holds a number of compressed chunks_
```xml
<?xml version='1.0' encoding='UTF-8'?>
<Dataset 
    xmlns="http://xml.opendap.org/ns/DAP/4.0#" 
    xmlns:dmrpp="http://xml.opendap.org/dap/dmrpp/1.0.0#"
    dapVersion="4.0" 
    dmrVersion="1.0" 
    name="chunked_gzipped_fourD.h5"
    dmrpp:href="data/dmrpp/chunked_gzipped_fourD.h5">

  <Float32 name="d_16_gzipped_chunks">
    <Dim size="40"/>
    <Dim size="40"/>
    <Dim size="40"/>
    <Dim size="40"/>
    <dmrpp:chunks deflate_level="6" compressionType="deflate">
      <dmrpp:chunkDimensionSizes>20 20 20 20</dmrpp:chunkDimensionSizes>
      <dmrpp:chunk offset="4728"  nBytes="170568" chunkPositionInArray="[0,0,0,0]" />
      <dmrpp:chunk offset="175296"  nBytes="174124" chunkPositionInArray="[0,0,0,20]" />
      <dmrpp:chunk offset="349420"  nBytes="170395" chunkPositionInArray="[0,0,20,0]" />
          ...
      <dmrpp:chunk offset="2312361"  nBytes="185511" chunkPositionInArray="[20,20,0,20]" />
      <dmrpp:chunk offset="2497872"  nBytes="184573" chunkPositionInArray="[20,20,20,0]" />
      <dmrpp:chunk offset="2684493"  nBytes="185594" chunkPositionInArray="[20,20,20,20]" />
    </dmrpp:chunks>
  </Float32>
</Dataset>
```

In Example 2 the chunks are compressed using the _deflate_ filter; the
`deflate_level` and `compressionType` attributes provide this information. Also
note that an `href` attribute is used in the \<Dataset\> element instead of
repeating the same information for each `dmrpp:chunk` elements.

---

### Element `dmrpp:block`

Child of `dmrpp:chunks` used for **linked-block storage**, non-contiguous pieces
of a variable stored as blocks that are assembled into a single piece of data.

#### Attributes of `dmrpp:block`

* `offset`, `nBytes`: byte location and size of a block.
* `href` and `trust` / `dmrpp:trust`: The `trust` attribute applies to the value
  of the `href` attribute. In systems such as NASA Earthdata Cloud (EDC), this
  allows authentication steps to be skipped by indicating to the DMR++ parser
  that the referenced `href` does not require authentication. It can be trusted
  because access to the DMR++ itself was already authenticated and authorized.
  When present, the values of `href` and `trust` override those specified in the
  `dap4:Dataset` element. 


> [!NOTE]
> Kent notes that the `href` and `trust` attributes might not be
> supported by the `drmpp:block` element. 

The DMR++ interpreter groups multiple blocks into a single buffer in memory that
is then treated as a 'chunk.'

#### Child elements of `dmrpp:block`

The `dmrpp:block` element has no child elements.

---

### Element `dmrpp:FixedLengthStringArray`

Child element of a DMR array variable element when that array is actually an
**array of fixed-length strings** stored as raw bytes.

The parser treats this as a marker that:

* indicates the base type is string-like but should be interpreted as
  **fixed-length strings**.

#### Attributes of `dmrpp:FixedLengthStringArray`

* attribute `string_length` (e.g., `"8"`) gives the per-string length in bytes,
* attribute `pad` describes how padding bytes are encoded (e.g., `"null"`,
  `"space"`, `"zero"`).

The software then slices the byte buffer into equal-sized string segments and
de-pads each one appropriately, extracting an array of strings.

#### Child elements of `dmrpp:FixedLengthStringArray`

The `dmrpp:FixedLengthStringArray` element has no child elements.

---

### Element `dmrpp:compact`

Child element of a DMR variable element indicating **HDF5 COMPACT storage** —
the data are stored inline in the DMR++ document, as **base64-encoded** values.
This encoding provides a way to include binary data in an XML document.

The interpreter:

* base64-decodes the contents,
* interprets them according to the variable’s DAP type (numeric, string,
  fixed-length string array, etc.),
* and populates the corresponding variable in memory without any external I/O.

This inline base64 encoding is only used for relatively small variables.

#### Attributes of `dmrpp:compact`

The `dmrpp:compact` element has no attributes.

#### Child elements of `dmrpp:compact`

The `dmrpp:compact` element has no child elements.

---

### Element `dmrpp:missingdata`

Child element of a DMR variable element containing **missing-data values** for
an array (or a single unsigned byte scalar) as base64-encoded bytes, optionally
compressed.

The parser:

* base64-decodes the contents,
* inflates them with zlib if needed,
* and either:
  copies directly into the variable (no projection), or
  uses the variable’s projection (start/stop/stride) to create a subset buffer.

This is used as a special “all missing” data source (e.g., when some chunks are
not present and are logically all fill/missing).

---

### Element `dmrpp:specialstructuredata`

Child of a structure variable (or array of structures) that encodes the content
of a **“special structure”** as base64.

The parser supports structures whose members are limited to:

* numeric scalars,
* numeric arrays,
* string scalars, and
* arrays of strings,

and decodes the flattened byte layout back into the structure (or array of
structures), including embedded base64-encoded strings separated by semicolons.

---

### Element `dmrpp:vlsa`

> [!NOTE]
> This is under construction

The `dmrpp:vlsa` element introduces the _values_ of an array of varying length
strings. The DMR++ document treats this kind of data specially because it does
not 'chunk well' and can present a number of performance issues, particularly
where datasets contain very large two-dimensional arrays of these varying length
strings.

The `dmrpp:vlsa` element wraps each value using a `dmrpp:v` element (see example
N below). Because a common pattern in datasets is to use these arrays for flags
that describe data quality, there are often many consecutive elements with the
same value. The `dmrpp:v` element has an optional _count_ attribute `dmrpp:c`
that encodes a Run Length Limited could of _N_ consecutive values.

In the example DMR++ document below, the string array _VLSArrayElements_ is a
vector of twelve elements. The first two are _Parting_ and _is such_ while the
remaining ten elements are all _sweet_.

---

_Example 3. How Varying Length Strings are Represented_
```xml
<?xml version="1.0" encoding="ISO-8859-1"?>
<Dataset xmlns="http://xml.opendap.org/ns/DAP/4.0#" 
    xmlns:dmrpp="http://xml.opendap.org/dap/dmrpp/1.0.0#" 
    dapVersion="4.0" dmrVersion="1.0" 
    name="t_vl_string_1d.h5" dmrpp:href="OPeNDAP_DMRpp_DATA_ACCESS_URL" 
    dmrpp:version="3.20.13">
    <String name="VLSArrayElements">
        <Dim size="10"/>
        <dmrpp:vlsa>
            <v>Bannana</v>
            <v>bread</v>
            <v>is</v>
            <v c="6">so</v>
            <v>tasty!</v>
        </dmrpp:vlsa>
    </String>
</Dataset>
```

---

## 2. dmrpp Namespace Attributes on the Dataset Element

The parser also recognizes these **dmrpp attributes on the root `Dataset`
element**:

* `dmrpp:href` – **required** in this implementation. A URL to the underlying
  data resource; used as the default data URL for all chunks and blocks that
  don’t specify their own `href`.
* `dmrpp:trust` – optional boolean (`"true"` / `"false"`). Signals whether the
  `dmrpp:href` is trusted as-is (controls how the URL is handled).
* `dmrpp:version` – optional string. Its presence switches off some legacy
  “emulate original filter order” behavior; if present and the `DMR` is actually
  a `DMRpp`, it’s stored in the DMRpp object.

I’ll expose these as an attributeGroup in the schema so the DMR schema can
import/reuse them.

---

## 3. Example dmrpp.xsd (XSD 1.1)

> [!NOTE]
> The schema is in the file dmrpp.xsd
