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

  <xsl:param name="RDF_PATH" select="'U34_RDF.xml'"/>

  <xsl:param name="BASE_WIT" select="'U34'"/>


  <xsl:template name="emit-rdfa-subject">
    <xsl:param name="RDF"/>
    <xsl:param name="about"/>

    <xsl:variable name="node" select="$RDF//*[@rdf:about=$about][1]"/>

    <xsl:if test="$node">
      <div hidden="hidden">
        <xsl:attribute name="about"><xsl:value-of select="$about"/></xsl:attribute>
        <xsl:attribute name="typeof"><xsl:value-of select="name($node)"/></xsl:attribute>


        <xsl:for-each select="$node/*[not(@rdf:resource)]">
          <span>
            <xsl:attribute name="property"><xsl:value-of select="name(.)"/></xsl:attribute>
            <xsl:if test="@xml:lang">
              <xsl:attribute name="lang"><xsl:value-of select="@xml:lang"/></xsl:attribute>
            </xsl:if>
            <xsl:value-of select="normalize-space(.)"/>
          </span>
        </xsl:for-each>

 
        <xsl:for-each select="$node/*[@rdf:resource]">
          <span>
            <xsl:attribute name="rel"><xsl:value-of select="name(.)"/></xsl:attribute>
            <xsl:attribute name="resource"><xsl:value-of select="@rdf:resource"/></xsl:attribute>
          </span>
        </xsl:for-each>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template name="emit-rdfa-bundle-u34">
    <xsl:param name="RDF"/>


    <xsl:call-template name="emit-rdfa-subject">
      <xsl:with-param name="RDF" select="$RDF"/>
      <xsl:with-param name="about" select="'id/work/CU'"/>
    </xsl:call-template>

    <xsl:call-template name="emit-rdfa-subject">
      <xsl:with-param name="RDF" select="$RDF"/>
      <xsl:with-param name="about" select="'id/expr/print1934'"/>
    </xsl:call-template>

    <xsl:call-template name="emit-rdfa-subject">
      <xsl:with-param name="RDF" select="$RDF"/>
      <xsl:with-param name="about" select="'id/manifest/print1934'"/>
    </xsl:call-template>

    <xsl:call-template name="emit-rdfa-subject">
      <xsl:with-param name="RDF" select="$RDF"/>
      <xsl:with-param name="about" select="'id/manifest/print1934-ex_FSAV-994'"/>
    </xsl:call-template>

    <xsl:call-template name="emit-rdfa-subject">
      <xsl:with-param name="RDF" select="$RDF"/>
      <xsl:with-param name="about" select="'id/repo/print-repo'"/>
    </xsl:call-template>

    <xsl:call-template name="emit-rdfa-subject">
      <xsl:with-param name="RDF" select="$RDF"/>
      <xsl:with-param name="about" select="'id/id/print1934-id'"/>
    </xsl:call-template>


    <xsl:call-template name="emit-rdfa-subject">
      <xsl:with-param name="RDF" select="$RDF"/>
      <xsl:with-param name="about" select="'id/expr/ms1925'"/>
    </xsl:call-template>

    <xsl:for-each select="$RDF//frbroo:F2_Expression[starts-with(@rdf:about,'id/expr/stageText/')]/@rdf:about">
      <xsl:call-template name="emit-rdfa-subject">
        <xsl:with-param name="RDF" select="$RDF"/>
        <xsl:with-param name="about" select="string(.)"/>
      </xsl:call-template>
    </xsl:for-each>


    <xsl:for-each select="$RDF//*[self::crm:E31_Document or self::schema:VideoObject or self::schema:ImageObject]/@rdf:about">
      <xsl:call-template name="emit-rdfa-subject">
        <xsl:with-param name="RDF" select="$RDF"/>
        <xsl:with-param name="about" select="string(.)"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>


  <xsl:template match="/tei:TEI">
    <xsl:variable name="RDF" select="document($RDF_PATH)"/>


    <xsl:variable name="docTitle" select="normalize-space(tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title)"/>
    <xsl:variable name="authorText" select="normalize-space(tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author)"/>

    <xsl:variable name="authorRefRaw" select="string(tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author/@ref)"/>
    <xsl:variable name="authorLink">
      <xsl:choose>
        <xsl:when test="starts-with($authorRefRaw,'http://') or starts-with($authorRefRaw,'https://')">
          <xsl:value-of select="$authorRefRaw"/>
        </xsl:when>
        <xsl:when test="$authorRefRaw != ''">
          <xsl:variable name="aid" select="$authorRefRaw"/>
          <xsl:value-of select="string((tei:teiHeader//tei:listPerson//tei:person[@xml:id=$aid]/tei:persName/@ref)[1])"/>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:variable>


    <xsl:variable name="biblMain" select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[1]"/>
    <xsl:variable name="edPublisher" select="normalize-space($biblMain/tei:publisher)"/>
    <xsl:variable name="edPlace" select="normalize-space($biblMain/tei:pubPlace)"/>
    <xsl:variable name="edDateWhen" select="string($biblMain/tei:date/@when)"/>
    <xsl:variable name="edDateText" select="normalize-space($biblMain/tei:date)"/>
    <xsl:variable name="edNote" select="normalize-space($biblMain/tei:note)"/>
    <xsl:variable name="witU34" select="tei:teiHeader/tei:fileDesc/tei:sourceDesc//tei:listWit/tei:witness[@xml:id='U34'][1]"/>
    <xsl:variable name="repoName" select="normalize-space($witU34//tei:orgName[@type='repository'][1])"/>
    <xsl:variable name="repoRefRaw" select="string($witU34//tei:orgName[@type='repository'][1]/@ref)"/>
    <xsl:variable name="repoId" select="substring-after($repoRefRaw,'#')"/>
    <xsl:variable name="repoLink" select="string((tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:authority[@xml:id=$repoId]/@ref)[1])"/>
    <xsl:variable name="shelfmark" select="normalize-space($witU34//tei:idno[@type='shelfmark'][1])"/>
    <xsl:variable name="msExpr" select="$RDF//frbroo:F2_Expression[@rdf:about='id/expr/ms1925'][1]"/>
    <xsl:variable name="relatedMsHref" select="string($msExpr/schema:url/@rdf:resource)"/>
    <xsl:variable name="perfObjects" select="$RDF//*[self::crm:E31_Document or self::schema:VideoObject or self::schema:ImageObject]"/>


    <xsl:variable name="URI_EXPR" select="'id/expr/print1934'"/>
    <xsl:variable name="URI_WORK" select="'id/work/CU'"/>

    <html vocab="https://schema.org/">
      <xsl:attribute name="prefix">
        <xsl:text>schema: https://schema.org/ </xsl:text>
        <xsl:text>dct: http://purl.org/dc/terms/ </xsl:text>
        <xsl:text>frbroo: http://iflastandards.info/ns/fr/frbr/frbroo/ </xsl:text>
        <xsl:text>crm: http://www.cidoc-crm.org/cidoc-crm/ </xsl:text>
        <xsl:text>rdf: http://www.w3.org/1999/02/22-rdf-syntax-ns#</xsl:text>
      </xsl:attribute>

      <head>
        <meta charset="UTF-8"/>
        <title><xsl:value-of select="$docTitle"/></title>
        <link rel="stylesheet" href="main.css"/>
      </head>

      <body>
        <div class="manuscript-viewer">
          <xsl:attribute name="data-default-wit"><xsl:value-of select="$BASE_WIT"/></xsl:attribute>

          <xsl:attribute name="about"><xsl:value-of select="$URI_EXPR"/></xsl:attribute>
          <xsl:attribute name="typeof">frbroo:F2_Expression</xsl:attribute>

          <div class="rdfa-graph" hidden="hidden">
            <xsl:call-template name="emit-rdfa-bundle-u34">
              <xsl:with-param name="RDF" select="$RDF"/>
            </xsl:call-template>
          </div>

          <header class="viewer-header">
            <h1 class="viewer-title" property="schema:name">
              <xsl:value-of select="$docTitle"/>
            </h1>

            <p class="viewer-author">
              <strong>Author:</strong>
              <xsl:text> </xsl:text>
              <xsl:choose>
                <xsl:when test="string($authorLink) != ''">
                  <a href="{$authorLink}" target="_blank" rel="noopener noreferrer schema:author">
                    <xsl:value-of select="$authorText"/>
                  </a>
                </xsl:when>
                <xsl:otherwise>
                  <span rel="schema:author"><xsl:value-of select="$authorText"/></span>
                </xsl:otherwise>
              </xsl:choose>
            </p>

            <span hidden="hidden">
              <xsl:attribute name="about"><xsl:value-of select="$URI_WORK"/></xsl:attribute>
              <span rel="frbroo:R3_is_realised_in">
                <xsl:attribute name="resource"><xsl:value-of select="$URI_EXPR"/></xsl:attribute>
              </span>
            </span>
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
                    <xsl:if test="@xml:id = $BASE_WIT">
                      <xsl:attribute name="selected">selected</xsl:attribute>
                    </xsl:if>
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

                      <xsl:apply-templates select="/tei:TEI/tei:text/tei:body/node()" mode="page">
                        <xsl:with-param name="pbId" select="$pbId"/>
                      </xsl:apply-templates>

                 
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
                              <xsl:when test="starts-with($ref,'#')">
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
                              <xsl:when test="count(ancestor::tei:speaker) &gt; 0">speaker</xsl:when>
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
                                  <xsl:when test="starts-with($ref,'#')"><xsl:value-of select="$ref"/></xsl:when>
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
              <h2 class="metadata-title">Printed Edition Metadata</h2>

              <div class="metadata-block">
                <h3>Work</h3>
                <p><strong>Title:</strong> <xsl:value-of select="$docTitle"/></p>
                <p><strong>Author:</strong>
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

                <xsl:if test="$shelfmark != ''">
                  <p><strong>ID:</strong> <xsl:value-of select="$shelfmark"/></p>
                </xsl:if>

                <xsl:if test="$repoName != ''">
                  <p><strong>Repository:</strong>
                    <xsl:text> </xsl:text>
                    <xsl:choose>
                      <xsl:when test="string($repoLink) != ''">
                        <a href="{$repoLink}" target="_blank" rel="noopener noreferrer">
                          <xsl:value-of select="$repoName"/>
                        </a>
                      </xsl:when>
                      <xsl:otherwise><xsl:value-of select="$repoName"/></xsl:otherwise>
                    </xsl:choose>
                  </p>
                </xsl:if>
              </div>

              <div class="metadata-block">
                <h3>Edition</h3>
                <xsl:if test="$edPublisher != ''">
                  <p><strong>Publisher:</strong> <xsl:value-of select="$edPublisher"/></p>
                </xsl:if>
                <xsl:if test="$edPlace != ''">
                  <p><strong>Place:</strong> <xsl:value-of select="$edPlace"/></p>
                </xsl:if>
                <p><strong>Date:</strong>
                  <xsl:text> </xsl:text>
                  <xsl:choose>
                    <xsl:when test="$edDateWhen != ''"><xsl:value-of select="$edDateWhen"/></xsl:when>
                    <xsl:otherwise><xsl:value-of select="$edDateText"/></xsl:otherwise>
                  </xsl:choose>
                </p>
                <xsl:if test="$edNote != ''">
                  <p><strong>Note:</strong> <xsl:value-of select="$edNote"/></p>
                </xsl:if>
              </div>

              <div class="metadata-block">
                <h3>Related resources</h3>

                <p>
                  <strong>Related manuscript:</strong>
                  <xsl:text> </xsl:text>
                  <xsl:choose>
                    <xsl:when test="string($relatedMsHref) != ''">
                      <a href="{$relatedMsHref}" target="_blank" rel="noopener noreferrer">Manuscript (1925)</a>
                    </xsl:when>
                    <xsl:otherwise>Manuscript (1925)</xsl:otherwise>
                  </xsl:choose>
                </p>

                <xsl:if test="count($perfObjects) &gt; 0">
                  <p><strong>Performance objects:</strong></p>
                  <ul>
                    <xsl:for-each select="$perfObjects">
                      <xsl:variable name="href" select="string(schema:mainEntityOfPage/@rdf:resource)"/>
                      <xsl:variable name="label">
                        <xsl:choose>
                          <xsl:when test="schema:name"><xsl:value-of select="normalize-space(schema:name)"/></xsl:when>
                          <xsl:otherwise><xsl:value-of select="normalize-space(dct:type)"/></xsl:otherwise>
                        </xsl:choose>
                      </xsl:variable>

                      <li>
                        <xsl:choose>
                          <xsl:when test="$href != ''">
                            <a href="{$href}"><xsl:value-of select="$label"/></a>
                          </xsl:when>
                          <xsl:otherwise><xsl:value-of select="$label"/></xsl:otherwise>
                        </xsl:choose>
                      </li>
                    </xsl:for-each>
                  </ul>
                </xsl:if>
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



  <xsl:template match="tei:pb" mode="page">
    <xsl:param name="pbId"/>
  </xsl:template>

  <xsl:template match="text()" mode="page">
    <xsl:param name="pbId"/>
    <xsl:if test="generate-id(preceding::tei:pb[1]) = $pbId">
      <xsl:value-of select="."/>
    </xsl:if>
  </xsl:template>


  <xsl:template match="*" mode="page">
    <xsl:param name="pbId"/>
    <xsl:if test="descendant-or-self::node()[not(self::tei:pb)]
                  [generate-id(preceding::tei:pb[1]) = $pbId]">
      <xsl:apply-templates select="node()" mode="page">
        <xsl:with-param name="pbId" select="$pbId"/>
      </xsl:apply-templates>
    </xsl:if>
  </xsl:template>


  <xsl:template match="tei:div" mode="page">
    <xsl:param name="pbId"/>
    <xsl:if test="descendant-or-self::node()[not(self::tei:pb)][generate-id(preceding::tei:pb[1]) = $pbId]">
      <div>
        <xsl:if test="@type">
          <xsl:attribute name="class">
            <xsl:text>div-</xsl:text><xsl:value-of select="@type"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:apply-templates select="node()" mode="page">
          <xsl:with-param name="pbId" select="$pbId"/>
        </xsl:apply-templates>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:head" mode="page">
    <xsl:param name="pbId"/>
    <xsl:if test="descendant-or-self::node()[not(self::tei:pb)][generate-id(preceding::tei:pb[1]) = $pbId]">
      <h3 class="head">
        <xsl:apply-templates mode="page">
          <xsl:with-param name="pbId" select="$pbId"/>
        </xsl:apply-templates>
      </h3>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:p" mode="page">
    <xsl:param name="pbId"/>
    <xsl:if test="descendant-or-self::node()[not(self::tei:pb)][generate-id(preceding::tei:pb[1]) = $pbId]">
      <p>
        <xsl:apply-templates mode="page">
          <xsl:with-param name="pbId" select="$pbId"/>
        </xsl:apply-templates>
      </p>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:sp" mode="page">
    <xsl:param name="pbId"/>
    <xsl:if test="descendant-or-self::node()[not(self::tei:pb)][generate-id(preceding::tei:pb[1]) = $pbId]">
      <div class="sp">
        <xsl:apply-templates select="tei:speaker" mode="page">
          <xsl:with-param name="pbId" select="$pbId"/>
        </xsl:apply-templates>
        <xsl:apply-templates select="node()[not(self::tei:speaker)]" mode="page">
          <xsl:with-param name="pbId" select="$pbId"/>
        </xsl:apply-templates>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:speaker" mode="page">
    <xsl:param name="pbId"/>
    <span class="speaker">
      <xsl:apply-templates mode="page">
        <xsl:with-param name="pbId" select="$pbId"/>
      </xsl:apply-templates>
    </span>
  </xsl:template>

  <xsl:template match="tei:stage" mode="page">
    <xsl:param name="pbId"/>
    <xsl:if test="descendant-or-self::node()[not(self::tei:pb)][generate-id(preceding::tei:pb[1]) = $pbId]">
      <div class="stage">
        <xsl:apply-templates mode="page">
          <xsl:with-param name="pbId" select="$pbId"/>
        </xsl:apply-templates>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:castList" mode="page">
    <xsl:param name="pbId"/>
    <xsl:if test="descendant-or-self::node()[not(self::tei:pb)][generate-id(preceding::tei:pb[1]) = $pbId]">
      <div class="castList">
        <xsl:apply-templates mode="page">
          <xsl:with-param name="pbId" select="$pbId"/>
        </xsl:apply-templates>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:castItem" mode="page">
    <xsl:param name="pbId"/>
    <xsl:if test="descendant-or-self::node()[not(self::tei:pb)][generate-id(preceding::tei:pb[1]) = $pbId]">
      <div class="castItem">
        <xsl:variable name="tip" select="normalize-space(tei:note[@type='app'][1])"/>
        <xsl:if test="$tip != ''">
          <xsl:attribute name="title"><xsl:value-of select="$tip"/></xsl:attribute>
        </xsl:if>
        <xsl:apply-templates select="node()[not(self::tei:note[@type='app'])]" mode="page">
          <xsl:with-param name="pbId" select="$pbId"/>
        </xsl:apply-templates>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:roleName | tei:role | tei:roleDesc" mode="page">
    <xsl:param name="pbId"/>
    <xsl:if test="descendant-or-self::node()[not(self::tei:pb)][generate-id(preceding::tei:pb[1]) = $pbId]">
      <div class="{local-name()}">
        <xsl:apply-templates mode="page">
          <xsl:with-param name="pbId" select="$pbId"/>
        </xsl:apply-templates>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:lb" mode="page">
    <xsl:param name="pbId"/>
    <br class="lb"/>
  </xsl:template>

  <xsl:template match="tei:foreign" mode="page">
    <xsl:param name="pbId"/>
    <span class="foreign" lang="{@xml:lang}">
      <xsl:apply-templates mode="page">
        <xsl:with-param name="pbId" select="$pbId"/>
      </xsl:apply-templates>
    </span>
  </xsl:template>

  <xsl:template match="tei:unclear" mode="page">
    <xsl:param name="pbId"/>
    <span class="unclear" title="Unclear">
      <xsl:apply-templates mode="page">
        <xsl:with-param name="pbId" select="$pbId"/>
      </xsl:apply-templates>
    </span>
  </xsl:template>

  <xsl:template match="tei:gap" mode="page">
    <xsl:param name="pbId"/>

    <xsl:if test="generate-id(preceding::tei:pb[1]) = $pbId">
      <span class="gap">
        <xsl:choose>
          <xsl:when test="translate(normalize-space(@sameAs),'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ') = 'NIT'">
            <span class="gap-marker">Not present in this version…</span>
          </xsl:when>
          <xsl:otherwise>
            <span class="gap-marker">[…]</span>
          </xsl:otherwise>
        </xsl:choose>
      </span>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:app" mode="page">
    <xsl:param name="pbId"/>
    <span class="choice text-block" data-base="{$BASE_WIT}">
      <xsl:apply-templates select="tei:lem | tei:rdg" mode="page">
        <xsl:with-param name="pbId" select="$pbId"/>
      </xsl:apply-templates>
    </span>
  </xsl:template>

  <xsl:template match="tei:lem | tei:rdg" mode="page">
    <xsl:param name="pbId"/>

    <xsl:variable name="witRaw" select="normalize-space(@wit)"/>
    <xsl:variable name="witClean" select="normalize-space(translate($witRaw, '#', ''))"/>

    <span>
      <xsl:attribute name="class">
        <xsl:text>variant </xsl:text><xsl:value-of select="local-name()"/>
      </xsl:attribute>

      <xsl:choose>
        <xsl:when test="$witClean != ''">
          <xsl:attribute name="data-wit"><xsl:value-of select="$witClean"/></xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="data-wit"><xsl:value-of select="$BASE_WIT"/></xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:apply-templates mode="page">
        <xsl:with-param name="pbId" select="$pbId"/>
      </xsl:apply-templates>
    </span>
  </xsl:template>


  <xsl:template match="tei:persName | tei:placeName | tei:name | tei:objectName" mode="page">
    <xsl:param name="pbId"/>
    <span class="entity {local-name()}">
      <xsl:apply-templates mode="page">
        <xsl:with-param name="pbId" select="$pbId"/>
      </xsl:apply-templates>
    </span>
  </xsl:template>

</xsl:stylesheet>

