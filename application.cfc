/*
    application.cfc - skeleton for cfsummit2025
    - Add app-wide settings, lifecycle handlers, and basic error/missing-template handling.
    - Tweak values (timeouts, logging) to match your environment.
*/

component {
    // Basic application settings
    this.name = hash("cfsummit2025");
    this.applicationTimeout = CreateTimeSpan(0,2,0,0); // 2 hours
    this.sessionManagement = false;
    this.clientManagement = false;

    // Fired once when the application starts
    public boolean function onApplicationStart() {

        // Define theme directories
        application.cfthemebase = "#server.ColdFusion.rootdir#/charting/themes";
        application.localthemeBase = expandPath('./themes');       

        // Initialize theme file lists
        application.themecfbasearr = directoryList( application.cfthemebase , false, "name" );
        application.themelocalbasearr = directoryList( application.localthemeBase , false, "name" );
        
        return true;
    }


    public boolean function onRequestStart(required string targetPage) {

        if (structKeyExists(url, "reload")) {
            onApplicationStart();            
        }

        // rebuild each request to pick up new themes
        application.themelocalbasearr = directoryList( application.localthemeBase , false, "name" );

        return true;
    }

}
