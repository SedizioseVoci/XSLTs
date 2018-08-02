<xsl:stylesheet xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="xlink" version="2.0">
	<xsl:output encoding="UTF-8" indent="yes" method="xml" standalone="yes"></xsl:output>
	<!-- top level elements ELEMENT DISS_description (DISS_title,DISS_dates,DISS_degree,(DISS_institution),(DISS_advisor)*,DISS_cmte_member*,DISS_categorization)>
    -->
	
	
	<xsl:param name="graduationSemester"></xsl:param>
	<xsl:variable name="smallcase" select="'abcdefghijklmnopqrstuvwxyz'"></xsl:variable>
	<xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"></xsl:variable>
	<xsl:template name="replace">
		<xsl:param name="text"></xsl:param>
		<xsl:param name="replace"></xsl:param>
		<xsl:param name="by"></xsl:param>
		<xsl:choose>
			<xsl:when test="contains($text, $replace)">
				<xsl:value-of select="substring-before($text,$replace)"></xsl:value-of>
				<xsl:value-of select="$by"></xsl:value-of>
				<xsl:call-template name="replace">
					<xsl:with-param name="text" select="substring-after($text,$replace)"></xsl:with-param>
					<xsl:with-param name="replace" select="$replace"></xsl:with-param>
					<xsl:with-param name="by" select="$by"></xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$text"></xsl:value-of>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- Template for comma delimited lists -->
	<xsl:template match="DISS_keyword">
		<xsl:choose>
			<xsl:when test="string(.)">
				<xsl:call-template name="output-tokens">
					<xsl:with-param name="list">
						<xsl:value-of select="text()"></xsl:value-of>
					</xsl:with-param>
					<xsl:with-param name="delimiter">,</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="output-tokens">
		<xsl:param name="list"></xsl:param>
		<xsl:param name="delimiter"></xsl:param>
		<xsl:variable name="newlist">
			<xsl:choose>
				<xsl:when test="contains($list, $delimiter)">
					<xsl:value-of select="normalize-space($list)"></xsl:value-of>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat(normalize-space($list), $delimiter)"
					></xsl:value-of>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="first" select="substring-before($newlist, $delimiter)"></xsl:variable>
		<xsl:variable name="remaining" select="substring-after($newlist, $delimiter)"></xsl:variable>
		<mods:subject xmlns="http://www.loc.gov/mods/v3" authority="local">
			<mods:topic>
				<xsl:value-of select="$first"></xsl:value-of>
			</mods:topic>
		</mods:subject>
		<xsl:if test="$remaining">
			<xsl:call-template name="output-tokens">
				<xsl:with-param name="list" select="$remaining"></xsl:with-param>
				<xsl:with-param name="delimiter">
					<xsl:value-of select="$delimiter"></xsl:value-of>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="/">
    
		<!-- <xsl:choose>-->
		<!-- <xsl:when test="//DISS_collection">
				 <modsCollection xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-6.xsd">
					<xsl:for-each select="//DISS_collection/DISS_submission">
						<mods version="3.6">
							<xsl:call-template name="DISS_submission"/>
						</mods>
					</xsl:for-each>
				</modsCollection>
			<xsl:otherwise>-->
		<mods:mods xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-6.xsd">
			<xsl:for-each select="//DISS_submission">
				
					<xsl:call-template name="DISS_submission"></xsl:call-template>
				
			</xsl:for-each>
		</mods:mods>
		<!-- </xsl:otherwise>
            </xsl:when>
		</xsl:choose>-->
	</xsl:template>
	<!--AUTHOR INFORMATION: NAME-->
	<xsl:template name="DISS_submission">
		<xsl:for-each select="DISS_authorship">
			<xsl:for-each select="DISS_author">
				<xsl:for-each select="DISS_name">
					<mods:name type="personal">
						<mods:namePart>
							<!-- Edited order of name elements to create correct inverted display JN 3/2017 -->
							<xsl:value-of select="DISS_surname"></xsl:value-of>
							<xsl:text>, </xsl:text>
							<xsl:value-of select="DISS_fname"></xsl:value-of>											
							<xsl:text></xsl:text>
							<xsl:value-of select="DISS__middle"> </xsl:value-of>
						</mods:namePart>
						<mods:role>
							<mods:roleTerm authority="marcrelator" type="text"
								>Creator</mods:roleTerm>
						</mods:role>
						<xsl:for-each select="//DISS_description/DISS_institution">
							<!-- start cleaning up the department -->
							<xsl:variable name="deptStart" select="DISS_inst_contact"></xsl:variable>
							<!-- remove everything after colon -->
							<xsl:variable name="deptSansColon">
								<xsl:choose>
									<xsl:when test="contains($deptStart, ':')">
										<xsl:value-of select="substring-before($deptStart, ':')"
										></xsl:value-of>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="$deptStart"></xsl:value-of>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<!-- replace ampersands with the word 'and' -->
							<xsl:variable name="deptExpandAmp">
								<xsl:call-template name="replace">
									<xsl:with-param name="text" select="$deptSansColon"></xsl:with-param>
									<xsl:with-param name="replace" select="'&amp;'"></xsl:with-param>
									<xsl:with-param name="by" select="'and'"></xsl:with-param>
								</xsl:call-template>
							</xsl:variable>
							<!-- make sure the department is in the proquest vocabulary? -->
							<mods:affiliation>
								<xsl:value-of select="DISS_inst_name"></xsl:value-of>
								<xsl:text>: </xsl:text>
								<xsl:value-of select="normalize-space($deptExpandAmp)"
								></xsl:value-of>
							</mods:affiliation>
						</xsl:for-each>
					</mods:name>
				</xsl:for-each>
			</xsl:for-each>
		</xsl:for-each>
		<xsl:if test="DISS_author/DISS_orcid">
			<mods:nameIdentifier type="orcid">
				<xsl:text></xsl:text>
				<xsl:value-of select="DISS_author/DISS_orcid"></xsl:value-of>
			</mods:nameIdentifier>
		</xsl:if>
		<!--TITLE and ABSTRACT INFORMATION: TITLEINFO and ABSTRACT-->
		<!--Uppercased all titles JN 3/2017 -->
		<xsl:for-each select="DISS_description">
		<xsl:variable name="smallcase" select="'abcdefghijklmnopqrstuvwxyz'" />
		<xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
		<mods:titleInfo>
				<mods:title>
					<xsl:value-of select="translate(DISS_title, $smallcase, $uppercase)"></xsl:value-of>
				</mods:title>		
		</mods:titleInfo>
		</xsl:for-each>
		<xsl:for-each select="DISS_content">
			
			<mods:abstract>
				<xsl:for-each select="DISS_abstract/DISS_para">
					<xsl:value-of select="."></xsl:value-of>
				</xsl:for-each>
			</mods:abstract>
			<mods:identifier type="local">
				<!--Added substring function to strip file type off identifier  JN 3/2017 -->
				<xsl:for-each select="DISS_binary">										
				<xsl:value-of select="substring-before(., '.pdf')"></xsl:value-of>
				</xsl:for-each>
	          </mods:identifier>
		</xsl:for-each>
		<!--PUBLICATION INFORMATION: ORIGININFO -->
		<!-- Taking this part out.  <dateCreate>"create" could refer to a number of dates. Bridget used the diss_accept_date as the dateIssued, so I'll stick with that for now. In dateIssued below, It's standard to use @encoding="iso8601" but the date given isn't formatted correctly.  Can this be normalized somehow?  
		<xsl:for-each select="/DISS_submission/DISS_description/DISS_dates/DISS_comp_date">
					<originInfo>
						<dateCreate encoding="iso8601" keyDate="yes">
							<xsl:value-of select="/DISS_submission/DISS_description/DISS_dates/DISS_comp_date"/>
						</dateCreate>
					</originInfo>		
		</xsl:for-each>-->
		<xsl:for-each select="/DISS_submission/DISS_description/DISS_dates/DISS_comp_date">
			<mods:originInfo>
				<mods:dateIssued encoding="iso8601">
					<xsl:value-of
						select="/DISS_submission/DISS_description/DISS_dates/DISS_comp_date"
					></xsl:value-of>
				</mods:dateIssued>
				<mods:dateCreated encoding="iso8601" keyDate="yes">
					
					<xsl:for-each select="/DISS_submission/DISS_description/DISS_dates/DISS_accept_date">
						<xsl:value-of select="substring-after(., '/01/')"></xsl:value-of>
					</xsl:for-each>
				</mods:dateCreated>
				<xsl:for-each
					select="/DISS_submission/DISS_description/DISS_institution/DISS_inst_name">
					<mods:publisher>
						<xsl:value-of select="."></xsl:value-of>
					</mods:publisher>
				</xsl:for-each>
			</mods:originInfo>
		</xsl:for-each>
		<!--GENRE-->
		<xsl:for-each select="DISS_description">
			<!-- Edited genre to insert proper AAT values and URIs  JN 3/2017 -->
			<xsl:choose>
				<xsl:when test="@type='masters'">
					<mods:genre authority="aat" valueURI="http://vocab.getty.edu/aat/300077723">
						<xsl:text>masters theses</xsl:text>
					</mods:genre>
				</xsl:when>
				<xsl:when test="@type='doctoral'">
					<mods:genre authority="aat" valueURI="http://vocab.getty.edu/aat/300312076">
						<xsl:text>doctoral dissertations</xsl:text>
					</mods:genre>
				</xsl:when>
			</xsl:choose>
			<!--Edited physical description area to conform to SCUA extent 300 field practices JN 3/2017 -->
			<mods:physicalDescription>
				<mods:extent>1 online resource (<xsl:value-of select="@page_count"/> pages) : PDF</mods:extent>
				<mods:internetMediaType>application/pdf</mods:internetMediaType>
				<mods:digitalOrigin>born digital</mods:digitalOrigin>
				<mods:reformattingQuality>access</mods:reformattingQuality>
			</mods:physicalDescription>
		</xsl:for-each>
		<!--KEYWORDS to NOTE  -->
		<xsl:for-each select="DISS_description">
			<xsl:for-each select="DISS_categorization">
				<xsl:choose>
					<xsl:when test="DISS_category">
						<xsl:for-each select="//DISS_cat_desc">
							<mods:note displayLabel="Keywords">
								<xsl:value-of select="."></xsl:value-of>
							</mods:note>
						</xsl:for-each>
					</xsl:when>
				</xsl:choose>
				<mods:note displayLabel="Keywords">
					<xsl:value-of select="DISS_keyword"></xsl:value-of>
				</mods:note>
			</xsl:for-each>
		</xsl:for-each>
		<!-- LANGUAGE INFORMATION: LANGUAGE -> removed by ARK because it references outside file-->
		<!-- <xsl:for-each select="DISS_categorization">-->
		<!-- <language>-->
		<!-- <languageTerm type="code" authority="iso639-2b">-->
		<!-- <xsl:call-template name="iso-639-1-converter"/>-->
		<!-- </languageTerm>-->
		<!-- </language>-->
		<!-- </xsl:for-each>-->
		<!--  KEYWORDS to SINGLE STRING OF SUBJECTS  
        <xsl:for-each select="DISS_description">
			<xsl:for-each select="DISS_categorization">
				<xsl:choose>
					<xsl:when test="DISS_category">
						<xsl:for-each select="//DISS_cat_desc">
							<subject xmlns="http://www.loc.gov/mods/v3"  authority="local">
                                <topic>
                                    <xsl:value-of select="."/>
                                </topic>
                            </subject>
						</xsl:for-each>
					</xsl:when>
				</xsl:choose>
				<subject xmlns="http://www.loc.gov/mods/v3"  authority="local">
                    <topic>
                        <xsl:value-of select="DISS_keyword"/>
                    </topic>
                </subject>
			</xsl:for-each>
        </xsl:for-each>-->
		<!-- KEYWORDS TO LIST OF SUBJECTS -->
		<xsl:for-each select="//DISS_description/DISS_categorization/DISS_keyword">
			<xsl:choose>
				<xsl:when test="string(.)">
					<xsl:call-template name="output-tokens">
						<xsl:with-param name="list">
							<xsl:value-of select="text()"></xsl:value-of>
						</xsl:with-param>
						<xsl:with-param name="delimiter">,</xsl:with-param>
					</xsl:call-template>
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>
		<!-- ACADEMIC INFORMATION (DEGREE, DISCIPLINE and ADVISOR): NOTE, NAME-->
		<!--Added FAST subject for electronic dissertations JN 3/2017 -->
		<mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast" valueURI="http://id.worldcat.org/fast/907182">
			<mods:topic>Electronic dissertations</mods:topic>
		</mods:subject>
		<xsl:for-each select="DISS_description">
			<xsl:for-each select="DISS_institution">
				<xsl:if test="DISS_inst_name">
					<mods:name type="corporate">
						<mods:namePart>
							<xsl:value-of select="DISS_inst_name"></xsl:value-of>
						</mods:namePart>
						<mods:role>
							<mods:roleTerm authority="marcrelator" type="text">Degree granting
								institution</mods:roleTerm>
						</mods:role>
					</mods:name>
				</xsl:if>
				<xsl:if test="DISS_inst_contact">
					<mods:note displayLabel="Academic concentration">
						<xsl:value-of select="DISS_inst_contact"></xsl:value-of>
					</mods:note>
				</xsl:if>
			</xsl:for-each>
			
			<mods:note type="thesis" displayLabel="Degree">
				<!--Edited to insert proper 502 thesis note in record JN 3/2017 -->
				<xsl:text>Thesis (</xsl:text>
				<xsl:value-of select="DISS_degree"></xsl:value-of>
				<xsl:text>)--</xsl:text>
				<xsl:value-of select="DISS_institution/DISS_inst_name"></xsl:value-of>
				<xsl:text>, </xsl:text>
				<xsl:value-of select="DISS_dates/DISS_comp_date"></xsl:value-of>
                <xsl:text>.</xsl:text>				
			</mods:note>
			
			<!--  06/16/2009  Alternate mapping for DISS_inst_contact via extension. -->
			<!--  <extension xmlns:marc="http://www.loc.gov/MARC21/slim"><xsl:value-of select="/DISS_submission/DISS_description/DISS_institution/DISS_inst_contact"/></extension>  -->
			<!--04/10/2014 Took out extension.  Don't use extension; too messy.  Sonoe-->
			<xsl:for-each select="DISS_advisor/DISS_name">
		    <!-- Inverted advisor name JN 3/2017 -->
				<mods:name type="personal">
					<mods:namePart>
						<xsl:value-of select="DISS_surname"></xsl:value-of>
						<xsl:text>, </xsl:text>
						<xsl:value-of select="DISS_fname"></xsl:value-of>
					</mods:namePart>								
					<mods:role>
						<mods:roleTerm authority="marcrelator" type="text">Thesis
							advisor</mods:roleTerm>
					</mods:role>
				</mods:name>
			</xsl:for-each>
			<xsl:for-each select="DISS_cmte_member/DISS_name">
				<mods:name type="personal">
					<mods:namePart type="given">
						<xsl:value-of select="DISS_fname"></xsl:value-of>
					</mods:namePart>
					<mods:namePart type="family">
						<xsl:value-of select="DISS_surname"></xsl:value-of>
					</mods:namePart>
					<mods:role>
						<mods:roleTerm authority="marcrelator" type="text">Committee
							member</mods:roleTerm>
					</mods:role>
				</mods:name>
			</xsl:for-each>
		</xsl:for-each>
		<!-- TYPE OF RESOURCE AND EXTENT: TYPE OF RESOURCE and PHYSICAL DESCRIPTION -->
		<mods:typeOfResource>text</mods:typeOfResource>
		<!--RESTRICTIONS AND ACCESS: ACCESSCONDITION-->
		<xsl:for-each select="DISS_repository">
			<mods:accessCondition xmlns="http://www.loc.gov/mods/v3" type="embargo end date">
				<xsl:value-of select="DISS_delayed_release"></xsl:value-of>
			</mods:accessCondition>
			<mods:accessCondition xmlns="http://www.loc.gov/mods/v3" type="restriction on access">
				<xsl:value-of select="DISS_access_option"></xsl:value-of>
			</mods:accessCondition>
			<!--  Embargo  -->
			<mods:accessCondition xmlns="http://www.loc.gov/mods/v3" type="embargo terms">
				<xsl:if test="DISS_acceptance = '1'">
					<xsl:value-of select="DISS_agreement_decision_date"></xsl:value-of>
				</xsl:if>
			</mods:accessCondition>
		</xsl:for-each>
		<!--Added administrative metadata for record JN 3/2017 -->
		<mods:recordInfo>
			<mods:recordContentSource authority="oclcorg">NKM</mods:recordContentSource>
			<mods:languageOfCataloging>
				<mods:languageTerm authority="iso639-2b">eng</mods:languageTerm>
			</mods:languageOfCataloging>
			<mods:recordInfoNote>Converted to MODS from ProQuest ETD metadata with XSLT.</mods:recordInfoNote>
		</mods:recordInfo>
		
		
		<!--  Mapped to DISS_submission/@embargo_code.  Conditional statements for embargo codes 0 - 2.  Sonoe-->
		<!--<xsl:for-each select="//@embargo_code">
			<xsl:choose>
				<xsl:when test=".=1">
					<accessCondition displayLabel="Embargo" type="restrictionOnAccess">This item is restricted from public view for 6 months after publication.</accessCondition>
				</xsl:when>
				<xsl:when test=".=2">
					<accessCondition displayLabel="Embargo" type="restrictionOnAccess">This item is restricted from public view for 1 year after publication.</accessCondition>
				</xsl:when>
				<xsl:when test=".=3">
					<accessCondition displayLabel="Embargo" type="restrictionOnAccess">This item is restricted from public view for 2 years after publication.</accessCondition>
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>-->
	</xsl:template>
</xsl:stylesheet>
