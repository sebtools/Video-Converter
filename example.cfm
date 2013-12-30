<cfinclude template="loader.cfm">

<cfset oVideoConverter = loadVideoConverter(ExpandPath("/f/"),"/f/")>

<cfdump var="#oVideoConverter#">