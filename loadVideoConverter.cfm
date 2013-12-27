<cffunction name="loadVideoConverter" access="public" returntype="any" output="no">
	<cfargument name="FilePath" type="string" required="true">
	
	<cfscript>
	var FileMgr = CreateObject("component","FileMgr").init(Arguments.FilePath,"/f/");
	var VideoConverter = CreateObject("component","VideoConverter").init(FileMgr);
	</cfscript>
	
	<cfreturn VideoConverter>
</cffunction>