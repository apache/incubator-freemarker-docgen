<#ftl ns_prefixes={"D":"http://docbook.org/ns/docbook"}>
<#-- Avoid inital empty line! -->
<#import "util.ftl" as u>
<#import "footer.ftl" as footer>
<#import "header.ftl" as header>
<#import "navigation.ftl" as nav>
<#import "google.ftl" as google>
<#import "node-handlers.ftl" as defaultNodeHandlers>
<#import "customizations.ftl" as customizations>
<#assign nodeHandlers = [customizations, defaultNodeHandlers]>
<#-- Avoid inital empty line! -->
<!doctype html>
<html lang="en">
<#compress>
<head prefix="og: http://ogp.me/ns#">
  <meta charset="utf-8">
  <#assign titleElement = u.getRequiredTitleElement(.node)>
  <#assign title = u.titleToString(titleElement)>
  <#assign topLevelTitle = u.getRequiredTitleAsString(.node?root.*)>
  <#assign pageTitle = topLevelTitle />
  <#if title != topLevelTitle>
    <#assign pageTitle = title + " - " + topLevelTitle>
  </#if>
  <title>${pageTitle?html?replace("&#39;", "'")}</title>
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <meta name="format-detection" content="telephone=no">
  <meta property="og:site_name" content="${topLevelTitle?html}">
  <meta property="og:title" content="${title?html?replace('&#39;', '\'')}">
  <meta property="og:locale" content="en_US">
  <#-- @todo: improve this logic -->
  <#assign nodeId = .node.@id>
  <#if nodeId == "autoid_1">
    <#assign nodeId = "index">
  </#if>
  <#if deployUrl??>
    <#assign canonicalUrl = "${deployUrl + nodeId}.html">
    <meta property="og:url" content="${canonicalUrl}">
    <link rel="canoical" href="${canonicalUrl}">
  </#if>

  <!--[if gt IE 9]><!-->
  <link rel="stylesheet" type="text/css" href="http://fonts.googleapis.com/css?family=Roboto:500,700,400|Droid+Sans+Mono">
  <link rel="stylesheet" type="text/css" href="docgen-resources/docgen.min.css">
  <!--<![endif]-->

  <#if !offline && onlineTrackerHTML??>
    ${onlineTrackerHTML}
  </#if>
</head>
</#compress>

<body itemscope itemtype="http://schema.org/Article">
  <!--[if lte IE 9]>
  <div style="background-color: #C00; color: #fff; padding: 12px 24px; margin-bottom: 18px;">
    Internet Explorer 9 and earlier isn't supported!
    You need a modern browser to view this website.
  </div>
  <![endif]-->
  <@header.header logo=logo />

  <div class="site-width">

    <#assign pageType = pageType!.node?node_name>

    <div class="content-wrapper page-${pageType?lower_case}<#if disableJavaScript> no-toc</#if>">

      <div id="table-of-contents-wrapper" class="col-left">
        <#-- table of contents generated by js -->
        <#-- execute immediately to prevent page jerking -->
        <#if !disableJavaScript>
          <script>
            <@nav.breadcrumbJs />
          </script>
          <script src="toc.js"></script>
          <script src="docgen-resources/main.js"></script>
        </#if>
      </div>

      <div class="col-right">
        <div class="page-content">
          <div class="page-title">
            <@nav.pagers class="top" />
            <div class="title-wrapper">
              <#visit titleElement using nodeHandlers>
            </div>
          </div>
          <#-- - Render either ToF (Table of Files) or Page ToC; -->
          <#--   both are called, but at least one of them will be empty: -->
          <#if pageType == "search">
            <@google.searchResults />
          <#elseif pageType == "index" || pageType == "glossary">
            <#visit .node using nodeHandlers>
          <#elseif pageType == "docgen:detailed_toc">
            <@toc att="docgen_detailed_toc_element" maxDepth=99 />
          <#else>
            <@toc att="docgen_file_element" maxDepth=maxTOFDisplayDepth />
            <@toc att="docgen_page_toc_element" maxDepth=99 minLength=2 />

            <#-- - Render the usual content, like <para>-s etc.: -->
            <#list .node.* as child>
              <#if child.@docgen_file_element?size == 0
                  && child?node_name != "title"
                  && child?node_name != "subtitle">
                <#visit child using nodeHandlers>
              </#if>
            </#list>
          </#if>

          <div class="bottom-pagers-wrapper">
            <@nav.pagers class="bottom" />
          </div>
        </div>
      </div>

      <#-- Render footnotes, if any: -->
      <#assign footnotes = defaultNodeHandlers.footnotes>
      <#if footnotes?size != 0>
        <div id="footnotes">
          Footnotes:
          <ol>
            <#list footnotes as footnote>
              <li><a name="autoid_footnote_${footnote_index + 1}"></a>${footnote}</li>
            </#list>
          </ol>
        </div>
      </#if>
    </div>
  </div>

  <@footer.footer topLevelTitle=topLevelTitle />
</body>
</html>


<#macro toc att maxDepth minLength=1>
  <#local tocElems = .node["*[@${att}]"]>
  <#if (tocElems?size >= minLength)>
      <@toc_inner tocElems=tocElems att=att maxDepth=maxDepth curDepth=1 />
  </#if>
</#macro>

<#macro toc_inner tocElems att maxDepth curDepth=1>

  <#if tocElems?size == 0><#return></#if>

  <#if curDepth == 1>
    <#local class = "page-menu">
  </#if>

  <ul<#if class?has_content> class="${class?trim}"</#if>>
    <#list tocElems as tocElem>
      <li><#t>
        <a class="page-menu-link" href="${CreateLinkFromID(tocElem.@id)?html}" data-menu-target="${tocElem.@id}"><#t>
          <#recurse u.getRequiredTitleElement(tocElem) using nodeHandlers><#t>
        </a><#lt>
        <#if (curDepth < maxDepth)>
          <@toc_inner tocElem["*[@${att}]"], att, maxDepth, curDepth + 1 />
        </#if>
      </li><#t>
    </#list>
  </ul><#t>
</#macro>
