<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>Theme File Viewer</title>
	<!-- Adobe Spectrum CSS -->
	<link rel="stylesheet" href="https://unpkg.com/@spectrum-css/typography@latest/dist/index-vars.css">
	<link rel="stylesheet" href="https://unpkg.com/@spectrum-css/page@latest/dist/index-vars.css">
	<link rel="stylesheet" href="https://unpkg.com/@spectrum-css/button@latest/dist/index-vars.css">
	<link rel="stylesheet" href="https://unpkg.com/@spectrum-css/dropdown@latest/dist/index-vars.css">
	<link rel="stylesheet" href="https://unpkg.com/@spectrum-css/fieldlabel@latest/dist/index-vars.css">
</head>
<body class="spectrum">

	<cfset themeDir = application.cfthemebase>
	<cfset fileList = application.themecfbasearr>

	<cfparam name="form.selectedFile" default="">
	<cfset fileContent = "">
	<cfif len(form.selectedFile)>
		<cffile action="read" file="#themeDir#\#form.selectedFile#" variable="fileContent">
	</cfif>
    
	<div class="spectrum-Page">
		<div class="spectrum-Page-content">
			<h1 class="spectrum-Heading spectrum-Heading--sizeL">ColdFusion Chart Themes</h1>
			
			<div style="margin-bottom: 30px; padding: 20px; background: #f0f8ff; border-radius: 4px; border: 1px solid #0078d4;">
				<h2 class="spectrum-Heading spectrum-Heading--sizeM">Theme Builder Tools</h2>
				<p class="spectrum-Body">Create and manage custom chart themes based on existing ColdFusion themes.</p>
				<div style="display: flex; gap: 15px; margin-top: 15px;">
					<a href="builder.cfm" class="spectrum-Button spectrum-Button--cta">Create New Theme</a>
					<a href="preview_theme.cfm" class="spectrum-Button spectrum-Button--secondary">View Saved Themes</a>
					<a href="edit_theme.cfm" class="spectrum-Button spectrum-Button--secondary">Edit Existing Theme</a>
				</div>
			</div>
			
			<h2 class="spectrum-Heading spectrum-Heading--sizeM">Theme File Viewer</h2>
			<form method="post">
				<label for="selectedFile" class="spectrum-FieldLabel">Select a theme file:</label>
				<select name="selectedFile" id="selectedFile" class="spectrum-Dropdown" onchange="this.form.submit()">
					<option value="">-- Select --</option>
					<cfoutput>
					<cfloop array="#fileList#" index="f">
						<option value="#f#" <cfif form.selectedFile EQ f>selected</cfif>>#f#</option>
					</cfloop>
					</cfoutput>
				</select>
			</form>

            <!-- File content display -->
            <cfif len(fileContent)>
				<cfset fileContentArray = deserializeJSON(fileContent)>

                <div class="spectrum-Grid spectrum-Grid--sizeL" style="display:flex; gap: 20px; margin-top: 20px;">
                    <!-- Dump Column -->
                    <div style="flex: 1; min-width: 300px; border: 1px solid #ccc; padding: 10px; overflow: auto;">
                        <h3 class="spectrum-Heading spectrum-Heading--sizeM">Parsed File</h3>
                        <cfdump var="#fileContentArray#">
                    </div>

					<!-- Raw JSON Column -->
					<div style="flex: 1; min-width: 300px; border: 1px solid #ccc; padding: 10px; overflow: auto;">
						<h3 class="spectrum-Heading spectrum-Heading--sizeM">Raw File Content</h3>
						<pre id="rawJson" style="white-space: pre-wrap; word-wrap: break-word; background:#f4f4f4; padding:1em; border:1px solid #ccc;"></pre>
					</div>

					<script>
						// Grab the JSON string from CF
						const jsonStr = '<cfoutput>#encodeForJavaScript(serializeJSON(fileContentArray))#</cfoutput>';
						// Parse and pretty-print it with indentation
						const prettyJson = JSON.stringify(JSON.parse(jsonStr), null, 4);
						// Display in the <pre>
						document.getElementById('rawJson').textContent = prettyJson;
					</script>
                </div>
            </cfif>

		</div>
	</div>

</body>
</html>
