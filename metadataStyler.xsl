<?xml version="1.0"?>
<!DOCTYPE xsl:stylesheet PUBLIC "Unofficial XSLT 1.0 DTD" "http://www.w3.org/1999/11/xslt10.dtd">
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="html" indent="yes"/>
	<xsl:template match="/">
		<html>
			<head>
				<title>
					<xsl:value-of select="x-extension-info/@name"/>
				</title>
			</head>
			<body>
				<h1>
					<xsl:value-of select="x-extension-info/@name"/>
				</h1>
				<table width="100%" border="1" cellspacing="4">
					<tbody>
						<tr>
							<th align="right">
								Platforms
							</th>
							<td>
								<xsl:value-of select="x-extension-info/@platforms"/>
							</td>
						</tr>
						<tr>
							<th align="right">
								Makefile Path
							</th>
							<td>
								<xsl:value-of select="x-extension-info/@path"/>
							</td>
						</tr>
						<tr>
							<th colspan="2" align="center">Dependencies</th>
						</tr>
						<xsl:for-each select="x-extension-info/dependency">
							<tr>
								<th align="right">
									Path:
								</th>
								<td>
									<xsl:value-of select="@path"/>
								</td>
							</tr>
						</xsl:for-each>
						<xsl:for-each select="x-extension-info/platform">
							<tr>
								<th colspan="2" align="center"><xsl:value-of select="@name"/>-specific dependencies</th>
							</tr>
							<xsl:for-each select="dependency">
								<tr>
									<td>
										<xsl:value-of select="@path"/>
									</td>
									<td>
										<xsl:value-of select="@require"/>
									</td>
								</tr>
							</xsl:for-each>
						</xsl:for-each>
						<xsl:for-each select="x-extension-info/footprint">
							<tr>
								<th align="right">General <xsl:value-of select="@type"/> footprint</th>
								<td>
									<xsl:value-of select="@value"/>
								</td>
							</tr>
							<xsl:for-each select="platform">
								<tr>
									<th align="right"><xsl:value-of select="@name"/>-specific <xsl:value-of select="../@type"/> footprint
									</th>
									<td>
										<xsl:value-of select="@size"/>
									</td>
								</tr>
							</xsl:for-each>
						</xsl:for-each>
						<xsl:for-each select="x-extension-info/link">
							<tr>
								<th align="right">Related <xsl:value-of select="@type"/> link</th>
								<td>
									<xsl:value-of select="@title"/>
								</td>
							</tr>
							<xsl:for-each select="platform">
								<tr>
									<th align="right"><xsl:value-of select="@name"/>-specific <xsl:value-of select="../@type"/> footprint
									</th>
									<td>
										<xsl:value-of select="@size"/>
									</td>
								</tr>
							</xsl:for-each>
						</xsl:for-each>
					</tbody>
				</table>
			</body>
		</html>
	</xsl:template>
</xsl:stylesheet>
