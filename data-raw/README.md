# Package Dataset

The contents of this folder include an R script ([make-datasets.R](make-datasets.R)) used to build the dataset in the **inlpubs** package, and the data files read during the build process. The R script retrieves and parses data from local sources. The resulting package dataset represents a snapshot of the publication data at a specified point in time. It is recommended that package developers add new citations at the end of each calendar year. Package releases integrate the latest citations and should occur on a regular basis.

## File and Folder Structure

```
data-raw
+-- README.md
+-- abstracts.md (abstract data)
+-- annotations.md (annotation data)
+-- authors.tsv (author data)
+-- citations.md (citation data)
+-- make-datasets.R (script for building datasets)
```

## File Formats

| Extension | Type | Description          |
| --------- | ---- | -------------------- |
| .md       | text | Markdown             |
| .R        | text | R Script/Code        |
| .tsv      | text | Tab-Separated Values |

## Add New Publication

To add a new publication to the bibliography of the U.S. Geological Survey (USGS) Idaho National Laboratory Project Office (INLPO) requires updates to file content in this folder. Workflow steps for entering a new publication into the bibliography are described using an example.

Consider a new publication's "suggested citation" as follows:

Knobel, L.L., Bartholomay, R.C., and Rousseau, J.P., 2005, Historical development of the U.S. Geological Survey hydrologic monitoring and investigative programs at the Idaho National Engineering and Environmental Laboratory, Idaho, 1949 to 2001: U.S. Geological Survey Open-File Report 2005–1223 (DOE/ID–22195), 93 p., https://doi.org/10.3133/ofr20051223.

### Author Entry

First identify any authors that are not in the existing INLPO bibliography. For this example, consider "R. C. Bartholomay" as a new author that needs to be included in the INLPO authors list. An author's information, such as their name and email address, is written as a row in the [authors.tsv](authors.tsv) data-table file. An author entry is added below the table header as tab-separated values. The table header and Bartholomay's entry are expressed as:

| Author key   | Last        | First | Middle | Email            | ORCID               |
| ------------ | ----------- | ----- | ------ | ---------------- | ------------------- |
| rbartholomay | Bartholomay | Roy   | C.     | rcbarth@usgs.gov | 0000-0002-4809-9287 |

Where `Author key` is the author's unique identifier formed by joining the author's initial and last name with no spaces and lower-case letters, such as `rbartholomay` in this example.

### Citation Entry

A citation entry is uniquely identified using the publication’s corresponding key value. The rules for creating a new citation-key are as follows:

- For publications with three or more authors, such as in this example, the citation-key is formed by joining the last name of the first author, the word `Others`, and the year of publication, for example `KnobelOthers2005`.
- For publications with two authors, the key is a concatenation of the authors last names, in the order specified in the document, and the year of publication (such as, `TwiningMaimer2019`).
- And for single-authored publication, the key is a concatenation of the author's last name and the year of publication (such as, `Rattray2019`).

The citation-key value is always written using the "upper [camel case]" naming convention, and any duplicates are resolved by appending a letter (such as, `Davis2006a` and `Davis2006b`).

A citation entry is specified in an enhanced [BibTeX] style. The data to include in a citation entry is based on the entry type. Where entry types correspond to the various types of bibliographic sources, such as a journal article or technical report. Use the `?bibentry` command to open help documentation that describes the various entry and field types. Citation entries are stored in the [citations.md](citations.md) file and written in [Markdown], a simple markup language that transforms to HTML. For this example, the citation entry is specified as:

```markdown
## KnobelOthers2005

Field       | Value
----------- | -----
bibtype     | TechReport
title       | Historical development of the U.S. ...
author      | lknobel, rbartholomay, jrousseau
institution | U.S. Geological Survey
type        | Open-File Report
year        | 2005
number      | 2005--1223 (DOE/ID--22195)
pages       | 93
doi         | 10.3133/ofr20051223
textVersion | Knobel, L.L., Bartholomay, R.C., and ...
```

Where
`bibtype` is the entry type,
`author` is the publication's author(s) represented using author-key values separated by commas, and
`textVersion` is the USGS suggested citation.

The citation-key is written in Markdown header syntax. Add two number signs (`#`) in front of the citation key and separate from surrounding content using blank lines. Citation fields are written in a Markdown table syntax. The first row is the table's header followed by an extra line of dashes (`-`). A vertical bar (`|`), also known as a pipe, is used for the cell delimiter. Note that outer vertical bars should not be used.

### Abstract Entry

Write the publication's abstract as an entry in the Markdown file [abstracts.md](abstracts.md). This plain-text file is encoded in UTF-8, a character encoding that covers the [list of Unicode characters]. Note that UTF-8 support on Windows has been historically poor, and sometimes leads to surprising results. Abstract entries are uniquely identified using the publication’s corresponding citation-key value. The citation key is written in a Markdown header syntax. Add two number signs (`#`) in front of the citation key and separate from surrounding content using blank lines. The abstract text is then written in Markdown paragraph syntax, a paragraph is defined as consecutive lines of text with a blank line between them. For this example, the abstract entry is specified as:

```markdown
## KnobelOthers2005

This report is a summary of the historical development, from
1949 to 2001, of the U.S. Geological Survey’s (USGS)
hydrologic monitoring and investigative programs at ...
```

### Annotation Entry

If an annotation is available for the publication, write it as an entry in the Markdown file [annotations.md](annotations.md). This plain-text file is encoded in UTF-8. Annotation entries are uniquely identified using the publication’s corresponding citation-key value. The citation key is written in a Markdown header syntax. Add two number signs (`#`) in front of the citation key and separate from surrounding content using blank lines. The annotation text is then written in Markdown paragraph syntax. Lastly, cite the source of the annotation by writing the citation information in a italic Markdown syntax. Add two dashes (`--`) in front of the citation and separate from surrounding content using blank lines. For example, a commonly used annotation citation for older publications is specified as:

```markdown
-- *Knobel and others (2005)*
```

## Build Package Dataset

To build the package dataset you may run the following commands:

```r
setwd("~/data-raw")
source("make-datasets.R")
```

Output from running the script is a single R-data file named "pubs.rda", which should be placed under the data directory (~/data/pubs.rda) prior to re-building the **inlpubs** package.

<!-- Embedded References -->

[R]: https://www.r-project.org/
[camel case]: https://en.wikipedia.org/wiki/Camel_case
[BibTeX]: https://en.wikipedia.org/wiki/BibTeX
[Markdown]: https://en.wikipedia.org/wiki/Markdown
[list of Unicode characters]: https://en.wikipedia.org/wiki/List_of_Unicode_characters
