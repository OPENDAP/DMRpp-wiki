Question:I have an annotated XML Schema document. There are annotations for all the element and attributes in the
schema. Is there an automated way to build documentation from that schema that will make a nice document? Assume that I
will write a more general narrative and the two will be used as Introduction and reference documentation.

Response:

Yes. This is a well-supported workflow: treat the XSD as the authoritative reference source, generate reference documentation from `xs:annotation/xs:documentation`, then write the narrative introduction separately.

For your use case, I would consider three tiers.

## Best polished option: Oxygen XML Editor / Oxygen Scripting

Oxygen has a built-in **XML Schema documentation** generator that produces documentation for content models, diagrams, annotations, and cross-references. It can output formats such as **HTML, PDF, and DocBook**. That fits your stated model well: hand-written introduction plus generated reference section. ([Oxygen XML Editor][1])

This is probably the best answer if you want “nice document” output with minimal custom engineering. Oxygen also has scripting/automation support, including a GitHub Action for generating docs from schema files, useful if you want documentation regenerated in CI. ([GitHub][2])

## Lightweight/open-source option: xs3p

`xs3p` is an XSLT-based XSD documentation generator. It transforms an XML Schema into XHTML documentation. There is an older SourceForge version and a modernized GitHub fork using Bootstrap/HTML5/Markdown. ([SourceForge][3])

This is attractive if you want something scriptable and open-source:

```bash
xsltproc xs3p.xsl your-schema.xsd > schema-reference.html
```

The tradeoff is that the visual output and completeness may require tuning, especially for complex schemas, imports/includes, namespaces, and custom annotation markup.

## Commercial documentation generators

Several commercial tools do exactly this:

| Tool                                      | Outputs / strengths                                                                                                                                                                                |
| ----------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Liquid Studio XSD Documentation Generator | Generates PDF, HTML, or ASP.NET documentation; includes schema code, diagrams, properties, type hierarchy, annotations, and references. ([Liquid Technologies][4])                                 |
| Stylus Studio                             | Generates Javadoc-like `xsddoc` documentation for XSDs. ([Stylus Studio][5])                                                                                                                       |
| FlexDoc/XML XSDDoc                        | Generates unified HTML or RTF documentation, including XSD diagrams. ([FlexDoc][6])                                                                                                                |
| TechWriter for XML Schemas                | Automatically produces reference documentation from XSD, DTD, XML instances, and JSON instances. ([TechWriter][7])                                                                                 |
| Document! X                               | Combines automatic XSD schema documentation with a WYSIWYG authoring environment; covers elements, complex/simple types, groups, attributes, constraints, and facets. ([Contiem Documentation][8]) |

## Recommended structure

I would not try to make the generated schema reference do everything. Use a two-part documentation set:

1. **Introduction / User Guide**

   * Purpose of the XML format
   * Design model / conceptual entities
   * Typical document structure
   * Example XML documents
   * Versioning rules
   * Compatibility / extension policy
   * Common authoring mistakes

2. **Generated Schema Reference**

   * Elements
   * Attributes
   * Types
   * Cardinality
   * Constraints / facets
   * Enumerations
   * Cross-references
   * Annotation text from `xs:documentation`

This mirrors what readers actually need: first, “How do I think about this XML vocabulary?” Then, “What is the exact syntax?”

## Practical recommendation

For a polished deliverable, use **Oxygen** first. It will likely give you the best result fastest, especially if your schema already has complete annotations.

For a reproducible open-source pipeline, try **xs3p** or a custom XSLT/XProc/Saxon pipeline. That would let you check generated HTML into your build, wrap it with your own CSS, and integrate it into Sphinx, MkDocs, Antora, or a static site.

A good workflow would be:

```text
schema.xsd
   ↓
XSD documentation generator
   ↓
schema-reference.html / schema-reference.pdf
   ↓
included or linked from hand-written user guide
```

If you are already writing the narrative in Markdown, I would generate **HTML reference docs** and publish both with MkDocs or Sphinx. If the target is a formal static document, generate **PDF** from Oxygen or generate DocBook/HTML and convert with your normal publishing chain.

[1]: https://www.oxygenxml.com/xml_editor/xml_schema_documentation.html?utm_source=chatgpt.com "XML Schema Documentation - Oxygen XML Editor"
[2]: https://github.com/marketplace/actions/oxygen-xml-json-generate-documentation?utm_source=chatgpt.com "Oxygen XML/JSON - Generate Documentation - GitHub Marketplace"
[3]: https://sourceforge.net/projects/xs3p/?utm_source=chatgpt.com "xs3p download | SourceForge.net"
[4]: https://www.liquid-technologies.com/xsd-documentation-generator?utm_source=chatgpt.com "XML Schema Documentation Generator - Liquid Technologies"
[5]: https://www.stylusstudio.com/xsd-documentation.html?utm_source=chatgpt.com "XSD Documentation Generator - Stylus Studio"
[6]: https://www.flexdoc.xyz/flexdoc-xml/xsddoc/?utm_source=chatgpt.com "FlexDoc/XML - XSDDoc (XML Schema Documentation Generator)"
[7]: https://techwriter.me/techwriter-for-xml-schemas.aspx?utm_source=chatgpt.com "XML Schema Documentation Generator: Documents XML, XSD, DTD & JSON"
[8]: https://documentation.contiem.com/HelpAuthoringTools/features_xsd.html?utm_source=chatgpt.com "Document! X for XSD Schema Documentation"
