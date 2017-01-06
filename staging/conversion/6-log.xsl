<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- 
        <p:documentation>
            <h2>Import reporting</h2>
            <p>This step generates a report in markdown format showing the proportion between previously existing and newly added entries.</p>
        </p:documentation>
    -->
    
    <xsl:strip-space elements="*"/>
    
    <xsl:param name="comparisonBase"/>
    
    <xsl:variable name="files" select="collection(concat('../../',$comparisonBase,'/?select=wl-*.xml'))"/>
    <xsl:variable name="categories">
        <category>general</category>
        <category>monthsDays</category>
        <category>geography</category>
        <category>persons</category>
        <category>religion</category>
    </xsl:variable>
    <xsl:variable name="rootNode" select="/"/>
    
    <xsl:template match="/">
        <md-wrapper>
         <!--<xsl:result-document href="output/foo.txt" method="text">-->
<xsl:text>
# WL Import Report </xsl:text><xsl:value-of select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/><xsl:text>

*Check this report for sanity. If all looks good replace `current` directory by `output` directory and create a commit.*
</xsl:text>
            <xsl:if test="not($comparisonBase = 'current')">
<xsl:text>

**CAUTION: Reporting based on test dataset**

</xsl:text>
            </xsl:if>
            
<xsl:text>
## Number of files/lemmata before and after import

</xsl:text>
<xsl:text>
### Greek 

</xsl:text>
            <xsl:call-template name="count-table-by-category">
                <xsl:with-param name="language" select="'grc'"/>
            </xsl:call-template>
            <xsl:text>
</xsl:text>
<xsl:text>
### Latin 

</xsl:text>
            <xsl:call-template name="count-table-by-category">
                <xsl:with-param name="language" select="'la'"/>
            </xsl:call-template>
            <xsl:text>
</xsl:text>
<xsl:text>
## New files/lemmata

</xsl:text>
            <xsl:if test="not($comparisonBase = 'current')">
<xsl:text>

**CAUTION: Reporting based on test dataset (restricted input, restricted base for comparison) – many of the following entries are not new**

</xsl:text>
            </xsl:if>
            <xsl:apply-templates/>
            
            <!--</xsl:result-document>-->
        </md-wrapper>
    </xsl:template>
    
    <xsl:template match="*:grc">
<xsl:text>
### Greek 

</xsl:text>
        <xsl:call-template name="entry-table-by-category"/>
    </xsl:template>
    
    <xsl:template match="*:la">
<xsl:text>
### Latin 

</xsl:text>
        <xsl:call-template name="entry-table-by-category"/>
    </xsl:template>
    
    <xsl:template name="entry-table-by-category">
        <xsl:for-each-group select="*:TEI" group-by="*:text/*:body/*:div/@type">
<xsl:text>#### Type: </xsl:text><xsl:value-of select="*:text/*:body/*:div/@type"/><xsl:text>
</xsl:text>
<xsl:text>
| Lemma        | WL ID | FileMaker RecordId | references |
| -----------|-------------|-------------|-------------|
</xsl:text>
            <xsl:for-each select="current-group()/*:teiHeader[//*:change[contains(text(),'Neuanlage')]]">
<xsl:text>| </xsl:text>
                <xsl:value-of select="parent::*:TEI/*:text//*:entry/*:form/*:orth[@type='original']"/>
<xsl:text>| </xsl:text>
                <xsl:value-of select="parent::*:TEI/*:text//*:entry/@xml:id"/>
<xsl:text>| </xsl:text>
                <xsl:value-of select="parent::*:TEI/*:text//*:entry/*:form/*:idno[@type='fp7']"/>
<xsl:text>| </xsl:text>
                <xsl:for-each select="parent::*:TEI/*:text//*:entry/*:xr/*:list/*:item">
<xsl:text>`</xsl:text><xsl:value-of select="*:ref"/><xsl:text>`</xsl:text>                    
                </xsl:for-each>
<xsl:text>|
</xsl:text>
            </xsl:for-each>            
        </xsl:for-each-group>
    </xsl:template>
    
    <xsl:template name="count-table-by-category">
        <xsl:param name="language"/>
<xsl:text>
| category        | count before import | count after import | difference | difference (%) |
| :-----------: |-------------:|-------------:|-------------:|-------------:|
</xsl:text>
        <xsl:for-each select="$categories/*:category">
            <xsl:variable name="count-old" select="count($files//*:TEI[//*:div[@type=current()]/*:entry[contains(@xml:id,$language)]])"/>
            <xsl:variable name="count-new" select="count($rootNode/*:wl-wrapper/*[local-name()=$language]/*:TEI/*:text/*:body/*:div[@type=current()])"/>
<xsl:text>| </xsl:text>
            <xsl:value-of select="current()"/>
<xsl:text>| </xsl:text>
            <xsl:value-of select="$count-old"/>
<xsl:text>| </xsl:text>
            <xsl:value-of select="$count-new"/>
<xsl:text>| </xsl:text>
            <xsl:value-of select="$count-new - $count-old"/>
<xsl:text>| </xsl:text>
            <xsl:choose>
                <xsl:when test="$count-old gt 0">
                    <xsl:variable name="difference" select="$count-new div $count-old * 100"/>
                    <xsl:if test="$difference gt 100"><xsl:text>+</xsl:text></xsl:if>
                    <xsl:value-of select="$difference - 100"/>         
                </xsl:when>
                <xsl:otherwise>(infinite)</xsl:otherwise>
            </xsl:choose>
<xsl:text>| 
</xsl:text>
        </xsl:for-each>
<xsl:text>| **Total**     |</xsl:text>
        <xsl:value-of select="count($files//*:TEI[//*:entry[contains(@xml:id,$language)]])"/>
<xsl:text>| **</xsl:text>
        <xsl:value-of select="count(*:wl-wrapper/*[local-name()=$language]/*:TEI)"/>
<xsl:text>** |</xsl:text>
        <xsl:value-of select="count(*:wl-wrapper/*[local-name()=$language]/*:TEI) - count($files//*:TEI[//*:entry[contains(@xml:id,$language)]])"/>
<xsl:text>|</xsl:text> 
        <xsl:choose>
            <xsl:when test="count($files//*:TEI[//*:entry[contains(@xml:id,$language)]]) gt 0">
                <xsl:variable name="difference" select="count(*:wl-wrapper/*[local-name()=$language]/*:TEI) div count($files//*:TEI[//*:entry[contains(@xml:id,$language)]]) * 100"/>
                <xsl:if test="$difference gt 100"><xsl:text>+</xsl:text></xsl:if>
                <xsl:value-of select="$difference - 100"/>         
            </xsl:when>
            <xsl:otherwise>(infinite)</xsl:otherwise>
        </xsl:choose>
<xsl:text>|</xsl:text>
    </xsl:template>
    
</xsl:stylesheet>