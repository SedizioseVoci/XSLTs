<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
version="2.0" xmlns:mods="http://www.loc.gov/mods/v3">
<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
<!-- Outputs records in Oxygen project with specified problem DEIA terms in the FAST topical subject element; preserves original filename; inserts updated MODS root element, 3.7 - template XSLT for DEIA audit project 2022-05-20 JRN -->
<xsl:variable name="probterm1" select="mods:mods/mods:subject/mods:topic/text()"/>  
<xsl:template match="mods:mods">
    <xsl:if test="$probterm1 = ('African American universities and colleges','Albinos and albinism','American poetry--Indian authors','Criminals','Antifa (Organisation)','Argentina--History--Dirty War, 1976-1983','Asian flu','Bildungsromans','Boat people','Bossiness','Brazil--History--Revolution, 1964','Brothers and sisters','Child pornography','Children of egg donors','Children of sperm donors','Chinese New Year','Climatic changes','Criminals','Crystalline lens','Defloration','Discovery and exploration','Domestic relations','Dwarfs (Persons)','East Indians','Eskimos',
        'Fetishism','Fugitive slaves','Future life','Gays','Gender-nonconforming people','God (Islam)','Hearing impaired','Hispanic Americans','Homeless persons','Husband and wife','Illegal immigration','Illegitimacy','Illegitimate children','Indians of North America','Inmates of institutions','Invalids','Juvenile delinquents','Kings and rulers','Lebanon--History--Israeli intervention, 1982-1985','Manic-depressive illness','Oriental literature','Orientalism','Palestinian Arabs','Parolees','People with mental disabilities','People with social disabilities','Poor','Popular music--South Korea--2011-2020','Pregnant women','Primitive art','Primitive societies','Prisoners','Problem children','Problem youth','Race','Race relations','Race riots','Racially mixed people','Schizophrenics','Sexual minorities','Sexual reorientation programs','Slaves','Slavery','Slaveholders','Social disabilities','Tenth of Muḥarram','Tramps','Triangles (Interpersonal relations)','Unskilled labor','Victims','Word recognition')">
        <xsl:result-document method="xml">
            <mods:mods xmlns="http://www.loc.gov/mods/v3"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-7.xsd"
                version="3.7">
                <xsl:copy-of select="*"/>
            </mods:mods>
        </xsl:result-document>
    </xsl:if>
</xsl:template> 
</xsl:stylesheet>