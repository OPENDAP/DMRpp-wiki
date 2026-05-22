# The DMR++ Document

**How to read this**. This describes the DMR++ XML document and how it can be used by both data clients (e.g.,
VirtualiZarr) and data servers. It is not a complete reference, for that see the DMR++ reference document that is
derived from the XML schema. The _Introduction_ describes how the DMR++ fits into the OPeNDAP data access protocol.
_Typical Use_ describes how most data are accessed using the information in the DMR++ and _Edge Cases_ describes how the
DMR++ handles information that does not fit within the overall logical model of 'chunked' data.

## Introduction

The DMR++ is an XML document that combines the OPeNDAP DMR document with additional metadata about location of  data
values in the dataset/file. This additional information is now commonly referred to as a 'Chunk Manifest.' The DMR
document describes the logical organization of a dataset that can be accessed using the OPeNDAP protocol. Datasets are
organized as hierarchical collections of variables with names and data types. Semantic metadata is bound to the dataset,
name hierarchies and variables using 'attributes' which are similar to the variables in that they also are named and
typed entities. The DMR++ combines this metadata about the logical structure of a dataset with the chunk manifest
metadata about the storage location of data value for the dataset.

The OPeNDAP protocol provides a web API that can be used to read the DMR. This response is returned as an XML document.
The protocol also provides a way to read data values from the dataset, using a simple 'constraint expression' language
that enables subsetting the dataset by hierarchy or variable and subsetting variables based on their data types. 

In the context of the OPeNDAP protocol, the DMR++ provides an alternate way of reading data values from datasets,
assuming those datasets meet some additional requirements. The data must be accessible using a protocol such as HTTP 1.1
(or greater), and that protocol must support the 'Range GET' operation. Note that the 'file:' protocol also meets these
requirements. In addition, the dataset must organize data so that blocks of data value can be read as 'raw' bytes and
then assembled to form the values of the variables in the dataset. The blocks of data are commonly referred to as
'chunks' amd they may need to be decoded (e.g., decompressed) before they can be combined to form the variable's data values.

The DMR++ document format was developed to enable users of NASA's ESDS OPeNDAP servers to continue to use the protocol
after the ESDS data were moved to the Earthdata Cloud system. That system shifted the datasets' files from POSIX file
systems to Web Object Stores (e.g., Amazon's S3) where the original API libraries could no longer be used to access and
subset those files. NASA ESDS now runs an OPeNDAP service in the Earthdata Cloud. That service uses the DMR++ to access
and subset data values. While originally developed for HDF5, support now exists for HDF4 and HDFEOS2 and HDFEOS5.

While the initial use of the DMR++ was for the OPeNDAP service in NASA's Earthdata Cloud, the DMR++ can be accessed as
an object independently of the OPeNDAP service. This enables a wide range of uses for the DMR++, including tools run by
individual researchers to directly access data and for larger 'virtual data stores' to be assembled using the
information in a collection of DMR++ documents.

Virtual data stores provide a single logical view of data that simplifies analysis, freeing people from managing the
details of the actual storage locations of the files. This abstraction hides the organization of a collection of data
files, simplifying data access in a way that is analogous to the role of a logical data model's role in freeing users
from managing the details of a myriad of data storage formats.

### Sidebar: NASA's nomenclature

NASA uses some specific terms when describing data.

Collection
: A collection of _granules_ that, taken as a whole, are what most users think of as a dataset.

Granule
: One part of a Collection. This is usually a single file, but some _granules_ are made up of more than one file.

### Sidebar: History – origins of the chunk manifest

HDF4 Maps

Zarr

## Typical Uses

## Edge Cases

