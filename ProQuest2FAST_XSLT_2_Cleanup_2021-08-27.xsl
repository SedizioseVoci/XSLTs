<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:mods="http://www.loc.gov/mods/v3" version="2.0" exclude-result-prefixes="mods">
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" media-type="text/xml"/>
    <xsl:strip-space elements="*"/>
    
    <!-- Removes elements with duplicate values, such as topical subject headings that appear twice; adds note to recordInfo indicating changes made with this two-part transformation JRN 2021-08-20 -->
    
    <xsl:template match="node()|@*">
        <xsl:if test="not(node()) or not(following-sibling::node()[.=string(current())])">
            <xsl:copy>
                <xsl:apply-templates select="node()[normalize-space()]|@*[normalize-space()]"/>
            </xsl:copy>
        </xsl:if>
    </xsl:template>
    
    <!-- Replaces empty namespace attribute with mods namespace attribute in elements that have a blank '' for that attribute value JRN 2021-08-15 -->
    
    <xsl:template match="*[namespace-uri()='']">
        <xsl:element name="{local-name(.)}" namespace="http://www.loc.gov/mods/v3">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>
    
    <!-- Adds note indicating changes to recordInfo element JRN 2021-08-20 -->
    
    <xsl:template match="mods:recordInfo[parent::mods:mods]">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <mods:recordInfoNote xmlns="http://www.loc.gov/mods/v3">Metadata remediated 9-2021 via XSLT: ProQuest subject vocabulary terms replaced with FAST subject terms; keywords lowercased; relatedItem mods prefix added.</mods:recordInfoNote>
        </xsl:copy>
    </xsl:template>
     
 </xsl:stylesheet>