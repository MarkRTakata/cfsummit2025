<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ColdFusion Chart Theme Builder</title>
    <!-- Adobe Spectrum CSS -->
    <link rel="stylesheet" href="https://unpkg.com/@spectrum-css/typography@latest/dist/index-vars.css">
    <link rel="stylesheet" href="https://unpkg.com/@spectrum-css/page@latest/dist/index-vars.css">
    <link rel="stylesheet" href="https://unpkg.com/@spectrum-css/button@latest/dist/index-vars.css">
    <link rel="stylesheet" href="https://unpkg.com/@spectrum-css/dropdown@latest/dist/index-vars.css">
    <link rel="stylesheet" href="https://unpkg.com/@spectrum-css/fieldlabel@latest/dist/index-vars.css">
    <link rel="stylesheet" href="https://unpkg.com/@spectrum-css/textfield@latest/dist/index-vars.css">
    <link rel="stylesheet" href="https://unpkg.com/@spectrum-css/accordion@latest/dist/index-vars.css">
    <style>
        .theme-builder-container { max-width: 1200px; margin: 0 auto; padding: 20px; }
        .form-section { margin-bottom: 30px; padding: 20px; border: 1px solid #ddd; border-radius: 4px; }
        .form-section h3 { margin-top: 0; color: #323232; }
        .field-group { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 15px; margin-bottom: 20px; }
        .field-item { display: flex; flex-direction: column; }
        .field-item label { margin-bottom: 5px; font-weight: 500; }
        .color-input { display: flex; align-items: center; gap: 10px; }
        .color-input input[type="color"] { width: 40px; height: 40px; border: none; border-radius: 4px; cursor: pointer; }
        .palette-row { display: flex; align-items: center; gap: 10px; margin-bottom: 10px; }
        .palette-color { width: 30px; height: 30px; border: 1px solid #ccc; border-radius: 3px; cursor: pointer; }
        .save-section { background: #f5f5f5; padding: 20px; border-radius: 4px; text-align: center; }
        .theme-name-input { max-width: 300px; margin: 0 auto 20px; }
        .base-theme-selection { background: #fff; padding: 20px; border: 2px solid #0078d4; border-radius: 4px; margin-bottom: 30px; }
    </style>
</head>
<body class="spectrum">
<cfset themeDir = application.cfthemebase>
<cfset currentDir = expandPath(".")>

<cfset fileList = application.themecfbasearr>
<cfset selectedTheme = {}>
<cfset showForm = false>

<!-- Handle form submissions -->
<cfparam name="form.baseTheme" default="">
<cfparam name="form.action" default="">
<cfparam name="form.newThemeName" default="">

<cfif len(form.baseTheme) AND form.action NEQ "save">
    <cffile action="read" file="#themeDir#\#form.baseTheme#" variable="themeContent">
    <cfset selectedTheme = deserializeJSON(themeContent)>
    <cfset showForm = true>
<cfelseif form.action EQ "save" AND len(form.newThemeName)>
    <!-- Save the new theme -->
    <!-- Start with the original theme structure -->
    <cffile action="read" file="#themeDir#\#form.baseTheme#" variable="originalThemeContent">
    <cfset newTheme = deserializeJSON(originalThemeContent)>
    
    <!-- Update theme name -->
    <cfset newTheme["theme-name"] = form.newThemeName>
    
    <!-- Process all form fields back into theme structure -->
    <cfloop collection="#form#" item="fieldName">
        <cfif fieldName NEQ "baseTheme" AND fieldName NEQ "action" AND fieldName NEQ "newThemeName" AND fieldName NEQ "fieldnames" AND fieldName NEQ "palette_data">
            <cfset fieldPath = listToArray(fieldName, "_")>
            <cfset currentLevel = newTheme>
            
            <!-- Navigate through the nested structure -->
            <cfloop from="1" to="#arrayLen(fieldPath)-1#" index="i">
                <cfset key = fieldPath[i]>
                <cfif NOT structKeyExists(currentLevel, key)>
                    <cfset currentLevel[key] = {}>
                </cfif>
                <cfset currentLevel = currentLevel[key]>
            </cfloop>
            
            <!-- Set the final value with proper type conversion -->
            <cfset finalKey = fieldPath[arrayLen(fieldPath)]>
            <cfset fieldValue = trim(form[fieldName])>
            
            <!-- Only update if we have a value -->
            <cfif fieldValue NEQ "">
                <!-- Handle JSON strings for complex values -->
                <cfif left(fieldValue, 1) EQ "{" OR left(fieldValue, 1) EQ "[">
                    <cftry>
                        <cfset currentLevel[finalKey] = deserializeJSON(fieldValue)>
                        <cfcatch>
                            <cfset currentLevel[finalKey] = fieldValue>
                        </cfcatch>
                    </cftry>
                <!-- Convert numeric strings to numbers -->
                <cfelseif isNumeric(fieldValue) AND fieldValue NEQ "">
                    <cfif find(".", fieldValue)>
                        <cfset currentLevel[finalKey] = val(fieldValue)>
                    <cfelse>
                        <cfset currentLevel[finalKey] = int(fieldValue)>
                    </cfif>
                <!-- Convert boolean strings -->
                <cfelseif fieldValue EQ "true" OR fieldValue EQ "false" OR fieldValue EQ "yes" OR fieldValue EQ "no">
                    <cfif fieldValue EQ "true" OR fieldValue EQ "yes">
                        <cfset currentLevel[finalKey] = true>
                    <cfelse>
                        <cfset currentLevel[finalKey] = false>
                    </cfif>
                <!-- Handle empty strings - keep original value -->
                <cfelseif fieldValue EQ "">
                    <!-- Don't change the original value -->
                <!-- Keep as string -->
                <cfelse>
                    <cfset currentLevel[finalKey] = fieldValue>
                </cfif>
            </cfif>
        </cfif>
    </cfloop>
    
    <!-- Handle palette specially -->
    <cfif structKeyExists(form, "palette_data") AND len(trim(form.palette_data))>
        <cftry>
            <cfset newTheme["palette"] = deserializeJSON(form.palette_data)>
            <cfcatch>
                <!-- Keep original palette if parsing fails -->
            </cfcatch>
        </cftry>
    </cfif>
    
    <!-- Clean up boolean values throughout the theme -->
    <cfset newTheme = cleanBooleanValues(newTheme)>
    
    <!-- Use ColdFusion's built-in JSON serialization -->
    <cfset themeJSON = serializeJSON(newTheme)>
    <cffile action="write" file="#currentDir#/themes/#form.newThemeName#.json" output="#themeJSON#">
    
    <cfset savedMessage = "Theme '#form.newThemeName#' saved successfully!">
</cfif>

<div class="spectrum-Page">
    <div class="spectrum-Page-content theme-builder-container">
        <a href="index.cfm" style="text-decoration: none; color: inherit;">
        <h1 class="spectrum-Heading spectrum-Heading--sizeXL">ColdFusion Chart Theme Builder</h1>
        </a>

        
        <cfif isDefined("savedMessage")>
            <div class="spectrum-Alert spectrum-Alert--positive" style="margin-bottom: 20px;">
                <cfoutput>#savedMessage#</cfoutput>
            </div>
        </cfif>
        
        <cfif NOT showForm>
            <!-- Base theme selection -->
            <div class="base-theme-selection">
                <h2 class="spectrum-Heading spectrum-Heading--sizeL">Select a Base Theme</h2>
                <p class="spectrum-Body">Choose an existing theme to use as a starting point for your custom theme.</p>
                
                <form method="post">
                    <div class="field-item">
                        <label for="baseTheme" class="spectrum-FieldLabel">Base Theme:</label>
                        <select name="baseTheme" id="baseTheme" class="spectrum-Dropdown" required>
                            <option value="">-- Select a Theme --</option>
                            <cfoutput>
                                <cfloop array="#fileList#" index="themeName">
                                    <option value="#themeName#">#themeName#</option>
                                </cfloop>
                            </cfoutput>
                        </select>
                    </div>
                    <button type="submit" class="spectrum-Button spectrum-Button--cta" style="margin-top: 15px;">
                        Load Theme for Editing
                    </button>
                </form>
            </div>
        <cfelse>
            <!-- Theme editing form -->
            <div class="base-theme-selection">
                <h2 class="spectrum-Heading spectrum-Heading--sizeL">Editing Theme: <cfoutput>#form.baseTheme#</cfoutput></h2>
                <a href="builder.cfm" class="spectrum-Button spectrum-Button--secondary">← Back to Theme Selection</a>
            </div>
            
            <form method="post" id="themeForm">
                <input type="hidden" name="action" value="save">
                <input type="hidden" name="baseTheme" value="<cfoutput>#form.baseTheme#</cfoutput>">
                <input type="hidden" name="palette_data" id="paletteData" value="">
                
                <cfoutput>
                    <!-- Generate form fields dynamically -->
                    #generateThemeForm(selectedTheme)#
                </cfoutput>
                
                <!-- Save section -->
                <div class="save-section">
                    <h3 class="spectrum-Heading spectrum-Heading--sizeM">Save Your Custom Theme</h3>
                    <div class="theme-name-input">
                        <label for="newThemeName" class="spectrum-FieldLabel">New Theme Name:</label>
                        <input type="text" name="newThemeName" id="newThemeName" class="spectrum-Textfield" 
                               placeholder="Enter theme name" required>
                    </div>
                    <button type="submit" class="spectrum-Button spectrum-Button--cta spectrum-Button--sizeL">
                        Save Theme
                    </button>
                </div>
            </form>
        </cfif>
    </div>
</div>

<!-- Web Fonts for font picker -->
<script>
const webFonts = [
    'Arial', 'Arial Black', 'Comic Sans MS', 'Courier New', 'Georgia', 
    'Helvetica', 'Impact', 'Lucida Console', 'Palatino', 'Times New Roman',
    'Trebuchet MS', 'Verdana', 'Roboto', 'Open Sans', 'Lato', 'Montserrat',
    'Source Sans Pro', 'Raleway', 'PT Sans', 'Lora', 'Merriweather'
];

// Color field detection and enhancement
document.addEventListener('DOMContentLoaded', function() {
    // Enhance color fields
    const colorFields = document.querySelectorAll('input[type="text"]');
    colorFields.forEach(field => {
        if (isColorValue(field.value)) {
            enhanceColorField(field);
        }
    });
    
    // Enhance font fields
    const fontFields = document.querySelectorAll('input[name*="font"]');
    fontFields.forEach(field => {
        if (!field.name.includes('size') && !field.name.includes('color')) {
            enhanceFontField(field);
        }
    });
    
    // Initialize palette editor
    initializePaletteEditor();
});

function isColorValue(value) {
    return /^#[0-9A-Fa-f]{3,6}$/.test(value) || 
           /^rgb/.test(value) || 
           value === 'none' || 
           ['white', 'black', 'red', 'blue', 'green', 'yellow', 'gray'].includes(value.toLowerCase());
}

function enhanceColorField(field) {
    const container = document.createElement('div');
    container.className = 'color-input';
    
    const colorPicker = document.createElement('input');
    colorPicker.type = 'color';
    colorPicker.value = convertToHex(field.value);
    
    field.parentNode.insertBefore(container, field);
    container.appendChild(colorPicker);
    container.appendChild(field);
    
    colorPicker.addEventListener('change', function() {
        field.value = this.value;
    });
    
    field.addEventListener('input', function() {
        if (isColorValue(this.value)) {
            colorPicker.value = convertToHex(this.value);
        }
    });
}

function enhanceFontField(field) {
    const select = document.createElement('select');
    select.className = 'spectrum-Dropdown';
    
    // Add current value as first option if not in standard list
    const currentFont = field.value || 'Arial';
    if (!webFonts.includes(currentFont)) {
        const currentOption = document.createElement('option');
        currentOption.value = currentFont;
        currentOption.textContent = currentFont;
        currentOption.selected = true;
        select.appendChild(currentOption);
    }
    
    webFonts.forEach(font => {
        const option = document.createElement('option');
        option.value = font;
        option.textContent = font;
        option.selected = (font === currentFont);
        select.appendChild(option);
    });
    
    field.parentNode.insertBefore(select, field);
    field.style.display = 'none';
    
    select.addEventListener('change', function() {
        field.value = this.value;
    });
}

function convertToHex(color) {
    if (color.startsWith('#')) return color;
    if (color === 'white') return '#ffffff';
    if (color === 'black') return '#000000';
    if (color === 'red') return '#ff0000';
    if (color === 'blue') return '#0000ff';
    if (color === 'green') return '#00ff00';
    if (color === 'yellow') return '#ffff00';
    if (color === 'gray') return '#808080';
    return '#000000';
}

function initializePaletteEditor() {
    const form = document.getElementById('themeForm');
    if (form) {
        form.addEventListener('submit', function() {
            updatePaletteData();
        });
    }
}

function editPaletteColor(element, currentColor) {
    const colorPicker = document.createElement('input');
    colorPicker.type = 'color';
    colorPicker.value = convertToHex(currentColor);
    
    const overlay = document.createElement('div');
    overlay.style.cssText = 'position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.5); z-index: 1000; display: flex; justify-content: center; align-items: center;';
    
    const dialog = document.createElement('div');
    dialog.style.cssText = 'background: white; padding: 20px; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.3);';
    
    const title = document.createElement('h3');
    title.textContent = 'Select Color';
    title.style.marginTop = '0';
    
    const buttons = document.createElement('div');
    buttons.style.cssText = 'margin-top: 15px; display: flex; gap: 10px; justify-content: flex-end;';
    
    const cancelBtn = document.createElement('button');
    cancelBtn.textContent = 'Cancel';
    cancelBtn.className = 'spectrum-Button spectrum-Button--secondary';
    cancelBtn.onclick = function() { document.body.removeChild(overlay); };
    
    const okBtn = document.createElement('button');
    okBtn.textContent = 'OK';
    okBtn.className = 'spectrum-Button spectrum-Button--cta';
    okBtn.onclick = function() {
        element.style.backgroundColor = colorPicker.value;
        element.dataset.color = colorPicker.value;
        document.body.removeChild(overlay);
    };
    
    buttons.appendChild(cancelBtn);
    buttons.appendChild(okBtn);
    dialog.appendChild(title);
    dialog.appendChild(colorPicker);
    dialog.appendChild(buttons);
    overlay.appendChild(dialog);
    document.body.appendChild(overlay);
}

function updatePaletteData() {
    const paletteRows = document.querySelectorAll('.palette-row');
    const paletteArray = [];
    
    paletteRows.forEach(row => {
        const colors = row.querySelectorAll('.palette-color');
        const colorRow = [];
        colors.forEach(colorEl => {
            colorRow.push(colorEl.dataset.color || colorEl.style.backgroundColor);
        });
        if (colorRow.length > 0) {
            paletteArray.push(colorRow);
        }
    });
    
    const paletteDataField = document.getElementById('paletteData');
    if (paletteDataField) {
        paletteDataField.value = JSON.stringify(paletteArray);
    }
}
</script>

<cffunction name="generateThemeForm" returntype="string" output="false">
    <cfargument name="themeData" type="struct" required="true">
    
    <cfset var html = "">
    
    <cfloop collection="#arguments.themeData#" item="key">
        <cfif key NEQ "theme-name">
            <cfset html &= generateSection(key, arguments.themeData[key], key)>
        </cfif>
    </cfloop>
    
    <cfreturn html>
</cffunction>

<cffunction name="generateSection" returntype="string" output="false">
    <cfargument name="sectionName" type="string" required="true">
    <cfargument name="sectionData" type="any" required="true">
    <cfargument name="fieldPrefix" type="string" required="true">
    
    <cfset var html = "">
    
    <cfif arguments.sectionName EQ "palette">
        <cfset html &= generatePaletteSection(arguments.sectionData)>
    <cfelseif isStruct(arguments.sectionData)>
        <cfset html &= '<div class="form-section">'>
        <cfset html &= '<h3 class="spectrum-Heading spectrum-Heading--sizeM">' & uCase(left(arguments.sectionName, 1)) & right(arguments.sectionName, len(arguments.sectionName)-1) & '</h3>'>
        <cfset html &= '<div class="field-group">'>
        
        <cfloop collection="#arguments.sectionData#" item="subKey">
            <cfif isStruct(arguments.sectionData[subKey])>
                <cfset html &= '</div>' & generateSection(subKey, arguments.sectionData[subKey], arguments.fieldPrefix & "_" & subKey) & '<div class="field-group">'>
            <cfelse>
                <cfset html &= generateField(subKey, arguments.sectionData[subKey], arguments.fieldPrefix & "_" & subKey)>
            </cfif>
        </cfloop>
        
        <cfset html &= '</div></div>'>
    </cfif>
    
    <cfreturn html>
</cffunction>

<cffunction name="generateField" returntype="string" output="false">
    <cfargument name="fieldName" type="string" required="true">
    <cfargument name="fieldValue" type="any" required="true">
    <cfargument name="fieldId" type="string" required="true">
    
    <cfset var html = "">
    <cfset var inputType = "text">
    <cfset var displayValue = "">
    
    <!-- Convert complex values to JSON strings -->
    <cfif isArray(arguments.fieldValue) OR isStruct(arguments.fieldValue)>
        <cfset displayValue = serializeJSON(arguments.fieldValue)>
    <cfelse>
        <cfset displayValue = toString(arguments.fieldValue)>
    </cfif>
    
    <!-- Determine input type based on field name and value -->
    <cfif findNoCase("size", arguments.fieldName) OR findNoCase("width", arguments.fieldName) OR findNoCase("height", arguments.fieldName) OR isNumeric(arguments.fieldValue)>
        <cfset inputType = "number">
        <cfif NOT isNumeric(displayValue)>
            <cfset displayValue = "">
        </cfif>
    </cfif>
    
    <cfset html &= '<div class="field-item">'>
    <cfset html &= '<label for="' & arguments.fieldId & '" class="spectrum-FieldLabel">' & arguments.fieldName & ':</label>'>
    
    <cfif isBoolean(arguments.fieldValue)>
        <cfset html &= '<select name="' & arguments.fieldId & '" id="' & arguments.fieldId & '" class="spectrum-Dropdown">'>
        <cfset html &= '<option value="true"' & (arguments.fieldValue ? ' selected' : '') & '>true</option>'>
        <cfset html &= '<option value="false"' & (NOT arguments.fieldValue ? ' selected' : '') & '>false</option>'>
        <cfset html &= '</select>'>
    <cfelse>
        <cfset html &= '<input type="' & inputType & '" name="' & arguments.fieldId & '" id="' & arguments.fieldId & '" value="' & EncodeForHTML(displayValue) & '" class="spectrum-Textfield">'>
    </cfif>
    
    <cfset html &= '</div>'>
    
    <cfreturn html>
</cffunction>

<cffunction name="generatePaletteSection" returntype="string" output="false">
    <cfargument name="paletteData" type="array" required="true">
    
    <cfset var html = "">
    
    <cfset html &= '<div class="form-section">'>
    <cfset html &= '<h3 class="spectrum-Heading spectrum-Heading--sizeM">Color Palette</h3>'>
    <cfset html &= '<p class="spectrum-Body">Each row represents a color series. Click colors to edit them.</p>'>
    
    <cfloop from="1" to="#arrayLen(arguments.paletteData)#" index="i">
        <cfset html &= '<div class="palette-row">'>
        <cfset html &= '<span class="spectrum-Body">Series ' & i & ':</span>'>
        
        <cfloop from="1" to="#arrayLen(arguments.paletteData[i])#" index="j">
            <cfset color = arguments.paletteData[i][j]>
            <cfset html &= '<div class="palette-color" style="background-color: ' & color & ';" data-row="' & i & '" data-col="' & j & '" data-color="' & color & '" onclick="editPaletteColor(this, ''' & color & ''')"></div>'>
        </cfloop>
        
        <cfset html &= '</div>'>
    </cfloop>
    
    <cfset html &= '</div>'>
    
    <cfreturn html>
</cffunction>



<cffunction name="cleanBooleanValues" returntype="any" output="false">
    <cfargument name="data" type="any" required="true">
    
    <cfif isStruct(arguments.data)>
        <cfset var result = {}>
        <cfloop collection="#arguments.data#" item="key">
            <cfset result[key] = cleanBooleanValues(arguments.data[key])>
        </cfloop>
        <cfreturn result>
    <cfelseif isArray(arguments.data)>
        <cfset var result = []>
        <cfloop from="1" to="#arrayLen(arguments.data)#" index="i">
            <cfset result[i] = cleanBooleanValues(arguments.data[i])>
        </cfloop>
        <cfreturn result>
    <cfelse>
        <!-- Convert boolean strings to actual booleans -->
        <cfif arguments.data EQ "yes" OR arguments.data EQ "YES">
            <cfreturn true>
        <cfelseif arguments.data EQ "no" OR arguments.data EQ "NO">
            <cfreturn false>
        <cfelse>
            <cfreturn arguments.data>
        </cfif>
    </cfif>
</cffunction>
</body>
</html>