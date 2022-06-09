<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0" xmlns:mods="http://www.loc.gov/mods/v3">
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
    <!-- Outputs records lacking a FAST subject topical term after ProQuest ETD transformation JRN 2021-08-18 -->
    <xsl:variable name="boosha" select="mods:mods/mods:subject[@authority='fast']"/>
    <xsl:template match="mods:mods">
       <xsl:if test="not($boosha)">
        <xsl:result-document method="xml" href="{mods:identifier}.xml">
            <mods xmlns="http://www.loc.gov/mods/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-7.xsd"
                version="3.7">
                <xsl:copy-of select="*"/>
            </mods>
        </xsl:result-document>
       </xsl:if>
    </xsl:template> 
</xsl:stylesheet>