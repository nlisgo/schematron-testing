Run:

```
./setup.sh
```

This will setup the dependencies. Once the reference-schematron repo is down the script adds a symlink in that folder to ./eLife-elem-citation-driver-final-compiled.xsl to ensure that the references in that file to countries.xml, journal-DOI.xml and publisher-locations.xml will work.

Then run:

```
./prepare_xml.sh
```

This will copy all of the article xml to a new folder (`article-xml`) and change the reference to the dtd so that it can look to the `niso-jats` repo.

Finally to validate the xml is `./article-xml` run:

```
./validate_xml.sh
```

To validate a single article XML:

```
java -jar Saxon-HE-9.6.0-4.jar ./article-xml ./reference-schematron/eLife-elem-citation-driver-final-compiled.xsl
```

The output should only contain schematron error and warning violations but at the moment there are some bugs which are interrupting the schematron validation. This is affecting 483 article XMLs and there have been 6 different errors fired.

See: `./errors-summary/errors-summary.txt`
