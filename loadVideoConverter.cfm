<cffunction name="loadVideoConverter" access="public" returntype="any" output="no">
	<cfargument name="FilePath" type="string" required="true">
	
	<cfscript>
	var oFileMgr = CreateObject("component","FileMgr").init(Arguments.FilePath,"/f/");
	var oVideoConverter = CreateObject("component","VideoConverter").init(oFileMgr);
	</cfscript>
	
	<cfreturn oVideoConverter>
</cffunction>

<cffunction name="loadWidgets" access="public" returntype="any" output="no">
	<cfargument name="FilePath" type="string" required="true">
	
	<cfscript>
	var oVideoConverter = loadVideoConverter(Arguments.FilePath);
	var oDataMgr = CreateObject("component","com.sebtools.DataMgr").init("");
	var oManager = CreateObject("component","com.sebtools.Manager").init(DataMgr=oDataMgr,FileMgr=oVideoConverter.FileMgr);
	var oWidgets = CreateObject("component","tests.Widgets").init(oManager,oVideoConverter);
	</cfscript>
	
	<cfreturn oWidgets>
</cffunction>