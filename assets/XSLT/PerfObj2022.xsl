<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:frbroo="http://iflastandards.info/ns/fr/frbr/frbroo/"
  xmlns:crm="http://www.cidoc-crm.org/cidoc-crm/"
  xmlns:dct="http://purl.org/dc/terms/"
  xmlns:schema="http://schema.org/"
  xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
  version="1.0"
  exclude-result-prefixes="tei rdf frbroo crm dct schema xsd">

  <xsl:output method="html" indent="yes" encoding="UTF-8"/>
  <xsl:strip-space elements="*"/>

  <xsl:param name="RDF_PATH" select="'PerfObj2022_RDF.xml'"/>
  <xsl:param name="OBJ_ID"   select="'id/poster/2022'"/>

  <xsl:param name="SITE_CSS"        select="'../assets/CSS/main.css'"/>
  <xsl:param name="VIEWER_CSS"      select="'../assets/css/perfobj-viewer.css'"/>

  <xsl:template match="/tei:TEI">
    <xsl:variable name="RDF" select="document($RDF_PATH, /)"/>

    <xsl:variable name="teiTitle"
      select="normalize-space(tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[1])"/>

    <xsl:variable name="teiAuthorName"
      select="normalize-space(tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author[1])"/>
    <xsl:variable name="teiAuthorRef"
      select="string(tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author[1]/@ref)"/>

    <xsl:variable name="obj"
      select="$RDF/rdf:RDF/schema:ImageObject[@rdf:about=$OBJ_ID]"/>
    <xsl:variable name="objAny"
      select="($obj | $RDF/rdf:RDF/*[@rdf:about=$OBJ_ID])[1]"/>

    <xsl:variable name="pageTitle">
      <xsl:choose>
        <xsl:when test="normalize-space(string($objAny/schema:name)) != ''">
          <xsl:value-of select="normalize-space(string($objAny/schema:name))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$teiTitle"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="imgSrc"
      select="string(($objAny/schema:image/@rdf:resource | $objAny/schema:contentUrl/@rdf:resource)[1])"/>

    <xsl:variable name="perfURI"
      select="string(($objAny/crm:P70_documents/@rdf:resource)[1])"/>
    <xsl:variable name="perf"
      select="$RDF/rdf:RDF/frbroo:F31_Performance[@rdf:about=$perfURI]"/>

    <xsl:variable name="startDate" select="normalize-space(string($perf/schema:startDate))"/>
    <xsl:variable name="endDate"   select="normalize-space(string($perf/schema:endDate))"/>
    <xsl:variable name="perfYearOrDate" select="normalize-space(string(($perf/dct:date)[1]))"/>

    <xsl:variable name="workURI"
      select="string(($perf/frbroo:R80_performed/@rdf:resource)[1])"/>
    <xsl:variable name="work"
      select="$RDF/rdf:RDF/frbroo:F1_Work[@rdf:about=$workURI]"/>

    <xsl:variable name="stageTextURI"
      select="string(($perf/schema:isBasedOn/@rdf:resource)[1])"/>
    <xsl:variable name="stageText"
      select="$RDF/rdf:RDF/frbroo:F2_Expression[@rdf:about=$stageTextURI]"/>

    <xsl:variable name="printExpr"
      select="$RDF/rdf:RDF/frbroo:F2_Expression[@rdf:about='id/expr/print1934']"/>
    <xsl:variable name="printHref"
      select="string(($printExpr/schema:url/@rdf:resource)[1])"/>

    <xsl:variable name="directorURI"
      select="string(($perf/schema:director/@rdf:resource)[1])"/>
    <xsl:variable name="director"
      select="$RDF/rdf:RDF/schema:Person[@rdf:about=$directorURI]"/>

    <xsl:variable name="placeURI"
      select="string(($perf/schema:location/@rdf:resource)[1])"/>
    <xsl:variable name="place"
      select="$RDF/rdf:RDF/schema:Place[@rdf:about=$placeURI]"/>

    <xsl:variable name="objYear" select="normalize-space(string(($objAny/dct:date)[1]))"/>
    <xsl:variable name="objType" select="normalize-space(string(($objAny/dct:type)[1]))"/>

    <xsl:variable name="sourceLink"
      select="string(tei:teiHeader/tei:fileDesc/tei:sourceDesc//tei:ref[@type='source'][1]/@target)"/>
    <xsl:variable name="sourceLabel"
      select="normalize-space(string(tei:teiHeader/tei:fileDesc/tei:sourceDesc//tei:ref[@type='source'][1]))"/>

    <html lang="en"
      prefix="rdf: http://www.w3.org/1999/02/22-rdf-syntax-ns#
              frbroo: http://iflastandards.info/ns/fr/frbr/frbroo/
              crm: http://www.cidoc-crm.org/cidoc-crm/
              dct: http://purl.org/dc/terms/
              schema: http://schema.org/
              xsd: http://www.w3.org/2001/XMLSchema#">

      <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>

        <title><xsl:value-of select="$pageTitle"/></title>

        <link rel="preconnect" href="https://fonts.googleapis.com"/>
        <link rel="preconnect" href="https://fonts.gstatic.com"/>
        <link rel="stylesheet"
              href="https://fonts.googleapis.com/css2?family=Raleway:wght@600;700&amp;family=Roboto:wght@400;500;700&amp;display=swap"/>

        <link rel="stylesheet" href="{$SITE_CSS}"/>
        <link rel="stylesheet" href="{$VIEWER_CSS}"/>
      </head>

      <body class="perfobj-page" about="{$OBJ_ID}" typeof="schema:ImageObject">

        <xsl:if test="$perfURI != ''">
          <span rel="schema:about" resource="{$perfURI}"></span>
        </xsl:if>
        <xsl:if test="$stageTextURI != ''">
          <span rel="schema:about" resource="{$stageTextURI}"></span>
        </xsl:if>
        <xsl:if test="$workURI != ''">
          <span rel="schema:about" resource="{$workURI}"></span>
        </xsl:if>

        <xsl:if test="normalize-space(string($objAny/schema:name)) != ''">
          <span property="schema:name">
            <xsl:value-of select="normalize-space(string($objAny/schema:name))"/>
          </span>
        </xsl:if>
        <xsl:if test="$objType != ''">
          <span property="dct:type"><xsl:value-of select="$objType"/></span>
        </xsl:if>
        <xsl:if test="$objYear != ''">
          <span property="dct:date" datatype="xsd:gYear"><xsl:value-of select="$objYear"/></span>
        </xsl:if>

        <div class="manuscript-viewer" about="{$OBJ_ID}" typeof="schema:ImageObject">

          <header class="viewer-header">
            <h1 class="viewer-title"><xsl:value-of select="$pageTitle"/></h1>

            <xsl:if test="$teiAuthorName != ''">
              <p class="viewer-author">
                <xsl:text>Author: </xsl:text>
                <xsl:choose>
                  <xsl:when test="$teiAuthorRef != ''">
                    <a href="{$teiAuthorRef}" target="_blank" rel="noopener">
                      <xsl:value-of select="$teiAuthorName"/>
                    </a>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="$teiAuthorName"/>
                  </xsl:otherwise>
                </xsl:choose>
              </p>
            </xsl:if>
          </header>

          <div class="viewer-layout">

            <section class="page-viewer" id="page-viewer">
              <article class="page is-active">

                <h2 class="page-title">
                  <xsl:choose>
                    <xsl:when test="normalize-space(tei:text/tei:body/tei:div[1]/tei:head) != ''">
                      <xsl:value-of select="normalize-space(tei:text/tei:body/tei:div[1]/tei:head)"/>
                    </xsl:when>
                    <xsl:otherwise>Object</xsl:otherwise>
                  </xsl:choose>
                </h2>

                <div class="page-inner">
                  <div class="page-text-column">
                    <xsl:apply-templates select="tei:text/tei:body"/>
                  </div>

                  <div class="page-image-column">
                    <xsl:if test="$imgSrc != ''">
                      <img class="page-image" src="{$imgSrc}" alt="{$pageTitle}"/>
                    </xsl:if>
                  </div>
                </div>

              </article>
            </section>

            <aside class="metadata-panel" id="metadata-panel">
              <h2 class="metadata-title">Poster Metadata</h2>

              <div class="metadata-block">
                <h3>Work</h3>

                <p>
                  <strong>Title:</strong>
                  <xsl:text> </xsl:text>
                  <xsl:choose>
                    <xsl:when test="$workURI != ''">
                      <span about="{$workURI}" typeof="frbroo:F1_Work">
                        <span property="schema:name">
                          <xsl:value-of select="normalize-space(string($work/schema:name))"/>
                        </span>
                      </span>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="normalize-space(string($work/schema:name))"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </p>

                <xsl:if test="$teiAuthorName != ''">
                  <p>
                    <strong>Author:</strong>
                    <xsl:text> </xsl:text>
                    <xsl:choose>
                      <xsl:when test="$teiAuthorRef != ''">
                        <a href="{$teiAuthorRef}" target="_blank" rel="noopener">
                          <xsl:value-of select="$teiAuthorName"/>
                        </a>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="$teiAuthorName"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </p>
                </xsl:if>
              </div>

              <div class="metadata-block">
                <h3>Performance</h3>

                <div about="{$perfURI}" typeof="frbroo:F31_Performance">

                  <xsl:if test="normalize-space(string($director/schema:name)) != ''">
                    <p>
                      <strong>Director:</strong>
                      <xsl:text> </xsl:text>
                      <xsl:choose>
                        <xsl:when test="$directorURI != ''">
                          <a href="{$directorURI}" target="_blank" rel="schema:director" resource="{$directorURI}">
                            <span about="{$directorURI}" typeof="schema:Person">
                              <span property="schema:name">
                                <xsl:value-of select="normalize-space(string($director/schema:name))"/>
                              </span>
                            </span>
                          </a>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:value-of select="normalize-space(string($director/schema:name))"/>
                        </xsl:otherwise>
                      </xsl:choose>
                    </p>
                  </xsl:if>

                  <xsl:if test="normalize-space(string($place/schema:name)) != ''">
                    <p>
                      <strong>Venue:</strong>
                      <xsl:text> </xsl:text>
                      <xsl:choose>
                        <xsl:when test="$placeURI != ''">
                          <a href="{$placeURI}" target="_blank" rel="schema:location" resource="{$placeURI}">
                            <span about="{$placeURI}" typeof="schema:Place">
                              <span property="schema:name">
                                <xsl:value-of select="normalize-space(string($place/schema:name))"/>
                              </span>
                            </span>
                          </a>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:value-of select="normalize-space(string($place/schema:name))"/>
                        </xsl:otherwise>
                      </xsl:choose>
                    </p>
                  </xsl:if>

                  <xsl:if test="$startDate != ''">
                    <p><strong>Start date:</strong> <span property="schema:startDate" datatype="xsd:date"><xsl:value-of select="$startDate"/></span></p>
                  </xsl:if>

                  <xsl:if test="$endDate != ''">
                    <p><strong>End date:</strong> <span property="schema:endDate" datatype="xsd:date"><xsl:value-of select="$endDate"/></span></p>
                  </xsl:if>

                  <xsl:if test="$startDate = '' and $endDate = '' and $perfYearOrDate != ''">
                    <p><strong>Date:</strong> <span property="dct:date"><xsl:value-of select="$perfYearOrDate"/></span></p>
                  </xsl:if>

                  <xsl:if test="$workURI != ''">
                    <span rel="frbroo:R80_performed" resource="{$workURI}"></span>
                  </xsl:if>

                  <xsl:if test="$stageTextURI != ''">
                    <span rel="schema:isBasedOn" resource="{$stageTextURI}"></span>
                  </xsl:if>

                </div>
              </div>

              <div class="metadata-block">
                <h3>Object</h3>

                <xsl:if test="$objType != ''">
                  <p><strong>Type:</strong> <span property="dct:type"><xsl:value-of select="$objType"/></span></p>
                </xsl:if>

                <xsl:if test="$objYear != ''">
                  <p><strong>Year:</strong> <span property="dct:date" datatype="xsd:gYear"><xsl:value-of select="$objYear"/></span></p>
                </xsl:if>

                <xsl:if test="$sourceLink != ''">
                  <p>
                    <strong>Original file:</strong>
                    <xsl:text> </xsl:text>
                    <a href="{$sourceLink}" target="_blank" rel="noopener">
                      <xsl:choose>
                        <xsl:when test="$sourceLabel != ''"><xsl:value-of select="$sourceLabel"/></xsl:when>
                        <xsl:otherwise>image</xsl:otherwise>
                      </xsl:choose>
                    </a>
                  </p>
                </xsl:if>
              </div>

              <div class="metadata-block">
                <h3>Related resources</h3>
                <p>
                  <strong>Printed edition:</strong>
                  <xsl:text> </xsl:text>
                  <xsl:choose>
                    <xsl:when test="$printHref != ''">
                      <a href="{$printHref}">Printed edition (1934)</a>
                    </xsl:when>
                    <xsl:otherwise>Printed edition (1934)</xsl:otherwise>
                  </xsl:choose>
                </p>

                <xsl:if test="$stageTextURI != ''">
                  <p>
                    <strong>Performance text:</strong>
                    <xsl:text> </xsl:text>
                    <code><xsl:value-of select="$stageTextURI"/></code>
                  </p>

                  <xsl:if test="normalize-space(string($stageText/dct:description)) != ''">
                    <p>
                      <strong>Note:</strong>
                      <xsl:text> </xsl:text>
                      <xsl:value-of select="normalize-space(string($stageText/dct:description))"/>
                    </p>
                  </xsl:if>
                </xsl:if>
              </div>

            </aside>

          </div>

        </div>

      </body>
    </html>
  </xsl:template>

  <xsl:template match="tei:body">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tei:div">
    <xsl:apply-templates select="node()[not(self::tei:head)]"/>
  </xsl:template>

  <xsl:template match="tei:p">
    <p><xsl:apply-templates/></p>
  </xsl:template>

  <xsl:template match="tei:hi">
    <xsl:choose>
      <xsl:when test="@rend='italic'">
        <em><xsl:apply-templates/></em>
      </xsl:when>
      <xsl:otherwise>
        <span><xsl:apply-templates/></span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:title">
    <em><xsl:apply-templates/></em>
  </xsl:template>

  <xsl:template match="text()">
    <xsl:value-of select="."/>
  </xsl:template>

</xsl:stylesheet>

