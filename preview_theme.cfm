<cfset currentDir = expandPath(".")>
<cfset themesDir = currentDir & "/themes">
<cfset builtInThemeDir = application.cfthemebase>
<cfset customThemeList = application.themelocalbasearr>
<cfset builtInThemeList = application.themecfbasearr>
<cfparam name="url.theme" default="">


<cfif NOT StructKeyExists(form, "theme")>
<div class="spectrum-Page">
    <div class="spectrum-Page-content preview-container">
        <h1 class="spectrum-Heading spectrum-Heading--sizeXL">Theme Preview</h1>
        <!-- Theme Selection Dropdown -->
        <div class="theme-selector">
            <h2 class="spectrum-Heading spectrum-Heading--sizeL">Select Theme</h2>
            <form method="post" action="preview_theme.cfm">
                <div class="field-item">
                    <label for="theme" class="spectrum-FieldLabel">Choose Theme:</label>
                    <select name="theme" id="theme" class="spectrum-Dropdown">
                        <option value="">-- Select a Theme --</option>
                        <cfoutput>
                            <cfif arrayLen(customThemeList) GT 0>
                                <optgroup label="Custom Themes">
                                    <cfloop array="#customThemeList#" index="themeName">
                                        <option value="custom:#themeName#">#themeName#</option>
                                    </cfloop>
                                </optgroup>
                            </cfif>
                            <cfif arrayLen(builtInThemeList) GT 0>
                                <optgroup label="Built-in Themes">
                                    <cfloop array="#builtInThemeList#" index="themeName">
                                        <cfset displayName = listFirst(themeName, ".")>
                                        <option value="builtin:#displayName#">#displayName#</option>
                                    </cfloop>
                                </optgroup>
                            </cfif>
                        </cfoutput>
                    </select>
                    <input type="submit" value="Preview" class="spectrum-Button spectrum-Button--primary">
                </div>
            </form>
        </div>

<cfelse>
<cfscript>
    // Determine theme type and build correct theme path
    themeValue = form.theme;
    themePath = "";
    
    if (left(themeValue, 7) == "custom:") {
        // Custom theme - use themes/filename.json pattern
        customThemeName = right(themeValue, len(themeValue) - 7);
        themePath = "themes/" & customThemeName;
    } else if (left(themeValue, 8) == "builtin:") {
        // Built-in theme - use just the theme name
        builtInThemeName = right(themeValue, len(themeValue) - 8);
        themePath = builtInThemeName;
    } else {
        // Legacy support - assume custom theme for backward compatibility
        themePath = "themes/" & themeValue;
    }
    
    border = {
        "border-radius" : "10"
    }

    border2 = {
        "borderRadiusTopLeft" : "10px",
        "borderRadiusTopRight": "10px"
    }

    plotPie = {
        "slice" : "60%"
    }

    plot = {
        "border-radius" : "10"
    }
    
</cfscript>
<cfchartset format="html" height="100%" width="100%" theme="#themePath#" layout="2x3">
            <!-- Revenue Chart -->
            <cfchart format="html" x="2%" y="1.5%"  height="48%" width="63%" type="curvedarea"  border="#border#" title="Revenue (Income vs Expenses)" >
                <cfchartseries type="area" serieslabel="Income" >
                    <cfchartdata item="January" value="1200" />
                    <cfchartdata item="February" value="1900" />
                    <cfchartdata item="March" value="3000" />
                    <cfchartdata item="April" value="5000" />
                    <cfchartdata item="May" value="2000" />
                </cfchartseries>
                <cfchartseries type="area" serieslabel="Expenses" >
                    <cfchartdata item="January" value="1000" />
                    <cfchartdata item="February" value="1700" />
                    <cfchartdata item="March" value="2500" />
                    <cfchartdata item="April" value="4500" />
                    <cfchartdata item="May" value="1800" />
                </cfchartseries>
            </cfchart>

            <!-- Sales by Category -->
            <cfchart format="html" x="66%" y="1.5%" height="48%" width="32%" border="#border#"  plot="#plotPie#" type="ring" title="Sales by Category" >
                <cfchartseries type="pie">
                    <cfchartdata item="Apparel" value="300" />
                    <cfchartdata item="Sports" value="50" />
                    <cfchartdata item="Others" value="100" />
                    <cfchartdata item="Test" value="200" />
                    <cfchartdata item="Test1" value="150" />
                </cfchartseries>
            </cfchart>

            
       
            
        
            
            <!-- Daily Sales (Money) -->
            <cfchart format="html" x="2%" y="51%" height="48%" width="30%" border="#border#" type="histogram" seriesplacement="stacked" title="Daily Sales (Money)" >
                <cfchartseries  serieslabel="This Week"  >
                    <cfchartdata item="Monday" value="200" />
                    <cfchartdata item="Tuesday" value="400" />
                    <cfchartdata item="Wednesday" value="600" />
                    <cfchartdata item="Thursday" value="800" />
                    <cfchartdata item="Friday" value="1000" />
                    <cfchartdata item="Saturday" value="900" />
                    <cfchartdata item="Sunday" value="700" />
                </cfchartseries>
                <cfchartseries  serieslabel="Last Week" border="#border2#">
                    <cfchartdata item="Monday" value="100" />
                    <cfchartdata item="Tuesday" value="300" />
                    <cfchartdata item="Wednesday" value="500" />
                    <cfchartdata item="Thursday" value="700" />
                    <cfchartdata item="Friday" value="800" />
                    <cfchartdata item="Saturday" value="600" />
                    <cfchartdata item="Sunday" value="500" />
                </cfchartseries>
            </cfchart>

            <!-- Daily Sales (Count) -->
            <cfchart format="html" x="33%" y="51%" height="48%"  width="30%" border="#border#" type="curve" title="Daily Sales (Number)" showLegend="false" >
                <cfchartseries  serieslabel="Sales Count" >
                    <cfchartdata item="Monday" value="20" />
                    <cfchartdata item="Tuesday" value="40" />
                    <cfchartdata item="Wednesday" value="60" />
                    <cfchartdata item="Thursday" value="80" />
                    <cfchartdata item="Friday" value="100" />
                    <cfchartdata item="Saturday" value="90" />
                    <cfchartdata item="Sunday" value="70" />
                </cfchartseries>
            </cfchart>

            <!-- Floating Bar Chart -->
            <cfchart format="html" x="64%" y="51%" height="48%" width="34%" border="#border#" type="fbar"  plot="#plot#" title="Sales Metrics (Approx Floating Bar)" >
                <cfchartseries  serieslabel="Electronics" >
                    <cfchartdata item="January" value="600" zvalue="300" />
                    <cfchartdata item="February" value="650" zvalue="350"/>
                    <cfchartdata item="March" value="700" zvalue="400"/>
                    <cfchartdata item="April" value="750" zvalue="450"/>
                    <cfchartdata item="May" value="720" zvalue="400"/>
                </cfchartseries>
                <cfchartseries  serieslabel="Apparel" >
                    <cfchartdata item="January" value="500" zvalue="200"/>
                    <cfchartdata item="February" value="550" zvalue="250"/>
                    <cfchartdata item="March" value="600" zvalue="300"/>
                    <cfchartdata item="April" value="650" zvalue="350"/>
                    <cfchartdata item="May" value="680" zvalue="350"/>
                </cfchartseries>
                <cfchartseries  serieslabel="Groceries" >
                    <cfchartdata item="January" value="700" zvalue="400"/>
                    <cfchartdata item="February" value="750" zvalue="450"/>
                    <cfchartdata item="March" value="800" zvalue="500"/>
                    <cfchartdata item="April" value="850" zvalue="550"/>
                    <cfchartdata item="May" value="800" zvalue="500"/>
                </cfchartseries>
            </cfchart>



</cfchartset>
</cfif>

    </div>
</div>

</body>
</html>