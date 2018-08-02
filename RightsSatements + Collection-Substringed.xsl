<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mods="http://www.loc.gov/mods/v3" exclude-result-prefixes="mods">
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" media-type="text/xml"/>
    <xsl:strip-space elements="*"/>               
         
    <xsl:template match="node()|@*">
        
        <xsl:copy>
            
            <xsl:apply-templates select="node()[normalize-space()]|@*[normalize-space()]"/>
        </xsl:copy>        
    </xsl:template>
        
         
    <xsl:template match="mods:relatedItem[parent::mods:mods]">
        <xsl:variable name="beulah" select="preceding-sibling::mods:titleInfo/mods:title/text()"/>
        <xsl:copy-of select="."/>
        <relatedItem xmlns="http://www.loc.gov/mods/v3" type="host">
              <titleInfo>
                <title>    
                    <xsl:value-of select="substring-before($beulah, ' events')"/>
                </title>
            </titleInfo>
        </relatedItem>
    </xsl:template>
  
   
    <xsl:template match="mods:accessCondition[parent::mods:mods]">
        <xsl:copy>
            <xsl:attribute name="displayLabel">local</xsl:attribute>
            <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
    </xsl:template>
         
    
    <!-- Adds full second DPLA rights statement . Match element used to be mods:identifier, but this didn't work on some motorsports collections that didn't have an identifier, so changed to mods recordInfo, though this does result in the two accessCondition statements being separated -->
    <xsl:template match="mods:identifier[parent::mods:mods]">
        <xsl:copy-of select="."/>
        <accessCondition xmlns="http://www.loc.gov/mods/v3" type="use and reproduction" xlink:href="http://rightsstatements.org/page/InC/1.0/?language=en" displayLabel="DPLA">This item is protected by copyright and/or related rights. You are free to use this item in any way that is permitted by the copyright and related rights legislation that applies to your use. For other uses you need to obtain permission from the rights-holder(s). For additional information, see http://rightsstatements.org/page/InC/1.0/?language=en.</accessCondition>
    </xsl:template>
        
    
</xsl:stylesheet>