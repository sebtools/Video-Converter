<cfcomponent extends="mxunit.framework.TestCase" displayname="Video Converter" output="no">

<!---<cfset onInvoked()>

<cffunction name="onInvoked" access="public" returntype="any" output="no">
	<cfset Variables.FormatsIn = "avi,flv,mp4,ogv,swf,webm,wmv">
	<cfset Variables.FormatsOut = "flv,mp4,ogv,swf,webm">
</cffunction>--->

<cffunction name="setUp" access="public" returntype="any" output="no">
	
	<cfset loadExternalVars("VideoConverter")>
	
	<cfset Variables.TestPath = getDirectoryFromPath(getCurrentTemplatePath())>
	<cfset Variables.dirdelim = Right(Variables.TestPath,1)>
	
	<cfset Variables.sTestFiles = {
		flv = "barsandtone.flv",
		mp4 = "barsandtone.mp4",
		ogg = "barsandtone.ogv",
		ogv = "barsandtone.ogv",
		swf = "barsandtone.swf",
		webm = "barsandtone.webm",
		avi = "barsandtone.avi"
	}>
	
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

<!--- ** GetVideoHTML TESTS *** --->

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

<!--- ** MODIFY XML TESTS *** --->

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

<cffunction name="getConvertedXml" access="private" returntype="string" output="no">
	
	<cfif NOT StructKeyExists(Variables,"ConvertedXml")>
		<cfset Variables.ConvertedXml = Variables.VideoConverter.modifyXml(getExampleXml(),"Video")>
	</cfif>
	
	<cfreturn Variables.ConvertedXml>
</cffunction>

<cffunction name="getParsedXml" access="private" returntype="any" output="no">
	
	<cfset var ConvertedXml = getConvertedXml()>
	
	<cfif NOT StructKeyExists(Variables,"ParsedXml")>
		
		<cfset shouldModifyXmlReturnValidXml()>
		
		<cfset Variables.ParsedXml = XmlParse(ConvertedXml)>
	</cfif>
	
	<cfreturn Variables.ParsedXml>
</cffunction>

<cffunction name="getSolvedXml" access="private" returntype="any" output="no" hint="This is the XML as it should be returned for the example XML.">
	
	<cfset var result = "">
	
	<cfsavecontent variable="result">
	<tables prefix="test">
		<table entity="Question" Specials="CreationDate,LastUpdatedDate,Sorter">
			<field
				name="Video"
				Label="Video"
				type="file"
				Accept="video/avi,video/msvideo,video/x-msvideo,video/x-flv,video/mp4,video/mpeg,application/ogg,video/ogg,application/x-shockwave-flash,video/webm"
				Extensions="avi,flv,mp4,mpeg,mpg,ogg,ogv,swf,webm"
			/>
			<field
				name="VideoMP4"
				Label="Video (.mp4)"
				type="file"
				Accept="video/mp4,video/mpeg"
				Extensions="mp4,mpeg,mpg"
				sebfield="false"
				sebcolumn="false"
			/><field
				name="VideoOGG"
				Label="Video (.ogg)"
				type="file"
				Accept="application/ogg,video/ogg"
				Extensions="ogg,ogv"
				sebfield="false"
				sebcolumn="false"
			/><field
				name="VideoSWF"
				Label="Video (.swf)"
				type="file"
				Accept="application/x-shockwave-flash"
				Extensions="swf"
				sebfield="false"
				sebcolumn="false"
			/><field
				name="VideoWEBM"
				Label="Video (.webm)"
				type="file"
				Accept="video/webm"
				Extensions="webm"
				sebfield="false"
				sebcolumn="false"
			/><field name="VideoWidth" label="Video Width" type="integer" help="The width of the video (in pixels)." required="true" default="320" />
			<field name="VideoHeight" label="Video Height" type="integer" help="The height of the video (in pixels)." required="true" default="240" />
		</table>
	</tables>
	</cfsavecontent>
	
	<cfreturn result>
</cffunction>

<cffunction name="shouldModifyXmlReturnValidXml" access="public" returntype="any" output="no"
	hint="The modifyXml method should return a valid XML string."
>
	
	<cfset var ConvertedXml = getConvertedXml()>
	
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
	
	<cfset var ConvertedXml = getConvertedXml()>
	<cfset var SolvedXml = getSolvedXml()>
	
	<cfset shouldModifyXmlReturnValidXml()>
	
	<cfset assertEquals(ToString(XmlParse(SolvedXml)),ToString(XmlParse(ConvertedXml)),"modifyXml did not return the correct XML.")>
	
</cffunction>

<cffunction name="shouldModifyXmlIncludeAllDesiredFormats" access="public" returntype="any" output="no"
	hint="The modifyXml method should have fields for each desired format - with correct extensions and mime-types."
>
	
	<cfset var xConverted = getParsedXml()>
	<cfset var axFields = XmlSearch(xConverted,"//field[starts-with(@name, 'Video')][@type='file']")>
	<cfset var ii = 0>
	<cfset var VideoType = "">
	<cfset var Extensions = "">
	<cfset var MimeTypes = "">
	<cfset var temp = "">
	
	<cfloop index="ii" from="1" to="#ArrayLen(axFields)#">
		<cfif axFields[ii].XmlAttributes.name NEQ "Video">
			<cfset assertTrue(StructKeyExists(axFields[ii].XmlAttributes,"Accept"),"The 'accept' attribute does not exist for '#axFields[ii].XmlAttributes.name#'.")>
			<cfset assertTrue(StructKeyExists(axFields[ii].XmlAttributes,"Extensions"),"The 'Extensions' attribute does not exist for '#axFields[ii].XmlAttributes.name#'.")>
			<cfset VideoType = ReplaceNoCase(axFields[ii].XmlAttributes.name,"Video","","ONE")>
			<cfswitch expression="#VideoType#">
			<cfcase value="MP4">
				<cfset MimeTypes = "video/mp4,video/mpeg,video/mpeg">
				<cfset Extensions = "mp4,mpeg,mpg">
			</cfcase>
			<cfcase value="OGG">
				<cfset MimeTypes = "application/ogg,video/ogg">
				<cfset Extensions = "ogg,ogv">
			</cfcase>
			<cfcase value="SWF">
				<cfset MimeTypes = "application/x-shockwave-flash">
				<cfset Extensions = "swf">
			</cfcase>
			<cfcase value="WebM">
				<cfset MimeTypes = "video/webm">
				<cfset Extensions = "webm">
			</cfcase>
			</cfswitch>
			<cfset temp = ListCompare(Extensions,axFields[ii].XmlAttributes.Extensions)>
			<cfset assertEquals("",temp,"The #axFields[ii].XmlAttributes.name# field is missing the following extensions: #temp#")>
			
			<cfset temp = ListCompare(axFields[ii].XmlAttributes.Extensions,Extensions)>
			<cfset assertEquals("",temp,"The #axFields[ii].XmlAttributes.name# field has the following extra extensions: #temp#")>
			
			<cfset temp = ListCompare(MimeTypes,axFields[ii].XmlAttributes.Accept)>
			<cfset assertEquals("",temp,"The #axFields[ii].XmlAttributes.name# field is missing the following mime-types: #temp#")>
			
			<cfset temp = ListCompare(axFields[ii].XmlAttributes.Accept,MimeTypes)>
			<cfset assertEquals("",temp,"The #axFields[ii].XmlAttributes.name# field has the following extra mime-types: #temp#")>
		</cfif>
	</cfloop>
	
</cffunction>

<cffunction name="shouldAddedFieldsBeHidden" access="public" returntype="any" output="no"
	hint="Any fields added by modifyXml have sebfield and sebcolumn attributes set to false."
>
	
	<cfset var xConverted = getParsedXml()>
	<cfset var axFields = XmlSearch(xConverted,"//field[starts-with(@name, 'Video')][@type='file']")>
	<cfset var ii = 0>
	
	<cfloop index="ii" from="1" to="#ArrayLen(axFields)#">
		<cfif axFields[ii].XmlAttributes.name NEQ "Video">
			<cfif NOT (
					StructKeyExists(axFields[ii].XmlAttributes,"sebfield")
				AND	axFields[ii].XmlAttributes["sebfield"] IS false
			)>
				<cfset fail("The 'sebfield' attribute for #axFields[ii].XmlAttributes.name# is not false.")>
			</cfif>
			<cfif NOT (
					StructKeyExists(axFields[ii].XmlAttributes,"sebcolumn")
				AND	axFields[ii].XmlAttributes["sebcolumn"] IS false
			)>
				<cfset fail("The 'sebcolumn' attribute for #axFields[ii].XmlAttributes.name# is not false.")>
			</cfif>
		</cfif>
	</cfloop>
	
</cffunction>

<cffunction name="shouldSourceFieldsBeSecured" access="public" returntype="any" output="no"
	hint="The source video should have the correct allowed extensions and mime-types."
>
	
	<cfset var xConverted = getParsedXml()>
	<cfset var axField = XmlSearch(xConverted,"//field[@name='Video']")>
	<cfset var AcceptedExtensions = "avi,flv,mp4,mpeg,mpg,ogg,ogv,swf,webm">
	<cfset var AcceptedMimeTypes = "video/avi,video/msvideo,video/x-msvideo,video/x-flv,video/mp4,video/mpeg,application/ogg,video/ogg,application/x-shockwave-flash,video/webm">
	<cfset var Missing = "">
	<cfset var Extra = "">
	
	<cfset assertEquals(1,ArrayLen(axField),"The source field does not exist as a singular field.")>
	<cfset assertTrue(StructKeyExists(axField[1].XmlAttributes,"Accept"),"The 'accept' attribute does not exist.")>
	<cfset assertTrue(StructKeyExists(axField[1].XmlAttributes,"Extensions"),"The 'Extensions' attribute does not exist.")>
	
	<cfset Missing = ListCompare(AcceptedExtensions,LCase(axField[1].XmlAttributes["Extensions"]))>
	<cfset Extra = ListCompare(LCase(axField[1].XmlAttributes["Extensions"]),AcceptedExtensions)>
	
	<cfif Len(Missing)>
		<cfset fail("The following extensions should be accepted but are not: #Missing#.")>
	</cfif>
	<cfif Len(Extra)>
		<cfset fail("The following extensions should not be accepted but are: #Extra#.")>
	</cfif>
	
	<cfset Missing = ListCompare(AcceptedMimeTypes,LCase(axField[1].XmlAttributes["Accept"]))>
	<cfset Extra = ListCompare(LCase(axField[1].XmlAttributes["Accept"]),AcceptedMimeTypes)>
	
	<cfif Len(Missing)>
		<cfset fail("The following mime-types should be accepted but are not: #Missing#.")>
	</cfif>
	<cfif Len(Extra)>
		<cfset fail("The following mime-types should not be accepted but are: #Extra#.")>
	</cfif>
	
</cffunction>

<!--- ** THUMBNAIL TESTS *** --->

<cffunction name="runThumbnailTest" access="public" returntype="any" output="no">
	<cfargument name="type" type="string" required="yes">
	
	<cfset var NewFile = Variables.VideoConverter.generateVideoThumb("#Variables.TestPath##Variables.sTestFiles[Arguments.type]#","video_converter,tests")>
	
	<cfif Len(NewFile) AND FileExists(NewFile)>
		<!---<cffile action="delete" file="#NewFile#">--->
		<cfset assertEquals(ListLast(NewFile,"."),"jpg","The file did not have the appropriate file format.")>
	<cfelse>
		<cfset fail("The file was not created.")>
	</cfif>
	
</cffunction>

<cffunction name="shouldThumbsCreateFromAVI" access="public" returntype="any" output="no"
	hint="Thumbnails should be created from AVI videos."
>
	
	<cfset runThumbnailTest("avi")>
	
</cffunction>

<cffunction name="shouldThumbsCreateFromFLV" access="public" returntype="any" output="no"
	hint="Thumbnails should be created from FLV videos."
>
	
	<cfset runThumbnailTest("flv")>
	
</cffunction>

<cffunction name="shouldThumbsCreateFromMP4" access="public" returntype="any" output="no"
	hint="Thumbnails should be created from MP4 videos."
>
	
	<cfset runThumbnailTest("mp4")>
	
</cffunction>

<cffunction name="shouldThumbsCreateFromOGG" access="public" returntype="any" output="no"
	hint="Thumbnails should be created from OGG videos."
>
	
	<cfset runThumbnailTest("ogv")>
	
</cffunction>

<cffunction name="shouldThumbsCreateFromSWF" access="public" returntype="any" output="no"
	hint="Thumbnails should be created from SWF videos."
>
	
	<cfset runThumbnailTest("swf")>
	
</cffunction>

<cffunction name="shouldThumbsCreateFromWEBM" access="public" returntype="any" output="no"
	hint="Thumbnails should be created from WEBM videos."
>
	
	<cfset runThumbnailTest("webm")>
	
</cffunction>

<!--- ** CONVERSION TESTS *** --->

<cffunction name="runVideoConvertTest" access="public" returntype="any" output="no">
	<cfargument name="from" type="string" required="yes">
	<cfargument name="to" type="string" required="yes">
	
	<cfset var NewFile = Variables.VideoConverter.convertVideo("#Variables.TestPath##Variables.sTestFiles[Arguments.from]#","video_converter,tests",Arguments.to)>
	
	<cfif Len(NewFile) AND FileExists(NewFile)>
		<!---<cffile action="delete" file="#NewFile#">--->
		<cfset assertEquals(ListLast(NewFile,"."),Arguments.to,"The file did not have the appropriate file format.")>
	<cfelse>
		<cfset fail("The file was not created.")>
	</cfif>
	
</cffunction>

<cffunction name="shouldConvertVideoConvertAVI2FLV" access="public" returntype="any" output="no"
	hint="Video conversion should work from AVI to FLV."
>
	
	<cfset runVideoConvertTest("avi","flv")>
	
</cffunction>

<cffunction name="shouldConvertVideoConvertAVI2MP4" access="public" returntype="any" output="no"
	hint="Video conversion should work from AVI to MP4."
>
	
	<cfset runVideoConvertTest("avi","mp4")>
	
</cffunction>

<cffunction name="shouldConvertVideoConvertAVI2OGG" access="public" returntype="any" output="no"
	hint="Video conversion should work from AVI to OGG."
>
	
	<cfset runVideoConvertTest("avi","ogv")>
	
</cffunction>

<cffunction name="shouldConvertVideoConvertAVI2SWF" access="public" returntype="any" output="no"
	hint="Video conversion should work from AVI to SWF."
>
	
	<cfset runVideoConvertTest("avi","swf")>
	
</cffunction>

<cffunction name="shouldConvertVideoConvertAVI2WEBM" access="public" returntype="any" output="no"
	hint="Video conversion should work from AVI to WEBM."
>
	
	<cfset runVideoConvertTest("avi","webm")>
	
</cffunction>

<cffunction name="shouldConvertVideoConvertFLV2AVI" access="public" returntype="any" output="no"
	hint="Video conversion should work from FLV to AVI."
>
	
	<cfset runVideoConvertTest("flv","avi")>
	
</cffunction>

<cffunction name="shouldConvertVideoConvertFLV2MP4" access="public" returntype="any" output="no"
	hint="Video conversion should work from FLV to MP4."
>
	
	<cfset runVideoConvertTest("flv","mp4")>
	
</cffunction>

<cffunction name="shouldConvertVideoConvertFLV2OGG" access="public" returntype="any" output="no"
	hint="Video conversion should work from FLV to OGG."
>
	
	<cfset runVideoConvertTest("flv","ogv")>
	
</cffunction>

<cffunction name="shouldConvertVideoConvertFLV2SWF" access="public" returntype="any" output="no"
	hint="Video conversion should work from FLV to SWF."
>
	
	<cfset runVideoConvertTest("flv","swf")>
	
</cffunction>

<cffunction name="shouldConvertVideoConvertFLV2WEBM" access="public" returntype="any" output="no"
	hint="Video conversion should work from FLV to WEBM."
>
	
	<cfset runVideoConvertTest("flv","webm")>
	
</cffunction>

<cffunction name="shouldConvertVideoConvertMP42AVI" access="public" returntype="any" output="no"
	hint="Video conversion should work from MP4 to AVI."
>
	
	<cfset runVideoConvertTest("mp4","avi")>
	
</cffunction>

<cffunction name="shouldConvertVideoConvertMP42FLV" access="public" returntype="any" output="no"
	hint="Video conversion should work from MP4 to FLV."
>
	
	<cfset runVideoConvertTest("mp4","flv")>
	
</cffunction>

<cffunction name="shouldConvertVideoConvertMP42OGG" access="public" returntype="any" output="no"
	hint="Video conversion should work from MP4 to OGG."
>
	
	<cfset runVideoConvertTest("mp4","ogv")>
	
</cffunction>

<cffunction name="shouldConvertVideoConvertMP42SWF" access="public" returntype="any" output="no"
	hint="Video conversion should work from MP4 to SWF."
>
	
	<cfset runVideoConvertTest("mp4","swf")>
	
</cffunction>

<cffunction name="shouldConvertVideoConvertMP42WEBM" access="public" returntype="any" output="no"
	hint="Video conversion should work from MP4 to WEBM."
>
	
	<cfset runVideoConvertTest("mp4","webm")>
	
</cffunction>

<cffunction name="shouldConvertVideoConvertOGG2AVI" access="public" returntype="any" output="no"
	hint="Video conversion should work from OGG to AVI."
>
	
	<cfset runVideoConvertTest("ogv","avi")>
	
</cffunction>

<cffunction name="shouldConvertVideoConvertOGG2FLV" access="public" returntype="any" output="no"
	hint="Video conversion should work from OGG to FLV."
>
	
	<cfset runVideoConvertTest("ogv","flv")>
	
</cffunction>

<cffunction name="shouldConvertVideoConvertOGG2MP4" access="public" returntype="any" output="no"
	hint="Video conversion should work from OGG to MP4."
>
	
	<cfset runVideoConvertTest("ogv","mp4")>
	
</cffunction>

<cffunction name="shouldConvertVideoConvertOGG2SWF" access="public" returntype="any" output="no"
	hint="Video conversion should work from OGG to SWF."
>
	
	<cfset runVideoConvertTest("ogv","swf")>
	
</cffunction>

<cffunction name="shouldConvertVideoConvertOGG2WEBM" access="public" returntype="any" output="no"
	hint="Video conversion should work from OGG to WEBM."
>
	
	<cfset runVideoConvertTest("ogv","webm")>
	
</cffunction>

<cffunction name="shouldConvertVideoConvertSWF2AVI" access="public" returntype="any" output="no"
	hint="Video conversion should work from SWF to AVI."
>
	
	<cfset runVideoConvertTest("swf","avi")>
	
</cffunction>

<cffunction name="shouldConvertVideoConvertSWF2FLV" access="public" returntype="any" output="no"
	hint="Video conversion should work from SWF to FLV."
>
	
	<cfset runVideoConvertTest("swf","flv")>
	
</cffunction>

<cffunction name="shouldConvertVideoConvertSWF2MP4" access="public" returntype="any" output="no"
	hint="Video conversion should work from SWF to MP4."
>
	
	<cfset runVideoConvertTest("swf","mp4")>
	
</cffunction>

<cffunction name="shouldConvertVideoConvertSWF2OGG" access="public" returntype="any" output="no"
	hint="Video conversion should work from SWF to OGG."
>
	
	<cfset runVideoConvertTest("swf","ogv")>
	
</cffunction>

<cffunction name="shouldConvertVideoConvertSWF2WEBM" access="public" returntype="any" output="no"
	hint="Video conversion should work from SWF to WEBM."
>
	
	<cfset runVideoConvertTest("swf","webm")>
	
</cffunction>

<cffunction name="shouldConvertVideoConvertWEBM2AVI" access="public" returntype="any" output="no"
	hint="Video conversion should work from WEBM to AVI."
>
	
	<cfset runVideoConvertTest("webm","avi")>
	
</cffunction>

<cffunction name="shouldConvertVideoConvertWEBM2FLV" access="public" returntype="any" output="no"
	hint="Video conversion should work from WEBM to FLV."
>
	
	<cfset runVideoConvertTest("webm","flv")>
	
</cffunction>

<cffunction name="shouldConvertVideoConvertWEBM2MP4" access="public" returntype="any" output="no"
	hint="Video conversion should work from WEBM to MP4."
>
	
	<cfset runVideoConvertTest("webm","mp4")>
	
</cffunction>

<cffunction name="shouldConvertVideoConvertWEBM2OGG" access="public" returntype="any" output="no"
	hint="Video conversion should work from WEBM to OGG."
>
	
	<cfset runVideoConvertTest("webm","ogv")>
	
</cffunction>

<cffunction name="shouldConvertVideoConvertWEBM2SWF" access="public" returntype="any" output="no"
	hint="Video conversion should work from WEBM to SWF."
>
	
	<cfset runVideoConvertTest("webm","swf")>
	
</cffunction>

<!---
 Compares one list against another to find the elements in the first list that don't exist in the second list.
 v2 mod by Scott Coldwell
 
 @param List1      Full list of delimited values. (Required)
 @param List2      Delimited list of values you want to compare to List1. (Required)
 @param Delim1      Delimiter used for List1.  Default is the comma. (Optional)
 @param Delim2      Delimiter used for List2.  Default is the comma. (Optional)
 @param Delim3      Delimiter to use for the list returned by the function.  Default is the comma. (Optional)
 @return Returns a delimited list of values. 
 @author Rob Brooks-Bilson (rbils@amkor.com) 
 @version 2, June 25, 2009 
--->
<cffunction name="listCompare" output="false" returnType="string">
       <cfargument name="list1" type="string" required="true" />
       <cfargument name="list2" type="string" required="true" />
       <cfargument name="delim1" type="string" required="false" default="," />
       <cfargument name="delim2" type="string" required="false" default="," />
       <cfargument name="delim3" type="string" required="false" default="," />

       <cfset var list1Array = ListToArray(arguments.List1,Delim1) />
       <cfset var list2Array = ListToArray(arguments.List2,Delim2) />

       <!--- Remove the subset List2 from List1 to get the diff --->
       <cfset list1Array.removeAll(list2Array) />

       <!--- Return in list format --->
       <cfreturn ArrayToList(list1Array, Delim3) />
</cffunction>

<cffunction name="loadExternalVars" access="private" returntype="void" output="no">
	<cfargument name="varlist" type="string" required="true">
	<cfargument name="scope" type="string" default="Application">
	<cfargument name="skipmissing" type="boolean" default="false">
	
	<cfset var varname = "">
	<cfset var scopestruct = 0>
	
	<cfif Left(arguments.scope,1) EQ "." AND Len(arguments.scope) GTE 2>
		<cfset variables[Right(arguments.scope,Len(arguments.scope)-1)] = Application[Right(arguments.scope,Len(arguments.scope)-1)]>
		<cfset arguments.scope = "Application#arguments.scope#">
	</cfif>
		
	<cfset scopestruct = StructGet(arguments.scope)>
	
	<cfloop index="varname" list="#arguments.varlist#">
		<cfif StructKeyExists(scopestruct,varname)>
			<cfset variables[varname] = scopestruct[varname]>
		<cfelseif NOT arguments.skipmissing>
			<cfthrow message="#scope#.#varname# is not defined.">
		</cfif>
	</cfloop>
	
</cffunction>

</cfcomponent>