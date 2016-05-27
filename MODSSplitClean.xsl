<?xml version="1.0" encoding="UTF-8"?>
<!-- This XSLT splits files of individual MODS records enclosed within a modsCollection tag into individual records and rename the files with the identifier value--> 
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0" xmlns:mods="http://www.loc.gov/mods/v3">
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
      <xsl:template match="mods:modsCollection/mods:mods">            
        <xsl:result-document method="xml" href="{mods:identifier}.xml">
            <mods xmlns="http://www.loc.gov/mods/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/1999/xlink"
                xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-5.xsd"
                version="3.5">
                <xsl:copy-of select="node()[normalize-space()]|@*[normalize-space()]"/>
            </mods>                          
      </xsl:result-document>
    </xsl:template> 
</xsl:stylesheet>