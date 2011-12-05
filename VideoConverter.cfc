<cfcomponent output="no">

<cffunction name="init" access="public" returntype="any" output="no">
	<cfargument name="FileMgr" type="any" required="true">
	<cfargument name="LogsFolder" type="string" default="video_converter,logs">
	
	<cfset Variables.FileMgr = Arguments.FileMgr>
	
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
	
	<cfreturn This>
</cffunction>

<cffunction name="convertVideo" access="public" returntype="string" output="no" hint="I convert a Video to the requested format. I return the file name" todo="tim">
	<cfargument name="VideoFilePath" type="string" required="yes" hint="The full path to the source video.">
	<cfargument name="Folder" type="string" required="yes" hint="The folder in which to place the new video.">
	<cfargument name="Extension" type="string" default="flv" hint="The extension for the new file.">
	<cfargument name="ffmpegPath" type="string" required="yes" default="#Variables.LibraryPath#ffmpeg.exe">
	<cfargument name="flvtoolPath" type="string" required="yes" default="#variables.LibraryPath#flvtool2.exe">
	<cfargument name="resultLogPath" type="string" required="yes" default="#variables.VideoLogPath#Output_result.log">
	<cfargument name="errorLogPath" type="string" required="yes" default="#variables.VideoLogPath#Output_error.log">
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
	<cfset outputFilePath = Variables.FileMgr.getDirectory(arguments.Folder) & ListFirst(ListLast(arguments.VideoFilePath,"/"),".") & "." & arguments.Extension>
	
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
			
			command = '#arguments.ffmpegPath# -i "#arguments.VideoFilePath#" -g 300 -y -s qvga -map_meta_data #outputFilePath#:#arguments.VideoFilePath# -b:v #bitrate# -b:a #audiobitrate# -r #framerate# -ar 44100 "#outputFilePath#"';
			
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
			<cfset addMetaData(arguments.flvtoolPath,outputFilePath)>
		</cfif>
		<cfset sConvertedFileInfo = GetFileInfo(outputFilePath)>
		<cfset ConvertedFileSize = sConvertedFileInfo.Size>
	</cfif>
	<cfset ConversionSuccessful = (ConvertedFileSize GT 0)>
	
	<cfif NOT ConversionSuccessful>
		<cfthrow type="VideoConverter" message="The file conversion was unsuccessful. Check the error log for details.">
	</cfif>
	
	<cfreturn ListLast(outputFilePath,"/")>
</cffunction>

<cffunction name="formatVideos" access="public" returntype="struct" output="no" hint="I reproduce any videos in the needed formats." todo="steve">
	<cfargument name="Component" type="any" required="yes" hint="The calling component.">
	<cfargument name="Args" type="struct" required="yes" hint="The incoming arguments to the calling method.">
	
	<cfreturn Arguments.Args>
</cffunction>

<cffunction name="generateVideoThumb" access="public" returntype="string" output="no" hint="I generate a Video thumbnail JPEG." todo="tim">
	<cfargument name="VideoFilePath" type="string" required="yes" hint="The full path to the video from which a thumbnail image will be created.">
	<cfargument name="ThumbFolder" type="string" required="yes" hint="The folder in which to place the resulting thumbnail image (Ideally with the same name as the video, but with a different file extension).">
	
	<!--- convert the file --->
	<cfset var oRuntime = "">
	<cfset var command = "">
	<cfset var process = "">
	<cfset var sResults = StructNew()>
	<cfset var sImageFileInfo = StructNew()>
	<cfset var result = "">
	<cfset var ThumbFileName = ListDeleteAt(Arguments.VideoFilePath,ListLen(Arguments.VideoFilePath,"."),".") & ".jpg">
	
	<!--- Determine the image path --->
	<cfset Arguments.ThumbFilePath = Variables.FileMgr.createUniqueFileName(Variables.FileMgr.getFilePath(ThumbFileName,Arguments.ThumbFolder))>

	<cfscript>
	try {
		oRuntime = CreateObject("java", "java.lang.Runtime").getRuntime();
		command = '#Variables.LibraryPath#ffmpeg.exe -i "#Arguments.VideoFilePath#" -r 1 -s qqvga -f image2 -ss 3 -vframes 1 "#Arguments.ThumbFilePath#"';
		process = oRuntime.exec(#command#);
		sResults.errorLogSuccess = processVideoStream(process.getErrorStream(), "#Variables.VideoLogPath#errors.log");
		sResults.resultLogSuccess = processVideoStream(process.getInputStream(), "#Variables.VideoLogPath#errors.log");
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
			<cfset result = getFileFromPath(Arguments.ThumbFilePath)>
		</cfif>
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="getVideoHTML" access="public" returntype="string" output="false" hint="I return the HTML to play the given video." todo="steve">
	<cfargument name="query" type="query" required="yes" hint="The query holding the video">
	<cfargument name="FileField" type="string" required="yes" hint="The field in the query representing the video.">
	<cfargument name="Controls" type="boolean" default="yes">
	<cfargument name="AutoPlay" type="boolean" default="yes">
	
	<cfset var result = "">
	
	<!--- http://camendesign.com/code/video_for_everybody --->
	
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
        }
        line = buffered.readLine();
    } 
    if ( Arguments.sendToFile ) {
       errorFound = writer.checkError();
       writer.flush();
       writer.close();
    }
    </cfscript>
	
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
