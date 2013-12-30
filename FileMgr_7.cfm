<cffunction name="uploadFile_7" access="public" returntype="struct" output="no">
	<cfargument name="FieldName" type="string" required="yes">
	<cfargument name="Folder" type="string" required="no">
	<cfargument name="NameConflict" type="string" default="Error">
	
	<cfset var destination = getDirectory(argumentCollection=arguments)>
	<cfset var CFFILE = StructNew()>
	<cfset var result = StructNew()>
	
	<!--- Make sure the folder exists --->
	<cfif StructKeyExists(arguments,"Folder")>
		<cfset makeFolder(arguments.Folder)>
	</cfif>
	
	<cffile action="UPLOAD" filefield="#arguments.FieldName#" destination="#destination#" nameconflict="#arguments.NameConflict#" result="CFFILE">
	<cfset result = CFFILE>
	
	<cfreturn result>
</cffunction>
<cfset This["uploadFile"] = uploadFile_7>