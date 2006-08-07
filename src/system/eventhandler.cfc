<!-----------------------------------------------------------------------Author 	    :	Luis MajanoDate        :	September 23, 2005Description :	This is a cfc that all event handlers should extendModification History:01/12/2006 - Added fix for whitespace management.06/08/2006 - Updated for coldbox07/29/2006 - Datasource support via getdatsource()-----------------------------------------------------------------------><cfcomponent name="eventhandler" hint="This is the event handler base cfc." output="false" extends="controller"><!------------------------------------------- CONSTRUCTOR ------------------------------------------->	<cffunction name="init" access="public" returntype="any" output="false">		<!--- UDF Library Call --->		<cfset includeUDF()>		<cfreturn this>	</cffunction><!------------------------------------------- PUBLIC ------------------------------------------->	<!--- ************************************************************* --->	<cffunction name="includeUDF" access="public" hint="Includes the UDF Library if found and exists. Called only by the framework." output="false" returntype="void">		<!--- check if UDFLibraryFile is defined  --->		<cfif getSetting("UDFLibraryFile") neq "">			<!--- Check if file exists on app's includes --->			<cfif fileExists("#getSetting("ApplicationPath",1)#/#getSetting("UDFLibraryFile")#")>				<cfinclude template="/#getSetting("AppMapping")#/#getSetting("UDFLibraryFile")#">			<cfelseif fileExists(ExpandPath("#getSetting("UDFLibraryFile")#"))>				<cfinclude template="#getSetting("UDFLibraryFile")#">			<cfelse>				<cfthrow type="Framework.eventhandler.UDFLibraryNotFoundException" message="Error loading UDFLibraryFile.  The file declared in the config.xml: #getSetting("UDFLibraryFile")# was not found in your application's include directory or in the following location: #ExpandPath(getSetting("UDFLibraryFile"))#. Please make sure you verify the file's location.">			</cfif>		</cfif>	</cffunction>	<!--- ************************************************************* --->	<!--- ************************************************************* --->	<cffunction name="getCurrentLayout" access="public" hint="Gets the current set layout" returntype="string" output="false">		<cfreturn getValue("currentLayout","")>	</cffunction>	<!--- ************************************************************* --->	<!--- ************************************************************* --->	<cffunction name="getCurrentView" access="public" hint="Gets the current set view" returntype="string" output="false">		<cfreturn getValue("currentView","")>	</cffunction>	<!--- ************************************************************* --->	<!--- ************************************************************* --->	<cffunction name="getCurrentEvent" access="public" hint="Gets the current set event" returntype="string" output="false">		<cfreturn getValue("event","")>	</cffunction>	<!--- ************************************************************* --->	<!--- ************************************************************* --->	<cffunction name="getResource" access="public" output="false" returnType="string" hint="Facade to i18n.getResource">		<!--- ************************************************************* --->		<cfargument name="resource" type="string" hint="The resource to retrieve from the bundle.">		<!--- ************************************************************* --->		<cfreturn getPlugin("i18n").getResource("#arguments.resource#")>	</cffunction>	<!--- ************************************************************* --->		<!--- ************************************************************* --->	<cffunction name="getDatasource" access="public" output="false" returnType="any" hint="I will return to you a datasourceBean according to the name of the datasource you wish to get from the configstruct (config.xml)">		<!--- ************************************************************* --->		<cfargument name="name" type="string" hint="The name of the datasource to get from the configstruct (name property in the config.xml)">		<!--- ************************************************************* --->		<cfset var datasources = getSetting("Datasources")>		<!--- Check for the datasources structure --->		<cfif structIsEmpty(datasources) >			<cfthrow type="Framework.eventhandler.DatasourceStructureEmptyException" message="There are no datasources defined for this application.">		</cfif>		<!--- Try to get the correct datasources --->		<cfif structKeyExists(datasources, arguments.name)>			<cfreturn getPlugin("beanFactory").create("coldbox.system.beans.datasource").init(datasources[arguments.name])>		<cfelse>			<cfthrow type="Framework.eventhandler.DatasourceNotFoundException" message="The datasource: #arguments.name# is not defined.">		</cfif>			</cffunction>	<!--- ************************************************************* ---><!------------------------------------------- PRIVATE ------------------------------------------->	<!--- ************************************************************* --->	<cffunction name="throw" access="private" hint="Facade for cfthrow" output="false">		<!--- ************************************************************* --->		<cfargument name="message" 	type="string" 	required="yes">		<cfargument name="detail" 	type="string" 	required="no" default="">		<cfargument name="type"  	type="string" 	required="no" default="Framework">		<!--- ************************************************************* --->		<cfthrow type="#arguments.type#" message="#arguments.message#"  detail="#arguments.detail#">	</cffunction>	<!--- ************************************************************* --->	<!--- ************************************************************* --->	<cffunction name="dump" access="private" hint="Facade for cfmx dump" returntype="void">		<!--- ************************************************************* --->		<cfargument name="var" required="yes" type="any">		<!--- ************************************************************* --->		<cfdump var="#var#">	</cffunction>	<!--- ************************************************************* --->	<!--- ************************************************************* --->	<cffunction name="abort" access="private" hint="Facade for cfabort" returntype="void" output="false">		<cfabort>	</cffunction>	<!--- ************************************************************* --->	<!--- ************************************************************* --->	<cffunction name="include" access="private" hint="Facade for cfinclude" returntype="void" output="false">		<!--- ************************************************************* --->		<cfargument name="template" type="string">		<!--- ************************************************************* --->		<cfinclude template="#template#">	</cffunction>	<!--- ************************************************************* --->	<!--- ************************************************************* --->	<cffunction name="filterQuery" access="private" returntype="query" hint="Filters a query by the given value" output="false">		<!--- ************************************************************* --->		<cfargument name="qry" 		type="query" 	required="yes" hint="Query to filter">		<cfargument name="field" 		type="string" 	required="yes" hint="Field to filter on">		<cfargument name="value" 		type="string" 	required="yes" hint="Value to filter on">		<cfargument name="cfsqltype" 	type="string" 	required="no" default="cf_sql_varchar" hint="The cf sql type of the value.">		<!--- ************************************************************* --->		<cfset var qryNew = QueryNew("")>		<cfquery name="qryNew" dbtype="query">			SELECT *				FROM arguments.qry				WHERE #trim(arguments.field)# = <cfqueryparam cfsqltype="#trim(arguments.cfsqltype)#" value="#trim(arguments.value)#">		</cfquery>		<cfreturn qryNew>	</cffunction>	<!--- ************************************************************* --->	<!--- ************************************************************* --->	<cffunction name="sortQuery" access="private" returntype="query" hint="Sorts a query by the given field" output="false">		<!--- ************************************************************* --->		<cfargument name="qry" 			type="query" 	required="yes" hint="Query to sort">		<cfargument name="sortBy" 		type="string" 	required="yes" hint="Sort by column(s)">		<cfargument name="sortOrder" 		type="string" 	required="no" default="ASC" hint="ASC/DESC">		<!--- ************************************************************* --->		<cfset var qryNew = QueryNew("")>		<cfquery name="qryNew" dbtype="query">			SELECT *				FROM arguments.qry				ORDER BY #trim(Arguments.SortBy)# #Arguments.SortOrder#		</cfquery>		<cfreturn qryNew>	</cffunction>	<!--- ************************************************************* ---></cfcomponent>