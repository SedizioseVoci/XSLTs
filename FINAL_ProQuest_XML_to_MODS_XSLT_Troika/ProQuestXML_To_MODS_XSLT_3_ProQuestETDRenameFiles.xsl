<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0" xmlns:mods="http://www.loc.gov/mods/v3">
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
    <!-- Part III of 3-part XSLT suite for processing incoming ProQuest XML ETD records for Niner Commons; this part renames the files with the value of the identifier element, in other words the filename; to be used with Part I. ProQuestXML_To_MODS_1_ProQuestETD2MODS and Part II. ProQuestXML_To_MODS_XSLT_2_ProQuestETDCleanup. JRN 2022-06-09  -->
   
   
    <xsl:template match="mods:mods">
        <xsl:result-document method="xml" href="{mods:identifier}.xml">
            <mods:mods xmlns="http://www.loc.gov/mods/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/1999/xlink"
                xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-7.xsd"
                version="3.7">                 
                <xsl:copy-of select="*"/>
            </mods:mods>
        </xsl:result-document>
    </xsl:template> 
 
   
    
</xsl:stylesheet>