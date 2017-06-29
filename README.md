Run:

```
./setup.sh
```

This will setup the dependencies. Once the reference-schematron repo is down the script adds a symlink in that folder to [./eLife-elem-citation-driver-final-compiled.xsl](eLife-elem-citation-driver-final-compiled.xsl) to ensure that the references in that file to countries.xml, journal-DOI.xml and publisher-locations.xml will work.

Then run:

```
./prepare_xml.sh
```

This will copy all of the article xml to a new folder (`article-xml`) and change the reference to the dtd so that it can look to the `niso-jats` repo.

Finally to validate the xml is `./article-xml` run:

```
./validate_xml_final.sh
./validate_xml_pre_edit.sh
```

To validate a single article XML:

```
java -jar Saxon-HE-9.6.0-4.jar ./article-xml/elife-00003-v1.xml ./reference-schematron/eLife-elem-citation-driver-final-compiled.xsl
```

To get cleaner output:

```
java -jar Saxon-HE-9.6.0-4.jar ./article-xml/elife-00003-v1.xml ./reference-schematron/eLife-elem-citation-driver-final-compiled.xsl 2>&1 | sed -e 's/&gt;/>/g' | sed -e 's/&lt;/</g' | sed -e 's/<?xml.*//g'
```

The output should only contain schematron error and warning violations. If there are no violations then we expect no output.

The article version XMLs that were tested were all those available in the https://github.com/elifesciences/elife-article-xml repository at commit [6e820f84e1c54efdb59508c0a6609a80ddebefc7](https://github.com/elifesciences/elife-article-xml/tree/6e820f84e1c54efdb59508c0a6609a80ddebefc7/articles).

See:
- [./logs/log-final.txt](logs/log-final.txt)
- [./logs/log-pre-edit.txt](logs/log-pre-edit.txt)
