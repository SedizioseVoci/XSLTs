<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mods="http://www.loc.gov/mods/v3" exclude-result-prefixes="mods">
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" media-type="text/xml"/>
    
    <!-- This XSLT 'cookbook' demonstrates a number of elements and functions that can be used to modify and process SCUA MODS metadata records. JN 3-21-2018 -->
    
    <!-- Inserting this strip-space element at the top of the XSLT will ensure that empty lines are stripped out -->
    <xsl:strip-space elements="*"/>
    <xsl:template match="*[not(node())]"/>  
    
       
    <!-- This param applies a substring function that snips off birthdates and death dates from values in elements identified in template match below. The param should be at the top of the XSLT, above the identity transform element. The element that is identified below with the template 'lulie' is fed into the 'inez' substring-replace function. -->
    <xsl:template name="lulie_sue">
        <xsl:param name="inez"/>
        <xsl:value-of select="substring-before($inez, ', 1')"/>
    </xsl:template>
    
    <!-- Another set of params for uppercasing an specified element. Further down, a template match identifies the MODS element that is to be uppercased (the title). The param name is called, and the value of that element (title) is fed into the translate function and processed. -->
    <xsl:param name="smallcase" select="'abcdefghijklmnopqrstuvwxyz'" />
    <xsl:param name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
        
    <xsl:template name="uppercase">
        <xsl:param name="value"/>
        <xsl:value-of select="translate($value, $smallcase, $uppercase)"/>
    </xsl:template>
          
    <!-- Example of XSLT variable. Variable is given a name; in the 'text' element, the variable value is provided. The variable should be at the top of the XSLT, above the identify transform. A template further down in the stylesheet identifies the specific MODS element that the variable will be applied to. When the name of the variable is given, the value identified here will be inserted, replacing any value that is already in the element -->
    <xsl:variable name="beulah">
        <xsl:text>North Carolina Digital Heritage Center</xsl:text>
    </xsl:variable>
    
    <!-- This is the identity transform piece that copies the entire body of the XML document being processed. The templates above and below make further changes to the XML document; those changes will be incorporated into the copy of the document that the identity transform makes. The identity transform CANNOT BE EXCLUDED from the XSLT; if it is, the output of the XSLT will be blank, and no changes will take place. -->
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()[normalize-space()]|@*[normalize-space()]"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Param template 'lulie sue' at top of stylesheet is called. The template match identifies the element value that will be fed into the 'inez' substring function, the name subjects -->
    <xsl:template match="mods:subject/mods:name[@type='personal']/mods:namePart/text()">    
        <xsl:call-template name="lulie_sue">
            <xsl:with-param name="inez" select="."/>
        </xsl:call-template>
    </xsl:template>
    
    <!-- Example of XSLT choose function. The template match identifies the MODS element that the choose function will act on: the geographic subject in this case. At this point, the XSLT will replace the North Carolina Concord value with North Carolina Charlotte. Values that don't match North Carolina Concord will be changed to North Carolina Rockingham -->
    <xsl:template match="mods:subject/mods:geographic/text()">
        <xsl:choose>
            <xsl:when test=".='North Carolina--Concord'">North Carolina--Charlotte</xsl:when>
            <xsl:otherwise>North Carolina--Rockingham</xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Example of XSLT 'if' function. This is essentially a simpler version of the 'choose' function. The template match identifies the MODS element the XSLT will match on (in this case geographic subjects). At that point, if the XSLT finds a certain variable in that element (North Carolina Concord here), it will change it to another variable, in this case North Carolina Charlotte. All other values will be left unchanged. -->
    <xsl:template match="mods:subject/mods:geographic/text()">
        <xsl:if test=".='North Carolina--Concord'">North Carolina--Charlotte</xsl:if>
    </xsl:template>
    
    <!-- This function changes the value of an element to another value, no matter what the original value in that element might have been  -->
    <xsl:template match="mods:typeOfResource[parent::mods:mods]/text()">still image</xsl:template>
    
    <!-- This element changes the name of an element (in this case genre) to something different (typeOfResource in this example) -->
    <xsl:template match="mods:genre[parent::mods:mods]">
        <typeOfResource><xsl:apply-templates select="@* | node()"/></typeOfResource>
    </xsl:template>
    
    <!-- This function simply strips out an identified element from the XML document, in this case the physicalDescription element and all subelements -->
    <xsl:template match="mods:physicalDescription[parent::mods:mods]"/>
        
    <!-- This template match identifies the title as the data to be acted on by the uppercasing param function at top of the XSLT. Calling on the param value 'value' feeds the title into the param function above, uppercasing it. -->
    <xsl:template match="mods:titleInfo/mods:title/text()">
       <xsl:call-template name="uppercase">
           <xsl:with-param name="value" select="."/>
       </xsl:call-template>
    </xsl:template>
    
    <!-- This function changes the value of an attribute in a specified element, in this case 'local,' to something different, 'isbn' -->
    <xsl:template match="mods:identifier[parent::mods:mods]/@type[.='local']">
        <xsl:attribute name="local"><xsl:value-of select="'isbn'"/></xsl:attribute>
    </xsl:template>
    
    <!-- This function adds an additional attribute and value to a specified element (accessCondition in this case) -->
    <xsl:template match="mods:accessCondition[parent::mods:mods][1]">
        <xsl:copy>
            <xsl:attribute name="displayLabel">local</xsl:attribute>
            <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
    </xsl:template>
    
    <!-- This function simply inserts a new element in the XML MODS below the element indicated in the template match. In this case, a second relatedItem element with a collection name is inserted. -->
    <xsl:template match="mods:relatedItem[parent::mods:mods]">
        <xsl:copy-of select="."/>
        <relatedItem xmlns="http://www.loc.gov/mods/v3" type="host">
            <titleInfo>
                <title>1974 Daytona 500</title>
            </titleInfo>
        </relatedItem>
    </xsl:template>
    
    <!-- Similar to the function exemplified immediately above, this function adds a new rights statement after the identifier element -->
    <xsl:template match="mods:identifier[parent::mods:mods]">
        <xsl:copy-of select="."/>
        <accessCondition xmlns="http://www.loc.gov/mods/v3" type="use and reproduction" xlink:href="http://rightsstatements.org/page/InC/1.0/?language=en" displayLabel="DPLA">This item is protected by copyright and/or related rights. You are free to use this item in any way that is permitted by the copyright and related rights legislation that applies to your use. For other uses you need to obtain permission from the rights-holder(s). For additional information, see http://rightsstatements.org/page/InC/1.0/?language=en.</accessCondition>
    </xsl:template>
           
    <!-- Here the stylesheet identifies the element, in this case the publisher element, whose value will be replaced with the variable identified at the top of the XSLT. -->
    <xsl:template match="mods:originInfo/mods:publisher/text()">
        <xsl:value-of select="$beulah"/>
    </xsl:template>
    
</xsl:stylesheet>