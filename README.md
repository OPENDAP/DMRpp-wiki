[![DOI](https://zenodo.org/badge/856493055.svg)](https://doi.org/10.5281/zenodo.14025926)

# DMR++ wiki


This Repository contains the source files for the [official DMR++ documentation](https://opendap.github.io/DMRpp-wiki/DMRpp.html). In it you can find how to build &amp; deploy DMR++ files using Hyrax.


## Contributing to the documentation
The documentation is built and deployed by travis, and hosted on GitHub Pages. If you are interested in making suggestions we recommend to first open an ISSUE. Once you are ready to make changes you can follow the next steps:

### Requirements
* Clone this repository onto machine. 
* Install AsciiDoctor.

### Steps

1. Navigate to your local cloned directory.
2. Create a new branch.
3. Make changes to the source file.
4. Test locally the new changes, making sure to spell check, and that any non-text structure appears well (like tables, math, hyperlinks). To test simply do on the command line:

```
asciidoctor DMRpp.adoc
```

That should generate a single `DMRpp.html` file. You can inspect it with a browser.

5. Push to create a new Pull Request. Indicate what is new addition, whether it is related to an open issue on this repository (or somewhere else).


## Source material
The material in this repository was migrated from its previous defuncted location at [docs.opendap.org/DMR++](https://docs.opendap.org/index.php/DMR%2B%2B). The older location is no longer updated and is consider archived/retired.
