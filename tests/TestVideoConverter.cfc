<cfcomponent extends="mxunit.framework.TestCase" displayname="Video Converter" output="no">

<!---<cfset onInvoked()>

<cffunction name="onInvoked" access="public" returntype="any" output="no">
	<cfset Variables.FormatsIn = "avi,flv,mp4,ogv,swf,webm,wmv">
	<cfset Variables.FormatsOut = "flv,mp4,ogv,swf,webm">
</cffunction>--->

<cfinclude template="../loader.cfm">

<cffunction name="beforeTests" access="public" returntype="any" output="no">
	<cfsetting requesttimeout="333" />
	<cfscript>
	Variables.TestPath = getDirectoryFromPath(getCurrentTemplatePath());
	Variables.dirdelim = Right(Variables.TestPath,1);
	Variables.WorkingPath = "#Variables.TestPath#f#Variables.dirdelim#";
	
	Variables.VideoConverter = loadVideoConverter(Variables.WorkingPath);

	Variables.sTestFiles = {
		flv = "barsandtone.flv",
		mov = "barsandtone.mov",
		mp4 = "barsandtone.mp4",
		ogg = "barsandtone.ogv",
		ogv = "barsandtone.ogv",
		swf = "barsandtone.swf",
		webm = "barsandtone.webm",
		avi = "barsandtone.avi",
		wmv = "leaves.wmv"
	};
	</cfscript>
</cffunction>

<cffunction name="afterTests" access="public" returntype="any" output="no">
	
	<cfset var qTestFiles = Variables.VideoConverter.FileMgr.getDirectoryList(directory=Variables.WorkingPath,recurse=true)>
	
	<cfoutput query="qTestFiles">
		<cfif Type EQ "File">
			<cffile action="delete" file="#Directory##Variables.dirdelim##Name#">
		</cfif>
	</cfoutput>
	
</cffunction>

<cffunction name="shouldFormatVideosCreateAllNeededFiles" access="public" returntype="any" output="no"
	hint="The formatVideos method should create all of the files needed by any video files in the component."
>
	
	<cfset var oWidgets = loadWidgets(Variables.WorkingPath)>
	<cfset var sArgs = StructFromArgs(WidgetID=0,Video="#Variables.TestPath#barsandtone.mp4")>
	<cfset var sResult = Variables.VideoConverter.formatVideos(oWidgets,sArgs)>
	<cfset var WidgetVideoPath = "#Variables.WorkingPath#test#dirdelim#widgets#dirdelim#video#dirdelim#">
	
	<cfif NOT FileExists("#WidgetVideoPath#mp4#dirdelim##sResult.VideoMP4#")>
		<cfset fail("The MP4 file does not exist in the correct location.")>
	</cfif>
	
	<cfif NOT FileExists("#WidgetVideoPath#ogg#dirdelim##sResult.VideoOGG#")>
		<cfset fail("The OGG/OGV file does not exist in the correct location.")>
	</cfif>
	
	<cfif NOT FileExists("#WidgetVideoPath#webm#dirdelim##sResult.VideoWEBM#")>
		<cfset fail("The WEBM file does not exist in the correct location.")>
	</cfif>
	
</cffunction>

<cffunction name="shouldFormatVideosReturnAllVideos" access="public" returntype="any" output="no"
	hint="The formatVideos method should return a structure including all created videos."
>
	
	<cfset var oWidgets = loadWidgets(Variables.WorkingPath)>
	<cfset var sArgs = StructFromArgs(WidgetID=0,Video="#Variables.TestPath#barsandtone.mp4")>
	<cfset var sResult = Variables.VideoConverter.formatVideos(oWidgets,sArgs)>
	<cfset var Keys = StructKeyList(sResult)>
	
	<cfif NOT ListFindNoCase(Keys,"Video")>
		<cfset fail("Original video not returned in structure.")>
	</cfif>
	
	<cfif NOT ListFindNoCase(Keys,"VideoMP4")>
		<cfset fail("MP4 video not returned in structure.")>
	</cfif>
	
	<cfif NOT ListFindNoCase(Keys,"VideoOGG")>
		<cfset fail("OGG/OGV video not returned in structure.")>
	</cfif>
	
	<cfif NOT ListFindNoCase(Keys,"VideoWEBM")>
		<cfset fail("WEBM video not returned in structure.")>
	</cfif>
	
</cffunction>

<!--- ** GetVideoHTML TESTS *** --->

<cffunction name="shouldHTMLIncludeVideoElementForHTML5Formats" access="public" returntype="any" output="no"
	hint="The getVideoHTML method should use a VIDEO element if any formats used by HTML5 are included."
>
	
	<cfset var VideoHTML = Variables.VideoConverter.getVideoHTML(VideoFiles="blah.ogv")>
	
	<cfif NOT VideoHTML CONTAINS "<video">
		<cfset fail("The Video HTML does not contain a video element even though and HTML video type is included.")>
	</cfif>
	
	<cfset VideoHTML = Variables.VideoConverter.getVideoHTML(VideoFiles="blah.swf")>
	
	<cfif VideoHTML CONTAINS "<video">
		<cfset fail("The Video HTML contains a video element even though no HTML video type is included.")>
	</cfif>
		
</cffunction>

<cffunction name="shouldHTMLIncludeObjectElementForSWF" access="public" returntype="any" output="no"
	hint="The getVideoHTML method should use an OBJECT element if any SWF files are included."
>
	
	<cfset var VideoHTML = Variables.VideoConverter.getVideoHTML(VideoFiles="blah.swf")>
	
	<cfif NOT VideoHTML CONTAINS "<object">
		<cfset fail("The Video HTML does not contain a object element even though and HTML video type is included.")>
	</cfif>
	
	<cfset VideoHTML = Variables.VideoConverter.getVideoHTML(VideoFiles="blah.ogg")>
	
	<cfif VideoHTML CONTAINS "<object">
		<cfset fail("The Video HTML contains a object element even though no HTML video type is included.")>
	</cfif>
	
</cffunction>

<!--- ** MODIFY XML TESTS *** --->

<cffunction name="getExampleXml" access="private" returntype="string" output="no">
	
	<cfset var result = "">
	
	<cfsavecontent variable="result"><cfoutput>
	<tables prefix="test">
		<table entity="Widget" Specials="CreationDate,LastUpdatedDate,Sorter">
			<field name="RandomField" type="text" />
			<field
				name="Video"
				Label="Video"
				type="file"
			/>
			<field name="VideoWidth" label="Video Width" type="integer" help="The width of the video (in pixels)." required="true" default="320" />
			<field name="VideoHeight" label="Video Height" type="integer" help="The height of the video (in pixels)." required="true" default="240" />
		</table>
	</cfoutput></tables>
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
	<cfargument name="prefix" type="boolean" default="true">
	
	<cfset var result = "">
	
	<cfsavecontent variable="result"><cfoutput>
	<cfif Arguments.prefix><?xml version="1.0" encoding="UTF-8"?></cfif>
	<tables prefix="test">
		<table Specials="CreationDate,LastUpdatedDate,Sorter" entity="Widget">
			<field name="RandomField" type="text"/>
			<field Accept="video/avi,video/msvideo,video/x-msvideo,video/x-flv,application/octet-stream,video/mp4,video/mpeg,application/ogg,video/ogg,application/x-shockwave-flash,video/webm,video/quicktime" Extensions="avi,flv,mp4,mpeg,mpg,ogg,ogv,swf,webm,mov" Label="Video" name="Video" type="file" video="true"/>
			<field Accept="video/mp4,video/mpeg" Extensions="mp4,mpeg,mpg" Folder="Video,mp4" Label="Video (.mp4)" name="VideoMP4" original="Video" sebcolumn="false" sebfield="false" type="file"/>
			<field Accept="application/ogg,video/ogg" Extensions="ogg,ogv" Folder="Video,ogg" Label="Video (.ogg)" name="VideoOGG" original="Video" sebcolumn="false" sebfield="false" type="file"/>
			<field Accept="application/x-shockwave-flash" Extensions="swf" Folder="Video,swf" Label="Video (.swf)" name="VideoSWF" original="Video" sebcolumn="false" sebfield="false" type="file"/>
			<field Accept="video/webm" Extensions="webm" Folder="Video,webm" Label="Video (.webm)" name="VideoWEBM" original="Video" sebcolumn="false" sebfield="false" type="file"/>
			<field default="320" help="The width of the video (in pixels)." label="Video Width" name="VideoWidth" required="true" type="integer"/>
			<field default="240" help="The height of the video (in pixels)." label="Video Height" name="VideoHeight" required="true" type="integer"/>
		</table>
	</tables>
	</cfoutput></cfsavecontent>
	
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
	
	<cfset var ConvertedXml = trim(rereplace(getConvertedXml(),">[\n|\s|\r]+<","><","all"))>
	<cfset var SolvedXml = trim(rereplace(getSolvedXml(),">[\n|\s|\r]+<","><","all"))>
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
				<cfset MimeTypes = "video/mp4,video/mpeg">
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
	<cfset var XmlSolved = getSolvedXml(false)>
	<cfset var xSolved = XmlParse(XmlSolved)>
	<cfset var xConverted = getParsedXml()>
	<cfset var axField = XmlSearch(xConverted,"//field[@name='Video']")>
	<cfset var AcceptedExtensions = xSolved.tables.table.field[2].XmlAttributes.Extensions>
	<cfset var AcceptedMimeTypes = xSolved.tables.table.field[2].XmlAttributes.Accept>
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

<cffunction name="runThumbnailTest" access="private" returntype="any" output="no">
	<cfargument name="type" type="string" required="yes">
	<cfargument name="Seconds" type="numeric" default="3">
	
	<cfset var NewFile = Variables.VideoConverter.generateVideoThumb("#Variables.TestPath##Variables.sTestFiles[Arguments.type]#","videos",Arguments.Seconds)>
	
	<cfif Len(NewFile) AND FileExists(NewFile)>
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
	
	<cfset runThumbnailTest("ogv",0)>
	
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

<cffunction name="runVideoConvertTest" access="private" returntype="any" output="no">
	<cfargument name="from" type="string" required="yes">
	<cfargument name="to" type="string" required="yes">
	
	<cfset var NewFile = Variables.VideoConverter.convertVideo("#Variables.TestPath##Variables.sTestFiles[Arguments.from]#","videos",Arguments.to)>
	
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

<cffunction name="shouldConvertVideoConvertAVI2MOV" access="public" returntype="any" output="no"
	hint="Video conversion should work from AVI to MOV."
>
	
	<cfset runVideoConvertTest("avi","mov")>
	
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

<cffunction name="shouldConvertVideoConvertFLV2MOV" access="public" returntype="any" output="no"
	hint="Video conversion should work from FLV to MOV."
>
	
	<cfset runVideoConvertTest("flv","mov")>
	
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

<cffunction name="shouldConvertVideoConvertMOV2AVI" access="public" returntype="any" output="no"
	hint="Video conversion should work from MOV to AVI."
>
	
	<cfset runVideoConvertTest("mov","avi")>
	
</cffunction>

<cffunction name="shouldConvertVideoConvertMOV2FLV" access="public" returntype="any" output="no"
	hint="Video conversion should work from MOV to FLV."
>
	
	<cfset runVideoConvertTest("mov","flv")>
	
</cffunction>

<cffunction name="shouldConvertVideoConvertMOV2MP4" access="public" returntype="any" output="no"
	hint="Video conversion should work from MOV to MP4."
>
	
	<cfset runVideoConvertTest("mov","mp4")>
	
</cffunction>

<cffunction name="shouldConvertVideoConvertMOV2OGG" access="public" returntype="any" output="no"
	hint="Video conversion should work from MOV to OGG."
>
	
	<cfset runVideoConvertTest("mov","ogv")>
	
</cffunction>

<cffunction name="shouldConvertVideoConvertMOV2SWF" access="public" returntype="any" output="no"
	hint="Video conversion should work from MOV to SWF."
>
	
	<cfset runVideoConvertTest("mov","swf")>
	
</cffunction>

<cffunction name="shouldConvertVideoConvertMOV2WEBM" access="public" returntype="any" output="no"
	hint="Video conversion should work from MOV to WEBM."
>
	
	<cfset runVideoConvertTest("mov","webm")>
	
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

<cffunction name="shouldConvertVideoConvertMP42MOV" access="public" returntype="any" output="no"
	hint="Video conversion should work from MP4 to MOV."
>
	
	<cfset runVideoConvertTest("mp4","mov")>
	
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

<cffunction name="shouldConvertVideoConvertOGG2MOV" access="public" returntype="any" output="no"
	hint="Video conversion should work from OGG to MOV."
>
	
	<cfset runVideoConvertTest("ogg","mov")>
	
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

<cffunction name="shouldConvertVideoConvertSWF2MOV" access="public" returntype="any" output="no"
	hint="Video conversion should work from SWF to MOV."
>
	
	<cfset runVideoConvertTest("swf","mov")>
	
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

<cffunction name="shouldConvertVideoConvertWEBM2MOV" access="public" returntype="any" output="no"
	hint="Video conversion should work from WEBM to MOV."
>
	
	<cfset runVideoConvertTest("webm","mov")>
	
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

<cffunction name="shouldConvertVideoConvertWMV2AVI" access="public" returntype="any" output="no"
	hint="Video conversion should work from WMV to AVI."
>
	
	<cfset runVideoConvertTest("wmv","avi")>
	
</cffunction>

<cffunction name="shouldConvertVideoConvertWMV2FLV" access="public" returntype="any" output="no"
	hint="Video conversion should work from WMV to FLV."
>
	
	<cfset runVideoConvertTest("wmv","flv")>
	
</cffunction>

<cffunction name="shouldConvertVideoConvertWMV2MOV" access="public" returntype="any" output="no"
	hint="Video conversion should work from WMV to MOV."
>
	
	<cfset runVideoConvertTest("wmv","mov")>
	
</cffunction>

<cffunction name="shouldConvertVideoConvertWMV2MP4" access="public" returntype="any" output="no"
	hint="Video conversion should work from WMV to MP4."
>
	
	<cfset runVideoConvertTest("wmv","mp4")>
	
</cffunction>

<cffunction name="shouldConvertVideoConvertWMV2OGG" access="public" returntype="any" output="no"
	hint="Video conversion should work from WMV to OGG."
>
	
	<cfset runVideoConvertTest("wmv","ogv")>
	
</cffunction>

<cffunction name="shouldConvertVideoConvertWMV2SWF" access="public" returntype="any" output="no"
	hint="Video conversion should work from WMV to SWF."
>
	
	<cfset runVideoConvertTest("wmv","swf")>
	
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
<cffunction name="listCompare" access="private" output="false" returnType="string">
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

<cffunction name="StructFromArgs" access="public" returntype="struct" output="false" hint="">
	
	<cfset var sTemp = 0>
	<cfset var sResult = StructNew()>
	<cfset var key = "">
	
	<cfif ArrayLen(arguments) EQ 1 AND isStruct(arguments[1])>
		<cfset sTemp = arguments[1]>
	<cfelse>
		<cfset sTemp = arguments>
	</cfif>
	
	<!--- set all arguments into the return struct --->
	<cfloop collection="#sTemp#" item="key">
		<cfif StructKeyExists(sTemp, key)>
			<cfset sResult[key] = sTemp[key]>
		</cfif>
	</cfloop>
	
	<cfreturn sResult>
</cffunction>

</cfcomponent>