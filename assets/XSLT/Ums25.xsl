<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:frbroo="http://iflastandards.info/ns/fr/frbr/frbroo/"
  xmlns:crm="http://www.cidoc-crm.org/cidoc-crm/"
  xmlns:schema="http://schema.org/"
  xmlns:dct="http://purl.org/dc/terms/"
  version="1.0"
  exclude-result-prefixes="tei rdf frbroo crm schema dct">

  <xsl:output method="html" indent="yes" encoding="UTF-8"/>
  <xsl:strip-space elements="*"/>


  <xsl:param name="RDF_PATH" select="'Ums25_RDF.xml'"/>


  <xsl:template match="/tei:TEI">
    <xsl:variable name="RDF" select="document($RDF_PATH)"/>


    <xsl:variable name="docTitle"
      select="normalize-space(tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title)"/>
    <xsl:variable name="authorText"
      select="normalize-space(tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author)"/>


    <xsl:variable name="authorRefRaw"
      select="string(tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author/@ref)"/>
    <xsl:variable name="authorLink">
      <xsl:choose>
        <xsl:when test="starts-with($authorRefRaw,'http://') or starts-with($authorRefRaw,'https://')">
          <xsl:value-of select="$authorRefRaw"/>
        </xsl:when>
        <xsl:when test="starts-with($authorRefRaw,'#')">
          <xsl:variable name="aid" select="substring-after($authorRefRaw,'#')"/>
          <xsl:value-of select="string((tei:teiHeader//tei:listPerson//tei:person[@xml:id=$aid]/tei:persName/@ref)[1])"/>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="msDesc" select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc"/>
    <xsl:variable name="msRepoRefRaw" select="string(($msDesc/tei:msIdentifier/tei:repository/@ref)[1])"/>
    <xsl:variable name="msRepoName"   select="normalize-space(($msDesc/tei:msIdentifier/tei:repository)[1])"/>
    <xsl:variable name="msCollection" select="normalize-space(($msDesc/tei:msIdentifier/tei:collection)[1])"/>
    <xsl:variable name="msIdno"       select="normalize-space(($msDesc/tei:msIdentifier/tei:idno)[1])"/>
    <xsl:variable name="msDateWhen"   select="string(($msDesc//tei:docDate/@when)[1])"/>
    <xsl:variable name="msDateText"   select="normalize-space(($msDesc//tei:docDate)[1])"/>

 
    <xsl:variable name="msRepoId" select="substring-after($msRepoRefRaw,'#')"/>
    <xsl:variable name="msRepoLink"
      select="string((tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:authority[@xml:id=$msRepoId]/@ref)[1])"/>

 
    <xsl:variable name="msExpr" select="$RDF//frbroo:F2_Expression[@rdf:about='id/expr/ms1925']"/>
    <xsl:variable name="relatedPrintHref"
      select="string((
        $msExpr/schema:relatedLink/@rdf:resource |
        $msExpr/schema:relatedLink[not(@rdf:resource)]
      )[1])"/>

    <html vocab="https://schema.org/"
      prefix="ex: https://capitanulisse.example.org/id/ frbroo: http://iflastandards.info/ns/fr/frbr/frbroo/ xsd: http://www.w3.org/2001/XMLSchema#">
      <head>
        <meta charset="UTF-8"/>
        <title><xsl:value-of select="$docTitle"/></title>
        <link rel="stylesheet" href="main.css"/>
      </head>

      <body>
        <div class="manuscript-viewer">
          <header class="viewer-header">
            <h1 class="viewer-title"><xsl:value-of select="$docTitle"/></h1>
            <p class="viewer-author">
              <strong>Author:</strong>
              <xsl:text> </xsl:text>
              <xsl:choose>
                <xsl:when test="string($authorLink) != ''">
                  <a href="{$authorLink}" target="_blank" rel="noopener noreferrer">
                    <xsl:value-of select="$authorText"/>
                  </a>
                </xsl:when>
                <xsl:otherwise><xsl:value-of select="$authorText"/></xsl:otherwise>
              </xsl:choose>
            </p>
          </header>

    
          <nav class="viewer-toolbar" id="mini-nav">
            <div class="toolbar-group toolbar-pages">
              <label for="page-select">Page:</label>
              <select id="page-select" class="page-select">
                <xsl:for-each select="tei:text//tei:pb">
                  <option value="{@n}" data-facs="{@facs}">
                    <xsl:text>Page </xsl:text><xsl:value-of select="@n"/>
                  </option>
                </xsl:for-each>
              </select>
            </div>

            <div class="toolbar-group toolbar-layers">
              <label for="layer-select">Witness:</label>
              <select id="layer-select" class="layer-select">
                <xsl:for-each select="tei:teiHeader//tei:listWit/tei:witness">
                  <option value="{@xml:id}">
                    <xsl:value-of select="@xml:id"/>
                  </option>
                </xsl:for-each>
              </select>
            </div>

            <div class="toolbar-group toolbar-metadata">
              <button type="button" id="metadata-toggle" class="metadata-toggle">Show / hide metadata</button>
            </div>
          </nav>

          <main class="viewer-layout">
            
            <section id="page-viewer" class="page-viewer">
              <xsl:for-each select="tei:text//tei:pb">
                <xsl:variable name="pageNum" select="@n"/>
                <xsl:variable name="pbId" select="generate-id(.)"/>

                
                <xsl:variable name="facsId" select="substring-after(@facs,'#')"/>
                <xsl:variable name="surface" select="/tei:TEI/tei:facsimile/tei:surface[@xml:id=$facsId]"/>
                <xsl:variable name="imgUrl" select="string($surface/tei:graphic/@url)"/>

           
                <xsl:variable name="pageRoots"
                  select="/tei:TEI/tei:text//*
                    [not(self::tei:pb)]
                    [generate-id(preceding::tei:pb[1]) = $pbId]
                    [not(ancestor::*[not(self::tei:pb)][generate-id(preceding::tei:pb[1]) = $pbId])]"
                />

                <article>
                  <xsl:attribute name="class">
                    <xsl:text>page</xsl:text>
                    <xsl:if test="position()=1"><xsl:text> is-active</xsl:text></xsl:if>
                  </xsl:attribute>
                  <xsl:attribute name="data-page"><xsl:value-of select="$pageNum"/></xsl:attribute>
                  <xsl:attribute name="data-facs"><xsl:value-of select="@facs"/></xsl:attribute>

                  <header class="page-header">
                    <h2 class="page-title">
                      <xsl:text>Page </xsl:text><xsl:value-of select="$pageNum"/>
                    </h2>
                  </header>

                  <div class="page-inner">
                    <div class="page-text-column">
     
                      <xsl:apply-templates select="$pageRoots" mode="render"/>

                     
                      <ul class="page-entities-source" hidden="hidden">
                        <xsl:for-each select="/tei:TEI/tei:text//*[self::tei:persName or self::tei:placeName or self::tei:objectName or self::tei:name]
                          [generate-id(preceding::tei:pb[1]) = $pbId]">

                          <xsl:variable name="type" select="local-name()"/>
                          <xsl:variable name="ref"  select="string(@ref)"/>
                          <xsl:variable name="id"   select="substring-after($ref,'#')"/>

                          
                          <xsl:variable name="wd">
                            <xsl:choose>
                              <xsl:when test="starts-with($ref,'http://') or starts-with($ref,'https://')">
                                <xsl:value-of select="$ref"/>
                              </xsl:when>
                              <xsl:when test="$type='persName' and starts-with($ref,'#')">
                                <xsl:choose>
                                  <xsl:when test="/tei:TEI/tei:teiHeader//tei:listPerson[@type='play_characters']//tei:person[@xml:id=$id]/tei:persName[@ref]">
                                    <xsl:value-of select="string(/tei:TEI/tei:teiHeader//tei:listPerson[@type='play_characters']//tei:person[@xml:id=$id]/tei:persName[@ref][1]/@ref)"/>
                                  </xsl:when>
                                  <xsl:when test="/tei:TEI/tei:teiHeader//tei:listPerson//tei:person[@xml:id=$id]/tei:persName[@ref]">
                                    <xsl:value-of select="string(/tei:TEI/tei:teiHeader//tei:listPerson//tei:person[@xml:id=$id]/tei:persName[@ref][1]/@ref)"/>
                                  </xsl:when>
                                  <xsl:otherwise/>
                                </xsl:choose>
                              </xsl:when>
                              <xsl:otherwise/>
                            </xsl:choose>
                          </xsl:variable>

                          <xsl:variable name="role">
                            <xsl:choose>
                              <xsl:when test="$type='persName' and count(ancestor::tei:speaker) &gt; 0">speaker</xsl:when>
                              <xsl:otherwise>mention</xsl:otherwise>
                            </xsl:choose>
                          </xsl:variable>

                          <xsl:variable name="label">
                            <xsl:choose>
                              <xsl:when test="$type='persName' and starts-with($ref,'#')">
                                <xsl:choose>
                                  <xsl:when test="/tei:TEI/tei:teiHeader//tei:listPerson[@type='play_characters']//tei:person[@xml:id=$id]/tei:persName">
                                    <xsl:value-of select="normalize-space(string(/tei:TEI/tei:teiHeader//tei:listPerson[@type='play_characters']//tei:person[@xml:id=$id]/tei:persName[1]))"/>
                                  </xsl:when>
                                  <xsl:when test="/tei:TEI/tei:teiHeader//tei:listPerson//tei:person[@xml:id=$id]/tei:persName">
                                    <xsl:value-of select="normalize-space(string(/tei:TEI/tei:teiHeader//tei:listPerson//tei:person[@xml:id=$id]/tei:persName[1]))"/>
                                  </xsl:when>
                                  <xsl:otherwise><xsl:value-of select="normalize-space(.)"/></xsl:otherwise>
                                </xsl:choose>
                              </xsl:when>
                              <xsl:otherwise><xsl:value-of select="normalize-space(.)"/></xsl:otherwise>
                            </xsl:choose>
                          </xsl:variable>

                          <xsl:if test="$type='persName' or starts-with($wd,'http://') or starts-with($wd,'https://')">
                            <li data-type="{$type}" data-role="{$role}" data-wd="{$wd}">
                              <xsl:attribute name="data-key">
                                <xsl:choose>
                                  <xsl:when test="starts-with($wd,'http://') or starts-with($wd,'https://')"><xsl:value-of select="$wd"/></xsl:when>
                                  <xsl:when test="$type='persName' and starts-with($ref,'#')"><xsl:value-of select="$ref"/></xsl:when>
                                  <xsl:otherwise><xsl:value-of select="$label"/></xsl:otherwise>
                                </xsl:choose>
                              </xsl:attribute>
                              <xsl:value-of select="$label"/>
                            </li>
                          </xsl:if>
                        </xsl:for-each>
                      </ul>
                    </div>

                    <div class="page-image-column">
                      <xsl:if test="$imgUrl != ''">
                        <img class="page-image" src="{$imgUrl}" alt="Facsimile page {$pageNum}"/>
                      </xsl:if>
                    </div>
                  </div>
                </article>
              </xsl:for-each>
            </section>

            
            <aside id="metadata-panel" class="metadata-panel" hidden="hidden">
              <h2 class="metadata-title">Manuscript Metadata</h2>

              <div class="metadata-block">
                <h3>Work</h3>
                <p><strong>Title:</strong> <xsl:value-of select="$docTitle"/></p>
                <p><strong>Author:</strong> <xsl:value-of select="$authorText"/></p>
              </div>

              <div class="metadata-block">
                <h3>Manuscript</h3>

                <p><strong>Repository:</strong>
                  <xsl:text> </xsl:text>
                  <xsl:choose>
                    <xsl:when test="string($msRepoLink) != ''">
                      <a href="{$msRepoLink}" target="_blank" rel="noopener noreferrer">
                        <xsl:value-of select="$msRepoName"/>
                      </a>
                    </xsl:when>
                    <xsl:otherwise><xsl:value-of select="$msRepoName"/></xsl:otherwise>
                  </xsl:choose>
                </p>

                <xsl:if test="$msCollection != ''">
                  <p><strong>Collection:</strong> <xsl:value-of select="$msCollection"/></p>
                </xsl:if>

                <p><strong>ID:</strong> <xsl:value-of select="$msIdno"/></p>

                <p><strong>Date:</strong>
                  <xsl:text> </xsl:text>
                  <xsl:choose>
                    <xsl:when test="$msDateWhen != ''"><xsl:value-of select="$msDateWhen"/></xsl:when>
                    <xsl:otherwise><xsl:value-of select="$msDateText"/></xsl:otherwise>
                  </xsl:choose>
                </p>
              </div>

              <div class="metadata-block">
                <h3>Related resources</h3>

                <p>
                  <strong>Related printed edition:</strong>
                  <xsl:text> </xsl:text>
                  <xsl:choose>
                    <xsl:when test="string($relatedPrintHref) != ''">
                      <a href="{$relatedPrintHref}" target="_blank" rel="noopener noreferrer">Printed edition</a>
                    </xsl:when>
                    <xsl:otherwise>Printed edition</xsl:otherwise>
                  </xsl:choose>
                </p>
              </div>


              <div class="metadata-block characters-block">
                <h3>People</h3>
                <ul id="meta-people-list"></ul>
              </div>

              <div class="metadata-block">
                <h3>Places</h3>
                <ul id="meta-places-list"></ul>
              </div>

              <div class="metadata-block">
                <h3>Other entities</h3>
                <ul id="meta-other-list"></ul>
              </div>
            </aside>
          </main>
        </div>

        <script src="script.js"></script>
      </body>
    </html>
  </xsl:template>


  <xsl:template match="tei:pb" mode="render"/>

  <xsl:template match="tei:div" mode="render">
    <div>
      <xsl:if test="@type">
        <xsl:attribute name="class">
          <xsl:text>div-</xsl:text><xsl:value-of select="@type"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="node()" mode="render"/>
    </div>
  </xsl:template>

  <xsl:template match="tei:head" mode="render">
    <h3 class="head"><xsl:apply-templates mode="render"/></h3>
  </xsl:template>

  <xsl:template match="tei:p" mode="render">
    <p><xsl:apply-templates mode="render"/></p>
  </xsl:template>

  <xsl:template match="tei:sp" mode="render">
    <div class="sp">
      <xsl:apply-templates select="tei:speaker" mode="render"/>
      <xsl:apply-templates select="node()[not(self::tei:speaker)]" mode="render"/>
    </div>
  </xsl:template>

  <xsl:template match="tei:speaker" mode="render">
    <span class="speaker"><xsl:apply-templates mode="render"/></span>
  </xsl:template>

  <xsl:template match="tei:stage" mode="render">
    <span class="stage"><xsl:apply-templates mode="render"/></span>
  </xsl:template>

  <xsl:template match="tei:castList" mode="render">
    <div class="castList"><xsl:apply-templates mode="render"/></div>
  </xsl:template>

  <xsl:template match="tei:castItem" mode="render">
    <div class="castItem"><xsl:apply-templates mode="render"/></div>
  </xsl:template>

  <xsl:template match="tei:roleName" mode="render">
    <span class="roleName"><xsl:apply-templates mode="render"/></span>
  </xsl:template>

  <xsl:template match="tei:roleDesc" mode="render">
    <span class="roleDesc"><xsl:apply-templates mode="render"/></span>
  </xsl:template>

  <xsl:template match="tei:note" mode="render">
    <span class="note"><xsl:apply-templates mode="render"/></span>
  </xsl:template>

  <xsl:template match="tei:lb" mode="render">
    <br class="lb"/>
  </xsl:template>

  <xsl:template match="tei:foreign" mode="render">
    <span class="foreign" lang="{@xml:lang}">
      <xsl:attribute name="title">
        <xsl:choose>
          <xsl:when test="@xml:lang='fr'">French</xsl:when>
          <xsl:when test="@xml:lang='en'">English</xsl:when>
        </xsl:choose>
      </xsl:attribute>
      <xsl:apply-templates mode="render"/>
    </span>
  </xsl:template>

 
  <xsl:template match="tei:unclear" mode="render">
    <span class="unclear">
      <xsl:attribute name="title">
        <xsl:text>Unclear</xsl:text>
        <xsl:if test="@reason">
          <xsl:text> (</xsl:text><xsl:value-of select="@reason"/><xsl:text>)</xsl:text>
        </xsl:if>
      </xsl:attribute>
      <xsl:apply-templates mode="render"/>
    </span>
  </xsl:template>
  
 
  <xsl:template match="tei:rdg/tei:gap[@reason='notInVersion']" mode="render"/>
  
 
  <xsl:template match="tei:gap" mode="render">
    <span class="gap">
      <xsl:attribute name="title">
        <xsl:text>Gap</xsl:text>
        <xsl:if test="@reason">
          <xsl:text> (</xsl:text><xsl:value-of select="@reason"/><xsl:text>)</xsl:text>
        </xsl:if>
      </xsl:attribute>
      <span class="gap-marker">[…]</span>
    </span>
  </xsl:template>
  

  <!-- Variants -->
  <xsl:template match="tei:app" mode="render">
    <span class="choice text-block">
      <xsl:apply-templates select="tei:lem | tei:rdg" mode="render"/>
    </span>
  </xsl:template>

  <xsl:template match="tei:lem | tei:rdg" mode="render">
    <xsl:variable name="wit" select="normalize-space(translate(@wit, '#', ''))"/>
    <span>
      <xsl:attribute name="class">
        <xsl:text>variant </xsl:text><xsl:value-of select="local-name()"/>
      </xsl:attribute>
      <xsl:if test="$wit != ''">
        <xsl:attribute name="data-wit"><xsl:value-of select="$wit"/></xsl:attribute>
      </xsl:if>
      <xsl:apply-templates mode="render"/>
    </span>
  </xsl:template>

  <!-- Entities -->
  <xsl:template match="tei:persName | tei:placeName | tei:name | tei:objectName" mode="render">
    <span class="entity {local-name()}"><xsl:apply-templates mode="render"/></span>
  </xsl:template>

  <!-- Default -->
  <xsl:template match="text()" mode="render">
    <xsl:value-of select="."/>
  </xsl:template>

  <xsl:template match="*" mode="render">
    <xsl:apply-templates select="node()" mode="render"/>
  </xsl:template>

</xsl:stylesheet>
