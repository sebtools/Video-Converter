<cfcomponent extends="com.sebtools.RecordsTester" output="no">

<cffunction name="setUp" access="public" returntype="any" output="no">
	
	<cfset loadExternalVars("VideoConverter")>
	<!---
		Current File formats: mp4,ogg,swf,webm (eventually will expand formats to convert from)
	--->
	
	<!--- ToDo: Need to find sample videos for testing - will place them directly in the "tests" folder --->
	
</cffunction>

<cffunction name="shouldFormatVideosCreateAllNeededFiles" access="public" returntype="any" output="no"
	hint="The formatVideos method should create all of the files needed by any video components in the component."
>
	
	<cfset fail("This test has not yet been implemented.")>
	
</cffunction>

<cffunction name="shouldFormatVideosReturnAllVideos" access="public" returntype="any" output="no"
	hint="The formatVideos method should return a structure including all created videos."
>
	
	<cfset fail("This test has not yet been implemented.")>
	
</cffunction>

<cffunction name="shouldHTMLIncludeVideoElementForHTML5Formats" access="public" returntype="any" output="no"
	hint="The getVideoHTML method should use a VIDEO element if any formats used by HTML5 are included."
>
	
	<cfset fail("This test has not yet been implemented.")>
	
</cffunction>

<cffunction name="shouldHTMLIncludeObjectElementForMP4" access="public" returntype="any" output="no"
	hint="The getVideoHTML method should use an OBJECT element if any MP4 files are included."
>
	
	<cfset fail("This test has not yet been implemented.")>
	
</cffunction>

<cffunction name="shouldHTMLIncludeEmbedElementForSWF" access="public" returntype="any" output="no"
	hint="The getVideoHTML method should use an Embed element if any SWF files are included."
>
	
	<cfset fail("This test has not yet been implemented.")>
	
</cffunction>

<cffunction name="shouldHTMLIncludeFallbackHTMLForNoSWF" access="public" returntype="any" output="no"
	hint="The getVideoHTML method should use a fallback message if no SWF files are included."
>
	
	<cfset fail("This test has not yet been implemented.")>
	
</cffunction>

<cffunction name="getExampleXml" access="private" returntype="string" output="no">
	
	<cfset var result = "">
	
	<cfsavecontent variable="result">
	<tables prefix="test">
		<table entity="Question" Specials="CreationDate,LastUpdatedDate,Sorter">
			<field
				name="Video"
				Label="Video"
				type="file"
			/>
			<field name="VideoWidth" label="Video Width" type="integer" help="The width of the video (in pixels)." required="true" default="320" />
			<field name="VideoHeight" label="Video Height" type="integer" help="The height of the video (in pixels)." required="true" default="240" />
		</table>
	</tables>
	</cfsavecontent>
	
	<cfreturn result>
</cffunction>

<cffunction name="shouldModifyXmlReturnValidXml" access="public" returntype="any" output="no"
	hint="The modifyXml method should return a valid XML string."
>
	
	<cfset var ConvertedXml = Variables.VideoConverter.modifyXml(getExampleXml())>
	
	<cfif NOT (
			isDefined("ConvertedXml")
		AND	isSimpleValue(ConvertedXml)
		AND	Len(Trim(ConvertedXml))
		AND	isXml(ConvertedXml)
	)>
		<cfset fail("The value returned from modifyXml is not a valid XML string.")>
	</cfif>
	
</cffunction>

<cffunction name="shouldModifyXmlBeCorrect" access="public" returntype="any" output="no"
	hint="The modifyXml method should return the correct XML (this is a shortcut for several tests)."
>
	
	<cfset var result = "">
	<cfset var ConvertedXml = Variables.VideoConverter.modifyXml(getExampleXml())>
	
	<cfsavecontent variable="result">
	<tables prefix="test">
		<table entity="Question" Specials="CreationDate,LastUpdatedDate,Sorter">
			<field
				name="Video"
				Label="Video"
				type="file"
				Accept="video/mp4,video/mpeg,video/mpeg,application/ogg,video/ogg,application/x-shockwave-flash,video/webm"
				Extensions="mp4,ogg,ogv,swf,webm"
			/>
			<field
				name="VideoMP4"
				Label="Video (.mp4)"
				type="file"
				Accept="video/mp4,video/mpeg,video/mpeg,"
				Extensions="mp4"
				sebfield="false"
				sebcolumn="false"
			/>
			<field
				name="VideoOGG"
				Label="Video (.ogg)"
				type="file"
				Accept="application/ogg,video/ogg"
				Extensions="ogg,ogv"
				sebfield="false"
				sebcolumn="false"
			/>
			<field
				name="VideoSWF"
				Label="Video (.swf)"
				type="file"
				Accept="application/x-shockwave-flash"
				Extensions="swf"
				sebfield="false"
				sebcolumn="false"
			/>
			<field
				name="VideoWebM"
				Label="Video (.webm)"
				type="file"
				Accept="video/webm"
				Extensions="webm"
				sebfield="false"
				sebcolumn="false"
			/>
			<field name="VideoWidth" label="Video Width" type="integer" help="The width of the video (in pixels)." required="true" default="320" />
			<field name="VideoHeight" label="Video Height" type="integer" help="The height of the video (in pixels)." required="true" default="240" />
		</table>
	</tables>
	</cfsavecontent>
	
	<cfset assertEquals(ToString(XmlParse(result)),ToString(XmlParse(ConvertedXml)),"modifyXml did not return the correct XML.")>
	
</cffunction>

<cffunction name="shouldModifyXmlIncludeAllDesiredFormats" access="public" returntype="any" output="no"
	hint="The modifyXml method should have fields for each desired format - with correct extensions and mime-types."
>
	
	<cfset fail("This test has not yet been implemented.")>
	
</cffunction>

<cffunction name="shouldAddedFieldsBeHidden" access="public" returntype="any" output="no"
	hint="Any fields added by modifyXMl have sebfield and sebcolumn attributes set to false."
>
	
	<cfset fail("This test has not yet been implemented.")>
	
</cffunction>

<cffunction name="shouldSourceFieldsBeSecured" access="public" returntype="any" output="no"
	hint="The source video should have the correct allowed extensions and mime-types."
>
	
	<cfset fail("This test has not yet been implemented.")>
	
</cffunction>

<!--- ** THUMBNAIL TESTS *** --->

<cffunction name="shouldThumbsCreateFromMP4" access="public" returntype="any" output="no"
	hint="Thumbnails should be created from MP4 videos."
>
	
	<cfset fail("This test has not yet been implemented.")>
	
</cffunction>

<cffunction name="shouldThumbsCreateFromOGG" access="public" returntype="any" output="no"
	hint="Thumbnails should be created from MP4 videos."
>
	
	<cfset fail("This test has not yet been implemented.")>
	
</cffunction>

<cffunction name="shouldThumbsCreateFromSWF" access="public" returntype="any" output="no"
	hint="Thumbnails should be created from MP4 videos."
>
	
	<cfset fail("This test has not yet been implemented.")>
	
</cffunction>

<cffunction name="shouldThumbsCreateFromWEBM" access="public" returntype="any" output="no"
	hint="Thumbnails should be created from MP4 videos."
>
	
	<cfset fail("This test has not yet been implemented.")>
	
</cffunction>

<!--- ** CONVERSION TESTS *** --->

<cffunction name="shouldConvertVideoConvertMP42OGG" access="public" returntype="any" output="no"
	hint="Video conversion should work from MP4 to OGG."
>
	
	<cfset fail("This test has not yet been implemented.")>
	
</cffunction>

<cffunction name="shouldConvertVideoConvertMP42SWF" access="public" returntype="any" output="no"
	hint="Video conversion should work from MP4 to SWF."
>
	
	<cfset fail("This test has not yet been implemented.")>
	
</cffunction>

<cffunction name="shouldConvertVideoConvertMP42WEBM" access="public" returntype="any" output="no"
	hint="Video conversion should work from MP4 to WEBM."
>
	
	<cfset fail("This test has not yet been implemented.")>
	
</cffunction>

<cffunction name="shouldConvertVideoConvertOGG2MP4" access="public" returntype="any" output="no"
	hint="Video conversion should work from OGG to MP4."
>
	
	<cfset fail("This test has not yet been implemented.")>
	
</cffunction>

<cffunction name="shouldConvertVideoConvertOGG2SWF" access="public" returntype="any" output="no"
	hint="Video conversion should work from OGG to SWF."
>
	
	<cfset fail("This test has not yet been implemented.")>
	
</cffunction>

<cffunction name="shouldConvertVideoConvertOGG2WEBM" access="public" returntype="any" output="no"
	hint="Video conversion should work from OGG to WEBM."
>
	
	<cfset fail("This test has not yet been implemented.")>
	
</cffunction>

<cffunction name="shouldConvertVideoConvertSWF2MP4" access="public" returntype="any" output="no"
	hint="Video conversion should work from SWF to MP4."
>
	
	<cfset fail("This test has not yet been implemented.")>
	
</cffunction>

<cffunction name="shouldConvertVideoConvertSWF2OGG" access="public" returntype="any" output="no"
	hint="Video conversion should work from SWF to OGG."
>
	
	<cfset fail("This test has not yet been implemented.")>
	
</cffunction>

<cffunction name="shouldConvertVideoConvertSWF2WEBM" access="public" returntype="any" output="no"
	hint="Video conversion should work from SWF to WEBM."
>
	
	<cfset fail("This test has not yet been implemented.")>
	
</cffunction>

<cffunction name="shouldConvertVideoConvertWEBM2MP4" access="public" returntype="any" output="no"
	hint="Video conversion should work from WEBM to MP4."
>
	
	<cfset fail("This test has not yet been implemented.")>
	
</cffunction>

<cffunction name="shouldConvertVideoConvertWEBM2OGG" access="public" returntype="any" output="no"
	hint="Video conversion should work from WEBM to OGG."
>
	
	<cfset fail("This test has not yet been implemented.")>
	
</cffunction>

<cffunction name="shouldConvertVideoConvertWEBM2SWF" access="public" returntype="any" output="no"
	hint="Video conversion should work from WEBM to SWF."
>
	
	<cfset fail("This test has not yet been implemented.")>
	
</cffunction>

</cfcomponent>