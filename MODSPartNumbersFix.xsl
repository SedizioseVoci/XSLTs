<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:mods="http://www.loc.gov/mods/v3" exclude-result-prefixes="mods">
    <!--This XSLT appends MODS part numbers to the titleInfo element and strips away empty nodes.-->
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" media-type="text/xml"/>
    <xsl:strip-space elements="*"/>
    <xsl:template match="*[not(node())]"/>    
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()[normalize-space()]|@*[normalize-space()]"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="mods:titleInfo[parent::mods:mods]">
        <xsl:copy>
            <xsl:element name="title" namespace="http://www.loc.gov/mods/v3">
                <xsl:value-of select="mods:title"/>
                <xsl:text>&#160;</xsl:text>
                <xsl:value-of select="mods:partNumber"/>
            </xsl:element>
            <xsl:element name="partNumber" namespace="http://www.loc.gov/mods/v3">
                <xsl:value-of select="mods:partNumber"/>
            </xsl:element>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>