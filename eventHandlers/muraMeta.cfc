<cfcomponent extends="mura.plugin.pluginGenericEventHandler">

  <cffunction name="onApplicationLoad">
      <cfargument name="$">
      <cfset variables.pluginConfig.addEventHandler(this)>
  </cffunction>

  <cffunction name="onRenderStart" output="false" returntype="any">
      <cfargument name="$">
      <cfset var metaTags = makeTwitterMeta($) & makeFacebookOpenGraphMeta($) />
      <cfHTMLHead text='#metaTags#'>
  </cffunction>

  <cffunction name="makeFacebookOpenGraphMeta" description="Creates valid Facebook Open Graph metadata output" output="true">
    <cfargument name="$">
    <cfset var NL = Chr(13) & Chr(10) />
    <cfset var openGraphMeta = "">
    <cfset var protocol = 'http://'>
    <cfif cgi.server_port_secure neq 0>
      <cfset protocol = 'https://'>
    </cfif>

    <cfswitch expression="#$.content().getValue('type')#">
      <cfdefaultcase>
        <cfset openGraphMeta = '  <meta property="og:title" content="#$.content().getHtmlTitle()#" />#NL#  <meta property="og:type" content="article" />#NL#'>

        <cfif len(stripHTMLandTruncate($.content().getValue("summary")))>
          <cfset openGraphMeta &= '  <meta property="og:description" content="#stripHTMLAndTruncate($.content().getValue("summary"))#" />#NL#'>
        <cfelseif len(stripHTMLandTruncate($.content().getValue("body")))>
          <cfset openGraphMeta &= '  <meta property="og:description" content="#stripHTMLAndTruncate($.content().getValue("body"))#" />#NL#'>
        <cfelse>
          <cfset openGraphMeta &='  <meta property="og:description" content="#$.siteConfig().getValue("facebookDefaultDescription")#" />#NL#'>
        </cfif>

        <cfset openGraphMeta &= '  <meta property="og:site_name" content="#stripHTMLAndTruncate($.siteConfig('site'))#" />#NL#'>

        <cfif $.content().getReleaseDate() neq ''>
          <cfset openGraphMeta &= '  <meta property="article:published_time" content="#DateFormat($.content().getReleaseDate(), "yyyy-MM-dd")#T#TimeFormat($.content().getReleaseDate(), "hh:mm:00")#+Z" />#NL#'>
        <cfelse>
          <cfset openGraphMeta &= '  <meta property="article:published_time" content="#DateFormat($.content().getCreated(), "yyyy-MM-dd")#T#TimeFormat($.content().getCreated(), "hh:mm:00")#+Z" />#NL#'>
        </cfif>

        <cfset openGraphMeta &= '<meta property="article:modified_time" content="#DateFormat($.content().getLastUpdate(), "yyyy-MM-dd")#T#TimeFormat($.content().getLastUpdate(), "hh:mm:00")#+Z" />'>

        <cfif len($.content().getImageURL())>
          <cfset openGraphMeta &= '  <meta property="og:image" content="#protocol##cgi.http_host##$.content().getImageURL(size='large')#" />#NL#'>
        </cfif>

        <cfif $.siteConfig().getValue("facebookID") neq ''>
          <cfset openGraphMeta &= '  <meta property="fb:app_id" content="#$.siteConfig().getValue("facebookID")#" />#NL#'>
        </cfif>
      </cfdefaultcase>
    </cfswitch>
    <cfreturn openGraphMeta>
  </cffunction>

  <cffunction name="makeTwitterMeta" description="Creates valid Twitter card metadata output" output="true">
    <cfargument name="$">
    <cfset var NL = Chr(13) & Chr(10) />
    <cfset var cardType = "summary">
    <cfset var incImage = true>
    <cfset var twitterMeta = "">
    <cfset var protocol = 'http://'>
    <cfif cgi.server_port_secure neq 0>
      <cfset protocol = 'https://'>
    </cfif>

    <cfswitch expression="#$.content().getValue('type')#">

      <cfcase value="Gallery">
        <cfset cardType="gallery">

        <cfset twitterMeta = '<meta name="twitter:card" content="#cardType#" />#NL#<meta name="twitter:site" content="#$.siteConfig().getValue("twitterHandle")#" />#NL#<meta name="twitter:title" content="#$.content().getHtmlTitle()#" />'>
        <cfif len(stripHTMLandTruncate($.content().getValue("summary")))>
          <cfset twitterMeta &='<meta name="twitter:description" content="#stripHTMLAndTruncate($.content().getValue("summary"))#" />'>
        <cfelseif len(stripHTMLandTruncate($.content().getValue("body")))>
          <cfset twitterMeta &='<meta name="twitter:description" content="#stripHTMLAndTruncate($.content().getValue("body"))#" />'>
        <cfelse>
          <cfset twitterMeta &='<meta name="twitter:description" content="#$.siteConfig().getValue("twitterDefaultDescription")#" />'>
        </cfif>
        <cfset theGalleryImages = application.contentManager.getActiveContent($.content().getContentID(), $.event('siteid'))>
        <cfset item = theGalleryImages.getKidsIterator()>
        <cfloop condition="#item.hasNext()# and item.currentIndex() LTE 3">
            <cfset thisImage = item.next()>
            <cfset twitterMeta &= '<meta name="twitter:image#item.currentIndex()-1#" content="#protocol##cgi.http_host##thisImage.getImageURL()#" />'>
        </cfloop>

      </cfcase>

      <cfdefaultcase>
          <cfif len($.content().getImageURL())>
              <cftry>
                  <cfimage action="info" source="#protocol##cgi.http_host##$.content().getImageURL()#" structName="thisAssocImage">
                      <cfif thisAssocImage.width GTE 280 and thisAssocImage.height GTE 150>
                          <cfset cardType = "summary_large_image">
                      <cfelseif thisAssocImage.width GTE 60 and thisAssocImage.height GTE 60>
                          <cfset cardType = "summary">
                      <cfelse>
                          <cfset incImage = false>
                      </cfif>
                  <cfcatch type="any">
                      <cfset incImage = false>
                  </cfcatch>
              </cftry>
          <cfelse>
              <cfset incImage = false>
          </cfif>

        <cfset twitterMeta = '<meta name="twitter:card" content="#cardType#" />#NL#<meta name="twitter:site" content="#$.siteConfig().getValue("twitterHandle")#" />#NL#<meta name="twitter:title" content="#$.content().getHtmlTitle()#" />'>

        <cfif len(stripHTMLandTruncate($.content().getValue("summary")))>
          <cfset twitterMeta &='<meta name="twitter:description" content="#stripHTMLAndTruncate($.content().getValue("summary"))#" />'>
        <cfelseif len(stripHTMLandTruncate($.content().getValue("body")))>
          <cfset twitterMeta &='<meta name="twitter:description" content="#stripHTMLAndTruncate($.content().getValue("body"))#" />'>
        <cfelse>
          <cfset twitterMeta &='<meta name="twitter:description" content="#$.siteConfig().getValue("twitterDefaultDescription")#" />'>
        </cfif>
        <cfif incImage>
          <cfset twitterMeta &= '<meta name="twitter:image" content="#protocol##cgi.http_host##$.content().getImageURL()#" />'>
        </cfif>
      </cfdefaultcase>
    </cfswitch>
    <cfreturn twitterMeta>
  </cffunction>

  <cffunction name="stripHTMLAndTruncate" output="no" returnType="string">
    <cfargument name="str" required="yes">
    <cfset str = reReplaceNoCase(str, "<*style.*?>(.*?)</style>","","all")>
    <cfset str = reReplaceNoCase(str, "<*script.*?>(.*?)</script>","","all")>
    <cfset str = reReplaceNoCase(str, "<.*?>","","all")>
    <cfset str = reReplaceNoCase(str, "^.*?>","")>
    <cfset str = reReplaceNoCase(str, "<.*$","")>
    <cfset str = left(str, 225)>
    <cfset str = xmlformat(str)>
    <cfreturn str>
  </cffunction>
</cfcomponent>
