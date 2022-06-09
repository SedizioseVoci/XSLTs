<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0" xmlns:mods="http://www.loc.gov/mods/v3">
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
    <!-- Part II of 3-part XSLT suite for processing incoming ProQuest XML ETDs for Niner Commons; this part removes duplicate subject headings applied by ProQuestXML_To_MODS_XSLT_1_ProQuestETD2MODS 1 and straightens out spacing in role terms in name elements and extent; to be followed by Part III, ProQuestXML_To_MODS_XSLT_3_ProQuestETDRenameFiles, which renames the files with the identifier element. JRN 2022-06-09 -->
    
    <xsl:template match="node()|@*">
        <xsl:if test="not(node()) or not(following-sibling::node()[.=string(current())])">
            <xsl:copy>
                <xsl:apply-templates select="node()[normalize-space()]|@*[normalize-space()]"/>
            </xsl:copy>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="/mods:mods/mods:name/mods:role/mods:roleTerm/text()">
        <xsl:value-of select="normalize-space()"/>
    </xsl:template>
    
    <xsl:template match="/mods:mods/mods:physicalDescription/mods:extent/text()">
        <xsl:value-of select="normalize-space()"/>
    </xsl:template>
    
</xsl:stylesheet>