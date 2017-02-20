<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:saxon="http://saxon.sf.net/"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                version="2.0"><!--Implementers: please note that overriding process-prolog or process-root is 
    the preferred method for meta-stylesheets to use where possible. The name or details of 
    this mode may change during 1Q 2007.-->


<!--PHASES-->


<!--PROLOG-->
   <xsl:output xmlns:iso="http://purl.oclc.org/dsdl/schematron"
               xmlns:osf="http://www.oxygenxml.com/sch/functions"
               method="xml"/>

   <!--KEYS-->


   <!--DEFAULT RULES-->


   <!--MODE: SCHEMATRON-FULL-PATH-->
   <!--This mode can be used to generate an ugly though full XPath for locators-->
   <xsl:template match="*" mode="schematron-get-full-path">
      <xsl:variable name="sameUri">
         <xsl:value-of select="saxon:system-id() = parent::node()/saxon:system-id()"
                       use-when="function-available('saxon:system-id')"/>
         <xsl:value-of select="true()" use-when="not(function-available('saxon:system-id'))"/>
      </xsl:variable>
      <xsl:if test="$sameUri = 'true'">
         <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      </xsl:if>
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">
            <xsl:value-of select="name()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>*:</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>[namespace-uri()='</xsl:text>
            <xsl:value-of select="namespace-uri()"/>
            <xsl:text>']</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="$sameUri = 'true'">
         <xsl:variable name="preceding"
                       select="count(preceding-sibling::*[local-name()=local-name(current())                                    and namespace-uri() = namespace-uri(current())])"/>
         <xsl:text>[</xsl:text>
         <xsl:value-of select="1+ $preceding"/>
         <xsl:text>]</xsl:text>
      </xsl:if>
   </xsl:template>
   <xsl:template match="@*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">@<xsl:value-of select="name()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>@*[local-name()='</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>' and namespace-uri()='</xsl:text>
            <xsl:value-of select="namespace-uri()"/>
            <xsl:text>']</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template match="text()" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:text>text()</xsl:text>
      <xsl:variable name="preceding" select="count(preceding-sibling::text())"/>
      <xsl:text>[</xsl:text>
      <xsl:value-of select="1+ $preceding"/>
      <xsl:text>]</xsl:text>
   </xsl:template>
   <xsl:template match="comment()" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:text>comment()</xsl:text>
      <xsl:variable name="preceding" select="count(preceding-sibling::comment())"/>
      <xsl:text>[</xsl:text>
      <xsl:value-of select="1+ $preceding"/>
      <xsl:text>]</xsl:text>
   </xsl:template>
   <xsl:template match="processing-instruction()" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:text>processing-instruction()</xsl:text>
      <xsl:variable name="preceding"
                    select="count(preceding-sibling::processing-instruction())"/>
      <xsl:text>[</xsl:text>
      <xsl:value-of select="1+ $preceding"/>
      <xsl:text>]</xsl:text>
   </xsl:template>

   <!--MODE: SCHEMATRON-FULL-PATH-2-->
   <!--This mode can be used to generate prefixed XPath for humans-->
   <xsl:template match="node() | @*" mode="schematron-get-full-path-2">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="preceding-sibling::*[name(.)=name(current())]">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@<xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>

   <!--MODE: GENERATE-ID-FROM-PATH -->
   <xsl:template match="/" mode="generate-id-from-path"/>
   <xsl:template match="text()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.text-', 1+count(preceding-sibling::text()), '-')"/>
   </xsl:template>
   <xsl:template match="comment()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.comment-', 1+count(preceding-sibling::comment()), '-')"/>
   </xsl:template>
   <xsl:template match="processing-instruction()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.processing-instruction-', 1+count(preceding-sibling::processing-instruction()), '-')"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.@', name())"/>
   </xsl:template>
   <xsl:template match="*" mode="generate-id-from-path" priority="-0.5">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:text>.</xsl:text>
      <xsl:choose>
         <xsl:when test="count(. | ../namespace::*) = count(../namespace::*)">
            <xsl:value-of select="concat('.namespace::-',1+count(namespace::*),'-')"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="concat('.',name(),'-',1+count(preceding-sibling::*[name()=name(current())]),'-')"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <!--MODE: GENERATE-ID-2 -->
   <xsl:template match="/" mode="generate-id-2">U</xsl:template>
   <xsl:template match="*" mode="generate-id-2" priority="2">
      <xsl:text>U</xsl:text>
      <xsl:number level="multiple" count="*"/>
   </xsl:template>
   <xsl:template match="node()" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>n</xsl:text>
      <xsl:number count="node()"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="string-length(local-name(.))"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="translate(name(),':','.')"/>
   </xsl:template>
   <!--Strip characters-->
   <xsl:template match="text()" priority="-1"/>

   <!--SCHEMA METADATA-->
   <xsl:template match="/">
      <xsl:apply-templates select="/" mode="M2"/>
      <xsl:apply-templates select="/" mode="M3"/>
      <xsl:apply-templates select="/" mode="M4"/>
      <xsl:apply-templates select="/" mode="M5"/>
      <xsl:apply-templates select="/" mode="M6"/>
      <xsl:apply-templates select="/" mode="M7"/>
      <xsl:apply-templates select="/" mode="M8"/>
      <xsl:apply-templates select="/" mode="M9"/>
      <xsl:apply-templates select="/" mode="M10"/>
      <xsl:apply-templates select="/" mode="M11"/>
      <xsl:apply-templates select="/" mode="M12"/>
      <xsl:apply-templates select="/" mode="M13"/>
      <xsl:apply-templates select="/" mode="M14"/>
      <xsl:apply-templates select="/" mode="M15"/>
   </xsl:template>

   <!--SCHEMATRON PATTERNS-->


   <!--PATTERN element-citation-general-testsGeneral Tests for 'element-citation'-->


	  <!--RULE elem-citation-general-->
   <xsl:template match="element-citation" priority="105" mode="M2">

		<!--REPORT error-->
      <xsl:if test="person-group/name[not(surname)]">
         <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                      xmlns:osf="http://www.oxygenxml.com/sch/functions">
            <xsl:text>Error:</xsl:text>
            <xsl:text>[err-elem-cit-gen-name-2] Each &lt;name&gt; element in a reference must contain a &lt;surname&gt; element. Reference '</xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
            <xsl:text>' does not.</xsl:text>
         </xsl:message>
      </xsl:if>

		    <!--REPORT error-->
      <xsl:if test="descendant::etal">
         <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                      xmlns:osf="http://www.oxygenxml.com/sch/functions">
            <xsl:text>Error:</xsl:text>
            <xsl:text>[err-elem-cit-gen-name-5] The &lt;etal&gt; element in a reference is not allowed. Reference '</xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
            <xsl:text>' contains it.</xsl:text>
         </xsl:message>
      </xsl:if>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M2"/>
   </xsl:template>

	  <!--RULE elem-citation-gen-name-3-1-->
   <xsl:template match="element-citation/person-group" priority="104" mode="M2">

		<!--REPORT error-->
      <xsl:if test=".[not (name or collab)]">
         <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                      xmlns:osf="http://www.oxygenxml.com/sch/functions">
            <xsl:text>Error:</xsl:text>
            <xsl:text>[err-elem-cit-gen-name-3-1] Each &lt;person-group&gt; element in a reference must contain at least one &lt;name&gt; or, if allowed, &lt;collab&gt; element. Reference '</xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
            <xsl:text>' does not.</xsl:text>
         </xsl:message>
      </xsl:if>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M2"/>
   </xsl:template>

	  <!--RULE elem-citation-gen-name-3-2-->
   <xsl:template match="element-citation/person-group/collab"
                 priority="103"
                 mode="M2">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(*) = count(italic | sub | sup)"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-gen-name-3-2] A &lt;collab&gt; element in a reference may contain characters and &lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. No other elements are allowed. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' does not meet this requirement.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M2"/>
   </xsl:template>

	  <!--RULE elem-citation-gen-name-4-->
   <xsl:template match="element-citation/person-group/name" priority="102" mode="M2">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="not(suffix) or .[suffix=('Jnr', 'Snr', 'I', 'II', 'III', 'VI', 'V', 'VI', 'VII', 'VIII', 'IX', 'X')] "/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-gen-name-4] The &lt;suffix&gt; element in a reference may only contain one of the specified values Jnr, Snr, I, II, III, VI, V, VI, VII, VIII, IX, X. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' does not meet this requirement as it contains the value '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="suffix"/>
               <xsl:text>'.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M2"/>
   </xsl:template>

	  <!--RULE elem-citation-year-->
   <xsl:template match="element-citation/year" priority="101" mode="M2">
      <xsl:variable name="YYYY" select="substring(normalize-space(.), 1, 4)"/>
      <xsl:variable name="current-year" select="year-from-date(current-date())"/>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="matches(normalize-space(.),'(^\d{4}[a-z]?)')"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-gen-date-1-1] The &lt;year&gt; element in a reference must contain 4 digits, possibly followed by one (but not more) lower-case letter. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' does not meet this requirement as it contains the value '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="."/>
               <xsl:text>'. </xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="(1700 le number($YYYY)) and (number($YYYY) le ($current-year + 5))"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-gen-date-1-2] The numeric value of the first 4 digits of the &lt;year&gt; element must be between 1700 and the current year + 5 years (inclusive). Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' does not meet this requirement as it contains the value '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="."/>
               <xsl:text>'. </xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="./@iso-8601-date"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-gen-date-1-3] The &lt;year&gt; element must have an @iso-8601-date attribute. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' does not. </xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="not(./@iso-8601-date) or (1700 le number(substring(normalize-space(@iso-8601-date),1,4)) and number(substring(normalize-space(@iso-8601-date),1,4)) le ($current-year + 5))"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-gen-date-1-4] The numeric value of the first 4 digits of the @iso-8601-date attribute on the &lt;year&gt; element must be between 1700 and the current year + 5 years (inclusive). Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' does not meet this requirement as the attribute contains the value '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="./@iso-8601-date"/>
               <xsl:text>'. </xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="not(./@iso-8601-date) or substring(normalize-space(./@iso-8601-date),1,4) = $YYYY"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-gen-date-1-5] The numeric value of the first 4 digits of the @iso-8601-date attribute must match the first 4 digits on the &lt;year&gt; element. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' does not meet this requirement as the element contains the value '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="."/>
               <xsl:text>' and the attribute contains the value '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="./@iso-8601-date"/>
               <xsl:text>'. </xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="not(concat($YYYY, 'a')=.) or (concat($YYYY, 'a')=. and        (some $y in //element-citation/descendant::year        satisfies (normalize-space($y) = concat($YYYY,'b'))        and (ancestor::element-citation/person-group[1]/name[1]/surname = $y/ancestor::element-citation/person-group[1]/name[1]/surname       or ancestor::element-citation/person-group[1]/collab[1] = $y/ancestor::element-citation/person-group[1]/collab[1]       )))"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-gen-date-1-6] If the &lt;year&gt; element contains the letter 'a' after the digits, there must be another reference with the same first author surname (or collab) with a letter "b" after the year. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' does not fulfill this requirement.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="not(starts-with(.,$YYYY) and matches(normalize-space(.),('\d{4}[b-z]'))) or       (some $y in //element-citation/descendant::year        satisfies (normalize-space($y) = concat($YYYY,translate(substring(normalize-space(.),5,1),'bcdefghijklmnopqrstuvwxyz',       'abcdefghijklmnopqrstuvwxy')))        and (ancestor::element-citation/person-group[1]/name[1]/surname = $y/ancestor::element-citation/person-group[1]/name[1]/surname       or ancestor::element-citation/person-group[1]/collab[1] = $y/ancestor::element-citation/person-group[1]/collab[1]       ))"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-gen-date-1-7] If the &lt;year&gt; element contains any letter other than 'a' after the digits, there must be another reference with the same first author surname (or collab) with the preceding letter after the year. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' does not fulfill this requirement.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT error-->
      <xsl:if test="some $x in (preceding::year)       satisfies (((count(ancestor::element-citation/person-group[1]/*)=1 and        count($x/ancestor::element-citation/person-group[1]/*)=1) and        ((ancestor::element-citation/person-group[1]/name[1]/surname and        concat($x,'+',$x/ancestor::element-citation/person-group[1]/name[1]/surname)       = concat(current(),'+',ancestor::element-citation/person-group[1]/name[1]/surname))       or       (ancestor::element-citation/person-group[1]/collab[1] and        concat($x,'+',$x/ancestor::element-citation/person-group[1]/collab[1])       = concat(current(),'+',ancestor::element-citation/person-group[1]/collab[1]))))       or ((count(ancestor::element-citation/person-group[1]/*) ge 3 and        count($x/ancestor::element-citation/person-group[1]/*) ge 3)  and        ((ancestor::element-citation/person-group[1]/name[1]/surname and        concat($x,'+',$x/ancestor::element-citation/person-group[1]/name[1]/surname)       = concat(current(),'+',ancestor::element-citation/person-group[1]/name[1]/surname))       or       (ancestor::element-citation/person-group[1]/collab[1] and        concat($x,'+',$x/ancestor::element-citation/person-group[1]/collab[1])       = concat(current(),'+',ancestor::element-citation/person-group[1]/collab[1]))))       or       ((count(ancestor::element-citation/person-group[1]/*)=2 and        count($x/ancestor::element-citation/person-group[1]/*)=2)  and        ((ancestor::element-citation/person-group[1]/name[1]/surname=$x/ancestor::element-citation/person-group[1]/name[1]/surname       and       (ancestor::element-citation/person-group[1]/name[2]/surname=$x/ancestor::element-citation/person-group[1]/name[2]/surname       or       ancestor::element-citation/person-group[1]/*[2]=$x/ancestor::element-citation/person-group[1]/*[2]))       or       (ancestor::element-citation/person-group[1]/*[1]=$x/ancestor::element-citation/person-group[1]/*[1]       and       (ancestor::element-citation/person-group[1]/name[2]/surname=$x/ancestor::element-citation/person-group[1]/name[2]/surname       or       ancestor::element-citation/person-group[1]/*[2]=$x/ancestor::element-citation/person-group[1]/*[2])))       and $x=current())       )">
         <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                      xmlns:osf="http://www.oxygenxml.com/sch/functions">
            <xsl:text>Error:</xsl:text>
            <xsl:text>[err-elem-cit-gen-date-1-8] </xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron"
                          select="count(ancestor::element-citation/person-group[1]/*)"/>
            <xsl:text> and </xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron"
                          select="ancestor::element-citation/person-group[1]/name[1]/surname"/>
            <xsl:text> Letter suffixes must be unique for the combination of year and author information. Reference '</xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
            <xsl:text>' does not fulfill this requirement as it contains the &lt;year&gt; '</xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="."/>
            <xsl:text>' for the author information '</xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron"
                          select="ancestor::element-citation/person-group[1]/name[1]/surname"/>
            <xsl:text>', which occurs in at least one other reference.</xsl:text>
         </xsl:message>
      </xsl:if>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M2"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M2"/>
   <xsl:template match="@*|node()" priority="-2" mode="M2">
      <xsl:choose><!--Housekeeping: SAXON warns if attempting to find the attribute
                           of an attribute-->
         <xsl:when test="not(@*)">
            <xsl:apply-templates select="node()" mode="M2"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates select="@*|node()" mode="M2"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <!--PATTERN element-citation-high-testsHigh-level Tests for 'element-citation'-->


	  <!--RULE ref-list-->
   <xsl:template match="ref-list" priority="104" mode="M3">
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M3"/>
   </xsl:template>

	  <!--RULE ref-->
   <xsl:template match="ref" priority="103" mode="M3">
      <xsl:variable name="name"
                    select="lower-case(if (local-name(element-citation/person-group[1]/*[1])='name')       then (element-citation/person-group[1]/name[1]/surname)       else (element-citation/person-group[1]/collab))"/>
      <xsl:variable name="name2"
                    select="lower-case(if (local-name(element-citation/person-group[1]/*[2])='name')       then (element-citation/person-group[1]/*[2]/surname)       else (element-citation/person-group[1]/*[2]))"/>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(*) = count(element-citation)"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-high-1] The only element that is allowed as a child of &lt;ref&gt; is &lt;element-citation&gt;. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="@id"/>
               <xsl:text>' has other elements. </xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="if (count(element-citation/person-group[1]/*) != 2)       then (count(preceding-sibling::ref) = 0 or        ($name &gt; lower-case(preceding-sibling::ref[1]/element-citation/person-group[1]/(name[1]/surname,collab))) or       ($name = lower-case(preceding-sibling::ref[1]/element-citation/person-group[1]/(name[1]/surname,collab)) and       element-citation/year &gt;= preceding-sibling::ref[1]/element-citation/year))       else (count(preceding-sibling::ref) = 0 or ($name &gt; lower-case(preceding-sibling::ref[1]/element-citation/person-group[1]/(name[1]/surname,collab))) or       ($name = lower-case(preceding-sibling::ref[1]/element-citation/person-group[1]/(name[1]/surname,collab)) and       $name2 &gt; lower-case(preceding-sibling::ref[1]/element-citation/person-group[1]/(name[2]/surname,collab)))        or        ($name = lower-case(preceding-sibling::ref[1]/element-citation/person-group[1]/(name[1]/surname,collab)) and       $name2 = lower-case(preceding-sibling::ref[1]/element-citation/person-group[1]/(name[2]/surname,collab)) and       element-citation/year &gt;= preceding-sibling::ref[1]/element-citation/year)       or       ($name = lower-case(preceding-sibling::ref[1]/element-citation/person-group[1]/(name[1]/surname,collab)) and       count(preceding-sibling::ref[1]/element-citation/person-group[1]/*) !=2)       )"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-high-2-2] The order of &lt;element-citation&gt;s should be name and date, arranged alphabetically by the first author’s surname, or the value of the &lt;collab&gt; element. In the case of two authors, the sequence is arranged by both authors' surnames, then date. For three or more authors, the sequence is the first author's surname, then date. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="@id"/>
               <xsl:text>' appears to be in a different order. </xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@id"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-high-3-1] Each &lt;ref&gt; element must have an @id attribute. </xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="matches(normalize-space(@id) ,'^bib\d+')"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-high-3-2] Each &lt;ref&gt; element must have an @id attribute that starts with 'bib' and ends with a number. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="@id"/>
               <xsl:text>' has the value '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="@id"/>
               <xsl:text>', which is incorrect. </xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(preceding-sibling::ref)=0 or number(substring(@id,4)) gt number(substring(preceding-sibling::ref[1]/@id,4))"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-high-3-3] The sequence of ids in the &lt;ref&gt; elements must increase monotonically. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="@id"/>
               <xsl:text>' has the value '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="@id"/>
               <xsl:text>', which does not. </xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="year-comma" select="', \d{4}\w?$'"/>
      <xsl:variable name="year-paren" select="' \(\d{4}\w?\)$'"/>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="every $x in //xref[@rid=current()/@id]       satisfies (       if (count(current()/element-citation/person-group[1]/(name | collab))=1)        then (       matches(normalize-space($x), concat('^', current()/element-citation/person-group[1]/name/surname, $year-comma))       or       matches(normalize-space($x), concat('^', current()/element-citation/person-group[1]/name/surname, $year-paren))       or       matches(normalize-space($x), concat('^', current()/element-citation/person-group[1]/collab, $year-comma))       or       matches(normalize-space($x), concat('^', current()/element-citation/person-group[1]/collab, $year-paren))       )       else        if (count(current()/element-citation/person-group[1]/(name|collab))=2)        then (       matches(replace($x,'\p{Zs}',' '), concat('^', current()/element-citation/person-group[1]/name[1]/surname,       ' and ', current()/element-citation/person-group[1]/name[2]/surname, $year-comma))       or       matches(replace($x,'\p{Zs}',' '), concat('^', current()/element-citation/person-group[1]/name[1]/surname,       ' and ', current()/element-citation/person-group[1]/name[2]/surname, $year-paren))       or       matches(replace($x,'\p{Zs}',' '), concat('^', current()/element-citation/person-group[1]/name[1]/surname,       ' and ', current()/element-citation/person-group[1]/collab[1], $year-comma))       or       matches(replace($x,'\p{Zs}',' '), concat('^', current()/element-citation/person-group[1]/name[1]/surname,       ' and ', current()/element-citation/person-group[1]/collab[1], $year-paren))       or       matches(replace($x,'\p{Zs}',' '), concat('^', current()/element-citation/person-group[1]/collab[1],       ' and ', current()/element-citation/person-group[1]/name[1]/surname, $year-comma))       or       matches(replace($x,'\p{Zs}',' '), concat('^', current()/element-citation/person-group[1]/collab[1],       ' and ', current()/element-citation/person-group[1]/name[1]/surname, $year-paren))       or       matches(replace($x,'\p{Zs}',' '), concat('^', current()/element-citation/person-group[1]/collab[1],       ' and ', current()/element-citation/person-group[1]/collab[2], $year-comma))       or       matches(replace($x,'\p{Zs}',' '), concat('^', current()/element-citation/person-group[1]/collab[1],       ' and ', current()/element-citation/person-group[1]/collab[2], $year-paren))       )       else        if (count(current()/element-citation/person-group[1]/(name|collab))&gt;2)        then (       matches(replace($x,'\p{Zs}',' '), concat('^', current()/element-citation/person-group[1]/name[1]/surname,       ' et al.', $year-comma))       or       matches(replace($x,'\p{Zs}',' '), concat('^', current()/element-citation/person-group[1]/name[1]/surname,       ' et al.', $year-paren))       or       matches(replace($x,'\p{Zs}',' '), concat('^', current()/element-citation/person-group[1]/collab[1],       ' et al.', $year-comma))       or       matches(replace($x,'\p{Zs}',' '), concat('^', current()/element-citation/person-group[1]/collab[1],       ' et al.', $year-paren))       )          else ()       )"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-high-4] If an element-citation/person-group contains one &lt;name&gt;, the content of the &lt;surname&gt; inside that name must appear in the content of all &lt;xref&gt;s that point to the &lt;element-citation&gt;. If an element-citation/person-group contains 2 &lt;name&gt;s, the content of the first &lt;surname&gt; of the first &lt;name&gt;, followed by the string “ and “, followed by the content of the &lt;surname&gt; of the second &lt;name&gt; must appear in the content of all &lt;xref&gt;s that point to the &lt;element-citation&gt;. If there are more than 2 &lt;name&gt;s in the &lt;person-group&gt;, &lt;xref&gt; that point to that citation must contain the content of only the first of the &lt;surname&gt;s, followed by the text "et al." All of these are followed by ', ' and the year, or the year in parentheses. There are </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron"
                             select="count(//xref[@rid=current()/@id]/@rid)"/>
               <xsl:text> &lt;xref&gt; references with @rid = </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="@id"/>
               <xsl:text> to be checked. The first name should be '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron"
                             select="element-citation/person-group[1]/(name[1]/surname | collab[1])[1]"/>
               <xsl:text>'. </xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="every $x in //xref[@rid=current()/@id]       satisfies (matches(replace($x,'\p{Zs}',' '), concat(', ',current()/element-citation/year),'s') or       matches(replace($x,'\p{Zs}',' '), concat('\(',current()/element-citation/year,'\)')))"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-high-5] All xrefs to &lt;ref&gt;s, which contain &lt;element-citation&gt;s, should contain, as the last part of their content, the string ", " followed by the content of the year element in the &lt;element-citation&gt;, or the year in parentheses. There are </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron"
                             select="count(//xref[@rid=current()/@id]/@rid)"/>
               <xsl:text> references to be checked; the incorrect &lt;xref&gt; has @rid </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="@id"/>
               <xsl:text> and should contain the string ', </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="element-citation/year"/>
               <xsl:text>' or the string '(</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="element-citation/year"/>
               <xsl:text>)' but does not. </xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M3"/>
   </xsl:template>

	  <!--RULE xref-->
   <xsl:template match="xref[@ref-type='bibr']" priority="102" mode="M3">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="not(matches(substring(normalize-space(.),string-length(.)),'[b-z]')) or        (some $x in preceding::xref       satisfies (substring(normalize-space(.),string-length(.)) gt substring(normalize-space($x),string-length(.))))"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-xref-high-2-1] Citations in the text to references with the same author(s) in the same year must be arranged in the same order as the reference list. The xref with the value '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="."/>
               <xsl:text>' is in the wrong order in the text. Check all the references to citations for the same authors to determine which need to be changed." </xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M3"/>
   </xsl:template>

	  <!--RULE elem-citation-->
   <xsl:template match="element-citation" priority="101" mode="M3">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@publication-type"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-high-6-1] The element-citation element must have a publication-type attribute. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="../@id"/>
               <xsl:text>' does not. </xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@publication-type = 'journal' or                     @publication-type = 'book'    or                     @publication-type = 'data'    or                     @publication-type = 'patent'    or                     @publication-type = 'clinicaltrial' or                     @publication-type = 'software'    or                     @publication-type = 'preprint' or                     @publication-type = 'web'    or                     @publication-type = 'periodical' or                     @publication-type = 'report'    or                     @publication-type = 'confproc'    or                     @publication-type = 'thesis'"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-high-6-2] The publication-type attribute may only take the values 'journal', 'book', 'data', 'patent', 'clinicaltrial', 'software', 'preprint', 'web', 'periodical', 'report', 'confproc', or 'thesis'. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="../@id"/>
               <xsl:text>' has the publication-type '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="@publication-type"/>
               <xsl:text>'.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M3"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M3"/>
   <xsl:template match="@*|node()" priority="-2" mode="M3">
      <xsl:choose><!--Housekeeping: SAXON warns if attempting to find the attribute
                           of an attribute-->
         <xsl:when test="not(@*)">
            <xsl:apply-templates select="node()" mode="M3"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates select="@*|node()" mode="M3"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <!--PATTERN element-citation-journal-testselement-citation publication-type="journal" Tests-->


	  <!--RULE elem-citation-journal-->
   <xsl:template match="element-citation[@publication-type='journal']"
                 priority="108"
                 mode="M4">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(person-group)=1"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-journal-2-1] Each &lt;element-citation&gt; of type 'journal' must contain one and only one &lt;person-group&gt; element. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(person-group)"/>
               <xsl:text> &lt;person-group&gt; elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="person-group[@person-group-type='author']"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-journal-2-2] Each &lt;element-citation&gt; of type 'journal' must contain one &lt;person-group&gt; with the attribute person-group-type set to 'author'. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has a &lt;person-group&gt; type of '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron"
                             select="person-group/@person-group-type"/>
               <xsl:text>'.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(article-title)=1"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-journal-3-1] Each &lt;element-citation&gt; of type 'journal' must contain one and only one &lt;article-title&gt; element. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(article-title)"/>
               <xsl:text> &lt;article-title&gt; elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(source)=1"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-journal-4-1] Each &lt;element-citation&gt; of type 'journal' must contain one and only one &lt;source&gt; element. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(source)"/>
               <xsl:text> &lt;source&gt; elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(source)=1 and (source/string-length() + sum(descendant::source/*/string-length()) ge 2)"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-journal-4-2-1] A &lt;source&gt; element within a &lt;element-citation&gt; of type 'journal' must contain at least two characters. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has too few characters.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(source)=1 and count(source/*)=count(source/(italic | sub | sup))"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-journal-4-2-2] A &lt;source&gt; element within a &lt;element-citation&gt; of type 'journal' may only contain the child elements&lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. No other elements are allowed. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has disallowed child elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(volume) le 1"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-journal-5-1-3] There may be at most one &lt;volume&gt; element within a &lt;element-citation&gt; of type 'journal'. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(volume)"/>
               <xsl:text> &lt;volume&gt; elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="(count(fpage) eq 1) or (count(elocation-id) eq 1) or (count(comment/text()='In press') eq 1)"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Warning:</xsl:text>
               <xsl:text>[warning-elem-cit-journal-6-1] One of &lt;fpage&gt;, &lt;elocation-id&gt;, or &lt;comment&gt;In press&lt;/comment&gt; should be present. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has missing page or elocation information.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT error-->
      <xsl:if test="lpage and not(fpage)">
         <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                      xmlns:osf="http://www.oxygenxml.com/sch/functions">
            <xsl:text>Error:</xsl:text>
            <xsl:text>[err-elem-cit-journal-6-5-1] &lt;lpage&gt; is only allowed if &lt;fpage&gt; is present. Reference '</xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
            <xsl:text>' has &lt;lpage&gt; but no &lt;fpage&gt;.</xsl:text>
         </xsl:message>
      </xsl:if>

		    <!--REPORT error-->
      <xsl:if test="lpage and (number(fpage) &gt;= number(lpage))">
         <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                      xmlns:osf="http://www.oxygenxml.com/sch/functions">
            <xsl:text>Error:</xsl:text>
            <xsl:text>[err-elem-cit-journal-6-5-2] &lt;lpage&gt; must be larger than &lt;fpage&gt;, if present. Reference '</xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
            <xsl:text>' has first page &lt;fpage&gt; = '</xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="fpage"/>
            <xsl:text>' but last page &lt;lpage&gt; = '</xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="lpage"/>
            <xsl:text>'.</xsl:text>
         </xsl:message>
      </xsl:if>

		    <!--REPORT error-->
      <xsl:if test="count(fpage) gt 1 or count(lpage) gt 1 or count(elocation-id) gt 1 or count(comment) gt 1">
         <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                      xmlns:osf="http://www.oxygenxml.com/sch/functions">
            <xsl:text>Error:</xsl:text>
            <xsl:text>[err-elem-cit-journal-6-7] The following tags may not occur more than once in an &lt;element-citation&gt;: &lt;fpage&gt;, &lt;lpage&gt;, &lt;elocation-id&gt;, and &lt;comment&gt;In press&lt;/comment&gt;. Reference '</xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
            <xsl:text>' has </xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(fpage)"/>
            <xsl:text> &lt;fpage&gt;, </xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(lpage)"/>
            <xsl:text> &lt;lpage&gt;, </xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(elocation-id)"/>
            <xsl:text> &lt;elocation-id&gt;, and </xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(comment)"/>
            <xsl:text> &lt;comment&gt; elements.</xsl:text>
         </xsl:message>
      </xsl:if>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(*) = count(person-group| year| article-title| source| volume| fpage| lpage| elocation-id| comment| pub-id)"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-journal-12] The only tags that are allowed as children of &lt;element-citation&gt; with the publication-type="journal" are: &lt;person-group&gt;, &lt;year&gt;, &lt;article-title&gt;, &lt;source&gt;, &lt;volume&gt;, &lt;fpage&gt;, &lt;lpage&gt;, &lt;elocation-id&gt;, &lt;comment&gt;, and &lt;pub-id&gt;. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has other elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M4"/>
   </xsl:template>

	  <!--RULE elem-citation-journal-article-title-->
   <xsl:template match="element-citation[@publication-type='journal']/article-title"
                 priority="107"
                 mode="M4">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(*) = count(sub|sup|italic)"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-journal-3-2] An &lt;article-title&gt; element in a reference may contain characters and &lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. No other elements are allowed. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' does not meet this requirement.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M4"/>
   </xsl:template>

	  <!--RULE elem-citation-journal-volume-->
   <xsl:template match="element-citation[@publication-type='journal']/volume"
                 priority="106"
                 mode="M4">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(*)=0 and (string-length(text()) ge 1)"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-journal-5-1-2] A &lt;volume&gt; element within a &lt;element-citation&gt; of type 'journal' must contain at least one character and may not contain child elements. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has too few characters and/or child elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M4"/>
   </xsl:template>

	  <!--RULE elem-citation-journal-fpage-->
   <xsl:template match="element-citation[@publication-type='journal']/fpage"
                 priority="105"
                 mode="M4">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(../elocation-id) eq 0 and count(../comment) eq 0"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-journal-6-2] If &lt;fpage&gt; is present, neither &lt;elocation-id&gt; nor &lt;comment&gt;In press&lt;/comment&gt; may be present. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has &lt;fpage&gt; and one of those elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="matches(normalize-space(.),'^\d.*') or (substring(normalize-space(../lpage),1,1) = substring(normalize-space(.),1,1))"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-journal-6-6] If the content of &lt;fpage&gt; begins with a letter, then the content of &lt;lpage&gt; must begin with the same letter. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' does not.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M4"/>
   </xsl:template>

	  <!--RULE elem-citation-journal-elocation-id-->
   <xsl:template match="element-citation[@publication-type='journal']/elocation-id"
                 priority="104"
                 mode="M4">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(../fpage) eq 0 and count(../comment) eq 0"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-journal-6-3] If &lt;elocation-id&gt; is present, neither &lt;fpage&gt; nor &lt;comment&gt;In press&lt;/comment&gt; may be present. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has &lt;elocation-id&gt; and one of those elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M4"/>
   </xsl:template>

	  <!--RULE elem-citation-journal-comment-->
   <xsl:template match="element-citation[@publication-type='journal']/comment"
                 priority="103"
                 mode="M4">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(../fpage) eq 0 and count(../elocation-id) eq 0"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-journal-6-4] If &lt;comment&gt;In press&lt;/comment&gt; is present, neither &lt;fpage&gt; nor &lt;elocation-id&gt; may be present. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has one of those elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="text() = 'In press'"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-journal-13] Comment elements with content other than 'In press' are not allowed. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has such a &lt;comment&gt; element.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M4"/>
   </xsl:template>

	  <!--RULE elem-citation-journal-pub-id-pmid-->
   <xsl:template match="element-citation[@publication-type='journal']/pub-id[@pub-id-type='pmid']"
                 priority="102"
                 mode="M4">

		<!--REPORT error-->
      <xsl:if test="matches(.,'\D')">
         <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                      xmlns:osf="http://www.oxygenxml.com/sch/functions">
            <xsl:text>Error:</xsl:text>
            <xsl:text>[err-elem-cit-journal-10] If &lt;pub-id pub-id-type="pmid"&gt; the content must be all numeric. The content of &lt;pub-id pub-id-type="pmid"&gt; in Reference '</xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
            <xsl:text>' is </xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="."/>
            <xsl:text>.</xsl:text>
         </xsl:message>
      </xsl:if>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M4"/>
   </xsl:template>

	  <!--RULE elem-citation-journal-pub-id-->
   <xsl:template match="element-citation[@publication-type='journal']/pub-id"
                 priority="101"
                 mode="M4">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@pub-id-type='doi' or @pub-id-type='pmid'"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-journal-9-1] Each &lt;pub-id&gt;, if present, must have a @pub-id-type of either "doi" or "pmid". The pub-id-type attribute on &lt;pub-id&gt; in Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' is </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="@pub-id-type"/>
               <xsl:text>.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M4"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M4"/>
   <xsl:template match="@*|node()" priority="-2" mode="M4">
      <xsl:choose><!--Housekeeping: SAXON warns if attempting to find the attribute
                           of an attribute-->
         <xsl:when test="not(@*)">
            <xsl:apply-templates select="node()" mode="M4"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates select="@*|node()" mode="M4"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <!--PATTERN element-citation-book-testselement-citation publication-type="book" Tests-->


	  <!--RULE elem-citation-book-->
   <xsl:template match="element-citation[@publication-type='book']"
                 priority="107"
                 mode="M5">
      <xsl:variable name="publisher-locations" select="'publisher-locations.xml'"/>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="person-group[@person-group-type='author'] or person-group[@person-group-type='editor']"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-book-2-2] The only values allowed for @person-group-type are "author" and "editor". Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has a &lt;person-group&gt; type of '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron"
                             select="person-group/@person-group-type"/>
               <xsl:text>'.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(person-group)=1 or ((count(person-group/@person-group-type='author')+       count(person-group/@person-group-type='editor')=2) and (count(edition)=1 or count(chapter-title)=1))"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-book-2-3] One and only 1 person-group element is allowed (either author or editor) 3a. unless there is an &lt;edition&gt; element or a &lt;chapter-title element in the &lt;element-citation&gt;, in which case there may be one person-group with @person-group-type="author" and one person-group with @person-group-type=editor. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(person-group)"/>
               <xsl:text> &lt;person-group&gt; elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(source)=1"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-book-book-10-1] Each &lt;element-citation&gt; of type 'book' must contain one and only one &lt;source&gt; element. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(source)"/>
               <xsl:text> &lt;source&gt; elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(source)=1 and (source/string-length() + sum(descendant::source/*/string-length()) ge 2)"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-book-10-2-1] A &lt;source&gt; element within a &lt;element-citation&gt; of type 'book' must contain at least two characters. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has too few characters.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(source)=1 and count(source/*)=count(source/(italic | sub | sup))"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-book-10-2-2] A &lt;source&gt; element within a &lt;element-citation&gt; of type 'book' may may only contain the child elements&lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. No other elements are allowed. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has child elements that are not allowed.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(publisher-name)=1"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-book-13-1] One and only one &lt;publisher-name&gt; is required. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(publisher-name)"/>
               <xsl:text> &lt;publisher-name&gt; elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT warning-->
      <xsl:if test="some $p in document($publisher-locations)/locations/location/text()       satisfies ends-with(publisher-name,$p)">
         <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                      xmlns:osf="http://www.oxygenxml.com/sch/functions">
            <xsl:text>Warning:</xsl:text>
            <xsl:text>[warning-elem-cit-book-13-3] The content of &lt;publisher-name&gt; may not end with a publisher location. Reference '</xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
            <xsl:text>' contains the string </xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="publisher-name"/>
            <xsl:text>, which ends with a publisher location.</xsl:text>
         </xsl:message>
      </xsl:if>

		    <!--REPORT error-->
      <xsl:if test="(lpage or fpage) and not(chapter-title)">
         <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                      xmlns:osf="http://www.oxygenxml.com/sch/functions">
            <xsl:text>Error:</xsl:text>
            <xsl:text>[err-elem-cit-book-16] &lt;lpage&gt; and &lt;fpage&gt; are allowed only if &lt;chapter-title&gt; is present. Reference '</xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
            <xsl:text>' has &lt;lpage&gt; or &lt;fpage&gt; but no &lt;chapter-title&gt;.</xsl:text>
         </xsl:message>
      </xsl:if>

		    <!--REPORT error-->
      <xsl:if test="(lpage and fpage) and (fpage ge lpage)">
         <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                      xmlns:osf="http://www.oxygenxml.com/sch/functions">
            <xsl:text>Error:</xsl:text>
            <xsl:text>[err-elem-cit-book-36-1] If both &lt;lpage&gt; and &lt;fpage&gt; are present, the value of &lt;fpage&gt; must be less than the value of &lt;lpage&gt;. Reference '</xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
            <xsl:text>' has &lt;lpage&gt; </xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="lpage"/>
            <xsl:text>, which is less than or equal to &lt;fpage&gt; </xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="fpage"/>
            <xsl:text>.</xsl:text>
         </xsl:message>
      </xsl:if>

		    <!--REPORT error-->
      <xsl:if test="lpage and not (fpage)">
         <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                      xmlns:osf="http://www.oxygenxml.com/sch/functions">
            <xsl:text>Error:</xsl:text>
            <xsl:text>[err-elem-cit-book-36-2] If &lt;lpage&gt; is present, &lt;fpage&gt; must also be present. Reference '</xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
            <xsl:text>' has &lt;lpage&gt; but not &lt;fpage&gt;.</xsl:text>
         </xsl:message>
      </xsl:if>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(*) = count(person-group| year| source| chapter-title| publisher-loc|publisher-name|volume|        edition| fpage| lpage| pub-id)"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-book-40] The only tags that are allowed as children of &lt;element-citation&gt; with the publication-type="book" are: &lt;person-group&gt;, &lt;year&gt;, &lt;source&gt;, &lt;chapter-title&gt;, &lt;publisher-loc&gt;, &lt;publisher-name&gt;, &lt;volume&gt;, &lt;edition&gt;, &lt;fpage&gt;, &lt;lpage&gt;, and &lt;pub-id&gt;. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has other elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M5"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="element-citation[@publication-type='book']/person-group"
                 priority="106"
                 mode="M5">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@person-group-type"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-book-2-1] Each &lt;person-group&gt; must have a @person-group-type attribute. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has a &lt;person-group&gt; element with no @person-group-type attribute.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M5"/>
   </xsl:template>

	  <!--RULE elem-citation-book-chapter-title-->
   <xsl:template match="element-citation[@publication-type='book']/chapter-title"
                 priority="105"
                 mode="M5">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(../person-group[@person-group-type='author'])=1"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-book-22] If there is a &lt;chapter-title&gt; element there must be one and only one &lt;person-group person-group-type="author"&gt;. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' does not meet this requirement.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(../person-group[@person-group-type='editor']) le 1"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-book-28-1] If there is a &lt;chapter-title&gt; element there may be a maximum of one &lt;person-group person-group-type="editor"&gt;. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' does not meet this requirement.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(*) = count(sub|sup|italic)"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-book-31] A &lt;chapter-title&gt; element in a reference may contain characters and &lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. No other elements are allowed. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' does not meet this requirement.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M5"/>
   </xsl:template>

	  <!--RULE elem-citation-book-publisher-name-->
   <xsl:template match="element-citation[@publication-type='book']/publisher-name"
                 priority="104"
                 mode="M5">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(*)=0"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-book-13-2] No elements are allowed inside &lt;publisher-name&gt;. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has child elements within the &lt;publisher-name&gt; element.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M5"/>
   </xsl:template>

	  <!--RULE elem-citation-book-edition-->
   <xsl:template match="element-citation[@publication-type='book']/edition"
                 priority="103"
                 mode="M5">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(*)=0"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-book-15] No elements are allowed inside &lt;edition&gt;. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has child elements within the &lt;edition&gt; element.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M5"/>
   </xsl:template>

	  <!--RULE elem-citation-book-pub-id-pmid-->
   <xsl:template match="element-citation[@publication-type='book']/pub-id[@pub-id-type='pmid']"
                 priority="102"
                 mode="M5">

		<!--REPORT error-->
      <xsl:if test="matches(.,'\D')">
         <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                      xmlns:osf="http://www.oxygenxml.com/sch/functions">
            <xsl:text>Error:</xsl:text>
            <xsl:text>[err-elem-cit-book-18] If &lt;pub-id pub-id-type="pmid"&gt; the content must be all numeric. The content of &lt;pub-id pub-id-type="pmid"&gt; in Reference '</xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
            <xsl:text>' is </xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="."/>
            <xsl:text>.</xsl:text>
         </xsl:message>
      </xsl:if>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M5"/>
   </xsl:template>

	  <!--RULE elem-citation-book-pub-id-->
   <xsl:template match="element-citation[@publication-type='book']/pub-id"
                 priority="101"
                 mode="M5">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@pub-id-type='doi' or @pub-id-type='pmid' or @pub-id-type='isbn'"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-book-17] Each &lt;pub-id&gt;, if present, must have a @pub-id-type of one of these values: doi, pmid, isbn. The pub-id-type attribute on &lt;pub-id&gt; in Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' is </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="@pub-id-type"/>
               <xsl:text>.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M5"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M5"/>
   <xsl:template match="@*|node()" priority="-2" mode="M5">
      <xsl:choose><!--Housekeeping: SAXON warns if attempting to find the attribute
                           of an attribute-->
         <xsl:when test="not(@*)">
            <xsl:apply-templates select="node()" mode="M5"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates select="@*|node()" mode="M5"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <!--PATTERN element-citation-data-testselement-citation publication-type="data" Tests-->


	  <!--RULE elem-citation-data-->
   <xsl:template match="element-citation[@publication-type='data']"
                 priority="104"
                 mode="M6">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(person-group[@person-group-type='author']) le 1 and       count(person-group[@person-group-type='compiler']) le 1 and       count(person-group[@person-group-type='curator']) le 1"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-data-3-1] Only 1 person-group of each type (author, compiler, curator) is allowed. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron"
                             select="count(person-group[@person-group-type='author'])"/>
               <xsl:text> &lt;person-group&gt; elements of type of 'author', </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron"
                             select="count(person-group[@person-group-type='author'])"/>
               <xsl:text> &lt;person-group&gt; elements of type of 'compiler', </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron"
                             select="count(person-group[@person-group-type='author'])"/>
               <xsl:text> &lt;person-group&gt; elements of type of 'curator', and </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron"
                             select="count(person-group[@person-group-type!='author' and @person-group-type!='compiler' and @person-group-type!='curator'])"/>
               <xsl:text> &lt;person-group&gt; elements of some other type.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(person-group) ge 1"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-data-3-2] Each &lt;element-citation&gt; of type 'data' must contain at least one &lt;person-group&gt; element. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(person-group)"/>
               <xsl:text> &lt;person-group&gt; elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(data-title)=1"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-data-10] Each &lt;element-citation&gt; of type 'data' must contain one and only one &lt;data-title&gt; element. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(data-title)"/>
               <xsl:text> &lt;data-title&gt; elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(source)=1"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-data-11-2] Each &lt;element-citation&gt; of type 'data' must contain one and only one &lt;source&gt; element. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(source)"/>
               <xsl:text> &lt;source&gt; elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(source)=1 and (source/string-length() + sum(descendant::source/*/string-length()) ge 2)"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-data-11-3-1] A &lt;source&gt; element within a &lt;element-citation&gt; of type 'data' must contain at least two characters. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has too few characters.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(source)=1 and count(source/*)=count(source/(italic | sub | sup))"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-data-11-3-2] A &lt;source&gt; element within a &lt;element-citation&gt; of type 'data' may only contain the child elements&lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. No other elements are allowed. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has disallowed child elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="pub-id or ext-link"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-data-13-1] There must be at least one pub-id OR an &lt;ext-link&gt;. There may be more than one pub-id. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(pub-id)"/>
               <xsl:text> &lt;pub-id elements and </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(ext-link)"/>
               <xsl:text> &lt;ext-link&gt; elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(pub-id) ge 1 or count(ext-link) ge 1"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-data-17-1] The &lt;ext-link&gt; element is required if there is no &lt;pub-id&gt;. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(pub-id)"/>
               <xsl:text> &lt;pub-id&gt; elements and </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(ext-link)"/>
               <xsl:text> &lt;ext-link&gt; elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(*) = count(person-group| data-title| source| year| pub-id| version| ext-link)"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-data-18] The only tags that are allowed as children of &lt;element-citation&gt; with the publication-type="data" are: &lt;person-group&gt;, &lt;data-title&gt;, &lt;source&gt;, &lt;year&gt;, &lt;pub-id&gt;, &lt;version&gt;, and &lt;ext-link&gt;. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has other elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M6"/>
   </xsl:template>

	  <!--RULE elem-citation-data-pub-id-doi-->
   <xsl:template match="element-citation[@publication-type='data']/pub-id[@pub-id-type='doi']"
                 priority="103"
                 mode="M6">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="not(@xlink:href)"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-data-14-2] If the pub-id is of pub-id-type doi, it may not have an @xlink:href. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has a &lt;pub-id element with type doi and an @link-href with value '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="@link-href"/>
               <xsl:text>'.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M6"/>
   </xsl:template>

	  <!--RULE elem-citation-data-pub-id-->
   <xsl:template match="element-citation[@publication-type='data']/pub-id"
                 priority="102"
                 mode="M6">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@pub-id-type=('accession', 'archive', 'ark', 'doi')"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-data-13-2] Each pub-id element must have one of these types: accession, archive, ark, assigning-authority or doi. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has a &lt;pub-id element with types '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="@pub-id-type"/>
               <xsl:text>'.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="if (@pub-id-type ne 'doi') then @xlink:href else ()"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-data-14-1] If the pub-id is of any pub-id-type except doi, it must have an @xlink:href. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has a &lt;pub-id element with type '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="@pub-id-type"/>
               <xsl:text>' but no @xlink-href.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M6"/>
   </xsl:template>

	  <!--RULE elem-citation-data-ext-link-->
   <xsl:template match="element-citation[@publication-type='data']/ext-link"
                 priority="101"
                 mode="M6">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@xlink:href"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-data-17-2] Each &lt;ext-link&gt; element must contain @xlink:href. The &lt;ext-link&gt; element in Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' does not.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="starts-with(@xlink:href, 'http://') or starts-with(@xlink:href, 'https://')"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-data-17-3] The value of @xlink:href must start with either "http://" or "https://". The &lt;ext-link&gt; element in Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' is '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="@xlink:href"/>
               <xsl:text>', which does not.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="normalize-space(@xlink:href)=normalize-space(.)"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-data-17-4] The value of @xlink:href must be the same as the element content of &lt;ext-link&gt;. The &lt;ext-link&gt; element in Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has @xlink:href='</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="@xlink:href"/>
               <xsl:text>' and content '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="."/>
               <xsl:text>'.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M6"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M6"/>
   <xsl:template match="@*|node()" priority="-2" mode="M6">
      <xsl:choose><!--Housekeeping: SAXON warns if attempting to find the attribute
                           of an attribute-->
         <xsl:when test="not(@*)">
            <xsl:apply-templates select="node()" mode="M6"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates select="@*|node()" mode="M6"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <!--PATTERN element-citation-patent-testselement-citation publication-type="patent" Tests-->


	  <!--RULE elem-citation-patent-->
   <xsl:template match="element-citation[@publication-type='patent']"
                 priority="105"
                 mode="M7">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(person-group[@person-group-type='inventor'])=1"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-patent-2-1] There must be one person-group with @person-group-type="inventor". Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron"
                             select="count(person-group[@person-group-type='inventor'])"/>
               <xsl:text> &lt;person-group&gt; elements of type 'inventor'.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="every $type in person-group/@person-group-type       satisfies $type = ('assignee','inventor')"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-patent-2-3] The only allowed types of person-group elements are "assignee" and "inventor". Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has &lt;person-group&gt; elements of other types.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(person-group[@person-group-type='assignee']) le 1"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-patent-2A] There may be zero or one person-group elements with @person-group-type="assignee" Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron"
                             select="count(person-group[@person-group-type='assignee'])"/>
               <xsl:text> &lt;person-group&gt; elements of type 'assignee'.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(article-title)=1"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-patent-8-1] Each &lt;element-citation&gt; of type 'patent' must contain one and only one &lt;article-title&gt; element. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(article-title)"/>
               <xsl:text> &lt;article-title&gt; elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(source) le 1"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-patent-9-1] Each &lt;element-citation&gt; of type 'patent' may contain zero or one &lt;source&gt; elements. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(source)"/>
               <xsl:text> &lt;source&gt; elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="patent"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-patent-10-1-1] The &lt;patent&gt; element is required. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has no &lt;patent&gt; elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="ext-link"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-patent-11-1] The &lt;ext-link&gt; element is required. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has no &lt;ext-link&gt; elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(*) = count(person-group| article-title| source| year| patent| ext-link)"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-patent-18] The only tags that are allowed as children of &lt;element-citation&gt; with the publication-type="patent" are: &lt;person-group&gt;, &lt;article-title&gt;, &lt;source&gt;, &lt;year&gt;, &lt;patent&gt;, and &lt;ext-link&gt;. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has other elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M7"/>
   </xsl:template>

	  <!--RULE elem-citation-patent-ext-link-->
   <xsl:template match="element-citation[@publication-type='patent']/ext-link"
                 priority="104"
                 mode="M7">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@xlink:href"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-patent-11-2] Each &lt;ext-link&gt; element must contain @xlink:href. The &lt;ext-link&gt; element in Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' does not.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="starts-with(@xlink:href, 'http://') or starts-with(@xlink:href, 'https://')"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-patent-11-3] The value of @xlink:href must start with either "http://" or "https://". The &lt;ext-link&gt; element in Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' is '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="@xlink:href"/>
               <xsl:text>', which does not.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="normalize-space(@xlink:href)=normalize-space(.)"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-patent-11-4] The value of @xlink:href must be the same as the element content of &lt;ext-link&gt;. The &lt;ext-link&gt; element in Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has @xlink:href='</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="@xlink:href"/>
               <xsl:text>' and content '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="."/>
               <xsl:text>'.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M7"/>
   </xsl:template>

	  <!--RULE elem-citation-patent-article-title-->
   <xsl:template match="element-citation[@publication-type='patent']/article-title"
                 priority="103"
                 mode="M7">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="./string-length() + sum(*/string-length()) ge 2"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-patent-8-2-1] A &lt;article-title&gt; element within a &lt;element-citation&gt; of type 'patent' must contain at least two characters. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has too few characters.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(*)=count(italic | sub | sup)"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-patent-8-2-2] A &lt;article-title&gt; element within a &lt;element-citation&gt; of type 'patent' may only contain the child elements&lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. No other elements are allowed. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has disallowed child elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M7"/>
   </xsl:template>

	  <!--RULE elem-citation-patent-source-->
   <xsl:template match="element-citation[@publication-type='patent']/source"
                 priority="102"
                 mode="M7">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="./string-length() + sum(*/string-length()) ge 2"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-patent-9-2-1] A &lt;source&gt; element within a &lt;element-citation&gt; of type 'patent' must contain at least two characters. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has too few characters.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(*)=count(italic | sub | sup)"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-patent-9-2-2] A &lt;source&gt; element within a &lt;element-citation&gt; of type 'patent' may only contain the child elements&lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. No other elements are allowed. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has disallowed child elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M7"/>
   </xsl:template>

	  <!--RULE elem-citation-patent-patent-->
   <xsl:template match="element-citation[@publication-type='patent']/patent"
                 priority="101"
                 mode="M7">
      <xsl:variable name="countries" select="'countries.xml'"/>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(*)=0"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-patent-10-1-2] The &lt;patent&gt; element may not have child elements. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has child elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="not(@country) or (@country = document($countries)/countries/country)"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-patent-10-2] The country attribute on the &lt;patent&gt; element is optional, but must have a value from the list if present. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has a patent/@country attribute with the value '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="@country"/>
               <xsl:text>', which is not in the list.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M7"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M7"/>
   <xsl:template match="@*|node()" priority="-2" mode="M7">
      <xsl:choose><!--Housekeeping: SAXON warns if attempting to find the attribute
                           of an attribute-->
         <xsl:when test="not(@*)">
            <xsl:apply-templates select="node()" mode="M7"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates select="@*|node()" mode="M7"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <!--PATTERN element-citation-clinicaltrial-testselement-citation publication-type="clinicaltrial" Tests-->


	  <!--RULE elem-citation-clinicaltrial-->
   <xsl:template match="element-citation[@publication-type='clinicaltrial']"
                 priority="103"
                 mode="M8">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(person-group)=1"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-clinicaltrial-2-1] Each &lt;element-citation&gt; of type 'clinicaltrial' must contain one and only one &lt;person-group&gt; element. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(person-group)"/>
               <xsl:text> &lt;person-group&gt; elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="person-group[@person-group-type=('author', 'collaborator', 'sponsor')]"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-clinicaltrial-2-2] Each &lt;element-citation&gt; of type 'clinicaltrial' must contain one &lt;person-group&gt; with the attribute person-group-type set to 'author', 'collaborator', or 'sponsor'. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has a &lt;person-group&gt; type of '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron"
                             select="person-group/@person-group-type"/>
               <xsl:text>'.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(article-title)=1"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-clinicaltrial-8-1] Each &lt;element-citation&gt; of type 'clinicaltrial' must contain one and only one &lt;article-title&gt; element. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(article-title)"/>
               <xsl:text> &lt;article-title&gt; elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(ext-link)=1"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-clinicaltrial-10-1] Each &lt;element-citation&gt; of type 'clinicaltrial' must contain one and only one &lt;ext-link&gt; element. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(ext-link)"/>
               <xsl:text> &lt;ext-link&gt; elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(*) = count(person-group| year| article-title| source| ext-link)"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-clinicaltrial-11] The only tags that are allowed as children of &lt;element-citation&gt; with the publication-type="clinicaltrial" are: &lt;person-group&gt;, &lt;year&gt;, &lt;article-title&gt;, &lt;source&gt;, and &lt;ext-link&gt; Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has other elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M8"/>
   </xsl:template>

	  <!--RULE elem-citation-clinicaltrial-article-title-->
   <xsl:template match="element-citation[@publication-type='clinicaltrial']/article-title"
                 priority="102"
                 mode="M8">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(*) = count(sub|sup|italic)"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-clinicaltrial-8-2] An &lt;article-title&gt; element in a reference may contain characters and &lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. No other elements are allowed. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' does not meet this requirement.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M8"/>
   </xsl:template>

	  <!--RULE elem-citation-clinicaltrial-ext-link-->
   <xsl:template match="element-citation[@publication-type='clinicaltrial']/ext-link"
                 priority="101"
                 mode="M8">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@xlink:href"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-clinicaltrial-10-2] Each &lt;ext-link&gt; element must contain @xlink:href. The &lt;ext-link&gt; element in Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' does not.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="starts-with(@xlink:href, 'http://') or starts-with(@xlink:href, 'https://')"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-clinicaltrial-10-3] The value of @xlink:href must start with either "http://" or "https://". The &lt;ext-link&gt; element in Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' is '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="@xlink:href"/>
               <xsl:text>', which does not.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="normalize-space(@xlink:href)=normalize-space(.)"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-clinicaltrial-10-4] The value of @xlink:href must be the same as the element content of &lt;ext-link&gt;. The &lt;ext-link&gt; element in Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has @xlink:href='</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="@xlink:href"/>
               <xsl:text>' and content '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="."/>
               <xsl:text>'.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M8"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M8"/>
   <xsl:template match="@*|node()" priority="-2" mode="M8">
      <xsl:choose><!--Housekeeping: SAXON warns if attempting to find the attribute
                           of an attribute-->
         <xsl:when test="not(@*)">
            <xsl:apply-templates select="node()" mode="M8"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates select="@*|node()" mode="M8"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <!--PATTERN element-citation-software-testselement-citation publication-type="software" Tests-->


	  <!--RULE elem-citation-software-->
   <xsl:template match="element-citation[@publication-type='software']"
                 priority="103"
                 mode="M9">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(person-group)=1"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-software-2-1] Each &lt;element-citation&gt; of type 'software' must contain one and only one &lt;person-group&gt; element. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(person-group)"/>
               <xsl:text> &lt;person-group&gt; elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="person-group[@person-group-type=('author', 'curator')]"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-software-2-2] Each &lt;element-citation&gt; of type 'software' must contain one &lt;person-group&gt; with the attribute person-group-type set to 'author'or 'curator'. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has a &lt;person-group&gt; type of '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron"
                             select="person-group/@person-group-type"/>
               <xsl:text>'.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT error-->
      <xsl:if test="count(data-title)&gt;1">
         <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                      xmlns:osf="http://www.oxygenxml.com/sch/functions">
            <xsl:text>Error:</xsl:text>
            <xsl:text>[err-elem-cit-software-10-1] Each &lt;element-citation&gt; of type 'software' may contain one and only one &lt;data-title&gt; element. Reference '</xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
            <xsl:text>' has </xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(data-title)"/>
            <xsl:text> &lt;data-title&gt; elements.</xsl:text>
         </xsl:message>
      </xsl:if>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(*) = count(person-group| year| data-title| source|version| publisher-name|publisher-loc|ext-link)"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-software-16] The only tags that are allowed as children of &lt;element-citation&gt; with the publication-type="software" are: &lt;person-group&gt;, &lt;year&gt;, &lt;data-title&gt;, &lt;source&gt;, &lt;version&gt;, &lt;publisher-name&gt;, &lt;publisher-loc&gt;, and &lt;ext-link&gt; Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has other elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M9"/>
   </xsl:template>

	  <!--RULE elem-citation-software-data-title-->
   <xsl:template match="element-citation[@publication-type='software']/data-title"
                 priority="102"
                 mode="M9">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(*) = count(sub|sup|italic)"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-software-10-2] An &lt;data-title&gt; element in a reference may contain characters and &lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. No other elements are allowed. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' does not meet this requirement.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M9"/>
   </xsl:template>

	  <!--RULE elem-citation-software-ext-link-->
   <xsl:template match="element-citation[@publication-type='software']/ext-link"
                 priority="101"
                 mode="M9">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@xlink:href"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-software-15-1] Each &lt;ext-link&gt; element must contain @xlink:href. The &lt;ext-link&gt; element in Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' does not.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="starts-with(@xlink:href, 'http://') or starts-with(@xlink:href, 'https://')"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-software-15-2] The value of @xlink:href must start with either "http://" or "https://". The &lt;ext-link&gt; element in Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' is '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="@xlink:href"/>
               <xsl:text>', which does not.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="normalize-space(@xlink:href)=normalize-space(.)"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-software-15-3] The value of @xlink:href must be the same as the element content of &lt;ext-link&gt;. The &lt;ext-link&gt; element in Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has @xlink:href='</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="@xlink:href"/>
               <xsl:text>' and content '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="."/>
               <xsl:text>'.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M9"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M9"/>
   <xsl:template match="@*|node()" priority="-2" mode="M9">
      <xsl:choose><!--Housekeeping: SAXON warns if attempting to find the attribute
                           of an attribute-->
         <xsl:when test="not(@*)">
            <xsl:apply-templates select="node()" mode="M9"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates select="@*|node()" mode="M9"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <!--PATTERN element-citation-preprint-testselement-citation publication-type="preprint" Tests-->


	  <!--RULE elem-citation-preprint-->
   <xsl:template match="element-citation[@publication-type='preprint']"
                 priority="106"
                 mode="M10">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(person-group)=1"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-preprint-2-1] There must be one and only one person-group. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(person-group)"/>
               <xsl:text> &lt;person-group&gt; elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(article-title)=1"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-preprint-8-1] Each &lt;element-citation&gt; of type 'preprint' must contain one and only one &lt;article-title&gt; element. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(article-title)"/>
               <xsl:text> &lt;article-title&gt; elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(source) = 1"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-preprint-9-1] Each &lt;element-citation&gt; of type 'preprint' must contain one and only one &lt;source&gt; element. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(source)"/>
               <xsl:text> &lt;source&gt; elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(pub-id) le 1"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-preprint-10-1] One &lt;pub-id&gt; element is allowed. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(pub-id)"/>
               <xsl:text> &lt;pub-id&gt; elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(pub-id)=1 or count(ext-link)=1"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-preprint-10-3] Either one &lt;pub-id&gt; or one &lt;ext-link&gt; element is required. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(pub-id)"/>
               <xsl:text> &lt;pub-id&gt; elements and </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(ext-link)"/>
               <xsl:text> &lt;ext-link&gt; elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(*) = count(person-group| article-title| source| year| pub-id| ext-link)"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-preprint-13] The only tags that are allowed as children of &lt;element-citation&gt; with the publication-type="preprint" are: &lt;person-group&gt;, &lt;article-title&gt;, &lt;source&gt;, &lt;year&gt;, &lt;pub-id&gt;, and &lt;ext-link&gt;. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has other elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M10"/>
   </xsl:template>

	  <!--RULE elem-citation-preprint-person-group-->
   <xsl:template match="element-citation[@publication-type='preprint']/person-group"
                 priority="105"
                 mode="M10">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@person-group-type='author'"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-preprint-2-2] The &lt;person-group&gt; element must contain @person-group-type='author'. The &lt;person-group&gt; element in Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' contains @person-group-type='</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="@person-group-type"/>
               <xsl:text>'.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M10"/>
   </xsl:template>

	  <!--RULE elem-citation-preprint-pub-id-->
   <xsl:template match="element-citation[@publication-type='preprint']/pub-id"
                 priority="104"
                 mode="M10">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@pub-id-type='doi'"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-preprint-10-2] If present, the &lt;pub-id&gt; element must contain @pub-id-type='doi'. The &lt;pub-id&gt; element in Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' contains @pub-id-type='</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="@pub-id-type"/>
               <xsl:text>'.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M10"/>
   </xsl:template>

	  <!--RULE elem-citation-preprint-ext-link-->
   <xsl:template match="element-citation[@publication-type='preprint']/ext-link"
                 priority="103"
                 mode="M10">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@xlink:href"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-preprint-11-1] Each &lt;ext-link&gt; element must contain @xlink:href. The &lt;ext-link&gt; element in Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' does not.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="starts-with(@xlink:href, 'http://') or starts-with(@xlink:href, 'https://')"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-preprint-11-2] The value of @xlink:href must start with either "http://" or "https://". The &lt;ext-link&gt; element in Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' is '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="@xlink:href"/>
               <xsl:text>', which does not.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="normalize-space(@xlink:href)=normalize-space(.)"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-preprint-11-3] The value of @xlink:href must be the same as the element content of &lt;ext-link&gt;. The &lt;ext-link&gt; element in Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has @xlink:href='</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="@xlink:href"/>
               <xsl:text>' and content '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="."/>
               <xsl:text>'.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M10"/>
   </xsl:template>

	  <!--RULE elem-citation-preprint-article-title-->
   <xsl:template match="element-citation[@publication-type='preprint']/article-title"
                 priority="102"
                 mode="M10">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="./string-length() + sum(*/string-length()) ge 2"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-preprint-8-2-1] A &lt;article-title&gt; element within a &lt;element-citation&gt; of type 'preprint' must contain at least two characters. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has too few characters.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(*)=count(italic | sub | sup)"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-preprint-8-2-2] A &lt;article-title&gt; element within a &lt;element-citation&gt; of type 'preprint' may only contain the child elements&lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. No other elements are allowed. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has disallowed child elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M10"/>
   </xsl:template>

	  <!--RULE elem-citation-preprint-source-->
   <xsl:template match="element-citation[@publication-type='preprint']/source"
                 priority="101"
                 mode="M10">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="./string-length() + sum(*/string-length()) ge 2"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-preprint-9-2-1] A &lt;source&gt; element within a &lt;element-citation&gt; of type 'preprint' must contain at least two characters. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has too few characters.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(*)=count(italic | sub | sup)"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-preprint-9-2-2] A &lt;source&gt; element within a &lt;element-citation&gt; of type 'preprint' may only contain the child elements&lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. No other elements are allowed. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has disallowed child elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M10"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M10"/>
   <xsl:template match="@*|node()" priority="-2" mode="M10">
      <xsl:choose><!--Housekeeping: SAXON warns if attempting to find the attribute
                           of an attribute-->
         <xsl:when test="not(@*)">
            <xsl:apply-templates select="node()" mode="M10"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates select="@*|node()" mode="M10"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <!--PATTERN element-citation-web-testselement-citation publication-type="web" Tests-->


	  <!--RULE elem-citation-web-->
   <xsl:template match="element-citation[@publication-type='web']"
                 priority="106"
                 mode="M11">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(person-group)=1"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-web-2-1] There must be one and only one person-group. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(person-group)"/>
               <xsl:text> &lt;person-group&gt; elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(article-title)=1"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-web-8-1] Each &lt;element-citation&gt; of type 'web' must contain one and only one &lt;article-title&gt; element. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(article-title)"/>
               <xsl:text> &lt;article-title&gt; elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT error-->
      <xsl:if test="count(source) &gt; 1">
         <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                      xmlns:osf="http://www.oxygenxml.com/sch/functions">
            <xsl:text>Error:</xsl:text>
            <xsl:text>[err-elem-cit-web-9-1] Each &lt;element-citation&gt; of type 'web' may contain one and only one &lt;source&gt; element. Reference '</xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
            <xsl:text>' has </xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(source)"/>
            <xsl:text> &lt;source&gt; elements.</xsl:text>
         </xsl:message>
      </xsl:if>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(ext-link)=1"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-web-10-1] One and only one &lt;ext-link&gt; element is required. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(ext-link)"/>
               <xsl:text> &lt;ext-link&gt; elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(date-in-citation)=1"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-web-11-1] One and only one &lt;date-in-citation&gt; element is required. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron"
                             select="count(date-in-citation)"/>
               <xsl:text> &lt;date-in-citation&gt; elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(*) = count(person-group | article-title | source| year| ext-link | date-in-citation)"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-web-12] The only tags that are allowed as children of &lt;element-citation&gt; with the publication-type="web" are: &lt;person-group&gt;, &lt;article-title&gt;, &lt;source&gt;, &lt;year&gt;, &lt;ext-link&gt; and &lt;date-in-citation&gt;. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has other elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M11"/>
   </xsl:template>

	  <!--RULE elem-citation-web-person-group-->
   <xsl:template match="element-citation[@publication-type='web']/person-group"
                 priority="105"
                 mode="M11">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@person-group-type='author'"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-web-2-2] The &lt;person-group&gt; element must contain @person-group-type='author'. The &lt;person-group&gt; element in Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' contains @person-group-type='</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="@person-group-type"/>
               <xsl:text>'.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M11"/>
   </xsl:template>

	  <!--RULE elem-citation-web-ext-link-->
   <xsl:template match="element-citation[@publication-type='web']/ext-link"
                 priority="104"
                 mode="M11">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@xlink:href"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-web-10-2] Each &lt;ext-link&gt; element must contain @xlink:href. The &lt;ext-link&gt; element in Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' does not.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="starts-with(@xlink:href, 'http://') or starts-with(@xlink:href, 'https://')"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-web-10-3] The value of @xlink:href must start with either "http://" or "https://". The &lt;ext-link&gt; element in Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' is '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="@xlink:href"/>
               <xsl:text>', which does not.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="normalize-space(@xlink:href)=normalize-space(.)"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-web-10-4] The value of @xlink:href must be the same as the element content of &lt;ext-link&gt;. The &lt;ext-link&gt; element in Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has @xlink:href='</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="@xlink:href"/>
               <xsl:text>' and content '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="."/>
               <xsl:text>'.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M11"/>
   </xsl:template>

	  <!--RULE elem-citation-web-article-title-->
   <xsl:template match="element-citation[@publication-type='web']/article-title"
                 priority="103"
                 mode="M11">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="./string-length() + sum(*/string-length()) ge 2"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-web-8-2-1] A &lt;article-title&gt; element within a &lt;element-citation&gt; of type 'web' must contain at least two characters. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has too few characters.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(*)=count(italic | sub | sup)"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-web-8-2-2] A &lt;article-title&gt; element within a &lt;element-citation&gt; of type 'web' may only contain the child elements&lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. No other elements are allowed. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has disallowed child elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M11"/>
   </xsl:template>

	  <!--RULE elem-citation-web-source-->
   <xsl:template match="element-citation[@publication-type='web']/source"
                 priority="102"
                 mode="M11">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="./string-length() + sum(*/string-length()) ge 2"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-web-9-2-1] A &lt;source&gt; element within a &lt;element-citation&gt; of type 'web' must contain at least two characters. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has too few characters.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(*)=count(italic | sub | sup)"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-web-9-2-2] A &lt;source&gt; element within a &lt;element-citation&gt; of type 'web' may only contain the child elements&lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. No other elements are allowed. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has disallowed child elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M11"/>
   </xsl:template>

	  <!--RULE elem-citation-web-date-in-citation-->
   <xsl:template match="element-citation[@publication-type='web']/date-in-citation"
                 priority="101"
                 mode="M11">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="./@iso-8601-date"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-web-11-2-2] The &lt;date-in-citation&gt; element must have an @iso-8601-date attribute. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' does not. </xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="matches(./@iso-8601-date,'^\d{4}-\d{2}-\d{2}$')"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-web-11-2-2] The &lt;date-in-citation&gt; element's @iso-8601-date attribute must have the format 'YYYY-MM-DD'. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="@iso-8601-date"/>
               <xsl:text>, which does not have that format. </xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="matches(normalize-space(.),'^(January|February|March|April|May|June|July|August|September|October|November|December) \d{1,2}, \d{4}')"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-web-11-3] The format of the element content must match month, space, day, comma, year. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="."/>
               <xsl:text>.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="format-date(xs:date(@iso-8601-date), '[MNn] [D], [Y]')=."/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-web-11-4] The element content date must match the @iso-8601-date value. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has element content of </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="."/>
               <xsl:text> but an @iso-8601-date value of </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="@iso-8601-date"/>
               <xsl:text>.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M11"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M11"/>
   <xsl:template match="@*|node()" priority="-2" mode="M11">
      <xsl:choose><!--Housekeeping: SAXON warns if attempting to find the attribute
                           of an attribute-->
         <xsl:when test="not(@*)">
            <xsl:apply-templates select="node()" mode="M11"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates select="@*|node()" mode="M11"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <!--PATTERN element-citation-report-testselement-citation publication-type="report" Tests-->


	  <!--RULE elem-citation-report-->
   <xsl:template match="element-citation[@publication-type='report']"
                 priority="106"
                 mode="M12">
      <xsl:variable name="publisher-locations" select="'publisher-locations.xml'"/>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(person-group)=1"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-report-2-1] One and only one person-group element is allowed. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(person-group)"/>
               <xsl:text> &lt;person-group&gt; elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(source)=1"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-report-report-9-1] Each &lt;element-citation&gt; of type 'report' must contain one and only one &lt;source&gt; element. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(source)"/>
               <xsl:text> &lt;source&gt; elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(publisher-name)=1"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-report-11-1] &lt;publisher-name&gt; is required. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(publisher-name)"/>
               <xsl:text> &lt;publisher-name&gt; elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT warning-->
      <xsl:if test="some $p in document($publisher-locations)/locations/location/text()       satisfies ends-with(publisher-name,$p)">
         <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                      xmlns:osf="http://www.oxygenxml.com/sch/functions">
            <xsl:text>Warning:</xsl:text>
            <xsl:text>[warning-elem-cit-report-11-3] The content of &lt;publisher-name&gt; may not end with a publisher location. Reference '</xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
            <xsl:text>' contains the string </xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="publisher-name"/>
            <xsl:text>, which ends with a publisher location.</xsl:text>
         </xsl:message>
      </xsl:if>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(*) = count(person-group| year| source| publisher-loc|publisher-name| ext-link| pub-id)"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-report-15] The only tags that are allowed as children of &lt;element-citation&gt; with the publication-type="report" are: &lt;person-group&gt;, &lt;year&gt;, &lt;source&gt;, &lt;publisher-loc&gt;, &lt;publisher-name&gt;, &lt;ext-link&gt;, and &lt;pub-id&gt;. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has other elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M12"/>
   </xsl:template>

	  <!--RULE elem-citation-report-preson-group-->
   <xsl:template match="element-citation[@publication-type='report']/person-group"
                 priority="105"
                 mode="M12">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@person-group-type='author'"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-report-2-2] Each &lt;person-group&gt; must have a @person-group-type attribute of type 'author'. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has a &lt;person-group&gt; element with @person-group-type attribute '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="@person-group-type"/>
               <xsl:text>'.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M12"/>
   </xsl:template>

	  <!--RULE elem-citation-report-source-->
   <xsl:template match="element-citation[@publication-type='report']/source"
                 priority="104"
                 mode="M12">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="(./string-length() + sum(*/string-length()) ge 2)"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-report-9-2-1] A &lt;source&gt; element within a &lt;element-citation&gt; of type 'report' must contain at least two characters. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has too few characters.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(*)=count(italic | sub | sup)"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-report-9-2-2] A &lt;source&gt; element within a &lt;element-citation&gt; of type 'report' may only contain the child elements&lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. No other elements are allowed. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has child elements that are not allowed.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M12"/>
   </xsl:template>

	  <!--RULE elem-citation-report-publisher-name-->
   <xsl:template match="element-citation[@publication-type='report']/publisher-name"
                 priority="103"
                 mode="M12">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(*)=0"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-report-11-2] No elements are allowed inside &lt;publisher-name&gt;. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has child elements within the &lt;publisher-name&gt; element.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M12"/>
   </xsl:template>

	  <!--RULE elem-citation-report-pub-id-->
   <xsl:template match="element-citation[@publication-type='report']/pub-id"
                 priority="102"
                 mode="M12">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@pub-id-type='doi' or @pub-id-type='isbn'"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-report-12-2] The only allowed pub-id types are 'doi' and 'isbn'. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has a pub-id type of '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="@pub-id-type"/>
               <xsl:text>'.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M12"/>
   </xsl:template>

	  <!--RULE elem-citation-report-ext-link-->
   <xsl:template match="element-citation[@publication-type='report']/ext-link"
                 priority="101"
                 mode="M12">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@xlink:href"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-report-14-1] Each &lt;ext-link&gt; element must contain @xlink:href. The &lt;ext-link&gt; element in Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' does not.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="starts-with(@xlink:href, 'http://') or starts-with(@xlink:href, 'https://')"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-report-14-2] The value of @xlink:href must start with either "http://" or "https://". The &lt;ext-link&gt; element in Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' is '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="@xlink:href"/>
               <xsl:text>', which does not.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="normalize-space(@xlink:href)=normalize-space(.)"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-report-14-3] The value of @xlink:href must be the same as the element content of &lt;ext-link&gt;. The &lt;ext-link&gt; element in Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has @xlink:href='</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="@xlink:href"/>
               <xsl:text>' and content '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="."/>
               <xsl:text>'.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M12"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M12"/>
   <xsl:template match="@*|node()" priority="-2" mode="M12">
      <xsl:choose><!--Housekeeping: SAXON warns if attempting to find the attribute
                           of an attribute-->
         <xsl:when test="not(@*)">
            <xsl:apply-templates select="node()" mode="M12"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates select="@*|node()" mode="M12"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <!--PATTERN element-citation-confproc-testselement-citation publication-type="confproc" Tests-->


	  <!--RULE elem-citation-confproc-->
   <xsl:template match="element-citation[@publication-type='confproc']"
                 priority="109"
                 mode="M13">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(person-group)=1"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-confproc-2-1] One and only one person-group element is allowed. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(person-group)"/>
               <xsl:text> &lt;person-group&gt; elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(article-title)=1"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-confproc-8-1] Each &lt;element-citation&gt; of type 'confproc' must contain one and only one &lt;article-title&gt; element. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(article-title)"/>
               <xsl:text> &lt;article-title&gt; elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(source) le 1"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-confproc-confproc-9-1] Each &lt;element-citation&gt; of type 'confproc' may contain one &lt;source&gt; element. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(source)"/>
               <xsl:text> &lt;source&gt; elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(conf-name)=1"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-confproc-10-1] &lt;conf-name&gt; is required. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(conf-name)"/>
               <xsl:text> &lt;conf-name&gt; elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT error-->
      <xsl:if test="(fpage and elocation-id) or (lpage and elocation-id)">
         <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                      xmlns:osf="http://www.oxygenxml.com/sch/functions">
            <xsl:text>Error:</xsl:text>
            <xsl:text>[err-elem-cit-confproc-12-1] The citation may contain &lt;fpage&gt; and &lt;lpage&gt;, only &lt;fpage&gt;, or only &lt;elocation-id&gt; elements, but not a mixture. Reference '</xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
            <xsl:text>' has </xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(fpage)"/>
            <xsl:text> &lt;fpage&gt; elements, </xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(lpage)"/>
            <xsl:text> &lt;lpage&gt; elements, and </xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(elocation-id)"/>
            <xsl:text> &lt;elocation-id&gt; elements.</xsl:text>
         </xsl:message>
      </xsl:if>

		    <!--REPORT error-->
      <xsl:if test="count(fpage) gt 1 or count(lpage) gt 1 or count(elocation-id) gt 1">
         <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                      xmlns:osf="http://www.oxygenxml.com/sch/functions">
            <xsl:text>Error:</xsl:text>
            <xsl:text>[err-elem-cit-confproc-12-2] The citation may contain no more than one of any of &lt;fpage&gt;, &lt;lpage&gt;, and &lt;elocation-id&gt; elements. Reference '</xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
            <xsl:text>' has </xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(fpage)"/>
            <xsl:text> &lt;fpage&gt; elements, </xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(lpage)"/>
            <xsl:text> &lt;lpage&gt; elements, and </xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(elocation-id)"/>
            <xsl:text> &lt;elocation-id&gt; elements.</xsl:text>
         </xsl:message>
      </xsl:if>

		    <!--REPORT error-->
      <xsl:if test="(lpage and fpage) and (fpage ge lpage)">
         <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                      xmlns:osf="http://www.oxygenxml.com/sch/functions">
            <xsl:text>Error:</xsl:text>
            <xsl:text>[err-elem-cit-confproc-12-3] If both &lt;lpage&gt; and &lt;fpage&gt; are present, the value of &lt;fpage&gt; must be less than the value of &lt;lpage&gt;. Reference '</xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
            <xsl:text>' has &lt;lpage&gt; </xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="lpage"/>
            <xsl:text>, which is less than or equal to &lt;fpage&gt; </xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="fpage"/>
            <xsl:text>.</xsl:text>
         </xsl:message>
      </xsl:if>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(fpage/*)=0 and count(lpage/*)=0"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-confproc-12-4] The content of the &lt;fpage&gt; and &lt;lpage&gt; elements can contain any alpha numeric value but no child elements are allowed. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(fpage/*)"/>
               <xsl:text> child elements in &lt;fpage&gt; and </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(lpage/*)"/>
               <xsl:text> child elements in &lt;lpage&gt;.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(pub-id) le 1"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-confproc-16-1] A maximum of one &lt;pub-id&gt; element is allowed. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(pub-id)"/>
               <xsl:text> &lt;pub-id&gt; elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(*) = count(person-group | article-title | year| source | conf-loc | conf-name | lpage |        fpage | elocation-id | ext-link | pub-id)"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-confproc-17] The only tags that are allowed as children of &lt;element-citation&gt; with the publication-type="confproc" are: &lt;person-group&gt;, &lt;year&gt;, &lt;article-title&gt;, &lt;source&gt;, &lt;conf-loc&gt;, &lt;conf-name&gt;, &lt;fpage&gt;, &lt;lpage&gt;, &lt;elocation-id&gt;, &lt;ext-link&gt;, and &lt;pub-id&gt;. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has other elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M13"/>
   </xsl:template>

	  <!--RULE elem-citation-confproc-preson-group-->
   <xsl:template match="element-citation[@publication-type='confproc']/person-group"
                 priority="108"
                 mode="M13">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@person-group-type='author'"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-confproc-2-2] Each &lt;person-group&gt; must have a @person-group-type attribute of type 'author'. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has a &lt;person-group&gt; element with @person-group-type attribute '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="@person-group-type"/>
               <xsl:text>'.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M13"/>
   </xsl:template>

	  <!--RULE elem-citation-confproc-source-->
   <xsl:template match="element-citation[@publication-type='confproc']/source"
                 priority="107"
                 mode="M13">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="(./string-length() + sum(*/string-length()) ge 2)"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-confproc-9-2-1] A &lt;source&gt; element within a &lt;element-citation&gt; of type 'confproc' must contain at least two characters. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has too few characters.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(*)=count(italic | sub | sup)"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-confproc-9-2-2] A &lt;source&gt; element within a &lt;element-citation&gt; of type 'confproc' may may only contain the child elements&lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. No other elements are allowed. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has child elements that are not allowed.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M13"/>
   </xsl:template>

	  <!--RULE elem-citation-confproc-article-title-->
   <xsl:template match="element-citation[@publication-type='confproc']/article-title"
                 priority="106"
                 mode="M13">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(*) = count(sub|sup|italic)"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-confproc-8-2] An &lt;article-title&gt; element in a reference may contain characters and &lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. No other elements are allowed. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' does not meet this requirement.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M13"/>
   </xsl:template>

	  <!--RULE elem-citation-confproc-conf-name-->
   <xsl:template match="element-citation[@publication-type='confproc']/conf-name"
                 priority="105"
                 mode="M13">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(*)=0"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-confproc-10-2] No elements are allowed inside &lt;conf-name&gt;. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has child elements within the &lt;conf-name&gt; element.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M13"/>
   </xsl:template>

	  <!--RULE elem-citation-confproc-conf-loc-->
   <xsl:template match="element-citation[@publication-type='confproc']/conf-loc"
                 priority="104"
                 mode="M13">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(*)=0"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-confproc-11-2] No elements are allowed inside &lt;conf-loc&gt;. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has child elements within the &lt;conf-loc&gt; element.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M13"/>
   </xsl:template>

	  <!--RULE elem-citation-confproc-fpage-->
   <xsl:template match="element-citation[@publication-type='confproc']/fpage"
                 priority="103"
                 mode="M13">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="matches(normalize-space(.),'^\d.*') or (substring(normalize-space(../lpage),1,1) = substring(normalize-space(.),1,1))"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-confproc-12-5] If the content of &lt;fpage&gt; begins with a letter, then the content of &lt;lpage&gt; must begin with the same letter. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has &lt;fpage&gt;='</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="."/>
               <xsl:text>' and &lt;lpage&gt;='</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="../lpage"/>
               <xsl:text>'.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M13"/>
   </xsl:template>

	  <!--RULE elem-citation-confproc-pub-id-->
   <xsl:template match="element-citation[@publication-type='confproc']/pub-id"
                 priority="102"
                 mode="M13">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@pub-id-type='doi' or @pub-id-type='pmid'"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-confproc-16-2] The only allowed pub-id types are 'doi' pr 'pmid'. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has a pub-id type of '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="@pub-id-type"/>
               <xsl:text>'.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M13"/>
   </xsl:template>

	  <!--RULE elem-citation-confproc-ext-link-->
   <xsl:template match="element-citation[@publication-type='confproc']/ext-link"
                 priority="101"
                 mode="M13">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@xlink:href"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-confproc-14-1] Each &lt;ext-link&gt; element must contain @xlink:href. The &lt;ext-link&gt; element in Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' does not.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="starts-with(@xlink:href, 'http://') or starts-with(@xlink:href, 'https://')"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-confproc-14-2] The value of @xlink:href must start with either "http://" or "https://". The &lt;ext-link&gt; element in Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' is '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="@xlink:href"/>
               <xsl:text>', which does not.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="normalize-space(@xlink:href)=normalize-space(.)"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-confproc-14-3] The value of @xlink:href must be the same as the element content of &lt;ext-link&gt;. The &lt;ext-link&gt; element in Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has @xlink:href='</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="@xlink:href"/>
               <xsl:text>' and content '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="."/>
               <xsl:text>'.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M13"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M13"/>
   <xsl:template match="@*|node()" priority="-2" mode="M13">
      <xsl:choose><!--Housekeeping: SAXON warns if attempting to find the attribute
                           of an attribute-->
         <xsl:when test="not(@*)">
            <xsl:apply-templates select="node()" mode="M13"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates select="@*|node()" mode="M13"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <!--PATTERN element-citation-thesis-testselement-citation publication-type="thesis" Tests-->


	  <!--RULE elem-citation-thesis-->
   <xsl:template match="element-citation[@publication-type='thesis']"
                 priority="107"
                 mode="M14">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(person-group)=1"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-thesis-2-1] One and only one person-group element is allowed. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(person-group)"/>
               <xsl:text> &lt;person-group&gt; elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(collab)=0"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-thesis-3] No &lt;collab&gt; elements are allowed in thesis citations. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(collab)"/>
               <xsl:text> &lt;collab&gt; elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(etal)=0"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-thesis-6] No &lt;etal&gt; elements are allowed in thesis citations. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(etal)"/>
               <xsl:text> &lt;etal&gt; elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(article-title)=1"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-thesis-8-1] Each &lt;element-citation&gt; of type 'thesis' must contain one and only one &lt;article-title&gt; element. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(article-title)"/>
               <xsl:text> &lt;article-title&gt; elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(publisher-name)=1"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-thesis-9-1] &lt;publisher-name&gt; is required. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(publisher-name)"/>
               <xsl:text> &lt;publisher-name&gt; elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(pub-id) le 1"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-thesis-11-1] A maximum of one &lt;pub-id&gt; element is allowed. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(pub-id)"/>
               <xsl:text> &lt;pub-id&gt; elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(*) = count(person-group | article-title | year| source | publisher-loc | publisher-name | ext-link | pub-id)"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-thesis-13] The only tags that are allowed as children of &lt;element-citation&gt; with the publication-type="thesis" are: &lt;person-group&gt;, &lt;year&gt;, &lt;article-title&gt;, &lt;source&gt;, &lt;publisher-loc&gt;, &lt;publisher-name&gt;, &lt;ext-link&gt;, and &lt;pub-id&gt;. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has other elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M14"/>
   </xsl:template>

	  <!--RULE elem-citation-thesis-preson-group-->
   <xsl:template match="element-citation[@publication-type='thesis']/person-group"
                 priority="106"
                 mode="M14">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@person-group-type='author'"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-thesis-2-2] Each &lt;person-group&gt; must have a @person-group-type attribute of type 'author'. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has a &lt;person-group&gt; element with @person-group-type attribute '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="@person-group-type"/>
               <xsl:text>'.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(name)=1"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-thesis-2-3] Each thesis citation must have one and only one author. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has a thesis citation with </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(name)"/>
               <xsl:text> authors.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M14"/>
   </xsl:template>

	  <!--RULE elem-citation-thesis-article-title-->
   <xsl:template match="element-citation[@publication-type='thesis']/article-title"
                 priority="105"
                 mode="M14">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(*) = count(sub|sup|italic)"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-thesis-8-2] An &lt;article-title&gt; element in a reference may contain characters and &lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. No other elements are allowed. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' does not meet this requirement.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M14"/>
   </xsl:template>

	  <!--RULE elem-citation-thesis-publisher-name-->
   <xsl:template match="element-citation[@publication-type='thesis']/publisher-name"
                 priority="104"
                 mode="M14">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(*)=0"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-thesis-9-2] No elements are allowed inside &lt;publisher-name&gt;. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has child elements within the &lt;publisher-name&gt; element.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M14"/>
   </xsl:template>

	  <!--RULE elem-citation-thesis-publisher-loc-->
   <xsl:template match="element-citation[@publication-type='thesis']/publisher-loc"
                 priority="103"
                 mode="M14">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(*)=0"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-thesis-10-2] No elements are allowed inside &lt;publisher-loc&gt;. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has child elements within the &lt;publisher-loc&gt; element.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M14"/>
   </xsl:template>

	  <!--RULE elem-citation-thesis-pub-id-->
   <xsl:template match="element-citation[@publication-type='thesis']/pub-id"
                 priority="102"
                 mode="M14">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@pub-id-type='doi'"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-thesis-11-2] The only allowed pub-id type is 'doi'. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has a pub-id type of '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="@pub-id-type"/>
               <xsl:text>'.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M14"/>
   </xsl:template>

	  <!--RULE elem-citation-thesis-ext-link-->
   <xsl:template match="element-citation[@publication-type='thesis']/ext-link"
                 priority="101"
                 mode="M14">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@xlink:href"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-thesis-12-1] Each &lt;ext-link&gt; element must contain @xlink:href. The &lt;ext-link&gt; element in Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' does not.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="starts-with(@xlink:href, 'http://') or starts-with(@xlink:href, 'https://')"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-thesis-12-2] The value of @xlink:href must start with either "http://" or "https://". The &lt;ext-link&gt; element in Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' is '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="@xlink:href"/>
               <xsl:text>', which does not.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="normalize-space(@xlink:href)=normalize-space(.)"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-thesis-12-3] The value of @xlink:href must be the same as the element content of &lt;ext-link&gt;. The &lt;ext-link&gt; element in Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has @xlink:href='</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="@xlink:href"/>
               <xsl:text>' and content '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="."/>
               <xsl:text>'.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M14"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M14"/>
   <xsl:template match="@*|node()" priority="-2" mode="M14">
      <xsl:choose><!--Housekeeping: SAXON warns if attempting to find the attribute
                           of an attribute-->
         <xsl:when test="not(@*)">
            <xsl:apply-templates select="node()" mode="M14"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates select="@*|node()" mode="M14"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <!--PATTERN element-citation-periodical-testselement-citation publication-type="periodical" Tests-->


	  <!--RULE elem-citation-periodical-->
   <xsl:template match="element-citation[@publication-type='periodical']"
                 priority="108"
                 mode="M15">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(person-group)=1"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-periodical-2-1] Each &lt;element-citation&gt; of type 'periodical' must contain one and only one &lt;person-group&gt; element. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(person-group)"/>
               <xsl:text> &lt;person-group&gt; elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="person-group[@person-group-type='author']"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-periodical-2-2] Each &lt;element-citation&gt; of type 'periodical' must contain one &lt;person-group&gt; with the attribute person-group-type set to 'author'. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has a &lt;person-group&gt; type of '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron"
                             select="person-group/@person-group-type"/>
               <xsl:text>'.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(string-date/year)=1"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-periodical-7-1] There must be one and only one &lt;year&gt; element in a &lt;string-date&gt; element. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(year)"/>
               <xsl:text> &lt;year&gt; elements in the &lt;string-date&gt; element.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(article-title)=1"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-periodical-8-1] Each &lt;element-citation&gt; of type 'periodical' must contain one and only one &lt;article-title&gt; element. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(article-title)"/>
               <xsl:text> &lt;article-title&gt; elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(source)=1"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-periodical-9-1] Each &lt;element-citation&gt; of type 'periodical' must contain one and only one &lt;source&gt; element. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(source)"/>
               <xsl:text> &lt;source&gt; elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(source)=1 and (source/string-length() + sum(descendant::source/*/string-length()) ge 2)"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-periodical-9-2-1] A &lt;source&gt; element within a &lt;element-citation&gt; of type 'periodical' must contain at least two characters. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has too few characters.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(source)=1 and count(source/*)=count(source/(italic | sub | sup))"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-periodical-9-2-2] A &lt;source&gt; element within a &lt;element-citation&gt; of type 'periodical' may only contain the child elements&lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. No other elements are allowed. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has disallowed child elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(volume) le 1"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-periodical-10-1-3] There may be at most one &lt;volume&gt; element within a &lt;element-citation&gt; of type 'periodical'. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(volume)"/>
               <xsl:text> &lt;volume&gt; elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT error-->
      <xsl:if test="lpage and not(fpage)">
         <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                      xmlns:osf="http://www.oxygenxml.com/sch/functions">
            <xsl:text>Error:</xsl:text>
            <xsl:text>[err-elem-cit-periodical-11-1] If &lt;lpage&gt; is present, &lt;fpage&gt; must also be present. Reference '</xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
            <xsl:text>' has </xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(fpage)"/>
            <xsl:text> &lt;fpage&gt; elements, </xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(lpage)"/>
            <xsl:text> &lt;lpage&gt; elements, and </xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(elocation-id)"/>
            <xsl:text> &lt;elocation-id&gt; elements.</xsl:text>
         </xsl:message>
      </xsl:if>

		    <!--REPORT error-->
      <xsl:if test="count(fpage) gt 1 or count(lpage) gt 1">
         <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                      xmlns:osf="http://www.oxygenxml.com/sch/functions">
            <xsl:text>Error:</xsl:text>
            <xsl:text>[err-elem-cit-periodical-11-2] The citation may contain no more than one &lt;fpage&gt; or &lt;lpage&gt; elements. Reference '</xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
            <xsl:text>' has </xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(fpage)"/>
            <xsl:text> &lt;fpage&gt; elements and </xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(lpage)"/>
            <xsl:text> &lt;lpage&gt; elements.</xsl:text>
         </xsl:message>
      </xsl:if>

		    <!--REPORT error-->
      <xsl:if test="(lpage and fpage) and (fpage ge lpage)">
         <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                      xmlns:osf="http://www.oxygenxml.com/sch/functions">
            <xsl:text>Error:</xsl:text>
            <xsl:text>[err-elem-cit-periodical-11-3] If both &lt;lpage&gt; and &lt;fpage&gt; are present, the value of &lt;fpage&gt; must be less than the value of &lt;lpage&gt;. Reference '</xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
            <xsl:text>' has &lt;lpage&gt; </xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="lpage"/>
            <xsl:text>, which is less than or equal to &lt;fpage&gt; </xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="fpage"/>
            <xsl:text>.</xsl:text>
         </xsl:message>
      </xsl:if>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(fpage/*)=0 and count(lpage/*)=0"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-periodical-11-4] The content of the &lt;fpage&gt; and &lt;lpage&gt; elements can contain any alpha numeric value but no child elements are allowed. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(fpage/*)"/>
               <xsl:text> child elements in &lt;fpage&gt; and </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(lpage/*)"/>
               <xsl:text> child elements in &lt;lpage&gt;.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(*) = count(person-group | year | string-date | article-title | source | volume | fpage | lpage)"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-periodical-13] The only tags that are allowed as children of &lt;element-citation&gt; with the publication-type="periodical" are: &lt;person-group&gt;, &lt;year&gt;, &lt;string-date&gt;, &lt;article-title&gt;, &lt;source&gt;, &lt;volume&gt;, &lt;fpage&gt;, and &lt;lpage&gt;. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has other elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(string-date)=1"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-periodical-14-1] There must be one and only one &lt;string-date&gt; element within a &lt;element-citation&gt; of type 'periodical'. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(string-date)"/>
               <xsl:text> &lt;string-date&gt; elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M15"/>
   </xsl:template>

	  <!--RULE elem-citation-periodical-year-->
   <xsl:template match="element-citation[@publication-type='periodical']/string-date/year"
                 priority="107"
                 mode="M15">
      <xsl:variable name="YYYY" select="substring(normalize-space(.), 1, 4)"/>
      <xsl:variable name="current-year" select="year-from-date(current-date())"/>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="./@iso-8601-date"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-periodical-7-2] The &lt;year&gt; element must have an @iso-8601-date attribute. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' does not. </xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="matches(normalize-space(@iso-8601-date),'(^\d{4}-\d{2}-\d{2})|(^\d{4}-\d{2})')"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-periodical-7-3] The @iso-8601-date value must include 4 digit year, 2 digit month, and (optionally) a 2 digit day. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' does not meet this requirement as it contains the value '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="@iso-8601-date"/>
               <xsl:text>'. </xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="matches(normalize-space(.),'(^\d{4}[a-z]?)')"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-periodical-7-4-1] The &lt;year&gt; element in a reference must contain 4 digits, possibly followed by one (but not more) lower-case letter. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' does not meet this requirement as it contains the value '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="."/>
               <xsl:text>'. </xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="(1700 le number($YYYY)) and (number($YYYY) le $current-year)"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-periodical-7-4-2] The numeric value of the first 4 digits of the &lt;year&gt; element must be between 1700 and the current year (inclusive). Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' does not meet this requirement as it contains the value '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="."/>
               <xsl:text>'. </xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="not(./@iso-8601-date) or substring(normalize-space(./@iso-8601-date),1,4) = $YYYY"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-periodical-7-5] The numeric value of the first 4 digits of the @iso-8601-date attribute must match the first 4 digits on the &lt;year&gt; element. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' does not meet this requirement as the element contains the value '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="."/>
               <xsl:text>' and the attribute contains the value '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="./@iso-8601-date"/>
               <xsl:text>'. </xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="not(concat($YYYY, 'a')=.) or (concat($YYYY, 'a')=. and        (some $y in //element-citation/descendant::year        satisfies (normalize-space($y) = concat($YYYY,'b'))        and ancestor::element-citation/person-group[1]/name[1]/surname = $y/ancestor::element-citation/person-group[1]/name[1]/surname)       )"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-periodical-7-6] If the &lt;year&gt; element contains the letter 'a' after the digits, there must be another reference with the same first author surname with a letter "b" after the year. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' does not fulfill this requirement.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="not(starts-with(.,$YYYY) and matches(normalize-space(.),('\d{4}[b-z]'))) or       (some $y in //element-citation/descendant::year        satisfies (normalize-space($y) = concat($YYYY,translate(substring(normalize-space(.),5,1),'bcdefghijklmnopqrstuvwxyz',       'abcdefghijklmnopqrstuvwxy')))        and ancestor::element-citation/person-group[1]/name[1]/surname = $y/ancestor::element-citation/person-group[1]/name[1]/surname)       "/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-periodical-7-7] If the &lt;year&gt; element contains any letter other than 'a' after the digits, there must be another reference with the same first author surname with the preceding letter after the year. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' does not fulfill this requirement.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT error-->
      <xsl:if test=". = preceding::year and        ancestor::element-citation/person-group[1]/name[1]/surname = preceding::year/ancestor::element-citation/person-group[1]/name[1]/surname">
         <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                      xmlns:osf="http://www.oxygenxml.com/sch/functions">
            <xsl:text>Error:</xsl:text>
            <xsl:text>[err-elem-cit-periodical-7-8] Letter suffixes must be unique for the combination of year and first author surname. Reference '</xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
            <xsl:text>' does not fulfill this requirement as it contains the &lt;year&gt; '</xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="."/>
            <xsl:text>' more than once for the same first author surname '</xsl:text>
            <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron"
                          select="ancestor::element-citation/person-group[1]/name[1]/surname"/>
            <xsl:text>'.</xsl:text>
         </xsl:message>
      </xsl:if>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M15"/>
   </xsl:template>

	  <!--RULE elem-citation-periodical-article-title-->
   <xsl:template match="element-citation[@publication-type='periodical']/article-title"
                 priority="106"
                 mode="M15">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(*) = count(sub|sup|italic)"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-periodical-8-2] An &lt;article-title&gt; element in a reference may contain characters and &lt;italic&gt;, &lt;sub&gt;, and &lt;sup&gt;. No other elements are allowed. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' does not meet this requirement.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M15"/>
   </xsl:template>

	  <!--RULE elem-citation-periodical-volume-->
   <xsl:template match="element-citation[@publication-type='periodical']/volume"
                 priority="105"
                 mode="M15">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(*)=0 and (string-length(text()) ge 1)"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-periodical-10-1-2] A &lt;volume&gt; element within a &lt;element-citation&gt; of type 'periodical' must contain at least one character and may not contain child elements. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has too few characters and/or child elements.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M15"/>
   </xsl:template>

	  <!--RULE elem-citation-periodical-fpage-->
   <xsl:template match="element-citation[@publication-type='periodical']/fpage"
                 priority="104"
                 mode="M15">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="matches(normalize-space(.),'^\d.*') or (substring(normalize-space(../lpage),1,1) = substring(normalize-space(.),1,1))"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-periodical-11-4] If the content of &lt;fpage&gt; begins with a letter, then the content of &lt;lpage&gt; must begin with the same letter. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has &lt;fpage&gt;='</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="."/>
               <xsl:text>' and &lt;lpage&gt;='</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="../lpage"/>
               <xsl:text>'.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M15"/>
   </xsl:template>

	  <!--RULE elem-citation-periodical-string-date-->
   <xsl:template match="element-citation[@publication-type='periodical']/string-date"
                 priority="103"
                 mode="M15">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(month)=1 and count(year)=1"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-periodical-14-2] The &lt;string-date&gt; element must include one of each of &lt;month&gt; and &lt;year&gt; elements. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' does not meet this requirement as it contains </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(month)"/>
               <xsl:text> &lt;month&gt; elements and </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(year)"/>
               <xsl:text> &lt;year&gt; elements. </xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(day) le 1"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-periodical-14-3] The &lt;string-date&gt; element may include one &lt;day&gt; element. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' does not meet this requirement as it contains </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="count(day)"/>
               <xsl:text> &lt;day&gt; elements. </xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="(name(child::node()[1])='month' and replace(child::node()[2],'\s+',' ')=' ' and        name(child::node()[3])='day' and replace(child::node()[4],'\s+',' ')=', ' and name(*[position()=last()])='year') or       (name(child::node()[1])='month' and replace(child::node()[2],'\s+',' ')=', ' and name(*[position()=last()])='year')"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-periodical-14-8] The format of the element content must match &lt;month&gt;, space, &lt;day&gt;, comma, &lt;year&gt;, or &lt;month&gt;, comma, &lt;year&gt;. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' has </xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="."/>
               <xsl:text>.</xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M15"/>
   </xsl:template>

	  <!--RULE elem-citation-periodical-month-->
   <xsl:template match="element-citation[@publication-type='periodical']/string-date/month"
                 priority="102"
                 mode="M15">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test=".=('January','February','March','April','May','June','July','August','September','October','November','December')"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-periodical-14-4] The content of &lt;month&gt; must be the month, written out, with correct capitalization. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' does not meet this requirement as it contains the value &lt;month&gt;='</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="."/>
               <xsl:text>'. </xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test=".=format-date(xs:date(../year/@iso-8601-date), '[MNn]')"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-periodical-14-5] The content of &lt;month&gt; must match the content of the month section of @iso-8601-date on the sibling year element. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' does not meet this requirement as it contains the value &lt;month&gt;='</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="."/>
               <xsl:text>' but &lt;year&gt;/@iso-8601-date='</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron"
                             select="../year/@iso-8601-date"/>
               <xsl:text>'. </xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M15"/>
   </xsl:template>

	  <!--RULE elem-citation-periodical-day-->
   <xsl:template match="element-citation[@publication-type='periodical']/string-date/day"
                 priority="101"
                 mode="M15">

		<!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="matches(normalize-space(.),'([1-9])|([1-2][0-9])|(3[0-1])')"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-periodical-14-6] The content of &lt;day&gt;, if present, must be the day, in digits, with no zeroes. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' does not meet this requirement as it contains the value &lt;day&gt;='</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="."/>
               <xsl:text>'. </xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test=".=format-date(xs:date(../year/@iso-8601-date), '[D]')"/>
         <xsl:otherwise>
            <xsl:message xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                         xmlns:osf="http://www.oxygenxml.com/sch/functions">
               <xsl:text>Error:</xsl:text>
               <xsl:text>[err-elem-cit-periodical-14-7] The content of &lt;day&gt;, if present, must match the content of the day section of @iso-8601-date on the sibling year element. Reference '</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="ancestor::ref/@id"/>
               <xsl:text>' does not meet this requirement as it contains the value &lt;day&gt;='</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron" select="."/>
               <xsl:text>' but &lt;year&gt;/@iso-8601-date='</xsl:text>
               <xsl:value-of xmlns="http://purl.oclc.org/dsdl/schematron"
                             select="../year/@iso-8601-date"/>
               <xsl:text>'. </xsl:text>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M15"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M15"/>
   <xsl:template match="@*|node()" priority="-2" mode="M15">
      <xsl:choose><!--Housekeeping: SAXON warns if attempting to find the attribute
                           of an attribute-->
         <xsl:when test="not(@*)">
            <xsl:apply-templates select="node()" mode="M15"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates select="@*|node()" mode="M15"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
</xsl:stylesheet>
