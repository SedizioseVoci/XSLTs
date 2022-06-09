<xsl:stylesheet xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="xlink" version="2.0">
	<xsl:output encoding="UTF-8" indent="yes" method="xml" standalone="yes"/>
	<xsl:strip-space elements="*"/>
	<!-- top level elements ELEMENT DISS_description (DISS_title,DISS_dates,DISS_degree,(DISS_institution),(DISS_advisor)*,DISS_cmte_member*,DISS_categorization)>
    -->

	<!-- Converts incoming ETDs in ProQuest XML to local Atkins MODS standard for Niner Commons; additionally, XSLT modifies capitalization of ProQuest and student-supplied keywords to Camel Case and inserts FAST topical and geographical headings based on ProQuest keywords. Part I of a three-part suite of XSLTs for processing ProQuest ETDs for Niner Commons; other parts are II. ProQuestXML_To_MODS_XSLT_2_ProQuestETDCleanup and III. ProQuestXML_To_MODS_3_ProQuestETDRenameFiles JRN 2022-06-09 -->

	<xsl:param name="graduationSemester"/>
	<xsl:variable name="smallcase" select="'abcdefghijklmnopqrstuvwxyz'"/>
	<xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>

	<xsl:template name="replace">
		<xsl:param name="text"/>
		<xsl:param name="replace"/>
		<xsl:param name="by"/>
		<xsl:choose>
			<xsl:when test="contains($text, $replace)">
				<xsl:value-of select="substring-before($text,$replace)"/>
				<xsl:value-of select="$by"/>
				<xsl:call-template name="replace">
					<xsl:with-param name="text" select="substring-after($text,$replace)"/>
					<xsl:with-param name="replace" select="$replace"/>
					<xsl:with-param name="by" select="$by"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$text"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- Template for comma delimited lists -->
	<xsl:template match="DISS_keyword">
		<xsl:choose>
			<xsl:when test="string(.)">
				<xsl:call-template name="output-tokens">
					<xsl:with-param name="list">
						<xsl:value-of select="text()"/>
					</xsl:with-param>
					<xsl:with-param name="delimiter">,</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:variable name="lulasue" select="mods:mods/mods:note[@displayLabel='ETDkeywords']/text()"/>

	<xsl:template name="CamelCase">
		<xsl:param name="text"/>
		<xsl:choose>

			<xsl:when test="contains($text,'-')">
				<xsl:call-template name="CamelCaseBeulah">
					<xsl:with-param name="text" select="substring-before($text,'-')"/>
				</xsl:call-template>
				<xsl:text>-</xsl:text>
				<xsl:call-template name="CamelCase">
					<xsl:with-param name="text" select="substring-after($text,'-')"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="contains($text,' ')">
				<xsl:call-template name="CamelCaseWord">
					<xsl:with-param name="text" select="substring-before($text,' ')"/>
				</xsl:call-template>
				<xsl:text> </xsl:text>
				<xsl:call-template name="CamelCase">
					<xsl:with-param name="text" select="substring-after($text,' ')"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="CamelCaseWord">
					<xsl:with-param name="text" select="$text"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="CamelCaseWord">
		<xsl:param name="text"/>
		<xsl:value-of
			select="translate(substring($text,1,1),'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>
		<xsl:value-of
			select="translate(substring($text,2,string-length($text)-1),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
		/>
	</xsl:template>

	<xsl:template name="CamelCaseBeulah">
		<xsl:param name="text"/>
		<xsl:value-of
			select="translate(substring($text,1,1),'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>
		<xsl:value-of
			select="translate(substring($text,2,string-length($text)-1),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
		/>
	</xsl:template>


	<xsl:template name="output-tokens">
		<xsl:param name="list"/>
		<xsl:param name="delimiter"/>
		<xsl:variable name="newlist">
			<xsl:choose>
				<xsl:when test="contains($list, $delimiter)">
					<xsl:value-of select="normalize-space($list)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat(normalize-space($list), $delimiter)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="first" select="substring-before($newlist, $delimiter)"/>
		<xsl:variable name="remaining" select="substring-after($newlist, $delimiter)"/>
		<!-- Moved keywords to special displayLabel note; previously they were in MODS subject; this template applies Camel casing to the keywords moved to the mods note fields 2022-06-08 JRN -->
		<mods:note xmlns="http://www.loc.gov/mods/v3" displayLabel="ETDkeywords">
		  <xsl:call-template name="CamelCase">	
			<xsl:with-param name="text" select="$first"/>
		  </xsl:call-template>	
		</mods:note>
		<xsl:if test="$remaining">
			<xsl:call-template name="output-tokens">
				<xsl:with-param name="list" select="$remaining"/>
				<xsl:with-param name="delimiter">
					<xsl:value-of select="$delimiter"/>
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
			xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-7.xsd"
			version="3.7">
			<xsl:for-each select="//DISS_submission">

				<xsl:call-template name="DISS_submission"/>

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
					<xsl:variable name="lurloola"
						select="//DISS_description/DISS_institution/DISS_inst_contact"/>
					<mods:name type="personal">

						<mods:namePart>
							<!-- Edited order of name elements to create correct inverted display JRN 4/2017 -->
							<xsl:value-of select="DISS_surname"/>
							<xsl:text>, </xsl:text>
							<xsl:value-of select="DISS_fname"/>
							<xsl:text/>
							<xsl:value-of select="DISS__middle"> </xsl:value-of>
						</mods:namePart>
						<mods:role>
							<mods:roleTerm authority="marcrelator" type="text"
								>creator</mods:roleTerm>
						</mods:role>
						<!--Snipped off extraneous information in parentheses from affiliation JRN 1/2019 -->
						<xsl:choose>
							<xsl:when test="contains($lurloola, ' &#x28;')">
								<mods:affiliation>
									<xsl:value-of select="substring-before($lurloola, ' &#x28;')"/>
								</mods:affiliation>
							</xsl:when>
							<xsl:otherwise>
								<mods:affiliation>
									<xsl:value-of select="$lurloola"/>
								</mods:affiliation>
							</xsl:otherwise>
						</xsl:choose>
					</mods:name>
				</xsl:for-each>
			</xsl:for-each>
		</xsl:for-each>

		<mods:name type="corporate">
			<mods:namePart>ProQuest (Firm)</mods:namePart>
			<mods:role>
				<mods:roleTerm authority="marcrelator" type="text">contributor</mods:roleTerm>
			</mods:role>
		</mods:name>


		<xsl:if test="DISS_author/DISS_orcid">
			<mods:nameIdentifier type="orcid">
				<xsl:text/>
				<xsl:value-of select="DISS_author/DISS_orcid"/>
			</mods:nameIdentifier>
		</xsl:if>
		<!--TITLE and ABSTRACT INFORMATION: TITLEINFO and ABSTRACT-->
		<!--Uppercased all titles; stripped out smart quotes with embedded translate functions JRN 4/2017 -->

		<!--TITLE and ABSTRACT INFORMATION: TITLEINFO and ABSTRACT-->
		<!--Uppercased all titles JN 3/2017 -->
		<xsl:for-each select="DISS_description">
			<xsl:variable name="smallcase" select="'abcdefghijklmnopqrstuvwxyz'"/>
			<xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
			<mods:titleInfo>
				<mods:title>
					<xsl:call-template name="strip-tags">
						<xsl:with-param name="text" select="DISS_title"/>
					</xsl:call-template>
				</mods:title>
			</mods:titleInfo>
		</xsl:for-each>
		<xsl:for-each select="DISS_content">

			<mods:abstract>
				<!-- Replaces smart quotes with genuine quotation marks in abstract JRN 4/2017 -->
				<xsl:for-each select="DISS_abstract/DISS_para">
					<xsl:value-of select="translate(translate(.,  '“', '&quot;'), '”', '&quot;')"/>
				</xsl:for-each>
			</mods:abstract>
			<mods:identifier type="local">
				<!--Added substring function to strip file type off identifier  JRN 4/2017 -->
				<xsl:for-each select="DISS_binary">
					<xsl:value-of select="substring-before(., '.pdf')"/>
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
		<!-- Switched out date issued from date created JRN 4/2017 -->
		<xsl:for-each select="/DISS_submission/DISS_description/DISS_dates/DISS_comp_date">
			<xsl:variable name="beulah"
				select="/DISS_submission/DISS_description/DISS_dates/DISS_comp_date"/>
			<!-- Stripped month off creation date JRN 1/2019; had to add choose test to deal with dash that appears in some dates but not in others -->
			<mods:originInfo>
				<xsl:choose>
					<xsl:when test="contains(., '-')">
						<mods:dateCreated encoding="w3cdtf">
							<xsl:value-of select="substring-before($beulah, '-')"/>
						</mods:dateCreated>
					</xsl:when>
					<xsl:otherwise>
						<mods:dateCreated encoding="w3cdtf">
							<xsl:value-of select="."/>
						</mods:dateCreated>
					</xsl:otherwise>
				</xsl:choose>

				<xsl:for-each
					select="/DISS_submission/DISS_description/DISS_institution/DISS_inst_name">
					<mods:publisher>
						<xsl:value-of select="."/>
					</mods:publisher>
				</xsl:for-each>
			</mods:originInfo>
		</xsl:for-each>
		<!--GENRE-->
		<xsl:for-each select="DISS_description">
			<!-- Edited genre to insert proper AAT values and URIs for dissertations and theses  JRN 4/2017 -->
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
			<!--Edited physical description area to conform to SCUA extent 300 field practices JRN 4/2017 -->
			<mods:physicalDescription>
				<mods:extent>1 online resource (<xsl:value-of select="@page_count"/> pages) :
					PDF</mods:extent>
				<mods:internetMediaType>application/pdf</mods:internetMediaType>
				<mods:digitalOrigin>born digital</mods:digitalOrigin>
				<mods:reformattingQuality>access</mods:reformattingQuality>
			</mods:physicalDescription>
		</xsl:for-each>
		<!--KEYWORDS to NOTE  -->

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
		<xsl:for-each select="DISS_description">
			<!-- Uppercased keywords JRN 4/2017 -->
			<xsl:for-each select="DISS_categorization">
				<xsl:variable name="smallcase" select="'abcdefghijklmnopqrstuvwxyz'"/>
				<xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
				<xsl:choose>
					<xsl:when test="DISS_category">
						<xsl:for-each select="//DISS_cat_desc">
							<mods:note type="admin" displayLabel="Keywords">
								<xsl:value-of select="."/>
							</mods:note>
						</xsl:for-each>
					</xsl:when>
				</xsl:choose>
				<mods:note type="admin" displayLabel="Keywords">
					<xsl:call-template name="CamelCase">
						<xsl:with-param name="text" select="DISS_keyword"/>
					</xsl:call-template>
				</mods:note>
			</xsl:for-each>
		</xsl:for-each>
		<xsl:for-each select="//DISS_description/DISS_categorization/DISS_keyword">

			<xsl:variable name="smallcase" select="'abcdefghijklmnopqrstuvwxyz'"/>
			<xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
			<xsl:choose>
				<xsl:when test="string(.)">
					<xsl:call-template name="output-tokens">
						<xsl:with-param name="list">
							<xsl:value-of select="text()"/>
						</xsl:with-param>
						<xsl:with-param name="delimiter">,</xsl:with-param>
					</xsl:call-template>
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>

		<!--Added DISS_cat_desc to terms transformed into subjects; uppercased the terms JRN 4/5/2017 -->
		<!--<xsl:for-each select="//DISS_description/DISS_categorization/DISS_category/DISS_cat_desc">
			<xsl:variable name="smallcase" select="'abcdefghijklmnopqrstuvwxyz'" />
			<xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
			<xsl:choose>
				<xsl:when test="string(.)">
					<xsl:call-template name="output-tokens">
						<xsl:with-param name="list">
							<xsl:value-of select="translate(text(),  $smallcase, $uppercase)"></xsl:value-of>
						</xsl:with-param>
						<xsl:with-param name="delimiter">,</xsl:with-param>
					</xsl:call-template>
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>-->
		<!-- ACADEMIC INFORMATION (DEGREE, DISCIPLINE and ADVISOR): NOTE, NAME-->

		<xsl:for-each select="DISS_description">

			<xsl:for-each select="DISS_institution">
				<xsl:variable name="ooloona" select="DISS_inst_contact"/>
				<xsl:if test="DISS_inst_name">
					<mods:name type="corporate">
						<mods:namePart>
							<xsl:value-of select="DISS_inst_name"/>
						</mods:namePart>
						<mods:role>
							<mods:roleTerm authority="marcrelator" type="text">degree granting
								institution</mods:roleTerm>
						</mods:role>
					</mods:name>
				</xsl:if>
				<xsl:choose>
					<xsl:when test="contains($ooloona, ' &#x28;')">
						<mods:note displayLabel="Academic concentration">
							<xsl:value-of select="substring-before($ooloona, ' &#x28;')"/>
						</mods:note>
					</xsl:when>
					<xsl:otherwise>
						<mods:note displayLabel="Academic concentration">
							<xsl:value-of select="$ooloona"/>
						</mods:note>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>

			<mods:note type="thesis" displayLabel="Degree">
				<xsl:variable name="lurlene" select="DISS_dates/DISS_comp_date"/>
				<!--Edited to insert proper 502 thesis note in record JRN 4/2017 -->
				<xsl:text>Thesis (</xsl:text>
				<xsl:value-of select="DISS_degree"/>
				<xsl:text>)--</xsl:text>
				<xsl:value-of select="DISS_institution/DISS_inst_name"/>
				<xsl:text>, </xsl:text>
				<!-- Stripped off month date from publication year for 502 statement JRN 1/2019 -->
				<xsl:choose>
					<xsl:when test="contains($lurlene, '-')">
						<xsl:value-of select="substring-before($lurlene, '-')"/>
						<xsl:text>.</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$lurlene"/>
						<xsl:text>.</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</mods:note>

			<mods:note displayLabel="ETDdegreeName">
				<xsl:value-of select="DISS_degree"/>
			</mods:note>

			<!--  06/16/2009  Alternate mapping for DISS_inst_contact via extension. -->
			<!--  <extension xmlns:marc="http://www.loc.gov/MARC21/slim"><xsl:value-of select="/DISS_submission/DISS_description/DISS_institution/DISS_inst_contact"/></extension>  -->

			<xsl:for-each select="DISS_advisor/DISS_name">
				<!-- Inverted advisor name JRN 4/2017 -->
				<mods:name type="personal">
					<mods:namePart>
						<xsl:value-of select="DISS_surname"/>
						<xsl:text>, </xsl:text>
						<xsl:value-of select="DISS_fname"/>
					</mods:namePart>
					<mods:role>
						<mods:roleTerm authority="marcrelator" type="text">thesis
							advisor</mods:roleTerm>
					</mods:role>
				</mods:name>
			</xsl:for-each>
			<!-- Inverted commmittee members' names JRN 4/2017 -->
			<xsl:for-each select="DISS_cmte_member/DISS_name">
				<mods:name type="personal">
					<mods:namePart>
						<xsl:value-of select="DISS_surname"/>
						<xsl:text>, </xsl:text>
						<xsl:value-of select="DISS_fname"/>
					</mods:namePart>
					<mods:role>
						<mods:roleTerm authority="marcrelator" type="text">committee
							member</mods:roleTerm>
					</mods:role>
				</mods:name>
			</xsl:for-each>
		</xsl:for-each>
		<!-- TYPE OF RESOURCE AND EXTENT: TYPE OF RESOURCE and PHYSICAL DESCRIPTION; NEW FAST SUBJECT TERMS INSERTED 2022-06-08 -->
		<mods:typeOfResource>text</mods:typeOfResource>
		<xsl:for-each select="DISS_description">
			<xsl:for-each select="DISS_categorization">
				<xsl:choose>
					<xsl:when test="DISS_category">
						<xsl:for-each select="//DISS_cat_desc">
							<xsl:if test=".='Mechanical engineering'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1013375">
									<mods:topic>Mechanical engineering</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Mechanics'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1013446">
									<mods:topic>Mechanics</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Materials science'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1011957">
									<mods:topic>Materials science</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Special education'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1128842">
									<mods:topic>Special education</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Electrical engineering'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1728596">
									<mods:topic>Electrical engineering</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Optics'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1046845">
									<mods:topic>Optics</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Engineering'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/910312">
									<mods:topic>Engineering</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Nanoscience'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1032629">
									<mods:topic>Nanoscience</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='School counseling'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/903395">
									<mods:topic>Educational counseling</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Middle school education'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1020518">
									<mods:topic>Middle school education</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Multicultural education'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1028816">
									<mods:topic>Multicultural education</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Computer science'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/872451">
									<mods:topic>Computer science</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Mathematics education'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1012236">
									<mods:topic>Mathematics--Study and teaching</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Education'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/902499">
									<mods:topic>Education</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Mathematics'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1012163">
									<mods:topic>Mathematics</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Organizational behavior'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1047801">
									<mods:topic>Organizational behavior</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Management'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1007141">
									<mods:topic>Management</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Chemistry'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/853344">
									<mods:topic>Chemistry</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Nanotechnology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1032639">
									<mods:topic>Nanotechnology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Nursing'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1041731">
									<mods:topic>Nursing</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Communication'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/869952">
									<mods:topic>Communication</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Medicine'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1014893">
									<mods:topic>Medicine</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Physics'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1063025">
									<mods:topic>Physics</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Civil engineering'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/862488">
									<mods:topic>Civil engineering</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Transportation'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1155007">
									<mods:topic>Transportation</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Statistics'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1132103">
									<mods:topic>Statistics</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Sociology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1123875">
									<mods:topic>Sociology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Social psychology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1122816">
									<mods:topic>Social psychology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Inorganic chemistry'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/853488">
									<mods:topic>Chemistry, Inorganic</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Molecular biology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1024734">
									<mods:topic>Molecular biology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Literature'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/999953">
									<mods:topic>Literature</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='English literature'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/911989">
									<mods:topic>English literature</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Energy'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1074275">
									<mods:topic>Power resources</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Counseling psychology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1740078">
									<mods:topic>Counseling psychology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Social structure'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1123372">
									<mods:topic>Social structure</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Women''s studies'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1178850">
									<mods:topic>Women's studies</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Geography'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/940469">
									<mods:topic>Geography</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Urban planning'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/862177">
									<mods:topic>City planning</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Biomechanics'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/832558">
									<mods:topic>Biomechanics</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='History'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/958235">
									<mods:topic>History</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Public health'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1082238">
									<mods:topic>Public health</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Educational leadership'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/903527">
									<mods:topic>Educational leadership</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Automotive engineering'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/823374">
									<mods:topic>Automobiles--Design and construction</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Physical chemistry'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/853521">
									<mods:topic>Chemistry, Physical and theoretical</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Naval engineering'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1009532">
									<mods:topic>Marine engineering</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Public policy'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1353198">
									<mods:topic>Government policy</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Political science'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1069781">
									<mods:topic>Political science</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Gender studies'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1114598/">
									<mods:topic>Sex role</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Immunology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/968006">
									<mods:topic>Immunology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Virology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1167670">
									<mods:topic>Virology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Higher education administration'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/903010">
									<mods:topic>Education, Higher--Administration</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Community college education'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/870810">
									<mods:topic>Community colleges--Study and teaching</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Industrial engineering'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/970992">
									<mods:topic>Industrial engineering</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Operations research'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1046387">
									<mods:topic>Operations research</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Commerce-Business'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/869279">
									<mods:topic>Commerce</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Business'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/842262">
									<mods:topic>Business</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Biology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/832383">
									<mods:topic>Biology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Microbiology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1019576">
									<mods:topic>Microbiology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Kinesiology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/987619">
									<mods:topic>Kinesiology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Educational evaluation'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/903437">
									<mods:topic>Educational evaluation</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Early childhood education'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/900596">
									<mods:topic>Early childhood education</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Elementary education'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/902945">
									<mods:topic>Education, Elementary</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Finance'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/924349">
									<mods:topic>Finance</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Higher education'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/903005">
									<mods:topic>Education, Higher</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Economics'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/902116">
									<mods:topic>Economics</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Psychology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1081447">
									<mods:topic>Psychology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Occupational psychology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1081592">
									<mods:topic>Psychology, Industrial</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Meteorology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1018441">
									<mods:topic>Meteorology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Teacher education'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1144404">
									<mods:topic>Teachers--Training of</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Library science'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/997916">
									<mods:topic>Library science</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Computer engineering'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/872078">
									<mods:topic>Computer engineering</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Reading instruction'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1090626">
									<mods:topic>Reading</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Sustainability'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1747391">
									<mods:topic>Sustainability</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Robotics'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1098997">
									<mods:topic>Robotics</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Bioinformatics'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/832181">
									<mods:topic>Bioinformatics</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Information technology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/973089">
									<mods:topic>Information technology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Applied mathematics'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1012163">
									<mods:topic>Mathematics</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Environmental engineering'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/912934">
									<mods:topic>Environmental engineering</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='English as a second language'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/911692">
									<mods:topic>English language--Study and teaching--Foreign
										speakers</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Sports management'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1130552">
									<mods:topic>Sports administration</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Health education'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/952878">
									<mods:topic>Health education</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Environmental science'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/913474">
									<mods:topic>Environmental sciences</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Educational psychology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/903571">
									<mods:topic>Educational psychology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Adult education'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/797275">
									<mods:topic>Adult education</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Individual &amp; family studies'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1728948">
									<mods:topic>Families--Study and teaching</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Social research'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1122944">
									<mods:topic>Social sciences--Research</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Curriculum development'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/885382">
									<mods:topic>Curriculum planning</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Alternative energy'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1094570">
									<mods:topic>Renewable energy sources</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Mass communication'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1011219">
									<mods:topic>Mass media</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Language arts'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/992284">
									<mods:topic>Language arts</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Mental health'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1016339">
									<mods:topic>Mental health</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Aerospace engineering'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/798623">
									<mods:topic>Aerospace engineering</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Genetics'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/940117">
									<mods:topic>Genetics</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Environmental economics'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/912895">
									<mods:topic>Environmental economics</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Educational tests &amp; measurements'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/903660">
									<mods:topic>Educational tests and measurements</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Artificial intelligence'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/817247">
									<mods:topic>Artificial intelligence</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Rhetoric'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1096948">
									<mods:topic>Rhetoric</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Medieval literature'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1000151">
									<mods:topic>Literature, Medieval</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Religious history'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/958270">
									<mods:topic>History--Religious aspects</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Water resources management'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1172006">
									<mods:topic>Water resources development--Management</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Epidemiology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/914091">
									<mods:topic>Epidemiology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Behavioral sciences'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1122877">
									<mods:topic>Social sciences</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Pedagogy'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/902499">
									<mods:topic>Education</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Geomorphology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/940955">
									<mods:topic>Geomorphology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Geology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/940627">
									<mods:topic>Geology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Soil sciences'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1124601">
									<mods:topic>Soil science</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Ecology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/901476">
									<mods:topic>Ecology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Conservation biology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/875490">
									<mods:topic>Conservation biology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Education policy'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/902835">
									<mods:topic>Education and state</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Educational sociology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/903596">
									<mods:topic>Educational sociology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Biochemistry'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/831961">
									<mods:topic>Biochemistry</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Geotechnology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1893896">
									<mods:topic>Geotechnical engineering</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Criminology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/883566">
									<mods:topic>Criminology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Health sciences'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1014601">
									<mods:topic>Medical sciences</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Religion'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1093763">
									<mods:topic>Religion</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Architecture'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/813346">
									<mods:topic>Architecture</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Design'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/891253/">
									<mods:topic>Design</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Education finance'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/902637">
									<mods:topic>Education--Finance</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Educational administration'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1107575">
									<mods:topic>School management and organization</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Law'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/993678">
									<mods:topic>Law</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Physical anthropology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1062357">
									<mods:topic>Physical anthropology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Cognitive psychology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/866541">
									<mods:topic>Cognitive psychology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Planetology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1065123">
									<mods:topic>Planetary science</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Environmental studies'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/962987">
									<mods:topic>Human ecology--Study and teaching</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Cultural anthropology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/916106">
									<mods:topic>Ethnology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Physiology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1063177">
									<mods:topic>Physiology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Neurosciences'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1036509">
									<mods:topic>Neurosciences</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Biophysics'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/832656">
									<mods:topic>Biophysics</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Gifted education'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/942566">
									<mods:topic>Gifted children--Education</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Biomedical engineering'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/832568">
									<mods:topic>Biomedical engineering</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Clinical psychology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/864407">
									<mods:topic>Clinical psychology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Endocrinology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/909749">
									<mods:topic>Endocrinology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Hydrologic sciences'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/965147">
									<mods:topic>Hydrology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Information science'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/972640">
									<mods:topic>Information science</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Technical communication'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/870307">
									<mods:topic>Communication of technical information</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Cellular biology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/886282">
									<mods:topic>Cytology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Public health education'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1082320">
									<mods:topic>Public health--Study and teaching</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Educational technology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/903623">
									<mods:topic>Educational technology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Art education'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/815338">
									<mods:topic>Art--Study and teaching</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Agriculture'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/801355">
									<mods:topic>Agriculture</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Gerontology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/942204">
									<mods:topic>Gerontology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Electromagnetics'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/906590">
									<mods:topic>Electromagnetism</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Biostatistics'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/832611">
									<mods:topic>Biometry</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Linguistics'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/999202">
									<mods:topic>Linguistics</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Creative writing'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/882489">
									<mods:topic>Creative writing</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Entrepreneurship'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/912787">
									<mods:topic>Entrepreneurship</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Biological oceanography'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1009447">
									<mods:topic>Marine biology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Organic chemistry'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/853501">
									<mods:topic>Chemistry, Organic</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Analytical chemistry'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/853459">
									<mods:topic>Analytical chemistry</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Oncology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1045739">
									<mods:topic>Oncology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Archaeology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/812938">
									<mods:topic>Archaeology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Classical studies'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/863004">
									<mods:topic>Civilization, Classical--Study and
										teaching</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Environmental management'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/913186">
									<mods:topic>Environmental management</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Philosophy'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1060777">
									<mods:topic>Philosophy</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Secondary education'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/903252">
									<mods:topic>Education, Secondary</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Experimental psychology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1081581">
									<mods:topic>Psychology, Experimental</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Philosophy of science'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1108336">
									<mods:topic>Science--Philosophy</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Health care management'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/953286">
									<mods:topic>Health services administration</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Geophysics'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/941002">
									<mods:topic>Geophysics</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='System science'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1141423">
									<mods:topic>System theory</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Business administration'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/971246">
									<mods:topic>Industrial management</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Comparative religion'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1093898">
									<mods:topic>Religions</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Fluid mechanics'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/927999">
									<mods:topic>Fluid mechanics</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Wildlife conservation'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1175253">
									<mods:topic>Wildlife conservation</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Acoustics'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1126935">
									<mods:topic>Sound</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Psychobiology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1081300">
									<mods:topic>Psychobiology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Urban forestry'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1162426">
									<mods:topic>Urban forestry</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Ethics'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/915833">
									<mods:topic>Ethics</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Philosophy of religion'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1060826">
									<mods:topic>Philosophy and religion</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Public administration'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1081976">
									<mods:topic>Public administration</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Continuing education'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/876705">
									<mods:topic>Continuing education</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Religious education'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1093997">
									<mods:topic>Religious education</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Theoretical physics'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1063025">
									<mods:topic>Physics</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Aesthetics'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/798702">
									<mods:topic>Aesthetics</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Sociolinguistics'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1123847">
									<mods:topic>Sociolinguistics</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Dance'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/887402">
									<mods:topic>Dance</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Physiological psychology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1081674">
									<mods:topic>Psychophysiology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Organization theory'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1047878">
									<mods:topic>Organizational sociology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='American literature'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/807113">
									<mods:topic>American literature</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Molecular physics'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1063025">
									<mods:topic>Physics</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Economic theory'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/902116">
									<mods:topic>Economics</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Performing arts'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1057887">
									<mods:topic>Performing arts</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Language'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/992154">
									<mods:topic>Language and languages</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Nutrition'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1042187">
									<mods:topic>Nutrition</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Web studies'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1181331/">
									<mods:topic>World Wide Web--Study and teaching</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Astronomy'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/819673">
									<mods:topic>Astronomy</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Military studies'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1020874">
									<mods:topic>Military art and science</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Zoology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1184696">
									<mods:topic>Zoology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Forestry'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/932632">
									<mods:topic>Forests and forestry</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Disability studies'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/894656">
									<mods:topic>Disability studies</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Personality psychology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1058667">
									<mods:topic>Personality</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Remote sensing'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1094469">
									<mods:topic>Remote sensing</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Environmental geology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/912988">
									<mods:topic>Environmental geology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Geochemistry'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/940343">
									<mods:topic>Geochemistry</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Military history'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1021222">
									<mods:topic>Military history</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Spirituality'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1130186">
									<mods:topic>Spirituality</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Science education'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1108387">
									<mods:topic>Science--Study and teaching</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Architectural engineering'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/840551">
									<mods:topic>Building</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Aging'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/800293">
									<mods:topic>Aging</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Dentistry'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/890633">
									<mods:topic>Dentistry</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Paleoecology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1051384">
									<mods:topic>Paleoecology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Metaphysics'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1018304">
									<mods:topic>Metaphysics</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Sexuality'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1114160">
									<mods:topic>Sex</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Accounting'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/795379">
									<mods:topic>Accounting</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Marketing'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1010167">
									<mods:topic>Marketing</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Regional studies'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/814190">
									<mods:topic>Area studies</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Computational physics'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1063025">
									<mods:topic>Physics</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Applied physics'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1063025">
									<mods:topic>Physics</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Plant sciences'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/836869">
									<mods:topic>Botany</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Paleontology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1051513">
									<mods:topic>Paleontology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Sedimentary geology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1111003">
									<mods:topic>Sedimentology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Land use planning'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/991528">
									<mods:topic>Land use--Planning</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='African literature'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/799832">
									<mods:topic>African literature</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Social sciences education'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1123000">
									<mods:topic>Social sciences--Study and teaching</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Evolution &amp; development'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1909527">
									<mods:topic>Evolutionary developmental biology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Plant pathology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1065378">
									<mods:topic>Plant diseases</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Aquatic sciences'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/812097">
									<mods:topic>Aquatic sciences</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Labor relations'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/971609">
									<mods:topic>Industrial relations</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Animal sciences'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/809386">
									<mods:topic>Animal scientists</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Wildlife management'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1175323">
									<mods:topic>Wildlife management</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Translation studies'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1154827">
									<mods:topic>Translations</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Film studies'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1027285">
									<mods:topic>Motion pictures</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Social work'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1123192">
									<mods:topic>Social service</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Museum studies'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1030207">
									<mods:topic>Museums--Study and teaching</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Developmental psychology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/891816">
									<mods:topic>Developmental psychology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Latin American literature'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/993031">
									<mods:topic>Latin American literature</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Instructional design'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/974357">
									<mods:topic>Instructional systems--Design</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Theology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1149559">
									<mods:topic>Theology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Recreation'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1091713">
									<mods:topic>Recreation</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Banking'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/826867">
									<mods:topic>Banks and banking</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Statistical physics'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1132076">
									<mods:topic>Statistical physics</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Educational philosophy'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/902499">
									<mods:topic>Education</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Islamic studies'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/979852">
									<mods:topic>Islam--Study and teaching</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Natural resource management'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1034438">
									<mods:topic>Natural resources--Management</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Petrology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1059885">
									<mods:topic>Petrology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Thermodynamics'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1149832">
									<mods:topic>Thermodynamics</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Atmospheric sciences'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/2003481">
									<mods:topic>Atmospheric science</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Medical imaging'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/892354">
									<mods:topic>Diagnostic imaging</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Judaic studies'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/984412">
									<mods:topic>Judaism--Study and teaching</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='International relations'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/977053">
									<mods:topic>International relations</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Obstetrics'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1042994">
									<mods:topic>Obstetrics</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Parasitology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1053186">
									<mods:topic>Parasitology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Folklore'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/930306">
									<mods:topic>Folklore</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Hydraulic engineering'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/964596">
									<mods:topic>Hydraulic engineering</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Surgery'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1139351">
									<mods:topic>Surgery</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Climate change'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/864229">
									<mods:topic>Climatic changes</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Pathology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1054964">
									<mods:topic>Pathology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Pharmaceutical sciences'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1060314">
									<mods:topic>Pharmacy--Research</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Modern history'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/958367">
									<mods:topic>History, Modern</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Theoretical mathematics'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1012163">
									<mods:topic>Mathematics</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Demography'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/890158">
									<mods:topic>Demography</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Condensed matter physics'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/874443">
									<mods:topic>Condensed matter</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Speech therapy'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1129277">
									<mods:topic>Speech therapy</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Music therapy'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1030628">
									<mods:topic>Music therapy</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Music education'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1030347">
									<mods:topic>Music--Instruction and study</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Quantitative psychology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1081529/">
									<mods:topic>Psychology--Statistical methods</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Paleoclimate science'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1051364">
									<mods:topic>Paleoclimatology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Agriculture economics'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/801415">
									<mods:topic>Agriculture--Economic aspects</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Cultural resources management'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/885019">
									<mods:topic>Cultural property--Protection</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Ethnic studies'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/916061">
									<mods:topic>Ethnicity--Study and teaching</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Physical geography'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1062647">
									<mods:topic>Physical geography</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Bioengineering'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/832028">
									<mods:topic>Bioengineering</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Behavioral psychology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/829929">
									<mods:topic>Behavior therapy</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Alternative medicine'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/806153">
									<mods:topic>Alternative medicine</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Developmental biology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/891773">
									<mods:topic>Developmental biology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Agriculture engineering'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/800726">
									<mods:topic>Agricultural engineering</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='World history'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1181345">
									<mods:topic>World history</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Pharmacology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1060259">
									<mods:topic>Pharmacology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Molecular chemistry'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/853344">
									<mods:topic>Chemistry</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Medical ethics'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1014081">
									<mods:topic>Medical ethics</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Holocaust studies'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/958866">
									<mods:topic>Jewish Holocaust (1939-1945)</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Arts management'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/817771">
									<mods:topic>Arts--Management</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Journalism'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/984032">
									<mods:topic>Journalism</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Art criticism'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/815492">
									<mods:topic>Art criticism</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Art history'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/815259">
									<mods:topic>Art--Historiography</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Cinematography'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/861484">
									<mods:topic>Cinematography</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Fashion'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/921600">
									<mods:topic>Fashion</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Fine arts'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/817721">
									<mods:topic>Arts</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Music'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1030269">
									<mods:topic>Music</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Music history'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1030329">
									<mods:topic>Music--Historiography</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Music theory'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1030620">
									<mods:topic>Music theory</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Musical composition'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/871761">
									<mods:topic>Composition (Music)</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Musical performances'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1030398">
									<mods:topic>Music--Performance</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Theater'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1149217">
									<mods:topic>Theater</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Theater history'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1149243">
									<mods:topic>Theater--Historiography</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Landscape architecture'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/991814">
									<mods:topic>Landscape architecture</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Bilingual education'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/902886">
									<mods:topic>Education, Bilingual</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Business education'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/842480">
									<mods:topic>Business education</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Education history'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/902669">
									<mods:topic>Education--Historiography</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Foreign language education'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/992220">
									<mods:topic>Language and languages--Study and
										teaching</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Home economics education'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/959223">
									<mods:topic>Home economics--Study and teaching</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Industrial arts education'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/970826">
									<mods:topic>Industrial arts--Study and teaching</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Performing arts education'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1057935">
									<mods:topic>Performing arts--Study and teaching</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Physical education'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1062401">
									<mods:topic>Physical education and training</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Vocational education'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1168486">
									<mods:topic>Vocational education</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Ancient history'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/958352">
									<mods:topic>History, Ancient</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Australian literature'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/821454">
									<mods:topic>Australian literature</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Canadian literature'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/845111">
									<mods:topic>Canadian literature</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Caribbean literature'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/847469">
									<mods:topic>Caribbean literature</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Classical literature'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/863509">
									<mods:topic>Classical literature</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Comparative literature'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1734553">
									<mods:topic>Comparative literature</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='French literature'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/934688">
									<mods:topic>French literature</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='French Canadian literature'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/934875">
									<mods:topic>French-Canadian literature</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='German literature'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/941797">
									<mods:topic>German literature</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Icelandic &amp; Scandinavian literature'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1106425">
									<mods:topic>Scandinavian literature</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Middle Eastern literature'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1020340">
									<mods:topic>Middle Eastern literature</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Modern language'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/992443">
									<mods:topic>Languages, Modern</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Modern literature'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1000172">
									<mods:topic>Literature, Modern</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Slavic literature'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1120729">
									<mods:topic>Slavic literature</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Biblical studies'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1356024">
									<mods:topic>Bible</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Canon law'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/845910">
									<mods:topic>Canon law</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Clergy'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/864014">
									<mods:topic>Clergy</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Divinity'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/944223">
									<mods:topic>Gods</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Epistemology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/988194">
									<mods:topic>Knowledge, Theory of</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Logic'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1002014">
									<mods:topic>Logic</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Pastoral counseling'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1054526">
									<mods:topic>Pastoral counseling</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Alternative dispute resolution'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/895372">
									<mods:topic>Dispute resolution (Law)</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Intellectual property'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/975774">
									<mods:topic>Intellectual property</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='International law'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/976984">
									<mods:topic>International law</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Law enforcement'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/993931">
									<mods:topic>Law enforcement</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Patent law'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1054823">
									<mods:topic>Patent laws and legislation</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Economic history'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/901974">
									<mods:topic>Economic history</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Forensic anthropology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/931952">
									<mods:topic>Forensic anthropology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Labor economics'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/989943">
									<mods:topic>Labor economics</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Peace studies'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1055838">
									<mods:topic>Peace--Study and teaching</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Biographies'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/832149">
									<mods:topic>Biography</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Food science'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/2003714">
									<mods:topic>Food science</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Home economics'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/959173">
									<mods:topic>Home economics</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Multimedia communications'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1028918">
									<mods:topic>Multimedia communications</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Textile research'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1148949">
									<mods:topic>Textile research</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Agriculture education'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/800702">
									<mods:topic>Agricultural education</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Agronomy'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/801886">
									<mods:topic>Agronomy</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Animal diseases'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/809483">
									<mods:topic>Animals--Diseases</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Horticulture'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/960791">
									<mods:topic>Horticulture</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Range management'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1089831">
									<mods:topic>Range management</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Botany'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/836869">
									<mods:topic>Botany</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Entomology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/912735">
									<mods:topic>Entomology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Histology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/957668">
									<mods:topic>Histology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Limnology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/998940">
									<mods:topic>Limnology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Systematic biology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1034274">
									<mods:topic>Natural history--Classification</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Macroecology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1005220">
									<mods:topic>Macroecology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Chemical engineering'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/852893">
									<mods:topic>Chemical engineering</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Geological engineering'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/910529">
									<mods:topic>Engineering geology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Mining'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1022541">
									<mods:topic>Mines and mineral resources</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Nuclear engineering'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1040032">
									<mods:topic>Nuclear engineering</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Ocean engineering'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1043504">
									<mods:topic>Ocean engineering</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Packaging'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1050156">
									<mods:topic>Packaging</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Petroleum engineering'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1059492">
									<mods:topic>Petroleum engineering</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Plastics'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1066542">
									<mods:topic>Plastics</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Environmental education'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/912902">
									<mods:topic>Environmental education</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Environmental health'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/912999">
									<mods:topic>Environmental health</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Environmental justice'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/913104">
									<mods:topic>Environmental justice</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Environmental law'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/913122">
									<mods:topic>Environmental law</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Environmental philosophy'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1751063">
									<mods:topic>Environmentalism--Philosophy</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Aeronomy'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/820350">
									<mods:topic>Upper atmosphere</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Atmospheric chemistry'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/820380">
									<mods:topic>Atmospheric chemistry</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Biogeochemistry'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/832090">
									<mods:topic>Biogeochemistry</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Chemical oceanography'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/853069">
									<mods:topic>Chemical oceanography</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Geobiology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/940325">
									<mods:topic>Geobiology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Marine geology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1136619">
									<mods:topic>Submarine geology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Mineralogy'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1022406">
									<mods:topic>Mineralogy</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Petroleum geology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1059280">
									<mods:topic>Petroleum--Geology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Physical oceanography'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1043671">
									<mods:topic>Oceanography</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Plate tectonics'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1066753">
									<mods:topic>Plate tectonics</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Audiology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/821108">
									<mods:topic>Audiology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Occupational safety'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/971664">
									<mods:topic>Industrial safety</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Occupational therapy'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1043273">
									<mods:topic>Occupational therapy</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Ophthalmology'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1046503">
									<mods:topic>Ophthalmology</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Optometry'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1046944">
									<mods:topic>Optometry</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Osteopathic medicine'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1048799">
									<mods:topic>Osteopathic medicine</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Physical therapy'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1062771">
									<mods:topic>Physical therapy</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Astrophysics'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/819797">
									<mods:topic>Astrophysics</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Atomic physics'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1040386">
									<mods:topic>Nuclear physics</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Computational chemistry'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/2021097">
									<mods:topic>Computational chemistry</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='High energy physics'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1054130">
									<mods:topic>Particles (Nuclear physics)</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Low temperature physics'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1003163">
									<mods:topic>Low temperatures</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Nuclear chemistry'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1039908">
									<mods:topic>Nuclear chemistry</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Plasma physics'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1066262">
									<mods:topic>Plasma (Ionized gases)</mods:topic>
								</mods:subject>
							</xsl:if>
							<xsl:if test=".='Quantum physics'">
								<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3"
									valueURI="http://id.worldcat.org/fast/1085128">
									<mods:topic>Quantum theory</mods:topic>
								</mods:subject>
							</xsl:if>
								<xsl:if test=".='High temperature physics'">
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/956482">
										<mods:topic>High temperature superconductivity</mods:topic>
									</mods:subject>
								</xsl:if>
								<xsl:if test=".='Geophysical engineering'">
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/910529">
										<mods:topic>Engineering geology</mods:topic>
									</mods:subject>
								</xsl:if>
								<xsl:if test=".='Morphology'">
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/1026452">
										<mods:topic>Morphology</mods:topic>
									</mods:subject>
								</xsl:if>
								<xsl:if test=".='Area planning and development'">
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/1093120">
										<mods:topic>Regional planning</mods:topic>
									</mods:subject>
								</xsl:if>
								<xsl:if test=".='Romance literature'">
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/1099871">
										<mods:topic>Romance-language literature</mods:topic>
									</mods:subject>
								</xsl:if>
								<xsl:if test=".='Asian literature'">
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/1048102">
										<mods:topic>Asian literature</mods:topic>
									</mods:subject>
								</xsl:if>
								<xsl:if test=".='Ancient languages'">
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/863486">
										<mods:topic>Classical languages</mods:topic>
									</mods:subject>
								</xsl:if>
								<xsl:if test=".='Continental dynamics'">
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/940406">
										<mods:topic>Geodynamics</mods:topic>
									</mods:subject>
								</xsl:if>
								<xsl:if test=".='Baltic studies'">
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/1241546">
										<mods:geographic>Baltic States</mods:geographic>
									</mods:subject>
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/814190">
										<mods:topic>Area studies</mods:topic>
									</mods:subject>
								</xsl:if>
								<xsl:if test=".='Canadian studies'">
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/1204310">
										<mods:geographic>Canada</mods:geographic>
									</mods:subject>
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/814190">
										<mods:topic>Area studies</mods:topic>
									</mods:subject>
								</xsl:if>
								<xsl:if test=".='European studies'">
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/1245064">
										<mods:geographic>Europe</mods:geographic>
									</mods:subject>
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/814190">
										<mods:topic>Area studies</mods:topic>
									</mods:subject>
								</xsl:if>
								<xsl:if test=".='North African studies'">
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/1239515">
										<mods:geographic>North Africa</mods:geographic>
									</mods:subject>
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/814190">
										<mods:topic>Area studies</mods:topic>
									</mods:subject>
								</xsl:if>
								<xsl:if test=".='Pacific Rim studies'">
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/1243504">
										<mods:geographic>Pacific Area</mods:geographic>
									</mods:subject>
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/814190">
										<mods:topic>Area studies</mods:topic>
									</mods:subject>
								</xsl:if>
								<xsl:if test=".='Scandinavian studies'">
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/1242804">
										<mods:geographic>Scandinavia</mods:geographic>
									</mods:subject>
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/814190">
										<mods:topic>Area studies</mods:topic>
									</mods:subject>
								</xsl:if>
								<xsl:if test=".='South African studies'">
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/1204616">
										<mods:geographic>South Africa</mods:geographic>
									</mods:subject>
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/814190">
										<mods:topic>Area studies</mods:topic>
									</mods:subject>
								</xsl:if>
								<xsl:if test=".='Canadian history'">
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/1204310">
										<mods:geographic>Canada</mods:geographic>
									</mods:subject>
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/958235">
										<mods:topic>History</mods:topic>
									</mods:subject>
								</xsl:if>
								<xsl:if test=".='History of Oceania'">
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/1242982">
										<mods:geographic>Oceania</mods:geographic>
									</mods:subject>
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/958235">
										<mods:topic>History</mods:topic>
									</mods:subject>
								</xsl:if>
								<xsl:if test=".='Italian studies'">
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/1204565">
										<mods:geographic>Italy</mods:geographic>
									</mods:subject>
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/814190">
										<mods:topic>Area studies</mods:topic>
									</mods:subject>
								</xsl:if>
								<xsl:if test=".='American history'">
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/958235">
										<mods:topic>History</mods:topic>
									</mods:subject>
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/1239786">
										<mods:geographic>America</mods:geographic>
									</mods:subject>
								</xsl:if>
								<xsl:if test=".='Latin American studies'">
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/814190">
										<mods:topic>Area studies</mods:topic>
									</mods:subject>
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/1245945">
										<mods:geographic>Latin America</mods:geographic>
									</mods:subject>
								</xsl:if>
								<xsl:if test=".='African studies'">
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/814190">
										<mods:topic>Area studies</mods:topic>
									</mods:subject>
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/1239509">
										<mods:geographic>Africa</mods:geographic>
									</mods:subject>
								</xsl:if>
								<xsl:if test=".='Southeast Asian studies'">
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/814190">
										<mods:topic>Area studies</mods:topic>
									</mods:subject>
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/1240499">
										<mods:geographic>Southeast Asia</mods:geographic>
									</mods:subject>
								</xsl:if>
								<xsl:if test=".='Latin American history'">
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/958235">
										<mods:topic>History</mods:topic>
									</mods:subject>
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/1245945">
										<mods:geographic>Latin America</mods:geographic>
									</mods:subject>
								</xsl:if>
								<xsl:if test=".='European history'">
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/958235">
										<mods:topic>History</mods:topic>
									</mods:subject>
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/1245064">
										<mods:geographic>Europe</mods:geographic>
									</mods:subject>
								</xsl:if>
								<xsl:if test=".='Asian studies'">
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/814190">
										<mods:topic>Area studies</mods:topic>
									</mods:subject>
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/1240495">
										<mods:geographic>Asia</mods:geographic>
									</mods:subject>
								</xsl:if>
								<xsl:if test=".='South Asian studies'">
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/814190">
										<mods:topic>Area studies</mods:topic>
									</mods:subject>
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/1244520">
										<mods:geographic>South Asia</mods:geographic>
									</mods:subject>
								</xsl:if>
								<xsl:if test=".='African history'">
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/958235">
										<mods:topic>History</mods:topic>
									</mods:subject>
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/1239509">
										<mods:geographic>Africa</mods:geographic>
									</mods:subject>
								</xsl:if>
								<xsl:if test=".='East European studies'">
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/814190">
										<mods:topic>Area studies</mods:topic>
									</mods:subject>
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/1245079">
										<mods:geographic>Eastern Europe</mods:geographic>
									</mods:subject>
								</xsl:if>
								<xsl:if test=".='Sub Saharan Africa studies'">
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/814190">
										<mods:topic>Area studies</mods:topic>
									</mods:subject>
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/1239520">
										<mods:geographic>Sub-Saharan Africa</mods:geographic>
									</mods:subject>
								</xsl:if>
								<xsl:if test=".='American studies'">
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/814190">
										<mods:topic>Area studies</mods:topic>
									</mods:subject>
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/1239786">
										<mods:geographic>America</mods:geographic>
									</mods:subject>
								</xsl:if>
								<xsl:if test=".='Caribbean studies'">
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/814190">
										<mods:topic>Area studies</mods:topic>
									</mods:subject>
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/1244080">
										<mods:geographic>Caribbean Area</mods:geographic>
									</mods:subject>
								</xsl:if>
								<xsl:if test=".='Asian history'">
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/958235">
										<mods:topic>History</mods:topic>
									</mods:subject>
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/1240495">
										<mods:geographic>Asia</mods:geographic>
									</mods:subject>
								</xsl:if>
								<xsl:if test=".='Russian history'">
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/958235">
										<mods:topic>History</mods:topic>
									</mods:subject>
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/1207312">
										<mods:geographic>Russia</mods:geographic>
									</mods:subject>
								</xsl:if>
								<xsl:if test=".='Black studies'">
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/916061">
										<mods:topic>Ethnicity--Study and teaching</mods:topic>
									</mods:subject>
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/799707">
										<mods:topic>African Americans--Study and teaching</mods:topic>
									</mods:subject>
								</xsl:if>
								<xsl:if test=".='Medieval history'">
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/958235">
										<mods:topic>History</mods:topic>
									</mods:subject>
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/1020301">
										<mods:topic>Middle Ages</mods:topic>
									</mods:subject>
								</xsl:if>
								<xsl:if test=".='Hispanic American studies'">
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/957606">
										<mods:topic>Hispanic Americans--Study and teaching</mods:topic>
									</mods:subject>
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/916061">
										<mods:topic>Ethnicity--Study and teaching</mods:topic>
									</mods:subject>
								</xsl:if>
								<xsl:if test=".='African American studies'">
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/916061">
										<mods:topic>Ethnicity--Study and teaching</mods:topic>
									</mods:subject>
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/799707">
										<mods:topic>African Americans--Study and teaching</mods:topic>
									</mods:subject>
								</xsl:if>
								<xsl:if test=".='Polymer chemistry'">
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/1070588">
										<mods:topic>Polymers</mods:topic>
									</mods:subject>
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/853344">
										<mods:topic>Chemistry</mods:topic>
									</mods:subject>
								</xsl:if>
								<xsl:if test=".='Black history'">
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/958235">
										<mods:topic>History</mods:topic>
									</mods:subject>
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/799707">
										<mods:topic>African Americans--Study and teaching</mods:topic>
									</mods:subject>
								</xsl:if>
								<xsl:if test=".='Wood sciences'">
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/1011957">
										<mods:topic>Materials science</mods:topic>
									</mods:subject>
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/1179191">
										<mods:topic>Wood</mods:topic>
									</mods:subject>
								</xsl:if>
								<xsl:if test=".='Nuclear physics and radiation'">
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/1040386">
										<mods:topic>Nuclear physics</mods:topic>
									</mods:subject>
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/1086839">
										<mods:topic>Radiation</mods:topic>
									</mods:subject>
								</xsl:if>
								<xsl:if test=".='Slavic studies'">
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/916061">
										<mods:topic>Ethnicity--Study and teaching</mods:topic>
									</mods:subject>
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/1120787">
										<mods:topic>Slavs--Study and teaching</mods:topic>
									</mods:subject>
								</xsl:if>
								<xsl:if test=".='Obstetrics'">
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/1042994">
										<mods:topic>Obstetrics</mods:topic>
									</mods:subject>
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/949684">
										<mods:topic>Gynecology</mods:topic>
									</mods:subject>
								</xsl:if>
								<xsl:if test=".='Asian American studies'">
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/916061">
										<mods:topic>Ethnicity--Study and teaching</mods:topic>
									</mods:subject>
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/818620">
										<mods:topic>Asian Americans</mods:topic>
									</mods:subject>
								</xsl:if>
								<xsl:if test=".='French Canadian culture'">
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/916061">
										<mods:topic>Ethnicity--Study and teaching</mods:topic>
									</mods:subject>
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/934912">
										<mods:topic>French-Canadians</mods:topic>
									</mods:subject>
								</xsl:if>
								<xsl:if test=".='Geographic information science and geodesy'">
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/940423">
										<mods:topic>Geographic information systems</mods:topic>
									</mods:subject>
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/940371">
										<mods:topic>Geodesy</mods:topic>
									</mods:subject>    
								</xsl:if><xsl:if test=".='Science history'">
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/1108176">
										<mods:topic>Science</mods:topic>
									</mods:subject>    
									<mods:subject authority="fast" xmlns="http://www.loc.gov/mods/v3" valueURI="http://id.worldcat.org/fast/958235">
										<mods:topic>History</mods:topic>
									</mods:subject>       
								</xsl:if>    	
						</xsl:for-each>
					</xsl:when>
				</xsl:choose>
			</xsl:for-each>
		</xsl:for-each>
		<!--RESTRICTIONS AND ACCESS: ACCESSCONDITION-->
		<xsl:for-each select="DISS_repository">
			<mods:accessCondition xmlns="http://www.loc.gov/mods/v3" type="embargo end date">
				<xsl:value-of select="DISS_delayed_release"/>
			</mods:accessCondition>
			<mods:accessCondition xmlns="http://www.loc.gov/mods/v3" type="restriction on access">
				<xsl:value-of select="DISS_access_option"/>
			</mods:accessCondition>
			<!--  Embargo  -->
			<mods:accessCondition xmlns="http://www.loc.gov/mods/v3" type="embargo terms">
				<xsl:if test="DISS_acceptance = '1'">
					<xsl:value-of select="DISS_agreement_decision_date"/>
				</xsl:if>
			</mods:accessCondition>
		</xsl:for-each>
		<!--Added administrative metadata for record JRN 4/2017 -->
		<mods:recordInfo>
			<mods:recordContentSource authority="oclcorg">NKM</mods:recordContentSource>
			<mods:languageOfCataloging>
				<mods:languageTerm authority="iso639-2b">eng</mods:languageTerm>
			</mods:languageOfCataloging>
			<mods:recordInfoNote>Converted to MODS from ProQuest ETD metadata; ingested in Niner Commons 2022-06.</mods:recordInfoNote>
		</mods:recordInfo>
		<!-- Added collection name JRN 1/2019 -->
		<mods:relatedItem xmlns="http://www.loc.gov/mods/v3" type="host">
			<mods:titleInfo>
				<mods:title>UNC Charlotte electronic theses and dissertations</mods:title>
			</mods:titleInfo>
		</mods:relatedItem>
		<!-- Added DPLA and local rights statements JRN 4/2017 -->
		<mods:accessCondition displayLabel="DPLA" type="use and reproduction"
			xlink:href="http://rightsstatements.org/page/InC/1.0/">This Item is protected by
			copyright and/or related rights. You are free to use this Item in any way that is
			permitted by the copyright and related rights legislation that applies to your use. For
			other uses you need to obtain permission from the rights-holder(s). For additional
			information, see http://rightsstatements.org/page/InC/1.0/.</mods:accessCondition>
		<mods:accessCondition displayLabel="local" type="use and reproduction">Copyright is held by
			the author unless otherwise indicated.</mods:accessCondition>
		<!--  Mapped to DISS_submission/@embargo_code.  Conditional statements for embargo codes 0 - 2.  -->
		<xsl:for-each select="//@embargo_code">
			<xsl:choose>
				<xsl:when test=".=1">
					<accessCondition displayLabel="Embargo" type="restrictionOnAccess">This item is
						restricted from public view for 6 months after
						publication.</accessCondition>
				</xsl:when>
				<xsl:when test=".=2">
					<accessCondition displayLabel="Embargo" type="restrictionOnAccess">This item is
						restricted from public view for 1 year after publication.</accessCondition>
				</xsl:when>
				<xsl:when test=".=3">
					<accessCondition displayLabel="Embargo" type="restrictionOnAccess">This item is
						restricted from public view for 2 years after publication.</accessCondition>
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="strip-tags">
		<xsl:param name="text"/>
		<xsl:choose>
			<xsl:when test="contains($text, '&lt;')">
				<xsl:value-of select="substring-before($text, '&lt;')"/>
				<xsl:call-template name="strip-tags">
					<xsl:with-param name="text" select="substring-after($text, '&gt;')"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$text"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	
</xsl:stylesheet>
