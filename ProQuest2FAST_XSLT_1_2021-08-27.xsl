<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:mods="http://www.loc.gov/mods/v3" version="2.0" exclude-result-prefixes="mods">
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" media-type="text/xml"/>
    <xsl:strip-space elements="*"/>
    <!-- Removed final element that deletes the ProQuest subject vocabulary terms and student keywords JRN 2021-08-27 -->
    <!-- New version 2021-08-20 JRN doesn't make adjustments to recordInfo element; those adjustments will be made in second XSLT that removes duplicates and problematic accessCondition elements -->
    <!--   Takes the 'admin' note field keywords, excludes the 'admin' note field element that contains multiple keywords concatenated with commas, normalizes them to the FAST terms, and then deletes the original admin terms. In cases in which a ProQuest subject is tied to two FAST values, the stylesheet will insert both of the latter. The keywords in this field are from the ProQuest controlled subject vocabulary; this XSLT is normalizing those terms to FAST equivalents 2021-08-12 JRN  -->
    <!--   Matches on and tests value of admin note field, which contains the ProQuest subject vocabulary terms in Niner Commons ETD metadata. Excludes the admin note field with terms concatenated with commas, which are student-assigned keywords. JRN 5-27-2021   -->
    <!-- Template and param for converting upper-case keywords to camel case JRN 2021-08-09 -->
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
    <!-- beulah template represents value of ProQuest keywords in current ETD metadata; values are matched with variables below JRN 2021-08-09 -->
    <xsl:variable name="beulah"
        select="mods:mods/mods:note[@type='admin'][@displayLabel='Keywords']/text()[not(contains(.,','))]"/>
    <!-- Replacement values for current ETD ProQuest keywords JRN 2021-08-09 -->
    <xsl:variable name="Mechanical_engineering">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1013375">
            <mods:topic>Mechanical engineering</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Mechanics">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1013446">
            <mods:topic>Mechanics</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Materials_science">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1011957">
            <mods:topic>Materials science</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Special_education">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1128842">
            <mods:topic>Special education</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Electrical_engineering">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1728596">
            <mods:topic>Electrical engineering</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Optics">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1046845">
            <mods:topic>Optics</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Engineering">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/910312">
            <mods:topic>Engineering</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Nanoscience">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1032629">
            <mods:topic>Nanoscience</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Educational_counseling">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/903395">
            <mods:topic>Educational counseling</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Middle_school_education">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1020518">
            <mods:topic>Middle school education</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Multicultural_education">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1028816">
            <mods:topic>Multicultural education</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Computer_science">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/872451">
            <mods:topic>Computer science</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Mathematics--Study_and_teaching">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1012236">
            <mods:topic>Mathematics--Study and teaching</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Education">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/902499">
            <mods:topic>Education</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Mathematics">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1012163">
            <mods:topic>Mathematics</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Organizational_behavior">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1047801">
            <mods:topic>Organizational behavior</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Management">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1007141">
            <mods:topic>Management</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Chemistry">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/853344">
            <mods:topic>Chemistry</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Nanotechnology">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1032639">
            <mods:topic>Nanotechnology</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Nursing">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1041731">
            <mods:topic>Nursing</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Communication">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/869952">
            <mods:topic>Communication</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Medicine">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1014893">
            <mods:topic>Medicine</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Physics">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1063025">
            <mods:topic>Physics</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Civil_engineering">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/862488">
            <mods:topic>Civil engineering</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Transportation">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1155007">
            <mods:topic>Transportation</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Statistics">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1132103">
            <mods:topic>Statistics</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Sociology">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1123875">
            <mods:topic>Sociology</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Social_psychology">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1122816">
            <mods:topic>Social psychology</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Chemistry_Inorganic">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/853488">
            <mods:topic>Chemistry, Inorganic</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Molecular_biology">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1024734">
            <mods:topic>Molecular biology</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Literature">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/999953">
            <mods:topic>Literature</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="English_literature">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/911989">
            <mods:topic>English literature</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Power_resources">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1074275">
            <mods:topic>Power resources</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Counseling_psychology">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1740078">
            <mods:topic>Counseling psychology</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Social_structure">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1123372">
            <mods:topic>Social structure</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Womens_studies">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1178850">
            <mods:topic>Women's studies</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Geography">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/940469">
            <mods:topic>Geography</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Geodesy">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/940371">
            <mods:topic>Geodesy</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="City_planning">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/862177">
            <mods:topic>City planning</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Biomechanics">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/832558">
            <mods:topic>Biomechanics</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="History">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/958235">
            <mods:topic>History</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Public_health">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1082238">
            <mods:topic>Public health</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Educational_leadership">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/903527">
            <mods:topic>Educational leadership</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Automobiles--Design_and_construction">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/823374">
            <mods:topic>Automobiles--Design and construction</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Chemistry_Physical_and_theoretical">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/853521">
            <mods:topic>Chemistry, Physical and theoretical</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Marine_engineering">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1009532">
            <mods:topic>Marine engineering</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Government_policy">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1353198">
            <mods:topic>Government policy</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Political_science">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1069781">
            <mods:topic>Political science</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Sex_role">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1114598/">
            <mods:topic>Sex role</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Immunology">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/968006">
            <mods:topic>Immunology</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Virology">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1167670">
            <mods:topic>Virology</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Education_Higher--Administration">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/903010">
            <mods:topic>Education, Higher--Administration</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Community_colleges--Study_and_teaching">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/870810">
            <mods:topic>Community colleges--Study and teaching</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Industrial_engineering">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/970992">
            <mods:topic>Industrial engineering</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Operations_research">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1046387">
            <mods:topic>Operations research</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Commerce">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/869279">
            <mods:topic>Commerce</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Biology">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/832383">
            <mods:topic>Biology</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Microbiology">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1019576">
            <mods:topic>Microbiology</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Kinesiology">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/987619">
            <mods:topic>Kinesiology</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Educational_evaluation">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/903437">
            <mods:topic>Educational evaluation</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Early_childhood_education">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/900596">
            <mods:topic>Early childhood education</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Education_Elementary">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/902945">
            <mods:topic>Education, Elementary</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Finance">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/924349">
            <mods:topic>Finance</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Education_Higher">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/903005">
            <mods:topic>Education, Higher</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Economics">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/902116">
            <mods:topic>Economics</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Psychology">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1081447">
            <mods:topic>Psychology</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Psychology_Industrial">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1081592">
            <mods:topic>Psychology, Industrial</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Meteorology">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1018441">
            <mods:topic>Meteorology</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Teachers--Training_of">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1144404">
            <mods:topic>Teachers--Training of</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Library_science">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/997916">
            <mods:topic>Library science</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Computer_engineering">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/872078">
            <mods:topic>Computer engineering</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Diagnostic_imaging">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/892354">
            <mods:topic>Diagnostic imaging</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Reading">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1090626">
            <mods:topic>Reading</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Sustainability">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1747391">
            <mods:topic>Sustainability</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Robotics">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1098997">
            <mods:topic>Robotics</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Bioinformatics">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/832181">
            <mods:topic>Bioinformatics</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Information_technology">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/973089">
            <mods:topic>Information technology</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Environmental_engineering">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/912934">
            <mods:topic>Environmental engineering</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="English_language--Study_and_teaching--Foreign_speakers">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/911692">
            <mods:topic>English language--Study and teaching--Foreign speakers</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Language_and_languages--Study_and_teaching">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/992220">
            <mods:topic>Language and languages--Study and teaching</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Sports_administration">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1130552">
            <mods:topic>Sports administration</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Health_education">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/952878">
            <mods:topic>Health education</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Environmental_sciences">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/913474">
            <mods:topic>Environmental sciences</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Educational_psychology">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/903571">
            <mods:topic>Educational psychology</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Adult_education">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/797275">
            <mods:topic>Adult education</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Queer_studies">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="https://homosaurus.org/v2/queerStudies">
            <mods:topic>Queer studies</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Families--Study_and_teaching">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1728948">
            <mods:topic>Families--Study and teaching</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Social_sciences--Research">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1122944">
            <mods:topic>Social sciences--Research</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Curriculum_planning">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/885382">
            <mods:topic>Curriculum planning</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Renewable_energy_sources">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1094570">
            <mods:topic>Renewable energy sources</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Mass_media">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1011219">
            <mods:topic>Mass media</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Language_arts">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/992284">
            <mods:topic>Language arts</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Mental_health">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1016339">
            <mods:topic>Mental health</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Aerospace_engineering">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/798623">
            <mods:topic>Aerospace engineering</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Genetics">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/940117">
            <mods:topic>Genetics</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Environmental_economics">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/912895">
            <mods:topic>Environmental economics</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Educational_tests_and_measurements">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/903660">
            <mods:topic>Educational tests and measurements</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Artificial_intelligence">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/817247">
            <mods:topic>Artificial intelligence</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Rhetoric">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1096948">
            <mods:topic>Rhetoric</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Literature_Medieval">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1000151">
            <mods:topic>Literature, Medieval</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="History--Religious_aspects">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/958270">
            <mods:topic>History--Religious aspects</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Water_resources_development--Management">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1172006">
            <mods:topic>Water resources development--Management</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Epidemiology">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/914091">
            <mods:topic>Epidemiology</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Social_sciences">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1122877">
            <mods:topic>Social sciences</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Geomorphology">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/940955">
            <mods:topic>Geomorphology</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Geology">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/940627">
            <mods:topic>Geology</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Soil_science">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1124601">
            <mods:topic>Soil science</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Foreign_study">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/931877">
            <mods:topic>Foreign study</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Ecology">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/901476">
            <mods:topic>Ecology</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Conservation_biology">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/875490">
            <mods:topic>Conservation biology</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Education_and_state">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/902835">
            <mods:topic>Education and state</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Educational_sociology">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/903596">
            <mods:topic>Educational sociology</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Biochemistry">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/831961">
            <mods:topic>Biochemistry</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Geotechnical_engineering">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1893896">
            <mods:topic>Geotechnical engineering</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Criminology">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/883566">
            <mods:topic>Criminology</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Medical_sciences">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1014601">
            <mods:topic>Medical sciences</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Religion">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1093763">
            <mods:topic>Religion</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Architecture">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/813346">
            <mods:topic>Architecture</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Design">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/891253/">
            <mods:topic>Design</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Education--Finance">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/902637">
            <mods:topic>Education--Finance</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="School_management_and_organization">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1107575">
            <mods:topic>School management and organization</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Law">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/993678">
            <mods:topic>Law</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Animal_behavior">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/809079">
            <mods:topic>Animal behavior</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Physical_anthropology">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1062357">
            <mods:topic>Physical anthropology</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Cognitive_psychology">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/866541">
            <mods:topic>Cognitive psychology</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Planetary_science">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1065123">
            <mods:topic>Planetary science</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Human_ecology--Study_and_teaching">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/962987">
            <mods:topic>Human ecology--Study and teaching</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Ethnology">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/916106">
            <mods:topic>Ethnology</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Business">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/842262">
            <mods:topic>Business</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Physiology">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1063177">
            <mods:topic>Physiology</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Neurosciences">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1036509">
            <mods:topic>Neurosciences</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Biophysics">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/832656">
            <mods:topic>Biophysics</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Gifted_children--Education">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/942566">
            <mods:topic>Gifted children--Education</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Biomedical_engineering">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/832568">
            <mods:topic>Biomedical engineering</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Clinical_psychology">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/864407">
            <mods:topic>Clinical psychology</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Endocrinology">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/909749">
            <mods:topic>Endocrinology</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Hydrology">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/965147">
            <mods:topic>Hydrology</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Information_science">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/972640">
            <mods:topic>Information science</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Communication_of_technical_information">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/870307">
            <mods:topic>Communication of technical information</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Cytology">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/886282">
            <mods:topic>Cytology</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Public_health--Study_and_teaching">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1082320">
            <mods:topic>Public health--Study and teaching</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Educational_technology">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/903623">
            <mods:topic>Educational technology</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Art--Study_and_teaching">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/815338">
            <mods:topic>Art--Study and teaching</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Agriculture">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/801355">
            <mods:topic>Agriculture</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Gerontology">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/942204">
            <mods:topic>Gerontology</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Electromagnetism">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/906590">
            <mods:topic>Electromagnetism</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Biometry">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/832611">
            <mods:topic>Biometry</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Linguistics">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/999202">
            <mods:topic>Linguistics</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Creative_writing">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/882489">
            <mods:topic>Creative writing</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Entrepreneurship">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/912787">
            <mods:topic>Entrepreneurship</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Marine_biology">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1009447">
            <mods:topic>Marine biology</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Chemistry_Organic">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/853501">
            <mods:topic>Chemistry, Organic</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Analytical_chemistry">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/853459">
            <mods:topic>Analytical chemistry</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Oncology">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1045739">
            <mods:topic>Oncology</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Archaeology">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/812938">
            <mods:topic>Archaeology</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Civilization_Classical--Study_and_teaching">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/863004">
            <mods:topic>Civilization, Classical--Study and teaching</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Environmental_management">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/913186">
            <mods:topic>Environmental management</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Philosophy">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1060777">
            <mods:topic>Philosophy</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Education_Secondary">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/903252">
            <mods:topic>Education, Secondary</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Psychology_Experimental">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1081581">
            <mods:topic>Psychology, Experimental</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Science--Philosophy">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1108336">
            <mods:topic>Science--Philosophy</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Health_services_administration">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/953286">
            <mods:topic>Health services administration</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Geophysics">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/941002">
            <mods:topic>Geophysics</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="System_theory">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1141423">
            <mods:topic>System theory</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Industrial_management">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/971246">
            <mods:topic>Industrial management</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Religions">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1093898">
            <mods:topic>Religions</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Fluid_mechanics">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/927999">
            <mods:topic>Fluid mechanics</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Wildlife_conservation">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1175253">
            <mods:topic>Wildlife conservation</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Sound">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1126935">
            <mods:topic>Sound</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Psychobiology">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1081300">
            <mods:topic>Psychobiology</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Urban_forestry">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1162426">
            <mods:topic>Urban forestry</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Ethics">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/915833">
            <mods:topic>Ethics</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Philosophy_and_religion">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1060826">
            <mods:topic>Philosophy and religion</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Regression_analysis">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1432090">
            <mods:topic>Regression analysis</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Public_administration">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1081976">
            <mods:topic>Public administration</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Continuing_education">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/876705">
            <mods:topic>Continuing education</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Religious_education">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1093997">
            <mods:topic>Religious education</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Interactive_multimedia">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/975995">
            <mods:topic>Interactive multimedia</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Aesthetics">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/798702">
            <mods:topic>Aesthetics</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Sociolinguistics">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1123847">
            <mods:topic>Sociolinguistics</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Dance">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/887402">
            <mods:topic>Dance</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Psychophysiology">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1081674">
            <mods:topic>Psychophysiology</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Organizational_sociology">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1047878">
            <mods:topic>Organizational sociology</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="American_literature">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/807113">
            <mods:topic>American literature</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Performing_arts">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1057887">
            <mods:topic>Performing arts</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Data_sets">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/2003345">
            <mods:topic>Data sets</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Stock_repurchasing">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1133631">
            <mods:topic>Stock repurchasing</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Language_and_languages">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/992154">
            <mods:topic>Language and languages</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Nutrition">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1042187">
            <mods:topic>Nutrition</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="World_Wide_Web--Study_and_teaching">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1181331/">
            <mods:topic>World Wide Web--Study and teaching</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Astronomy">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/819673">
            <mods:topic>Astronomy</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Military_art_and_science">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1020874">
            <mods:topic>Military art and science</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Metrology">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1018841">
            <mods:topic>Metrology</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Zoology">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1184696">
            <mods:topic>Zoology</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Forests_and_forestry">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/932632">
            <mods:topic>Forests and forestry</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Disability_studies">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/894656">
            <mods:topic>Disability studies</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Transportation--Planning">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1155146">
            <mods:topic>Transportation--Planning</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Personality">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1058667">
            <mods:topic>Personality</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Remote_sensing">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1094469">
            <mods:topic>Remote sensing</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Environmental_geology">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/912988">
            <mods:topic>Environmental geology</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Geochemistry">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/940343">
            <mods:topic>Geochemistry</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Military_history">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1021222">
            <mods:topic>Military history</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Spirituality">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1130186">
            <mods:topic>Spirituality</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Science--Study_and_teaching">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1108387">
            <mods:topic>Science--Study and teaching</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Building">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/840551">
            <mods:topic>Building</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Aging">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/800293">
            <mods:topic>Aging</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Dentistry">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/890633">
            <mods:topic>Dentistry</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Paleoecology">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1051384">
            <mods:topic>Paleoecology</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Metaphysics">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1018304">
            <mods:topic>Metaphysics</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Sex">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1114160">
            <mods:topic>Sex</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Accounting">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/795379">
            <mods:topic>Accounting</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Marketing">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1010167">
            <mods:topic>Marketing</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Area_studies">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/814190">
            <mods:topic>Area studies</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Botany">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/836869">
            <mods:topic>Botany</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Paleontology">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1051513">
            <mods:topic>Paleontology</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Sedimentology">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1111003">
            <mods:topic>Sedimentology</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Land_use--Planning">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/991528">
            <mods:topic>Land use--Planning</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="African_literature">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/799832">
            <mods:topic>African literature</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Automated_vehicles">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1909261">
            <mods:topic>Automated vehicles</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Social_sciences--Study_and_teaching">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1123000">
            <mods:topic>Social sciences--Study and teaching</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Evolutionary_developmental_biology">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1909527">
            <mods:topic>Evolutionary developmental biology</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Plant_diseases">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1065378">
            <mods:topic>Plant diseases</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Aquatic_sciences">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/812097">
            <mods:topic>Aquatic sciences</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Industrial_relations">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/971609">
            <mods:topic>Industrial relations</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="DNA">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/886555">
            <mods:topic>DNA</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Animal_scientists">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/809386">
            <mods:topic>Animal scientists</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Wildlife_management">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1175323">
            <mods:topic>Wildlife management</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Translations">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1154827">
            <mods:topic>Translations</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Motion_pictures">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1027285">
            <mods:topic>Motion pictures</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Social_service">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1123192">
            <mods:topic>Social service</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Museums--Study_and_teaching">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1030207">
            <mods:topic>Museums--Study and teaching</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Developmental_psychology">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/891816">
            <mods:topic>Developmental psychology</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Latin_American_literature">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/993031">
            <mods:topic>Latin American literature</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Instructional_systems--Design">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/974357">
            <mods:topic>Instructional systems--Design</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Theology">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1149559">
            <mods:topic>Theology</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Recreation">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1091713">
            <mods:topic>Recreation</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Banks_and_banking">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/826867">
            <mods:topic>Banks and banking</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Statistical_physics">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1132076">
            <mods:topic>Statistical physics</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Islam--Study_and_teaching">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/979852">
            <mods:topic>Islam--Study and teaching</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Natural_resources--Management">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1034438">
            <mods:topic>Natural resources--Management</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Petrology">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1059885">
            <mods:topic>Petrology</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Thermodynamics">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1149832">
            <mods:topic>Thermodynamics</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Atmospheric_science">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/2003481">
            <mods:topic>Atmospheric science</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Judaism--Study_and_teaching">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/984412">
            <mods:topic>Judaism--Study and teaching</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="International_relations">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/977053">
            <mods:topic>International relations</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Medical_personnel">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1014407">
            <mods:topic>Medical personnel</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Mechanics_Applied--Mathematics">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1013494/">
            <mods:topic>Mechanics, Applied--Mathematics</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Three-dimensional_modeling">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1910261">
            <mods:topic>Three-dimensional modeling</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Leadership">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/994701">
            <mods:topic>Leadership</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Acoustic_emission">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/795898">
            <mods:topic>Acoustic emission</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Obstetrics">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1042994">
            <mods:topic>Obstetrics</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Parasitology">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1053186">
            <mods:topic>Parasitology</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Electric_power_systems">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/905529">
            <mods:topic>Electric power systems</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Folklore">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/930306">
            <mods:topic>Folklore</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Hydraulic_engineering">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/964596">
            <mods:topic>Hydraulic engineering</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Surgery">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1139351">
            <mods:topic>Surgery</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Climatic_changes">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/864229">
            <mods:topic>Climatic changes</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Pathology">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1054964">
            <mods:topic>Pathology</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Pharmacy--Research">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1060314">
            <mods:topic>Pharmacy--Research</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Childrens_literature">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1759351">
            <mods:topic>Children's literature</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="History_Modern">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/958367">
            <mods:topic>History, Modern</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Demography">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/890158">
            <mods:topic>Demography</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Condensed_matter">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/874443">
            <mods:topic>Condensed matter</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Speech_therapy">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1129277">
            <mods:topic>Speech therapy</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Music_therapy">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1030628">
            <mods:topic>Music therapy</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Music--Instruction_and_study">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1030347">
            <mods:topic>Music--Instruction and study</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Professional_learning_communities">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1747223">
            <mods:topic>Professional learning communities</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Psychology--Statistical_methods">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1081529/">
            <mods:topic>Psychology--Statistical methods</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Paleoclimatology">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1051364">
            <mods:topic>Paleoclimatology</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Agriculture--Economic_aspects">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/801415">
            <mods:topic>Agriculture--Economic aspects</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Cultural_property--Protection">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/885019">
            <mods:topic>Cultural property--Protection</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Ethnicity--Study_and_teaching">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/916061">
            <mods:topic>Ethnicity--Study and teaching</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Physical_geography">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1062647">
            <mods:topic>Physical geography</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Education--Philosophy">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/902721/">
            <mods:topic>Education--Philosophy</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Bioengineering">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/832028">
            <mods:topic>Bioengineering</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Career_development">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/847280">
            <mods:topic>Career development</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Behavior_therapy">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/829929">
            <mods:topic>Behavior therapy</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Visual_perception">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1168049">
            <mods:topic>Visual perception</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Alternative_medicine">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/806153">
            <mods:topic>Alternative medicine</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Obesity_in_children">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1042770">
            <mods:topic>Obesity in children</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Toxicology">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1153364">
            <mods:topic>Toxicology</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Indigenous_peoples">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/970213">
            <mods:topic>Indigenous peoples</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="North_America">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1242475">
            <mods:topic>North America</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Developmental_biology">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/891773">
            <mods:topic>Developmental biology</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Agricultural_engineering">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/800726">
            <mods:topic>Agricultural engineering</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="World_history">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1181345">
            <mods:topic>World history</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Pharmacology">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1060259">
            <mods:topic>Pharmacology</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Health--Social_aspects">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/952795">
            <mods:topic>Health--Social aspects</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Medical_ethics">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1014081">
            <mods:topic>Medical ethics</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Hispanic_Americans--Study_and_teaching">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/957606">
            <mods:topic>Hispanic Americans--Study and teaching</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Polymers">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1070588">
            <mods:topic>Polymers</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Nuclear_physics">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1040386">
            <mods:topic>Nuclear physics</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Commodity_exchanges">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/869717">
            <mods:topic>Commodity exchanges</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="African_Americans--Study_and_teaching">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/799707">
            <mods:topic>African Americans--Study and teaching</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Middle_Ages">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1020301">
            <mods:topic>Middle Ages</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Wood">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1179191">
            <mods:topic>Wood</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Radiation">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1086839">
            <mods:topic>Radiation</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Energy_industries">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/910110">
            <mods:topic>Energy industries</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Optical_engineering">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1740023">
            <mods:topic>Optical engineering</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Slavs--Study_and_teaching">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1120787">
            <mods:topic>Slavs--Study and teaching</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Gynecology">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/949684">
            <mods:topic>Gynecology</mods:topic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="America">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1239786">
            <mods:geographic>America</mods:geographic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Latin_America">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1245945">
            <mods:geographic>Latin America</mods:geographic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Africa">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1239509">
            <mods:geographic>Africa</mods:geographic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Southeast_Asia">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1240499">
            <mods:geographic>Southeast Asia</mods:geographic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Europe">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1245064">
            <mods:geographic>Europe</mods:geographic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Asia">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1240495">
            <mods:geographic>Asia</mods:geographic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="South_Asia">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1244520">
            <mods:geographic>South Asia</mods:geographic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Middle_East">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1241586">
            <mods:geographic>Middle East</mods:geographic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Eastern_Europe">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1245079">
            <mods:geographic>Eastern Europe</mods:geographic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Sub-Saharan_Africa">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1239520">
            <mods:geographic>Sub-Saharan Africa</mods:geographic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Caribbean_Area">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1244080">
            <mods:geographic>Caribbean Area</mods:geographic>
        </mods:subject>
    </xsl:variable>
    <xsl:variable name="Russia">
        <mods:subject xmlns="http://www.loc.gov/mods/v3" authority="fast"
            valueURI="http://id.worldcat.org/fast/1207312">
            <mods:geographic>Russia</mods:geographic>
        </mods:subject>
    </xsl:variable>
    <!-- Identity transform piece that copies entire MODS document and makes only the changes specified by the templates below JRN 2021-08-09 -->
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()[normalize-space()]|@*[normalize-space()]"/>
        </xsl:copy>
    </xsl:template>
    <!-- Removes spaces in role terms for committee members and advisors JRN 2021-08-27 -->
    <xsl:template match="/mods:mods/mods:name/mods:role/mods:roleTerm/text()">
        <xsl:value-of select="normalize-space()"/>
    </xsl:template>
    <!-- Templates compare keyword value in current ETD metadata and replace those keywords with the FAST terms in the keywords above JRN 2021-08-09 -->
    <xsl:template match="mods:typeOfResource[parent::mods:mods]">
        <xsl:copy-of select="."/>
        <xsl:if test="$beulah='MECHANICAL ENGINEERING'">
            <xsl:apply-templates select="$Mechanical_engineering"/>
        </xsl:if>
        <xsl:if test="$beulah='MECHANICS'">
            <xsl:apply-templates select="$Mechanics"/>
        </xsl:if>
        <xsl:if test="$beulah='MATERIALS SCIENCE'">
            <xsl:apply-templates select="$Materials_science"/>
        </xsl:if>
        <xsl:if test="$beulah='SPECIAL EDUCATION'">
            <xsl:apply-templates select="$Special_education"/>
        </xsl:if>
        <xsl:if test="$beulah='ELECTRICAL ENGINEERING'">
            <xsl:apply-templates select="$Electrical_engineering"/>
        </xsl:if>
        <xsl:if test="$beulah='OPTICS'">
            <xsl:apply-templates select="$Optics"/>
        </xsl:if>
        <xsl:if test="$beulah='ENGINEERING'">
            <xsl:apply-templates select="$Engineering"/>
        </xsl:if>
        <xsl:if test="$beulah='NANOSCIENCE'">
            <xsl:apply-templates select="$Nanoscience"/>
        </xsl:if>
        <xsl:if test="$beulah='SCHOOL COUNSELING'">
            <xsl:apply-templates select="$Educational_counseling"/>
        </xsl:if>
        <xsl:if test="$beulah='MIDDLE SCHOOL EDUCATION'">
            <xsl:apply-templates select="$Middle_school_education"/>
        </xsl:if>
        <xsl:if test="$beulah='MULTICULTURAL EDUCATION'">
            <xsl:apply-templates select="$Multicultural_education"/>
        </xsl:if>
        <xsl:if test="$beulah='COMPUTER SCIENCE'">
            <xsl:apply-templates select="$Computer_science"/>
        </xsl:if>
        <xsl:if test="$beulah='MATHEMATICS EDUCATION'">
            <xsl:apply-templates select="$Mathematics--Study_and_teaching"/>
        </xsl:if>
        <xsl:if test="$beulah='EDUCATION'">
            <xsl:apply-templates select="$Education"/>
        </xsl:if>
        <xsl:if test="$beulah='MATHEMATICS'">
            <xsl:apply-templates select="$Mathematics"/>
        </xsl:if>
        <xsl:if test="$beulah='ORGANIZATIONAL BEHAVIOR'">
            <xsl:apply-templates select="$Organizational_behavior"/>
        </xsl:if>
        <xsl:if test="$beulah='MANAGEMENT'">
            <xsl:apply-templates select="$Management"/>
        </xsl:if>
        <xsl:if test="$beulah='CHEMISTRY'">
            <xsl:apply-templates select="$Chemistry"/>
        </xsl:if>
        <xsl:if test="$beulah='NANOTECHNOLOGY'">
            <xsl:apply-templates select="$Nanotechnology"/>
        </xsl:if>
        <xsl:if test="$beulah='NURSING'">
            <xsl:apply-templates select="$Nursing"/>
        </xsl:if>
        <xsl:if test="$beulah='COMMUNICATION'">
            <xsl:apply-templates select="$Communication"/>
        </xsl:if>
        <xsl:if test="$beulah='MEDICINE'">
            <xsl:apply-templates select="$Medicine"/>
        </xsl:if>
        <xsl:if test="$beulah='PHYSICS'">
            <xsl:apply-templates select="$Physics"/>
        </xsl:if>
        <xsl:if test="$beulah='CIVIL ENGINEERING'">
            <xsl:apply-templates select="$Civil_engineering"/>
        </xsl:if>
        <xsl:if test="$beulah='TRANSPORTATION'">
            <xsl:apply-templates select="$Transportation"/>
        </xsl:if>
        <xsl:if test="$beulah='STATISTICS'">
            <xsl:apply-templates select="$Statistics"/>
        </xsl:if>
        <xsl:if test="$beulah='SOCIOLOGY'">
            <xsl:apply-templates select="$Sociology"/>
        </xsl:if>
        <xsl:if test="$beulah='SOCIAL PSYCHOLOGY'">
            <xsl:apply-templates select="$Social_psychology"/>
        </xsl:if>
        <xsl:if test="$beulah='INORGANIC CHEMISTRY'">
            <xsl:apply-templates select="$Chemistry_Inorganic"/>
        </xsl:if>
        <xsl:if test="$beulah='MOLECULAR BIOLOGY'">
            <xsl:apply-templates select="$Molecular_biology"/>
        </xsl:if>
        <xsl:if test="$beulah='LITERATURE'">
            <xsl:apply-templates select="$Literature"/>
        </xsl:if>
        <xsl:if test="$beulah='ENGLISH LITERATURE'">
            <xsl:apply-templates select="$English_literature"/>
        </xsl:if>
        <xsl:if test="$beulah='ENERGY'">
            <xsl:apply-templates select="$Power_resources"/>
        </xsl:if>
        <xsl:if test="$beulah='COUNSELING PSYCHOLOGY'">
            <xsl:apply-templates select="$Counseling_psychology"/>
        </xsl:if>
        <xsl:if test="$beulah='SOCIAL STRUCTURE'">
            <xsl:apply-templates select="$Social_structure"/>
        </xsl:if>
        <!-- Double apostrophe JRN 2021-08-12 -->
        <xsl:if test="$beulah='WOMEN''S STUDIES'">
            <xsl:apply-templates select="$Womens_studies"/>
        </xsl:if>
        <xsl:if test="$beulah='GEOGRAPHY'">
            <xsl:apply-templates select="$Geography"/>
        </xsl:if>
        <xsl:if test="$beulah='GEOGRAPHIC INFORMATION SCIENCE AND GEODESY'">
            <xsl:apply-templates select="$Geodesy"/>
        </xsl:if>
        <xsl:if test="$beulah='URBAN PLANNING'">
            <xsl:apply-templates select="$City_planning"/>
        </xsl:if>
        <xsl:if test="$beulah='BIOMECHANICS'">
            <xsl:apply-templates select="$Biomechanics"/>
        </xsl:if>
        <xsl:if test="$beulah='HISTORY'">
            <xsl:apply-templates select="$History"/>
        </xsl:if>
        <xsl:if test="$beulah='PUBLIC HEALTH'">
            <xsl:apply-templates select="$Public_health"/>
        </xsl:if>
        <xsl:if test="$beulah='EDUCATIONAL LEADERSHIP'">
            <xsl:apply-templates select="$Educational_leadership"/>
        </xsl:if>
        <xsl:if test="$beulah='AUTOMOTIVE ENGINEERING'">
            <xsl:apply-templates select="$Automobiles--Design_and_construction"/>
        </xsl:if>
        <xsl:if test="$beulah='PHYSICAL CHEMISTRY'">
            <xsl:apply-templates select="$Chemistry_Physical_and_theoretical"/>
        </xsl:if>
        <xsl:if test="$beulah='NAVAL ENGINEERING'">
            <xsl:apply-templates select="$Marine_engineering"/>
        </xsl:if>
        <xsl:if test="$beulah='PUBLIC POLICY'">
            <xsl:apply-templates select="$Government_policy"/>
        </xsl:if>
        <xsl:if test="$beulah='POLITICAL SCIENCE'">
            <xsl:apply-templates select="$Political_science"/>
        </xsl:if>
        <xsl:if test="$beulah='GENDER STUDIES'">
            <xsl:apply-templates select="$Sex_role"/>
        </xsl:if>
        <xsl:if test="$beulah='IMMUNOLOGY'">
            <xsl:apply-templates select="$Immunology"/>
        </xsl:if>
        <xsl:if test="$beulah='VIROLOGY'">
            <xsl:apply-templates select="$Virology"/>
        </xsl:if>
        <xsl:if test="$beulah='HIGHER EDUCATION ADMINISTRATION'">
            <xsl:apply-templates select="$Education_Higher--Administration"/>
        </xsl:if>
        <xsl:if test="$beulah='COMMUNITY COLLEGE EDUCATION'">
            <xsl:apply-templates select="$Community_colleges--Study_and_teaching"/>
        </xsl:if>
        <xsl:if test="$beulah='INDUSTRIAL ENGINEERING'">
            <xsl:apply-templates select="$Industrial_engineering"/>
        </xsl:if>
        <xsl:if test="$beulah='OPERATIONS RESEARCH'">
            <xsl:apply-templates select="$Operations_research"/>
        </xsl:if>
        <xsl:if test="$beulah='COMMERCE-BUSINESS'">
            <xsl:apply-templates select="$Commerce"/>
        </xsl:if>
        <xsl:if test="$beulah='BIOLOGY'">
            <xsl:apply-templates select="$Biology"/>
        </xsl:if>
        <xsl:if test="$beulah='MICROBIOLOGY'">
            <xsl:apply-templates select="$Microbiology"/>
        </xsl:if>
        <xsl:if test="$beulah='KINESIOLOGY'">
            <xsl:apply-templates select="$Kinesiology"/>
        </xsl:if>
        <xsl:if test="$beulah='EDUCATIONAL EVALUATION'">
            <xsl:apply-templates select="$Educational_evaluation"/>
        </xsl:if>
        <xsl:if test="$beulah='EARLY CHILDHOOD EDUCATION'">
            <xsl:apply-templates select="$Early_childhood_education"/>
        </xsl:if>
        <xsl:if test="$beulah='ELEMENTARY EDUCATION'">
            <xsl:apply-templates select="$Education_Elementary"/>
        </xsl:if>
        <xsl:if test="$beulah='FINANCE'">
            <xsl:apply-templates select="$Finance"/>
        </xsl:if>
        <xsl:if test="$beulah='HIGHER EDUCATION'">
            <xsl:apply-templates select="$Education_Higher"/>
        </xsl:if>
        <xsl:if test="$beulah='ECONOMICS'">
            <xsl:apply-templates select="$Economics"/>
        </xsl:if>
        <xsl:if test="$beulah='PSYCHOLOGY'">
            <xsl:apply-templates select="$Psychology"/>
        </xsl:if>
        <xsl:if test="$beulah='OCCUPATIONAL PSYCHOLOGY'">
            <xsl:apply-templates select="$Psychology_Industrial"/>
        </xsl:if>
        <xsl:if test="$beulah='METEOROLOGY'">
            <xsl:apply-templates select="$Meteorology"/>
        </xsl:if>
        <xsl:if test="$beulah='TEACHER EDUCATION'">
            <xsl:apply-templates select="$Teachers--Training_of"/>
        </xsl:if>
        <xsl:if test="$beulah='LIBRARY SCIENCE'">
            <xsl:apply-templates select="$Library_science"/>
        </xsl:if>
        <xsl:if test="$beulah='COMPUTER ENGINEERING'">
            <xsl:apply-templates select="$Computer_engineering"/>
        </xsl:if>
        <xsl:if test="$beulah='MEDICAL IMAGING AND RADIOLOGY'">
            <xsl:apply-templates select="$Diagnostic_imaging"/>
        </xsl:if>
        <xsl:if test="$beulah='READING INSTRUCTION'">
            <xsl:apply-templates select="$Reading"/>
        </xsl:if>
        <xsl:if test="$beulah='SUSTAINABILITY'">
            <xsl:apply-templates select="$Sustainability"/>
        </xsl:if>
        <xsl:if test="$beulah='ROBOTICS'">
            <xsl:apply-templates select="$Robotics"/>
        </xsl:if>
        <xsl:if test="$beulah='BIOINFORMATICS'">
            <xsl:apply-templates select="$Bioinformatics"/>
        </xsl:if>
        <xsl:if test="$beulah='INFORMATION TECHNOLOGY'">
            <xsl:apply-templates select="$Information_technology"/>
        </xsl:if>
        <xsl:if test="$beulah='APPLIED MATHEMATICS'">
            <xsl:apply-templates select="$Mathematics"/>
        </xsl:if>
        <xsl:if test="$beulah='ENVIRONMENTAL ENGINEERING'">
            <xsl:apply-templates select="$Environmental_engineering"/>
        </xsl:if>
        <xsl:if test="$beulah='ENGLISH AS A SECOND LANGUAGE'">
            <xsl:apply-templates select="$English_language--Study_and_teaching--Foreign_speakers"/>
        </xsl:if>
        <xsl:if test="$beulah='FOREIGN LANGUAGE INSTRUCTION'">
            <xsl:apply-templates select="$Language_and_languages--Study_and_teaching"/>
        </xsl:if>
        <xsl:if test="$beulah='SPORTS MANAGEMENT'">
            <xsl:apply-templates select="$Sports_administration"/>
        </xsl:if>
        <xsl:if test="$beulah='HEALTH EDUCATION'">
            <xsl:apply-templates select="$Health_education"/>
        </xsl:if>
        <xsl:if test="$beulah='ENVIRONMENTAL SCIENCE'">
            <xsl:apply-templates select="$Environmental_sciences"/>
        </xsl:if>
        <xsl:if test="$beulah='EDUCATIONAL PSYCHOLOGY'">
            <xsl:apply-templates select="$Educational_psychology"/>
        </xsl:if>
        <xsl:if test="$beulah='ADULT EDUCATION'">
            <xsl:apply-templates select="$Adult_education"/>
        </xsl:if>
        <xsl:if test="$beulah='LGBTQ STUDIES'">
            <xsl:apply-templates select="$Queer_studies"/>
        </xsl:if>
        <!-- Includes ampersand JRN 2021-08-12 -->
        <xsl:if test="$beulah='INDIVIDUAL &amp; FAMILY STUDIES'">
            <xsl:apply-templates select="$Families--Study_and_teaching"/>
        </xsl:if>
        <xsl:if test="$beulah='SOCIAL RESEARCH'">
            <xsl:apply-templates select="$Social_sciences--Research"/>
        </xsl:if>
        <xsl:if test="$beulah='CURRICULUM DEVELOPMENT'">
            <xsl:apply-templates select="$Curriculum_planning"/>
        </xsl:if>
        <xsl:if test="$beulah='ALTERNATIVE ENERGY'">
            <xsl:apply-templates select="$Renewable_energy_sources"/>
        </xsl:if>
        <xsl:if test="$beulah='MASS COMMUNICATION'">
            <xsl:apply-templates select="$Mass_media"/>
        </xsl:if>
        <xsl:if test="$beulah='LANGUAGE ARTS'">
            <xsl:apply-templates select="$Language_arts"/>
        </xsl:if>
        <xsl:if test="$beulah='MENTAL HEALTH'">
            <xsl:apply-templates select="$Mental_health"/>
        </xsl:if>
        <xsl:if test="$beulah='AEROSPACE ENGINEERING'">
            <xsl:apply-templates select="$Aerospace_engineering"/>
        </xsl:if>
        <xsl:if test="$beulah='GENETICS'">
            <xsl:apply-templates select="$Genetics"/>
        </xsl:if>
        <xsl:if test="$beulah='ENVIRONMENTAL ECONOMICS'">
            <xsl:apply-templates select="$Environmental_economics"/>
        </xsl:if>
        <!-- Includes ampersand JRN 2021-08-12 -->
        <xsl:if test="$beulah='EDUCATIONAL TESTS &amp; MEASUREMENTS'">
            <xsl:apply-templates select="$Educational_tests_and_measurements"/>
        </xsl:if>
        <xsl:if test="$beulah='ARTIFICIAL INTELLIGENCE'">
            <xsl:apply-templates select="$Artificial_intelligence"/>
        </xsl:if>
        <xsl:if test="$beulah='RHETORIC'">
            <xsl:apply-templates select="$Rhetoric"/>
        </xsl:if>
        <xsl:if test="$beulah='MEDIEVAL LITERATURE'">
            <xsl:apply-templates select="$Literature_Medieval"/>
        </xsl:if>
        <xsl:if test="$beulah='RELIGIOUS HISTORY'">
            <xsl:apply-templates select="$History--Religious_aspects"/>
        </xsl:if>
        <xsl:if test="$beulah='WATER RESOURCES MANAGEMENT'">
            <xsl:apply-templates select="$Water_resources_development--Management"/>
        </xsl:if>
        <xsl:if test="$beulah='EPIDEMIOLOGY'">
            <xsl:apply-templates select="$Epidemiology"/>
        </xsl:if>
        <xsl:if test="$beulah='BEHAVIORAL SCIENCES'">
            <xsl:apply-templates select="$Social_sciences"/>
        </xsl:if>
        <xsl:if test="$beulah='PEDAGOGY'">
            <xsl:apply-templates select="$Education"/>
        </xsl:if>
        <xsl:if test="$beulah='GEOMORPHOLOGY'">
            <xsl:apply-templates select="$Geomorphology"/>
        </xsl:if>
        <xsl:if test="$beulah='GEOLOGY'">
            <xsl:apply-templates select="$Geology"/>
        </xsl:if>
        <xsl:if test="$beulah='SOIL SCIENCES'">
            <xsl:apply-templates select="$Soil_science"/>
        </xsl:if>
        <xsl:if test="$beulah='STUDY ABROAD'">
            <xsl:apply-templates select="$Foreign_study"/>
        </xsl:if>
        <xsl:if test="$beulah='ECOLOGY'">
            <xsl:apply-templates select="$Ecology"/>
        </xsl:if>
        <xsl:if test="$beulah='CONSERVATION BIOLOGY'">
            <xsl:apply-templates select="$Conservation_biology"/>
        </xsl:if>
        <xsl:if test="$beulah='EDUCATION POLICY'">
            <xsl:apply-templates select="$Education_and_state"/>
        </xsl:if>
        <xsl:if test="$beulah='EDUCATIONAL SOCIOLOGY'">
            <xsl:apply-templates select="$Educational_sociology"/>
        </xsl:if>
        <xsl:if test="$beulah='BIOCHEMISTRY'">
            <xsl:apply-templates select="$Biochemistry"/>
        </xsl:if>
        <xsl:if test="$beulah='GEOTECHNOLOGY'">
            <xsl:apply-templates select="$Geotechnical_engineering"/>
        </xsl:if>
        <xsl:if test="$beulah='CRIMINOLOGY'">
            <xsl:apply-templates select="$Criminology"/>
        </xsl:if>
        <xsl:if test="$beulah='HEALTH SCIENCES'">
            <xsl:apply-templates select="$Medical_sciences"/>
        </xsl:if>
        <xsl:if test="$beulah='RELIGION'">
            <xsl:apply-templates select="$Religion"/>
        </xsl:if>
        <xsl:if test="$beulah='ARCHITECTURE'">
            <xsl:apply-templates select="$Architecture"/>
        </xsl:if>
        <xsl:if test="$beulah='DESIGN'">
            <xsl:apply-templates select="$Design"/>
        </xsl:if>
        <xsl:if test="$beulah='EDUCATION FINANCE'">
            <xsl:apply-templates select="$Education--Finance"/>
        </xsl:if>
        <xsl:if test="$beulah='EDUCATIONAL ADMINISTRATION'">
            <xsl:apply-templates select="$School_management_and_organization"/>
        </xsl:if>
        <xsl:if test="$beulah='LAW'">
            <xsl:apply-templates select="$Law"/>
        </xsl:if>
        <xsl:if test="$beulah='ANIMAL BEHAVIOR'">
            <xsl:apply-templates select="$Animal_behavior"/>
        </xsl:if>
        <xsl:if test="$beulah='PHYSICAL ANTHROPOLOGY'">
            <xsl:apply-templates select="$Physical_anthropology"/>
        </xsl:if>
        <xsl:if test="$beulah='COGNITIVE PSYCHOLOGY'">
            <xsl:apply-templates select="$Cognitive_psychology"/>
        </xsl:if>
        <xsl:if test="$beulah='PLANETOLOGY'">
            <xsl:apply-templates select="$Planetary_science"/>
        </xsl:if>
        <xsl:if test="$beulah='ENVIRONMENTAL STUDIES'">
            <xsl:apply-templates select="$Human_ecology--Study_and_teaching"/>
        </xsl:if>
        <xsl:if test="$beulah='CULTURAL ANTHROPOLOGY'">
            <xsl:apply-templates select="$Ethnology"/>
        </xsl:if>
        <xsl:if test="$beulah='BUSINESS'">
            <xsl:apply-templates select="$Business"/>
        </xsl:if>
        <xsl:if test="$beulah='PHYSIOLOGY'">
            <xsl:apply-templates select="$Physiology"/>
        </xsl:if>
        <xsl:if test="$beulah='NEUROSCIENCES'">
            <xsl:apply-templates select="$Neurosciences"/>
        </xsl:if>
        <xsl:if test="$beulah='BIOPHYSICS'">
            <xsl:apply-templates select="$Biophysics"/>
        </xsl:if>
        <xsl:if test="$beulah='GIFTED EDUCATION'">
            <xsl:apply-templates select="$Gifted_children--Education"/>
        </xsl:if>
        <xsl:if test="$beulah='BIOMEDICAL ENGINEERING'">
            <xsl:apply-templates select="$Biomedical_engineering"/>
        </xsl:if>
        <xsl:if test="$beulah='CLINICAL PSYCHOLOGY'">
            <xsl:apply-templates select="$Clinical_psychology"/>
        </xsl:if>
        <xsl:if test="$beulah='ENDOCRINOLOGY'">
            <xsl:apply-templates select="$Endocrinology"/>
        </xsl:if>
        <xsl:if test="$beulah='HYDROLOGIC SCIENCES'">
            <xsl:apply-templates select="$Hydrology"/>
        </xsl:if>
        <xsl:if test="$beulah='INFORMATION SCIENCE'">
            <xsl:apply-templates select="$Information_science"/>
        </xsl:if>
        <xsl:if test="$beulah='TECHNICAL COMMUNICATION'">
            <xsl:apply-templates select="$Communication_of_technical_information"/>
        </xsl:if>
        <xsl:if test="$beulah='CELLULAR BIOLOGY'">
            <xsl:apply-templates select="$Cytology"/>
        </xsl:if>
        <xsl:if test="$beulah='PUBLIC HEALTH EDUCATION'">
            <xsl:apply-templates select="$Public_health--Study_and_teaching"/>
        </xsl:if>
        <xsl:if test="$beulah='EDUCATIONAL TECHNOLOGY'">
            <xsl:apply-templates select="$Educational_technology"/>
        </xsl:if>
        <xsl:if test="$beulah='ART EDUCATION'">
            <xsl:apply-templates select="$Art--Study_and_teaching"/>
        </xsl:if>
        <xsl:if test="$beulah='AGRICULTURE'">
            <xsl:apply-templates select="$Agriculture"/>
        </xsl:if>
        <xsl:if test="$beulah='GERONTOLOGY'">
            <xsl:apply-templates select="$Gerontology"/>
        </xsl:if>
        <xsl:if test="$beulah='ELECTROMAGNETICS'">
            <xsl:apply-templates select="$Electromagnetism"/>
        </xsl:if>
        <xsl:if test="$beulah='BIOSTATISTICS'">
            <xsl:apply-templates select="$Biometry"/>
        </xsl:if>
        <xsl:if test="$beulah='LINGUISTICS'">
            <xsl:apply-templates select="$Linguistics"/>
        </xsl:if>
        <xsl:if test="$beulah='CREATIVE WRITING'">
            <xsl:apply-templates select="$Creative_writing"/>
        </xsl:if>
        <xsl:if test="$beulah='ENTREPRENEURSHIP'">
            <xsl:apply-templates select="$Entrepreneurship"/>
        </xsl:if>
        <xsl:if test="$beulah='BIOLOGICAL OCEANOGRAPHY'">
            <xsl:apply-templates select="$Marine_biology"/>
        </xsl:if>
        <xsl:if test="$beulah='ORGANIC CHEMISTRY'">
            <xsl:apply-templates select="$Chemistry_Organic"/>
        </xsl:if>
        <xsl:if test="$beulah='ANALYTICAL CHEMISTRY'">
            <xsl:apply-templates select="$Analytical_chemistry"/>
        </xsl:if>
        <xsl:if test="$beulah='ONCOLOGY'">
            <xsl:apply-templates select="$Oncology"/>
        </xsl:if>
        <xsl:if test="$beulah='ARCHAEOLOGY'">
            <xsl:apply-templates select="$Archaeology"/>
        </xsl:if>
        <xsl:if test="$beulah='CLASSICAL STUDIES'">
            <xsl:apply-templates select="$Civilization_Classical--Study_and_teaching"/>
        </xsl:if>
        <xsl:if test="$beulah='ENVIRONMENTAL MANAGEMENT'">
            <xsl:apply-templates select="$Environmental_management"/>
        </xsl:if>
        <xsl:if test="$beulah='PHILOSOPHY'">
            <xsl:apply-templates select="$Philosophy"/>
        </xsl:if>
        <xsl:if test="$beulah='SECONDARY EDUCATION'">
            <xsl:apply-templates select="$Education_Secondary"/>
        </xsl:if>
        <xsl:if test="$beulah='EXPERIMENTAL PSYCHOLOGY'">
            <xsl:apply-templates select="$Psychology_Experimental"/>
        </xsl:if>
        <xsl:if test="$beulah='PHILOSOPHY OF SCIENCE'">
            <xsl:apply-templates select="$Science--Philosophy"/>
        </xsl:if>
        <xsl:if test="$beulah='HEALTH CARE MANAGEMENT'">
            <xsl:apply-templates select="$Health_services_administration"/>
        </xsl:if>
        <xsl:if test="$beulah='GEOPHYSICS'">
            <xsl:apply-templates select="$Geophysics"/>
        </xsl:if>
        <xsl:if test="$beulah='SYSTEM SCIENCE'">
            <xsl:apply-templates select="$System_theory"/>
        </xsl:if>
        <xsl:if test="$beulah='BUSINESS ADMINISTRATION'">
            <xsl:apply-templates select="$Industrial_management"/>
        </xsl:if>
        <xsl:if test="$beulah='COMPARATIVE RELIGION'">
            <xsl:apply-templates select="$Religions"/>
        </xsl:if>
        <xsl:if test="$beulah='SYSTEMS SCIENCE'">
            <xsl:apply-templates select="$System_theory"/>
        </xsl:if>
        <xsl:if test="$beulah='FLUID MECHANICS'">
            <xsl:apply-templates select="$Fluid_mechanics"/>
        </xsl:if>
        <xsl:if test="$beulah='WILDLIFE CONSERVATION'">
            <xsl:apply-templates select="$Wildlife_conservation"/>
        </xsl:if>
        <xsl:if test="$beulah='ACOUSTICS'">
            <xsl:apply-templates select="$Sound"/>
        </xsl:if>
        <xsl:if test="$beulah='GLBT STUDIES'">
            <xsl:apply-templates select="$Queer_studies"/>
        </xsl:if>
        <xsl:if test="$beulah='PSYCHOBIOLOGY'">
            <xsl:apply-templates select="$Psychobiology"/>
        </xsl:if>
        <xsl:if test="$beulah='URBAN FORESTRY'">
            <xsl:apply-templates select="$Urban_forestry"/>
        </xsl:if>
        <xsl:if test="$beulah='ETHICS'">
            <xsl:apply-templates select="$Ethics"/>
        </xsl:if>
        <xsl:if test="$beulah='PHILOSOPHY OF RELIGION'">
            <xsl:apply-templates select="$Philosophy_and_religion"/>
        </xsl:if>
        <xsl:if test="$beulah='MULTINOMIAL LOGISITC REGRESSION'">
            <xsl:apply-templates select="$Regression_analysis"/>
        </xsl:if>
        <xsl:if test="$beulah='PUBLIC ADMINISTRATION'">
            <xsl:apply-templates select="$Public_administration"/>
        </xsl:if>
        <xsl:if test="$beulah='CONTINUING EDUCATION'">
            <xsl:apply-templates select="$Continuing_education"/>
        </xsl:if>
        <xsl:if test="$beulah='RELIGIOUS EDUCATION'">
            <xsl:apply-templates select="$Religious_education"/>
        </xsl:if>
        <xsl:if test="$beulah='THEORETICAL PHYSICS'">
            <xsl:apply-templates select="$Physics"/>
        </xsl:if>
        <xsl:if test="$beulah='MULTIMEDIA'">
            <xsl:apply-templates select="$Interactive_multimedia"/>
        </xsl:if>
        <xsl:if test="$beulah='AESTHETICS'">
            <xsl:apply-templates select="$Aesthetics"/>
        </xsl:if>
        <xsl:if test="$beulah='SOCIOLINGUISTICS'">
            <xsl:apply-templates select="$Sociolinguistics"/>
        </xsl:if>
        <xsl:if test="$beulah='DANCE'">
            <xsl:apply-templates select="$Dance"/>
        </xsl:if>
        <xsl:if test="$beulah='PHYSIOLOGICAL PSYCHOLOGY'">
            <xsl:apply-templates select="$Psychophysiology"/>
        </xsl:if>
        <xsl:if test="$beulah='ORGANIZATION THEORY'">
            <xsl:apply-templates select="$Organizational_sociology"/>
        </xsl:if>
        <xsl:if test="$beulah='AMERICAN LITERATURE'">
            <xsl:apply-templates select="$American_literature"/>
        </xsl:if>
        <xsl:if test="$beulah='MOLECULAR PHYSICS'">
            <xsl:apply-templates select="$Physics"/>
        </xsl:if>
        <xsl:if test="$beulah='ECONOMIC THEORY'">
            <xsl:apply-templates select="$Economics"/>
        </xsl:if>
        <xsl:if test="$beulah='PERFORMING ARTS'">
            <xsl:apply-templates select="$Performing_arts"/>
        </xsl:if>
        <xsl:if test="$beulah='DIFFERENTIAL PRIVACY'">
            <xsl:apply-templates select="$Data_sets"/>
        </xsl:if>
        <xsl:if test="$beulah='SHARE REPURCHASES'">
            <xsl:apply-templates select="$Stock_repurchasing"/>
        </xsl:if>
        <xsl:if test="$beulah='LANGUAGE'">
            <xsl:apply-templates select="$Language_and_languages"/>
        </xsl:if>
        <xsl:if test="$beulah='NUTRITION'">
            <xsl:apply-templates select="$Nutrition"/>
        </xsl:if>
        <xsl:if test="$beulah='WEB STUDIES'">
            <xsl:apply-templates select="$World_Wide_Web--Study_and_teaching"/>
        </xsl:if>
        <xsl:if test="$beulah='ASTRONOMY'">
            <xsl:apply-templates select="$Astronomy"/>
        </xsl:if>
        <xsl:if test="$beulah='MILITARY STUDIES'">
            <xsl:apply-templates select="$Military_art_and_science"/>
        </xsl:if>
        <xsl:if test="$beulah='METROLOGY'">
            <xsl:apply-templates select="$Metrology"/>
        </xsl:if>
        <xsl:if test="$beulah='ZOOLOGY'">
            <xsl:apply-templates select="$Zoology"/>
        </xsl:if>
        <xsl:if test="$beulah='FORESTRY'">
            <xsl:apply-templates select="$Forests_and_forestry"/>
        </xsl:if>
        <xsl:if test="$beulah='DISABILITY STUDIES'">
            <xsl:apply-templates select="$Disability_studies"/>
        </xsl:if>
        <xsl:if test="$beulah='TRANSPORTATION PLANNING'">
            <xsl:apply-templates select="$Transportation--Planning"/>
        </xsl:if>
        <xsl:if test="$beulah='PERSONALITY PSYCHOLOGY'">
            <xsl:apply-templates select="$Personality"/>
        </xsl:if>
        <xsl:if test="$beulah='REMOTE SENSING'">
            <xsl:apply-templates select="$Remote_sensing"/>
        </xsl:if>
        <xsl:if test="$beulah='ENVIRONMENTAL GEOLOGY'">
            <xsl:apply-templates select="$Environmental_geology"/>
        </xsl:if>
        <xsl:if test="$beulah='GEOCHEMISTRY'">
            <xsl:apply-templates select="$Geochemistry"/>
        </xsl:if>
        <xsl:if test="$beulah='MILITARY HISTORY'">
            <xsl:apply-templates select="$Military_history"/>
        </xsl:if>
        <xsl:if test="$beulah='SOCIOLOGY OF EDUCATION'">
            <xsl:apply-templates select="$Educational_sociology"/>
        </xsl:if>
        <xsl:if test="$beulah='SPIRITUALITY'">
            <xsl:apply-templates select="$Spirituality"/>
        </xsl:if>
        <xsl:if test="$beulah='SCIENCE EDUCATION'">
            <xsl:apply-templates select="$Science--Study_and_teaching"/>
        </xsl:if>
        <xsl:if test="$beulah='ARCHITECTURAL ENGINEERING'">
            <xsl:apply-templates select="$Building"/>
        </xsl:if>
        <xsl:if test="$beulah='AGING'">
            <xsl:apply-templates select="$Aging"/>
        </xsl:if>
        <xsl:if test="$beulah='DENTISTRY'">
            <xsl:apply-templates select="$Dentistry"/>
        </xsl:if>
        <xsl:if test="$beulah='PALEOECOLOGY'">
            <xsl:apply-templates select="$Paleoecology"/>
        </xsl:if>
        <xsl:if test="$beulah='METAPHYSICS'">
            <xsl:apply-templates select="$Metaphysics"/>
        </xsl:if>
        <xsl:if test="$beulah='SEXUALITY'">
            <xsl:apply-templates select="$Sex"/>
        </xsl:if>
        <xsl:if test="$beulah='ACCOUNTING'">
            <xsl:apply-templates select="$Accounting"/>
        </xsl:if>
        <xsl:if test="$beulah='MARKETING'">
            <xsl:apply-templates select="$Marketing"/>
        </xsl:if>
        <xsl:if test="$beulah='REGIONAL STUDIES'">
            <xsl:apply-templates select="$Area_studies"/>
        </xsl:if>
        <xsl:if test="$beulah='COMPUTATIONAL PHYSICS'">
            <xsl:apply-templates select="$Physics"/>
        </xsl:if>
        <xsl:if test="$beulah='APPLIED PHYSICS'">
            <xsl:apply-templates select="$Physics"/>
        </xsl:if>
        <xsl:if test="$beulah='PLANT SCIENCES'">
            <xsl:apply-templates select="$Botany"/>
        </xsl:if>
        <xsl:if test="$beulah='PALEONTOLOGY'">
            <xsl:apply-templates select="$Paleontology"/>
        </xsl:if>
        <xsl:if test="$beulah='SEDIMENTARY GEOLOGY'">
            <xsl:apply-templates select="$Sedimentology"/>
        </xsl:if>
        <xsl:if test="$beulah='LAND USE PLANNING'">
            <xsl:apply-templates select="$Land_use--Planning"/>
        </xsl:if>
        <xsl:if test="$beulah='AFRICAN LITERATURE'">
            <xsl:apply-templates select="$African_literature"/>
        </xsl:if>
        <xsl:if test="$beulah='CONNECTED AND AUTONOMOUS VEHICLE'">
            <xsl:apply-templates select="$Automated_vehicles"/>
        </xsl:if>
        <xsl:if test="$beulah='SOCIAL SCIENCES EDUCATION'">
            <xsl:apply-templates select="$Social_sciences--Study_and_teaching"/>
        </xsl:if>
        <!-- Includes ampersand JRN 2021-08-12 -->
        <xsl:if test="$beulah='EVOLUTION &amp; DEVELOPMENT'">
            <xsl:apply-templates select="$Evolutionary_developmental_biology"/>
        </xsl:if>
        <xsl:if test="$beulah='PLANT PATHOLOGY'">
            <xsl:apply-templates select="$Plant_diseases"/>
        </xsl:if>
        <xsl:if test="$beulah='AQUATIC SCIENCES'">
            <xsl:apply-templates select="$Aquatic_sciences"/>
        </xsl:if>
        <xsl:if test="$beulah='LABOR RELATIONS'">
            <xsl:apply-templates select="$Industrial_relations"/>
        </xsl:if>
        <xsl:if test="$beulah='SLEEPING BEAUTY TRANSPOSON'">
            <xsl:apply-templates select="$DNA"/>
        </xsl:if>
        <xsl:if test="$beulah='ANIMAL SCIENCES'">
            <xsl:apply-templates select="$Animal_scientists"/>
        </xsl:if>
        <xsl:if test="$beulah='WILDLIFE MANAGEMENT'">
            <xsl:apply-templates select="$Wildlife_management"/>
        </xsl:if>
        <xsl:if test="$beulah='TRANSLATION STUDIES'">
            <xsl:apply-templates select="$Translations"/>
        </xsl:if>
        <xsl:if test="$beulah='FILM STUDIES'">
            <xsl:apply-templates select="$Motion_pictures"/>
        </xsl:if>
        <xsl:if test="$beulah='SOCIAL WORK'">
            <xsl:apply-templates select="$Social_service"/>
        </xsl:if>
        <xsl:if test="$beulah='MUSEUM STUDIES'">
            <xsl:apply-templates select="$Museums--Study_and_teaching"/>
        </xsl:if>
        <xsl:if test="$beulah='DEVELOPMENTAL PSYCHOLOGY'">
            <xsl:apply-templates select="$Developmental_psychology"/>
        </xsl:if>
        <xsl:if test="$beulah='LATIN AMERICAN LITERATURE'">
            <xsl:apply-templates select="$Latin_American_literature"/>
        </xsl:if>
        <xsl:if test="$beulah='INSTRUCTIONAL DESIGN'">
            <xsl:apply-templates select="$Instructional_systems--Design"/>
        </xsl:if>
        <xsl:if test="$beulah='THEOLOGY'">
            <xsl:apply-templates select="$Theology"/>
        </xsl:if>
        <xsl:if test="$beulah='RECREATION'">
            <xsl:apply-templates select="$Recreation"/>
        </xsl:if>
        <xsl:if test="$beulah='BANKING'">
            <xsl:apply-templates select="$Banks_and_banking"/>
        </xsl:if>
        <xsl:if test="$beulah='STATISTICAL PHYSICS'">
            <xsl:apply-templates select="$Statistical_physics"/>
        </xsl:if>
        <xsl:if test="$beulah='EDUCATIONAL PHILOSOPHY'">
            <xsl:apply-templates select="$Education"/>
        </xsl:if>
        <xsl:if test="$beulah='ISLAMIC STUDIES'">
            <xsl:apply-templates select="$Islam--Study_and_teaching"/>
        </xsl:if>
        <xsl:if test="$beulah='NATURAL RESOURCE MANAGEMENT'">
            <xsl:apply-templates select="$Natural_resources--Management"/>
        </xsl:if>
        <xsl:if test="$beulah='PETROLOGY'">
            <xsl:apply-templates select="$Petrology"/>
        </xsl:if>
        <xsl:if test="$beulah='THERMODYNAMICS'">
            <xsl:apply-templates select="$Thermodynamics"/>
        </xsl:if>
        <xsl:if test="$beulah='ATMOSPHERIC SCIENCES'">
            <xsl:apply-templates select="$Atmospheric_science"/>
        </xsl:if>
        <xsl:if test="$beulah='MEDICAL IMAGING'">
            <xsl:apply-templates select="$Diagnostic_imaging"/>
        </xsl:if>
        <xsl:if test="$beulah='JUDAIC STUDIES'">
            <xsl:apply-templates select="$Judaism--Study_and_teaching"/>
        </xsl:if>
        <xsl:if test="$beulah='INTERNATIONAL RELATIONS'">
            <xsl:apply-templates select="$International_relations"/>
        </xsl:if>
        <xsl:if test="$beulah='MEDICAL PERSONNEL'">
            <xsl:apply-templates select="$Medical_personnel"/>
        </xsl:if>
        <xsl:if test="$beulah='COMPUTATIONAL MECHANICS'">
            <xsl:apply-templates select="$Mechanics_Applied--Mathematics"/>
        </xsl:if>
        <xsl:if test="$beulah='FRINGE PROJECTION'">
            <xsl:apply-templates select="$Three-dimensional_modeling"/>
        </xsl:if>
        <xsl:if test="$beulah='LEADERSHIP'">
            <xsl:apply-templates select="$Leadership"/>
        </xsl:if>
        <xsl:if test="$beulah='ACOUSTIC EMISSION'">
            <xsl:apply-templates select="$Acoustic_emission"/>
        </xsl:if>
        <xsl:if test="$beulah='OBSTETRICS'">
            <xsl:apply-templates select="$Obstetrics"/>
        </xsl:if>
        <xsl:if test="$beulah='PARASITOLOGY'">
            <xsl:apply-templates select="$Parasitology"/>
        </xsl:if>
        <xsl:if test="$beulah='POWER SYSTEMS'">
            <xsl:apply-templates select="$Electric_power_systems"/>
        </xsl:if>
        <xsl:if test="$beulah='FOLKLORE'">
            <xsl:apply-templates select="$Folklore"/>
        </xsl:if>
        <xsl:if test="$beulah='HYDRAULIC ENGINEERING'">
            <xsl:apply-templates select="$Hydraulic_engineering"/>
        </xsl:if>
        <xsl:if test="$beulah='SURGERY'">
            <xsl:apply-templates select="$Surgery"/>
        </xsl:if>
        <xsl:if test="$beulah='CLIMATE CHANGE'">
            <xsl:apply-templates select="$Climatic_changes"/>
        </xsl:if>
        <xsl:if test="$beulah='PATHOLOGY'">
            <xsl:apply-templates select="$Pathology"/>
        </xsl:if>
        <xsl:if test="$beulah='PHARMACEUTICAL SCIENCES'">
            <xsl:apply-templates select="$Pharmacy--Research"/>
        </xsl:if>
        <!-- Double apostrophe JRN 2021-08-12 -->
        <xsl:if test="$beulah='CHILDREN''S LITERATURE'">
            <xsl:apply-templates select="$Childrens_literature"/>
        </xsl:if>
        <xsl:if test="$beulah='MODERN HISTORY'">
            <xsl:apply-templates select="$History_Modern"/>
        </xsl:if>
        <xsl:if test="$beulah='THEORETICAL MATHEMATICS'">
            <xsl:apply-templates select="$Mathematics"/>
        </xsl:if>
        <xsl:if test="$beulah='DEMOGRAPHY'">
            <xsl:apply-templates select="$Demography"/>
        </xsl:if>
        <xsl:if test="$beulah='CONDENSED MATTER PHYSICS'">
            <xsl:apply-templates select="$Condensed_matter"/>
        </xsl:if>
        <xsl:if test="$beulah='SPEECH THERAPY'">
            <xsl:apply-templates select="$Speech_therapy"/>
        </xsl:if>
        <xsl:if test="$beulah='MUSIC THERAPY'">
            <xsl:apply-templates select="$Music_therapy"/>
        </xsl:if>
        <xsl:if test="$beulah='MUSIC EDUCATION'">
            <xsl:apply-templates select="$Music--Instruction_and_study"/>
        </xsl:if>
        <xsl:if test="$beulah='PROFESSIONAL LEARNING COMMUNITIES'">
            <xsl:apply-templates select="$Professional_learning_communities"/>
        </xsl:if>
        <xsl:if test="$beulah='QUANTITATIVE PSYCHOLOGY'">
            <xsl:apply-templates select="$Psychology--Statistical_methods"/>
        </xsl:if>
        <xsl:if test="$beulah='PALEOCLIMATE SCIENCE'">
            <xsl:apply-templates select="$Paleoclimatology"/>
        </xsl:if>
        <xsl:if test="$beulah='AGRICULTURE ECONOMICS'">
            <xsl:apply-templates select="$Agriculture--Economic_aspects"/>
        </xsl:if>
        <xsl:if test="$beulah='CULTURAL RESOURCES MANAGEMENT'">
            <xsl:apply-templates select="$Cultural_property--Protection"/>
        </xsl:if>
        <xsl:if test="$beulah='ETHNIC STUDIES'">
            <xsl:apply-templates select="$Ethnicity--Study_and_teaching"/>
        </xsl:if>
        <xsl:if test="$beulah='PHYSICAL GEOGRAPHY'">
            <xsl:apply-templates select="$Physical_geography"/>
        </xsl:if>
        <xsl:if test="$beulah='PHILOSOPHY OF EDUCATION'">
            <xsl:apply-templates select="$Education--Philosophy"/>
        </xsl:if>
        <xsl:if test="$beulah='BIOENGINEERING'">
            <xsl:apply-templates select="$Bioengineering"/>
        </xsl:if>
        <xsl:if test="$beulah='PROFESSIONAL DEVELOPMENT'">
            <xsl:apply-templates select="$Career_development"/>
        </xsl:if>
        <xsl:if test="$beulah='BEHAVIORAL PSYCHOLOGY'">
            <xsl:apply-templates select="$Behavior_therapy"/>
        </xsl:if>
        <xsl:if test="$beulah='PUBLIC HEALTH OCCUPATIONS EDUCATION'">
            <xsl:apply-templates select="$Public_health--Study_and_teaching"/>
        </xsl:if>
        <xsl:if test="$beulah='MULTI-OBJECT TRACKING'">
            <xsl:apply-templates select="$Visual_perception"/>
        </xsl:if>
        <xsl:if test="$beulah='ALTERNATIVE MEDICINE'">
            <xsl:apply-templates select="$Alternative_medicine"/>
        </xsl:if>
        <xsl:if test="$beulah='CHILDHOOD OBESITY'">
            <xsl:apply-templates select="$Obesity_in_children"/>
        </xsl:if>
        <xsl:if test="$beulah='TOXICOLOGY'">
            <xsl:apply-templates select="$Toxicology"/>
        </xsl:if>
        <xsl:if test="$beulah='EARLY COLLEGE'">
            <xsl:apply-templates select="$Education_Secondary"/>
        </xsl:if>
        <xsl:if test="$beulah='NATIVE AMERICAN STUDIES'">
            <xsl:apply-templates select="$Indigenous_peoples"/>
        </xsl:if>
        <xsl:if test="$beulah='NATIVE AMERICAN STUDIES'">
            <xsl:apply-templates select="$North_America"/>
        </xsl:if>
        <xsl:if test="$beulah='DEVELOPMENTAL BIOLOGY'">
            <xsl:apply-templates select="$Developmental_biology"/>
        </xsl:if>
        <xsl:if test="$beulah='AGRICULTURE ENGINEERING'">
            <xsl:apply-templates select="$Agricultural_engineering"/>
        </xsl:if>
        <xsl:if test="$beulah='WORLD HISTORY'">
            <xsl:apply-templates select="$World_history"/>
        </xsl:if>
        <xsl:if test="$beulah='PHARMACOLOGY'">
            <xsl:apply-templates select="$Pharmacology"/>
        </xsl:if>
        <xsl:if test="$beulah='MOLECULAR CHEMISTRY'">
            <xsl:apply-templates select="$Chemistry"/>
        </xsl:if>
        <xsl:if test="$beulah='SOCIAL DETERMINANTS OF HEALTH'">
            <xsl:apply-templates select="$Health--Social_aspects"/>
        </xsl:if>
        <xsl:if test="$beulah='MEDICAL ETHICS'">
            <xsl:apply-templates select="$Medical_ethics"/>
        </xsl:if>
        <xsl:if test="$beulah='BLACK STUDIES'">
            <xsl:apply-templates
                select="$African_Americans--Study_and_teaching|$Ethnicity--Study_and_teaching"/>
        </xsl:if>
        <xsl:if test="$beulah='MEDIEVAL HISTORY'">
            <xsl:apply-templates select="$Middle_Ages|$History"/>
        </xsl:if>
        <xsl:if test="$beulah='AMERICAN HISTORY'">
            <xsl:apply-templates select="$History|$America"/>
        </xsl:if>
        <xsl:if test="$beulah='HISPANIC AMERICAN STUDIES'">
            <xsl:apply-templates
                select="$Ethnicity--Study_and_teaching|$Hispanic_Americans--Study_and_teaching"/>
        </xsl:if>
        <xsl:if test="$beulah='LATIN AMERICAN STUDIES'">
            <xsl:apply-templates select="$Area_studies|$Latin_America"/>
        </xsl:if>
        <xsl:if test="$beulah='AFRICAN AMERICAN STUDIES'">
            <xsl:apply-templates
                select="$African_Americans--Study_and_teaching|$Ethnicity--Study_and_teaching"/>
        </xsl:if>
        <xsl:if test="$beulah='AFRICAN STUDIES'">
            <xsl:apply-templates select="$Area_studies|$Africa"/>
        </xsl:if>
        <xsl:if test="$beulah='SOUTHEAST ASIAN STUDIES'">
            <xsl:apply-templates select="$Area_studies|$Southeast_Asia"/>
        </xsl:if>
        <xsl:if test="$beulah='LATIN AMERICAN HISTORY'">
            <xsl:apply-templates select="$History|$Latin_America"/>
        </xsl:if>
        <xsl:if test="$beulah='EUROPEAN HISTORY'">
            <xsl:apply-templates select="$History|$Europe"/>
        </xsl:if>
        <xsl:if test="$beulah='ASIAN STUDIES'">
            <xsl:apply-templates select="$Area_studies|$Asia"/>
        </xsl:if>
        <xsl:if test="$beulah='SOUTH ASIAN STUDIES'">
            <xsl:apply-templates select="$Area_studies|$South_Asia"/>
        </xsl:if>
        <xsl:if test="$beulah='NEAR EASTERN STUDIES'">
            <xsl:apply-templates select="$Area_studies|$Middle_East"/>
        </xsl:if>
        <xsl:if test="$beulah='AFRICAN HISTORY'">
            <xsl:apply-templates select="$History|$Africa"/>
        </xsl:if>
        <xsl:if test="$beulah='POLYMER CHEMISTRY'">
            <xsl:apply-templates select="$Chemistry|$Polymers"/>
        </xsl:if>
        <xsl:if test="$beulah='EAST EUROPEAN STUDIES'">
            <xsl:apply-templates select="$Area_studies|$Eastern_Europe"/>
        </xsl:if>
        <xsl:if test="$beulah='SUB SAHARAN AFRICA STUDIES'">
            <xsl:apply-templates select="$Area_studies|$Sub-Saharan_Africa"/>
        </xsl:if>
        <xsl:if test="$beulah='MIDDLE EASTERN HISTORY'">
            <xsl:apply-templates select="$History|$Middle_East"/>
        </xsl:if>
        <xsl:if test="$beulah='BLACK HISTORY'">
            <xsl:apply-templates select="$African_Americans--Study_and_teaching|$History"/>
        </xsl:if>
        <xsl:if test="$beulah='AMERICAN STUDIES'">
            <xsl:apply-templates select="$Area_studies|$America"/>
        </xsl:if>
        <xsl:if test="$beulah='MIDDLE EASTERN STUDIES'">
            <xsl:apply-templates select="$Area_studies|$Middle_East"/>
        </xsl:if>
        <xsl:if test="$beulah='WOOD SCIENCES'">
            <xsl:apply-templates select="$Wood|$Materials_science"/>
        </xsl:if>
        <xsl:if test="$beulah='NUCLEAR PHYSICS AND RADIATION'">
            <xsl:apply-templates select="$Radiation|$Nuclear_physics"/>
        </xsl:if>
        <xsl:if test="$beulah='ENERGY MARKETS'">
            <xsl:apply-templates select="$Energy_industries|$Commodity_exchanges"/>
        </xsl:if>
        <xsl:if test="$beulah='CARIBBEAN STUDIES'">
            <xsl:apply-templates select="$Area_studies|$Caribbean_Area"/>
        </xsl:if>
        <xsl:if test="$beulah='OPTICAL METROLOGY'">
            <xsl:apply-templates select="$Optical_engineering|$Metrology"/>
        </xsl:if>
        <xsl:if test="$beulah='SLAVIC STUDIES'">
            <xsl:apply-templates select="$Slavs--Study_and_teaching|$Ethnicity--Study_and_teaching"
            />
        </xsl:if>
        <xsl:if test="$beulah='ASIAN HISTORY'">
            <xsl:apply-templates select="$History|$Asia"/>
        </xsl:if>
        <xsl:if test="$beulah='NATIVE AMERICAN STUDIES'">
            <xsl:apply-templates
                select="$Indigenous_peoples|$Ethnicity--Study_and_teaching|$North_America"/>
        </xsl:if>
        <xsl:if test="$beulah='OBSTETRICS AND GYNECOLOGY'">
            <xsl:apply-templates select="$Obstetrics|$Gynecology"/>
        </xsl:if>
        <xsl:if test="$beulah='RUSSIAN HISTORY'">
            <xsl:apply-templates select="$History|$Russia"/>
        </xsl:if>
    </xsl:template>
    <!-- Template for camel casing capitalized ETD keywords; feeds into template and param at top of stylesheet. JRN 2021-08-09 -->
    <xsl:template match="mods:mods/mods:note[@displayLabel='ETDkeywords']/text()">
        <xsl:call-template name="CamelCase">
            <xsl:with-param name="text" select="."/>
        </xsl:call-template>
    </xsl:template>
    <!--   Adds MODS prefix to relatedItem element, which is missing in first iteration. JRN 2021-08-27 -->
    <xsl:template match="mods:relatedItem[parent::mods:mods]"/>
    <xsl:template match="mods:recordInfo[parent::mods:mods]">
        <xsl:copy-of select="."/>
        <mods:relatedItem xmlns="http://www.loc.gov/mods/v3" type="host">
            <mods:titleInfo>
                <mods:title>UNC Charlotte electronic theses and dissertations</mods:title>
            </mods:titleInfo>
        </mods:relatedItem>       
    </xsl:template>    
</xsl:stylesheet>