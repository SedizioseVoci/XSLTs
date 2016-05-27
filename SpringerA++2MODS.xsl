<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mods="http://www.loc.gov/mods/v3"
    exclude-result-prefixes="xs" version="2.0">
    <xsl:output indent="yes" method="xml"></xsl:output>
    <!--Extremely inelegant and clunky XSLT for transforming A++ metadata for Springer monographs to MODS.-->
    <xsl:template match="/Publisher">
        <mods:mods
            xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-0.xsd"
            xmlns="http://www.loc.gov/mods/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
                <mods:titleInfo>
                    <mods:title>
                        <xsl:apply-templates select="Series/Book/BookInfo/BookTitle"/>
                    </mods:title>
                </mods:titleInfo>
                <xsl:for-each select="//EditorName | //AuthorName">
                    <mods:name type="personal">
                        <mods:namePart>
                            <xsl:value-of select="FamilyName"></xsl:value-of>
                            <xsl:text>, </xsl:text>
                            <xsl:value-of select="GivenName"></xsl:value-of>
                        </mods:namePart>
                        <mods:role>
                            <xsl:if test="self::AuthorName">
                                <mods:roleTerm type="text">creator</mods:roleTerm>
                            </xsl:if>
                            <xsl:if test="self::EditorName">
                                <mods:roleTerm type="text">editor</mods:roleTerm>
                            </xsl:if>
                        </mods:role>
                    </mods:name>
                </xsl:for-each>
                <mods:originInfo>
                    <mods:place>
                        <mods:placeTerm>
                            <xsl:apply-templates select="PublisherInfo/PublisherLocation"/>
                        </mods:placeTerm>
                    </mods:place>
                    <mods:publisher>
                        <xsl:apply-templates select="PublisherInfo/PublisherName"/>
                    </mods:publisher>
                    <mods:dateCreated encoding="w3cdtf" keyDate="yes">
                        <xsl:apply-templates select="Series/Book/BookInfo/BookEdition"/>
                    </mods:dateCreated>                    
                </mods:originInfo>
                <physicalDescription>
                    <mods:extent>1 online resource : illustrations</mods:extent>
                </physicalDescription>
                <mods:note type="bibliography">Includes bibliographical references.</mods:note>
                <xsl:for-each select="//BookSubject">
                    <mods:subject>
                        <mods:topic>
                            <xsl:value-of select="."></xsl:value-of>
                        </mods:topic>
                    </mods:subject>
                </xsl:for-each>
                <mods:relatedItem type="series">
                    <titleInfo>
                        <title>
                            <xsl:apply-templates select="Series/SeriesInfo/SeriesTitle"/>
                        </title>
                    </titleInfo>
                </mods:relatedItem>
                <mods:identifier type="isbn">
                    <xsl:apply-templates select="Series/Book/BookInfo/BookElectronicISBN"/>
                </mods:identifier>
                <mods:genre authority="aat">monographs</mods:genre>
                <mods:typeOfResource>text</mods:typeOfResource>
                <mods:recordInfo>
                <mods:recordContentSource authority="oclcorg">NKM</mods:recordContentSource>
                <mods:languageOfCataloging>
                    <mods:languageTerm authority="iso639-2b">eng</mods:languageTerm>
                </mods:languageOfCataloging>
            </mods:recordInfo>
        </mods:mods>
    </xsl:template>
</xsl:stylesheet>