<cfcomponent output="no">

<cffunction name="init" access="public" returntype="any" output="no">
	<cfargument name="FileMgr" type="any" required="true">
	<cfargument name="LogsFolder" type="string" default="video_converter,logs">
	
	<cfset Variables.FileMgr = Arguments.FileMgr>
	
	<cfif StructKeyExists(Variables.FileMgr,"FileMgr")>
		<cfset Variables.FileMgr = Variables.FileMgr.FileMgr>
	</cfif>
	
	<cfset Variables.VideoFormats = "MP4,OGG,SWF,WEBM">
	
	<cfset Variables.FileMgr.makeFolder(Arguments.LogsFolder)>
	
	<cfset Variables.sMe = getMetaData(This)>
	<cfset Variables.Folder = getDirectoryFromPath(Variables.sMe.Path)>
	<cfset Variables.Delim = Right(Variables.Folder,1)>
	
	<cfset Variables.LibraryPath = "#Variables.Folder#lib#Variables.Delim#">
	<cfset Variables.VideoLogPath = Variables.FileMgr.getDirectory(Arguments.LogsFolder)>
	
	<!--- Make sure log files exist --->
	<cfif NOT FileExists(Variables.FileMgr.getFilePath("errors.log",Arguments.LogsFolder))>
		<cfset Variables.FileMgr.writeFile("errors.log","",Arguments.LogsFolder)>
	</cfif>
	<cfif NOT FileExists(Variables.FileMgr.getFilePath("results.log",Arguments.LogsFolder))>
		<cfset Variables.FileMgr.writeFile("results.log","",Arguments.LogsFolder)>
	</cfif>
	
	<!--- ToDo: Move this to its own method --->
	<!--- Mime types supported by modifyXml() --->	
	<cfset Variables.MimeTypes = arrayNew(1)>	
	<cfset Variables.MimeTypes[1] = 
			{
				extension="avi",
				type="video/avi,video/msvideo,video/x-msvideo"
			}>
	<cfset Variables.MimeTypes[2] = 
			{
				extension="flv",
				type="video/x-flv"
			}>
	<cfset Variables.MimeTypes[3] = 
			{
				extension="mp4,mpeg,mpg",
				type="video/mp4,video/mpeg"
			}>
	<cfset Variables.MimeTypes[4] = 
			{
				extension="ogg,ogv",
				type="application/ogg,video/ogg"
			}>
	<cfset Variables.MimeTypes[5] = 
			{
				extension="swf",
				type="application/x-shockwave-flash"
			}>
	<cfset Variables.MimeTypes[6] = 
			{
				extension="webm",
				type="video/webm"
			}>
	
	<cfreturn This>
</cffunction>

<cffunction name="convertVideo" access="public" returntype="string" output="no" hint="I convert a Video to the requested format. I return the file name">
	<cfargument name="VideoFilePath" type="string" required="yes" hint="The full path to the source video.">
	<cfargument name="Folder" type="string" required="yes" hint="The folder in which to place the new video.">
	<cfargument name="Extension" type="string" default="flv" hint="The extension for the new file.">
	<cfargument name="writeLogsToFile" type="boolean" required="yes" default="true">
	
	<!--- %%TODO: Provide variable bitrates dependent on client bandwidth --->
	
	<!--- convert the file --->
	<cfset var oRuntime = "">
	<cfset var command = "">
	<cfset var process = "">
	<cfset var sResults = StructNew()>
	<cfset var sConvertedFileInfo = StructNew()>
	<cfset var ConvertedFileSize = 0>
	<cfset var ConversionSuccessful = true>
	<cfset var VideoInfo = getVideoInfo(file=arguments.VideoFilePath)>
	<cfset var bitrate = "64k">
	<cfset var audiobitrate = "128k">
	<cfset var framerate = 24>
	<cfset var outputFilePath = "">
	<!--- <cfset var audiocodec = VideoInfo.AudioCodec> --->

	<cfset Variables.FileMgr.makeFolder(Arguments.Folder)>
	<cfset outputFilePath = Variables.FileMgr.getDirectory(arguments.Folder) & ListFirst(ListLast(getFileFromPath(arguments.VideoFilePath),"/"),".") & "." & arguments.Extension>
	<cfset outputFilePath = Variables.FileMgr.createUniqueFileName(outputFilePath)>
	
	<!--- value returned in VideoInfo is kb/s --->
	<cfif StructKeyExists(VideoInfo,"BitRate")>
		<cfset bitrate = VideoInfo.BitRate & "k">
	</cfif>
	<cfif StructKeyExists(VideoInfo,"AudioBitrate")>
		<cfset audiobitrate = VideoInfo.AudioBitrate & "k">
	</cfif>
	<cfif StructKeyExists(VideoInfo,"Framerate")>
		<cfset framerate = VideoInfo.Framerate>
	</cfif>

	<cfscript>
	try {
		oRuntime = CreateObject("java", "java.lang.Runtime").getRuntime();
		
		//command = '#Variables.LibraryPath#ffmpeg.exe -i "#arguments.VideoFilePath#" -g 300 -y -s qvga -map_meta_data "#outputFilePath#:#arguments.VideoFilePath#" -b:v #bitrate# -b:a #audiobitrate# -r #framerate# -ar 44100 "#outputFilePath#"';
		command = '#Variables.LibraryPath#ffmpeg.exe -i "#arguments.VideoFilePath#" -g 300 -y -s qvga -b:v #bitrate# -b:a #audiobitrate# -r #framerate# -ar 44100 "#outputFilePath#"';
		
		process = oRuntime.exec(#command#);
		sResults.errorLogSuccess = processVideoStream(process.getErrorStream(),arguments.writeLogsToFile);
		sResults.resultLogSuccess = processVideoStream(process.getInputStream(),arguments.writeLogsToFile);
		sResults.exitCode = process.waitFor();
	}
	catch(exception e) {
		sResults.status = e;
	}
	</cfscript>
	
	<!--- Check for converted file. Size > 0 means a successful conversion. --->
	<cfif FileExists(outputFilePath)>
		<cfif arguments.Extension EQ "flv">
			<cfset addMetaData(outputFilePath)>
		</cfif>
		<cfset sConvertedFileInfo = GetFileInfo(outputFilePath)>
		<cfset ConvertedFileSize = sConvertedFileInfo.Size>
	</cfif>
	<cfset ConversionSuccessful = (ConvertedFileSize GT 0)>
	
	<cfif NOT ConversionSuccessful>
		<cfthrow type="VideoConverter" message="The file conversion was unsuccessful. Check the error log for details.">
	</cfif>
	
	<cfreturn outputFilePath>
</cffunction>

<cffunction name="formatVideos" access="public" returntype="struct" output="no" hint="I reproduce any videos in the needed formats." todo="steve">
	<cfargument name="Component" type="any" required="yes" hint="The calling component.">
	<cfargument name="Args" type="struct" required="yes" hint="The incoming arguments to the calling method.">
	
	<cfset var sFields = Arguments.Component.getFieldsStruct()>
	<cfset var sSources = StructNew()>
	<cfset var key = "">
	<cfset var format = "">
	
	<!--- Find all source videos and their related videos --->
	<cfloop collection="#sFields#" item="key">
		<cfif
				StructKeyExists(sFields[key],"original")
			AND	Len(sFields[key].original)
			AND	StructKeyExists(sFields,sFields[key].original)
			AND	StructKeyExists(sFields[sFields[key].original],"video")
			AND	sFields[sFields[key].original]["video"] IS true
			AND	StructKeyExists(sFields[key],"Extensions")
			AND	Len(sFields[key].Extensions)
			AND	StructKeyExists(sFields[key],"Folder")
			AND	Len(sFields[key].Folder)
			AND	StructKeyExists(Arguments.Args,sFields[key].original)
			AND	NOT (
							StructKeyExists(Arguments.Args,key)
						AND	Len(Arguments.Args[key])
				)
		>
			<cfif NOT StructKeyExists(sSources,sFields[key].original)>
				<cfset sSources[sFields[key].original] = "">
			</cfif>
			<cfset sSources[sFields[key].original] = ListAppend(sSources[sFields[key].original],sFields[key].name)>
		</cfif>
	</cfloop>
	
	<cfloop collection="#sSources#" item="key">
		<cfif StructKeyExists(Arguments.Args,key) AND isSimpleValue(Arguments.Args[key]) AND Len(Arguments.Args[key])>
			<cfloop list="#sSources[key]#" index="format">
				<cfset Arguments.Args[format] = getFileFromPath(
					convertVideo(
						VideoFilePath = Variables.FileMgr.getFilePath(Arguments.Args[key],sFields[key].Folder),
						Folder = sFields[format].Folder,
						Extension = ListFirst(sFields[format].Extensions)
					)
				)>
			</cfloop>
		</cfif>
	</cfloop>
	
	<cfreturn Arguments.Args>
</cffunction>

<cffunction name="generateVideoThumb" access="public" returntype="string" output="no" hint="I generate a Video thumbnail JPEG.">
	<cfargument name="VideoFilePath" type="string" required="yes" hint="The full path to the video from which a thumbnail image will be created.">
	<cfargument name="ThumbFolder" type="string" required="yes" hint="The folder in which to place the resulting thumbnail image (Ideally with the same name as the video, but with a different file extension).">
	
	<!--- convert the file --->
	<cfset var oRuntime = "">
	<cfset var command = "">
	<cfset var process = "">
	<cfset var sResults = StructNew()>
	<cfset var sImageFileInfo = StructNew()>
	<cfset var result = "">
	<cfset var ThumbFileName = getFileFromPath(ListDeleteAt(Arguments.VideoFilePath,ListLen(Arguments.VideoFilePath,"."),".") & ".jpg")>
	
	<!--- Determine the image path --->
	<cfset Arguments.ThumbFilePath = Variables.FileMgr.createUniqueFileName(Variables.FileMgr.getFilePath(ThumbFileName,Arguments.ThumbFolder))>

	<cfscript>
	try {
		oRuntime = CreateObject("java", "java.lang.Runtime").getRuntime();
		command = '#Variables.LibraryPath#ffmpeg.exe -i "#Arguments.VideoFilePath#" -r 1 -s qqvga -f image2 -ss 3 -vframes 1 "#Arguments.ThumbFilePath#"';
		process = oRuntime.exec(#command#);
		sResults.errorLogSuccess = processVideoStream(process.getErrorStream());
		sResults.resultLogSuccess = processVideoStream(process.getInputStream());
		sResults.exitCode = process.waitFor();
	}
	catch(exception e) {
		sResults.status = e;
	}
	</cfscript>
	
	<!--- Check for generated image file. Size > 0 means a successful gen. --->
	<cfif FileExists(Arguments.ThumbFilePath)>
		<cfset sImageFileInfo = GetFileInfo(Arguments.ThumbFilePath)>
		<cfif sImageFileInfo.Size GT 0>
			<cfset result = Arguments.ThumbFilePath>
		</cfif>
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="getVideoFiles" access="public" returntype="string" output="false" hint="I return a list of files from a query. This is based on the way that modifyXml creates fields for Records.cfc components.">
	<cfargument name="query" type="query" required="yes" hint="The query holding the video">
	<cfargument name="FileField" type="string" required="yes" hint="The field in the query representing the video.">
	<cfargument name="row" type="numeric" default="1">
	
	<cfset var result = "">
	<cfset var format = "">
	<cfset var cols = Arguments.query.ColumnList>
	<cfset var col = "">
	
	<cfif Arguments.query.RecordCount GTE Arguments.row>
		<cfloop list="#Variables.VideoFormats#" index="format">
			<cfset col = "#Arguments.FileField##format#URL">
			<cfif ListFindNoCase(cols,col) AND Len(Arguments.query[col][row])>
				<cfset result = ListAppend(result,Arguments.query[col][row])>
			</cfif>
		</cfloop>
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="getVideoSize" access="public" returntype="struct" output="false" hint="I return a structure with the height and width of the video.">
	<cfargument name="Component" type="any" required="true" hint="The Records component for this video">
	<cfargument name="FileField" type="string" required="true" hint="The field representing the video.">
	<cfargument name="query" type="query" required="false" hint="The query holding the video">
	<cfargument name="row" type="numeric" default="1">
	
	<cfset var sResult = StructNew()>
	<cfset var sFields = Arguments.Component.getFieldsStruct()>
	<cfset var sField = StructCopy(sFields[Arguments.FileField])>
	
	<cfset sResult["width"] = "">
	<cfset sResult["height"] = "">
	
	<cfif NOT StructKeyExists(sField,"width")>
		<cfset sField["width"] = "#Arguments.FileField#Width">
	</cfif>
	
	<cfif NOT StructKeyExists(sField,"height")>
		<cfset sField["height"] = "#Arguments.FileField#Height">
	</cfif>
	
	<cfif isNumeric(sField.width)>
		<cfset sResult["width"] = sField.width>
	<cfelseif StructKeyExists(sFields,sField["width"])>
		<cfif StructKeyExists(Arguments,"query") AND Arguments.query.RecordCount GTE Arguments.row AND ListFindNoCase(Arguments.query.ColumnList,sField["width"])>
			<cfset sResult["width"] = Arguments.query[sField["width"]][Arguments.row]>
		<cfelseif StructKeyExists(sFields[sField["width"]],"default")>
			<cfset sResult["width"] = sFields[sField["width"]]["default"]>
		</cfif>
	</cfif>
	
	<cfif isNumeric(sField.height)>
		<cfset sResult["height"] = sField.height>
	<cfelseif StructKeyExists(sFields,sField["height"])>
		<cfif StructKeyExists(Arguments,"query") AND Arguments.query.RecordCount GTE Arguments.row AND ListFindNoCase(Arguments.query.ColumnList,sField["height"])>
			<cfset sResult["height"] = Arguments.query[sField["height"]][Arguments.row]>
		<cfelseif StructKeyExists(sFields[sField["height"]],"default")>
			<cfset sResult["height"] = sFields[sField["height"]]["default"]>
		</cfif>
	</cfif>
	
	<cfreturn sResult>
</cffunction>

<cffunction name="getVideoHTMLForRecords" access="public" returntype="string" output="false" hint="I return the HTML to play the given video.">
	<cfargument name="Component" type="any" required="yes" hint="The Records component for this video">
	<cfargument name="query" type="query" required="yes" hint="The query holding the video">
	<cfargument name="FileField" type="string" required="yes" hint="The field in the query representing the video.">
	<cfargument name="row" type="numeric" default="1">
	<cfargument name="Title" type="string" default="video">
	<cfargument name="Controls" type="boolean" default="true">
	<cfargument name="AutoPlay" type="boolean" default="true">
	
	<cfset var sSize = getVideoSize(ArgumentCollection=Arguments)>
	
	<cfset Arguments["VideoFiles"] = getVideoFiles(ArgumentCollection=Arguments)>
	<cfif isNumeric(sSize["Width"]) AND Val(sSize["Width"])>
		<cfset Arguments["Width"] = sSize["Width"]>
	</cfif>
	<cfif isNumeric(sSize["Height"]) AND Val(sSize["Height"])>
		<cfset Arguments["Height"] = sSize["Height"]>
	</cfif>
	<cfreturn getVideoHTML(ArgumentCollection=Arguments)>
</cffunction>

<cffunction name="getVideoHTML" access="public" returntype="string" output="false" hint="I return the HTML to play the given video.">
	<cfargument name="VideoFiles" type="string" required="yes" hint="A list of URLs to the video files that should be played.">
	<cfargument name="Width" type="numeric" required="false">
	<cfargument name="Height" type="numeric" required="false">
	<cfargument name="Title" type="string" default="video">
	<cfargument name="Controls" type="boolean" default="true">
	<cfargument name="AutoPlay" type="boolean" default="true">
	
	<cfset var result = "">
	<cfset var sVideos = StructNew()>
	<cfset var FileURL = "">
	<cfset var ext = "">
	<cfset var useVideoElement = false>
	
	<cfif NOT StructKeyExists(Arguments,"Width")>
		<cfset Arguments.Width = "">
	</cfif>
	
	<cfif NOT StructKeyExists(Arguments,"Height")>
		<cfset Arguments.Height = "">
	</cfif>
	
	<cfloop list="#Arguments.VideoFiles#" index="FileURL">
		<cfset ext = LCase(ListLast(FileURL,"."))>
		<cfswitch expression="#ext#">
		<cfcase value="jpg,jpeg,gif">
			<cfset sVideos["jpg"] = FileURL>
		</cfcase>
		<cfcase value="ogg,ogv">
			<cfset sVideos["ogg"] = FileURL>
		</cfcase>
		<cfdefaultcase>
			<cfset sVideos[ext] = FileURL>
		</cfdefaultcase>
		</cfswitch>
	</cfloop>
	
	<cfset useVideoElement = ( StructKeyExists(sVideos,"mp4") OR StructKeyExists(sVideos,"webm") OR StructKeyExists(sVideos,"ogg") )>
	
	<!--- http://camendesign.com/code/video_for_everybody --->
	<!--- http://videojs.com/ --->
	<!--- first try HTML5 playback: if serving as XML, expand `controls` to `controls="controls"` and autoplay likewise --->
	<!--- warning: playback does not work on iOS3 if you include the poster attribute! fixed in iOS4.0 --->
	<cfsavecontent variable="result"><cfoutput><div class="video-js-box"><cfif useVideoElement>
	<video width="#Arguments.Width#" height="#Arguments.Height#"<cfif Arguments.Controls> controls="controls"</cfif><cfif Arguments.AutoPlay> autoplay="autoplay"</cfif>><cfif StructKeyExists(sVideos,"mp4")><!--- MP4 must be first for iPad! --->
		<source src="#sVideos.mp4#" type="video/mp4" /><!--- Safari / iOS video    ---></cfif><cfif StructKeyExists(sVideos,"webm")>
		<source src="#sVideos.webm#" type="video/webm" /><!--- Firefox / Opera / Chrome10 ---></cfif><cfif StructKeyExists(sVideos,"ogg")>
		<source src="#sVideos.ogg#" type="video/ogg" /><!--- Firefox / Opera / Chrome10 ---></cfif></cfif><cfif StructKeyExists(sVideos,"swf")><!--- fallback to Flash: --->
		<object width="#Arguments.Width#" height="#Arguments.Height#" type="application/x-shockwave-flash" data="#sVideos.swf#"><!--- Firefox uses the "data" attribute above, IE/Safari uses the param below --->
			<param name="movie" value="#sVideos.swf#" />
			<param name="quality" value="high" />
			<param name="allowFullScreen" value="true" />
			<param name="wmode" value="window" />
			<param name="allowScriptAccess" value="sameDomain" />
			<embed
				type="application/x-shockwave-flash"
				width="#Arguments.Width#"
				height="#Arguments.Height#"
				src="#sVideos.swf#"
				quality="high"
				allowFullScreen="true"
				wmode="window"
				allowScriptAccess="sameDomain"
			><cfif StructKeyExists(sVideos,"jpg")>
			<img src="#sVideos.jpg#" width="#Arguments.Width#" height="#Arguments.Height#" alt="#Arguments.Title#" title="No video playback capabilities, please download the video below" /></cfif>
		</object><cfelseif StructKeyExists(sVideos,"jpg")>
		<img src="#sVideos.jpg#" width="#Arguments.Width#" height="#Arguments.Height#" alt="#Arguments.Title#" title="No video playback capabilities, please download the video below" /></cfif><cfif useVideoElement>
	</video><!--- you *must* offer a download link as they may be able to play the file locally. customise this bit all you want --->
	<p class="vjs-no-video">	<strong>Download Video:</strong><cfif StructKeyExists(sVideos,"mp4")>
		<a href="#sVideos.mp4#">MP4</a></cfif><cfif StructKeyExists(sVideos,"webm")>
		<a href="#sVideos.webm#">WebM</a></cfif><cfif StructKeyExists(sVideos,"ogg")>
		<a href="#sVideos.ogg#">Ogg</a></cfif>
	</p></cfif>
	</div></cfoutput></cfsavecontent>
	
	<cfreturn result>
</cffunction>

<cffunction name="getVideoInfo" access="public" returntype="struct" output="false">	
	<cfargument name="file" type="string" required="yes">
	
	<cfscript>		
	var VideoInfo=StructNew();			
	var ffmpegOut="";
	var command = "";
	var process = "";
	var oRuntime = "";
	var stdError = "";
	var reader = "";
	var buffered = "";
	var line = "";

	VideoInfo.fileExists = false;
	VideoInfo.fileSize = 0;
	VideoInfo.duration = '';
	VideoInfo.seconds = 0;
	VideoInfo.format = 'unknown';
	VideoInfo.bitrate = 0;	

	if (NOT fileExists(file)) { return VideoInfo; }
	VideoInfo.fileExists = true;			
	VideoInfo.fileSize = createObject("java", "java.io.File").init("#Arguments.file#").length();
	if ( VideoInfo.FileSize eq 0) { return VideoInfo; }
	
	oRuntime = CreateObject("java", "java.lang.Runtime").getRuntime();	
	command = '#Variables.LibraryPath#ffmpeg.exe -i "#Arguments.file#"';
	process = oRuntime.exec(#command#);
	stdError = process.getErrorStream();
	reader = CreateObject("java", "java.io.InputStreamReader").init(stdError);
    buffered = CreateObject("java", "java.io.BufferedReader").init(reader);
    line = buffered.readLine();
    while ( IsDefined("line") ) {
    	ffmpegOut = ffmpegOut & line;
        line = buffered.readLine();
    }
    
	// check file type
	if (FindNoCase('Unknown format',ffmpegOut,1))
		{ return VideoInfo; }
	//VideoInfo.format = ReFindNoCase('Input ##0, [[:alnum:],]+, from',ffmpegOut,1,1);
	//VideoInfo.format = mid(ffmpegOut,VideoInfo.format.pos[1]+10,VideoInfo.format.len[1]-16);

	// get playing time
	VideoInfo.Duration = REFindNoCase('Duration: \d{2}:\d{2}:([\d\.]){0,2}',ffmpegOut,1,true);
	if (VideoInfo.Duration.len[1] GT 0) {
		VideoInfo.Duration = Mid(ffmpegOut,VideoInfo.duration.pos[1]+10,8);
	} else {
		StructDelete(VideoInfo,"Duration");
	}
	//VideoInfo.seconds = ListGetAt(VideoInfo.duration,1,':') * 3600;
	//VideoInfo.seconds = VideoInfo.seconds + ListGetAt(VideoInfo.duration,2,':') * 60;
	//VideoInfo.seconds = VideoInfo.seconds + ListGetAt(VideoInfo.duration,3,':');
	
	// get bitrate
	VideoInfo.Bitrate = REFindNoCase('bitrate: \d+ kb/s',ffmpegOut,1,true);
	if (VideoInfo.Bitrate.len[1] GT 0) {
		VideoInfo.Bitrate = Mid(ffmpegOut,VideoInfo.Bitrate.pos[1]+9,VideoInfo.Bitrate.len[1]-14);
	} else {
		StructDelete(VideoInfo,"Bitrate");
	}
	
	//get frame rate
	VideoInfo.Framerate = REFindNoCase('\d+ tbr',ffmpegOut,1,true);
	if (VideoInfo.Framerate.len[1] GT 0) {
		VideoInfo.Framerate = Mid(ffmpegOut,VideoInfo.Framerate.pos[1],VideoInfo.Framerate.len[1]-4);
	} else {
		StructDelete(VideoInfo,"Framerate");
	}
	
	// get audio bitrate
	VideoInfo.AudioBitrate = REFindNoCase('Audio: .+? \d+ kb/s',ffmpegOut,1,true);
	if (VideoInfo.AudioBitrate.len[1] GT 0) {
		VideoInfo.AudioBitrate = Mid(ffmpegOut,VideoInfo.AudioBitrate.pos[1],VideoInfo.AudioBitrate.len[1]);
		VideoInfo.AudioBitrateLocation = ListContainsNoCase(VideoInfo.AudioBitRate,"kb/s");
		VideoInfo.AudioBitrate = ListGetAt(VideoInfo.AudioBitrate,VideoInfo.AudioBitrateLocation);
		VideoInfo.AudioBitrate = ListGetAt(VideoInfo.AudioBitrate,1," ");
	} else {
		StructDelete(VideoInfo,"AudioBitrate");
	}
	
	// get audio codec
	//VideoInfo.AudioCodec = REFindNoCase('Audio: .+?,',ffmpegOut,1,true);
	//VideoInfo.AudioCodec = Mid(ffmpegOut,VideoInfo.AudioCodec.pos[1]+7,VideoInfo.AudioCodec.len[1]-8);
	
	return VideoInfo;
	</cfscript>	
</cffunction>

<cffunction name="modifyXml" access="public" output="false" returntype="string" hint="I take Manager XML and add definitions for additional video files." todo="steve">
	<cfargument name="xml" type="string" required="yes" hint="This XML to be modified.">
	<cfargument name="SourceVideoFile" type="string" required="yes" hint="The original video file.">
	<cfargument name="FileTypes" type="string" default="mp4,ogg,swf,webm" hint="A list of file extensions to add as new fields.">
	
	<cfset var result = "">
	<cfset var XmlObj = XmlNew()>
	<cfset var Fields = arrayNew(1)>
	<cfset var i = "">
	<cfset var j = "">
	<cfset var FieldTagPosition = 0>
	<cfset var AllFileExtensions = "">	
	<cfset var AllMimeTypes = "">		
	
	<cfif isXml(Arguments.xml)>
		<cfset XmlObj = XMLParse(Arguments.xml)>
		
		<!--- ToDo: Make more generic so that "tables[@prefix]/table[@entity]/" is not assumed. --->
		
		<!--- assuming tables tag with attr prefix and table tag with entity attribute are mentioned as mandatory in the dtd --->
		<cfset Fields = XmlSearch(XmlObj, "/tables[@prefix]/table[@entity]/field")>			
		
		<cfif ArrayLen(Fields)>		
		
			<!--- Xpath expression to calculate the position of the field tag with attribute 'name' same as arguments.SourceVideoFile
				If not found returns 1, so that a new element <field Name='SourceVideoFile'> is inserted
		 	--->
			<cfset FieldTagPosition =  XmlSearch(XmlObj,"count(//field[@name='#Arguments.SourceVideoFile#']/preceding-sibling::*)+1")>
			
			<!--- insert new field tag <field name="SourceVideoFile" Label="SourceVideoFile"> --->
			<cfif FieldTagPosition eq 1 and Fields[1].XmlAttributes["name"] neq Arguments.SourceVideoFile>
				<cfset arrayInsertAt(XmlObj.tables.table.XmlChildren,FieldTagPosition,XmlElemNew(XmlObj,"field"))>	
				<cfset XmlObj.tables.table.XmlChildren[FieldTagPosition].XmlAttributes = {	
						"name"	= "#Arguments.SourceVideoFile#",					
						"Label" = "#Arguments.SourceVideoFile#",
						"type" = "file"
					} >
			</cfif>		
			
			<cfloop list="#Arguments.FileTypes#" index="i">				
				<cfset FieldTagPosition = FieldTagPosition + 1>
				<cfset FileExtension = "">
				<cfloop from="1" to =#ArrayLen(Variables.MimeTypes)# index="j">
					<cfif listFind(Variables.MimeTypes[j].extension,i)>						
						<cfbreak>
					</cfif>
				</cfloop>	
				<cfset arrayInsertAt(XmlObj.tables.table.XmlChildren,FieldTagPosition,XmlElemNew(XmlObj,"field"))>					
				<cfset XmlObj.tables.table.XmlChildren[FieldTagPosition].XmlAttributes = {	
						"name"	= "#Arguments.SourceVideoFile##UCase(i)#",					
						"Label" = "#Arguments.SourceVideoFile# (.#i#)",
						"type" = "file",
						"Accept" = "#Variables.MimeTypes[j].type#",
						"Extensions" ="#Variables.MimeTypes[j].extension#",
						"sebfield" = "false",
						"sebcolumn" = "false"
					} >				
			</cfloop>
						
			<cfloop from=1 to=#arrayLen(Variables.MimeTypes)# index="j">
				<cfset AllFileExtensions = listAppend(AllFileExtensions, Variables.MimeTypes[j].extension) >
				<cfset AllMimeTypes = listAppend(AllMimeTypes, Variables.MimeTypes[j].type) >
			</cfloop>
			
			<cfset structInsert(XmlObj.tables.table.XmlChildren[1].XmlAttributes,"Accept",AllMimeTypes)>
			<cfset structInsert(XmlObj.tables.table.XmlChildren[1].XmlAttributes,"Extensions",AllFileExtensions)>		
			
			<cfset result = toString(XmlObj)>					
		</cfif>
	</cfif>		
	

	<cfreturn result>
</cffunction>

<cffunction name="processVideoStream" access="public" output="false" returntype="boolean" hint="I drain the input/output streams and optionally write the stream to a file. I return true if stream was successfully processed.">
    <cfargument name="in" type="any" required="true" hint="java.io.InputStream object">
	<cfargument name="sendToFile" type="boolean" hint="Send this video stream to file?" default="false">
	
	<cfset var out = "">
	<cfset var writer = "">
	<cfset var reader = "">
	<cfset var buffered = "">
	<cfset var line = "">
	<cfset var errorFound = false>
	<cfset var aErrors = ArrayNew(1)>
	
	<cfscript>
	if ( Arguments.sendToFile ) {
		out = CreateObject("java", "java.io.FileOutputStream").init("#variables.VideoLogPath#errors.log");
		writer = CreateObject("java", "java.io.PrintWriter").init(out);
	}
	
	reader = CreateObject("java", "java.io.InputStreamReader").init(Arguments.in);
	buffered = CreateObject("java", "java.io.BufferedReader").init(reader);
	line = buffered.readLine();
	while ( IsDefined("line") ) {
		if ( Arguments.sendToFile ) {
			writer.println(line);
			ArrayAppend(aErrors,line);
		}
		line = buffered.readLine();
	} 
	if ( Arguments.sendToFile ) {
		errorFound = writer.checkError();
		writer.flush();
		writer.close();
	}
	</cfscript>
	
	<!---<cfif ArrayLen(aErrors)>
		<cfdump var="#aErrors#">
		<cfabort>
	</cfif>--->
	
	<!--- return true if no errors found. --->
	<cfreturn (NOT errorFound)>
</cffunction>

<cffunction name="addMetaData" access="private" returntype="void" output="no" hint="I add meta data to a Video.">
	<cfargument name="FilePath" type="string" required="yes">
	
	<cfset var oRuntime = 0>
	<cfset var command = "">
	<cfset var process = 0>
	<cfset var sResults = StructNew()>
	
	<cfscript>
	try {
		oRuntime = CreateObject("java", "java.lang.Runtime").getRuntime();
		command = '#Variables.LibraryPath#flvtool2.exe -U #Arguments.FilePath#';
		process = oRuntime.exec(#command#);
	}
	catch(exception e) {
		sResults.status = e;
	}
	</cfscript>	

</cffunction>

<cffunction name="getEpochTime" access="private" returntype="string" output="no" hint="I get an Epoch time string (the number of seconds since January 1, 1970, 00:00:00).">
<cfscript>
/**
* Returns the number of seconds since January 1, 1970, 00:00:00
*
* @param DateTime      Date/time object you want converted to Epoch time.
* @return Returns a numeric value.
* @author Chris Mellon (mellan@mnr.org)
* @version 1, February 21, 2002
*/
    var datetime = 0;
    
    if (ArrayLen(Arguments) is 0) {
        datetime = Now();

    }
    else {
        if (IsDate(Arguments[1])) {
            datetime = Arguments[1];
        } else {
            return NULL;
        }
    }
    
    return DateDiff("s", "January 1 1970 00:00", datetime);
</cfscript>
</cffunction>

</cfcomponent>