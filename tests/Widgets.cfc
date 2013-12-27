<cfcomponent extends="com.sebtools.Records" output="no">

<cffunction name="init" access="public" returntype="any" output="no">
	<cfargument name="Manager" type="any" required="true">
	<cfargument name="VideoConverter" type="any" required="true">
	
	<cfset initInternal(ArgumentCollection=Arguments)>
	
	<cfreturn This> 
</cffunction>

<cffunction name="xml" access="public" returntype="string" output="yes">#Variables.VideoConverter.modifyXml('
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
</tables>','Video')#
</cffunction>

</cfcomponent>