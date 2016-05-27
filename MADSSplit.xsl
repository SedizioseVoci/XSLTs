<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:mads="http://www.loc.gov/mads/v2">
    <!-- This XSLT splits files of individual MADS records enclosed within a madsCollection tag into individual MADS records and renames them with the recordIdentifier value.-->  
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
    <xsl:template match="mads:madsCollection/mads:mads">
        <xsl:result-document method="xml" href="{mads:recordInfo/mads:recordIdentifier}.xml">
            <mads:mads xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:mads="http://www.loc.gov/mads/v2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.0" xsi:schemaLocation="http://www.loc.gov/mads/ http://www.loc.gov/standards/mads/mads.xsd http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-2.xsd">
                <xsl:copy-of select="*"/>
            </mads:mads>
        </xsl:result-document>
    </xsl:template> 
</xsl:stylesheet>