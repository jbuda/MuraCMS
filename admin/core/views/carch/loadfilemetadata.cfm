<cfset request.layout=false>
<cfset fileMetaData=$.getBean('fileMetaData').loadBy(fileid=rc.fileid,contenthistid=rc.contenthistid,siteid=rc.siteid)>
<cfoutput>
<div class="tabbable">
	<ul class="nav nav-tabs tabs initActiveTab">
		<li>
			<a href="##tabFileMetaBasic" data-toggle="tab"><span>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.tabs.basic')#</span></a>
		</li>
		<li>
			<a href="##tabFileMetaAdvanced" data-toggle="tab"><span>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.tabs.advanced')#</span></a>
		</li>
	</ul>
	<div class="tab-content row-fluid">	
		<div id="tabFileMetaBasic" class="tab-pane active">	
			<div class="fieldset">
			 	<cfif fileMetaData.hasImageFileExt()>
				<div class="control-group">
					<label class="control-label">
						#application.rbFactory.getKeyValue(session.rb,'sitemanager.filemetadata.image')#
					</label>
					<div class="controls">
						<img src="#fileMetaData.getUrlForImage('medium')#"/>
					</div>
				</div>
				</cfif>
				<div class="control-group">
					<label class="control-label">
						#application.rbFactory.getKeyValue(session.rb,'sitemanager.filemetadata.caption')#
					</label>
					<div class="controls">
						<textarea id="file-caption" data-property="caption" class="filemeta span4 htmlEditor">#fileMetaData.getCaption()#</textarea>
					</div>
				</div>
				<div class="control-group">
					<label class="control-label">
						#application.rbFactory.getKeyValue(session.rb,'sitemanager.filemetadata.alttext')#
					</label>
					<div class="controls">
						<input type="text" data-property="alttext" value="#HTMLEditFormat(fileMetaData.getAltText())#"  maxlength="255" class="filemeta span4">
					</div>
				</div>
				<div class="control-group">
					<label class="control-label">
						#application.rbFactory.getKeyValue(session.rb,'sitemanager.filemetadata.credits')#
					</label>
					<div class="controls">
						<input type="text" data-property="credits" value="#HTMLEditFormat(fileMetaData.getCredits())#"  maxlength="255" class="filemeta span4">
					</div>
				</div>
				<div class="control-group">
					<label class="control-label">
						#application.rbFactory.getKeyValue(session.rb,'sitemanager.filemetadata.updatedefaults')#
					</label>
					<div class="controls checkbox">
						<input type="checkbox" id="filemeta-setasdefault"> #application.rbFactory.getKeyValue(session.rb,'sitemanager.filemetadata.setasdefault')#
					</div>
				</div>
				<!---<input type="hidden" data-property="property" value="#HTMLEditFormat(rc.property)#" class="filemeta">--->
			</div>
		</div>
		<div id="tabFileMetaAdvanced" class="tab-pane">
			<div class="fieldset">
			 	
				<div class="control-group">
					<label class="control-label">
						#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.remoteid')#
					</label>
					<div class="controls">
						<input type="text" data-property="remoteid" value="#HTMLEditFormat(fileMetaData.getRemoteID())#"  maxlength="255" class="filemeta span4">
					</div>
				</div>
				<div class="control-group">
					<label class="control-label">
						#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.remoteurl')#
					</label>
					<div class="controls">
						<input type="text" data-property="remoteurl" value="#HTMLEditFormat(fileMetaData.getRemoteURL())#"  maxlength="255" class="filemeta span4">
					</div>
				</div>
				<div class="control-group">
					<label class="control-label">
						#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.remotepublicationdate')#
					</label>
					<div class="controls">
						<input type="text" data-property="remotepubdate" value="#LSDateFormat(fileMetaData.getRemotePubDate(),session.dateKeyFormat)#"  maxlength="255" class="filemeta span4 datepicker">
					</div>
				</div>
				<div class="control-group">
					<label class="control-label">
						#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.remotesource')#
					</label>
					<div class="controls">
						<input type="text" data-property="remotesource" value="#HTMLEditFormat(fileMetaData.getRemoteSource())#"  maxlength="255" class="filemeta span4">
					</div>
				</div>
				<div class="control-group">
					<label class="control-label">
						#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.remotesourceurl')#
					</label>
					<div class="controls">
						<input type="text" data-property="remotesourceurl" value="#HTMLEditFormat(fileMetaData.getRemoteSourceURL())#"  maxlength="255" class="filemeta span4">
					</div>
				</div>
			</div>
		</div>
	</div>
</div>	
</cfoutput>