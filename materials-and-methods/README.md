# Materials and Methods

This directory is for building a container for a tool that writes materials and methods sections for pipelines based on [utia-gc/ngs](https://github.com/utia-gc/ngs).

The materials-and-methods container is mainly composed of two pieces of software:

1. [jinja2-cli](https://github.com/mattrobenolt/jinja2-cli) -- Build methods document from a template.
2. [Pandoc](https://pandoc.org/) -- Convert the methods document to a finished product in .docx format.
