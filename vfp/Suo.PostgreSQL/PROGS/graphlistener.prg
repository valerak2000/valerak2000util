* Define some constants we'll use.
#DEFINE FRX_OBJCOD_TITLE                    0	&& OBJCODE for title band
#DEFINE FRX_OBJCOD_PAGEHEADER               1	&& OBJCODE for page header band
#DEFINE GDIPLUS_FontStyle_Regular           0	&& GDI+ font style: regular
#DEFINE GDIPLUS_Unit_Point                  3	&& GDI+ units: points

* The GraphListener class.
DEFINE CLASS GraphListener AS _ReportListener OF "_REPORTLISTENER.VCX"
    oGDIGraphics=.NULL.
    namereport=.NULL.
    namealias=.NULL.
    rowlist=.NULL.
    columnlist=.NULL.
    idtypegraph=.NULL.
    nCurrentRow=.NULL.
    DIMENSION aColumnColors[1]		&& array of column colors

    DIMENSION aRecords[1]			&& array of flags for each FRX record
    				&& current row being processed in aValues

    FUNCTION INIT
	PARAMETERS tcnamealias, tcrowlist, tccolumnlist, tnidtypegraph, tcnamereport
		STORE IIF(VARTYPE(m.tcnamereport)#'C','',m.tcnamereport) TO THIS.namereport
		STORE tcnamealias TO THIS.namealias
		STORE tcrowlist TO THIS.rowlist
		STORE tccolumnlist TO THIS.columnlist
		STORE tnidtypegraph TO THIS.idtypegraph

		DIMENSION THIS.aColumnColors[8, 2]
		STORE THIS.CreateColor(RGB(  0,   0, 255)) TO THIS.aColumnColors[1, 1]	&& Blue
		STORE RGB(  0,   0, 255) TO THIS.aColumnColors[1, 2]	&& Blue
		STORE THIS.CreateColor(RGB(255,   0,   0)) TO THIS.aColumnColors[2, 1]	&& Red
		STORE RGB(255,   0,   0) TO THIS.aColumnColors[2, 2]	&& Red
		STORE THIS.CreateColor(RGB(255, 255,   0)) TO THIS.aColumnColors[3, 1]	&& Yellow
		STORE RGB(255, 255,   0) TO THIS.aColumnColors[3, 2]	&& Yellow
		STORE THIS.CreateColor(RGB(255,   0, 255)) TO THIS.aColumnColors[4, 1]	&& Magenta
		STORE RGB(255,   0, 255) TO THIS.aColumnColors[4, 2]	&& Magenta
		STORE THIS.CreateColor(RGB(  0, 255,   0)) TO THIS.aColumnColors[5, 1]	&& Green
		STORE RGB(  0, 255,   0) TO THIS.aColumnColors[5, 2]	&& Green
		STORE THIS.CreateColor(RGB(  0, 255, 255)) TO THIS.aColumnColors[6, 1]	&& Cyan
		STORE RGB(  0, 255, 255) TO THIS.aColumnColors[6, 2]	&& Cyan
		STORE THIS.CreateColor(RGB(255, 128,   0)) TO THIS.aColumnColors[7, 1]	&& Orange
		STORE RGB(255, 128,   0) TO THIS.aColumnColors[7, 2]	&& Orange
		STORE THIS.CreateColor(RGB(128,   0, 255)) TO THIS.aColumnColors[8, 1]	&& Purple
		STORE RGB(128,   0, 255) TO THIS.aColumnColors[8, 2]	&& Purple

        DODEFAULT()
    ENDFUNC

	* Do some setup tasks before the report starts.
    FUNCTION BEFOREREPORT
        DODEFAULT()

        WITH THIS
			* Create a GPGraphics object so we can do GDI+ drawing.
            .oGDIGraphics=NEWOBJECT("GPGraphics", "_GDIPLUS.VCX")

            .SetFRXDataSession()
            DIMENSION .aRecords[RECCOUNT(), 4]
            .ResetDataSession()
        ENDWITH
    ENDFUNC

    FUNCTION BEFOREBAND(tnBandObjCode, tnFRXRecNo)
        WITH THIS
            IF INLIST(m.tnBandObjCode, FRX_OBJCOD_PAGEHEADER, FRX_OBJCOD_TITLE)
                IF NOT .IsSuccessor
                    .SharedGDIPlusGraphics = .GDIPLUSGRAPHICS
                ENDIF NOT .IsSuccessor

                .oGDIGraphics.SetHandle(.SharedGDIPlusGraphics)
            ENDIF

            DODEFAULT(m.tnBandObjCode, m.tnFRXRecNo)
        ENDWITH
    ENDFUNC

	* Return a SCATTER NAME object for the specified record in the FRX.
    PROCEDURE GetReportObject(tnFRXRecno)
        LOCAL loObject
        THIS.SetFRXDataSession()
        GO m.tnFRXRecno
        SCATTER MEMO NAME loObject
        THIS.ResetDataSession()
        RETURN m.loObject
    ENDPROC

	* Handle a shape to see if it's a column chart.
    PROCEDURE ADJUSTOBJECTSIZE(tnFRXRecno, toObjProperties)
        LOCAL loObject
        WITH THIS
			* If we haven't already checked if this object is a column chart, find its
			* record in the FRX and see if its USER memo contains "COLUMNCHART". Then flag
			* that we have checked it so we don't do it again.
            IF NOT .aRecords[m.tnFRXRecno, 1]
                loObject=.GetReportObject(m.tnFRXRecno)
                .aRecords[m.tnFRXRecno, 1] = .T.
                .aRecords[m.tnFRXRecno, 2] = ATC("GRAPHCHART", m.loObject.USER)>0
            ENDIF
            IF .aRecords[m.tnFRXRecno, 2]
*                toObjProperties.HEIGHT = toObjProperties.WIDTH
                toObjProperties.Reload=.T.
            ENDIF
        ENDWITH
    ENDPROC

	* Handle a field to see if it's involved in the column chart.
    PROCEDURE EVALUATECONTENTS(tnFRXRecno, toObjProperties)
        LOCAL loObject, lcText, lnRow

        WITH THIS
			* If we haven't already checked if this object is involved in the column chart,
			* find its record in the FRX and see if its USER memo contains "LABEL" or
			* "VALUE". Then flag that we have checked it so we don't do it again.
            IF NOT .aRecords[m.tnFRXRecno, 1]
                loObject = .GetReportObject(m.tnFRXRecno)
                .aRecords[m.tnFRXRecno, 1] = .T.
                .aRecords[m.tnFRXRecno, 3] = ATC("LABEL", m.loObject.USER) > 0
                .aRecords[m.tnFRXRecno, 4] = ATC("DATA",  m.loObject.USER) > 0
            ENDIF
			* Get the value for the field, then decide what to do with it.
            lcText = toObjProperties.TEXT
            DO CASE
			* If this is a label, ensure it's in our array.
            CASE .aRecords[m.tnFRXRecno, 3]
*!*	                lnRow = ASCAN(.aValues, lcText, -1, -1, 1, 15)
*!*	                IF lnRow = 0
*!*	                    lnRow = IIF(EMPTY(.aValues[1]), 1, ALEN(.aValues, 1) + 1)
*!*	                    DIMENSION .aValues[lnRow, 2]
*!*	                    .aValues[lnRow, 1] = lcText
*!*	                    .aValues[lnRow, 2] = 0
*!*	                ENDIF lnRow = 0
*!*	                .nCurrentRow = lnRow
			* If this is a data value, add it to the current total.
            CASE .aRecords[m.tnFRXRecno, 4]
*!*	                .aValues[.nCurrentRow, 2] = .aValues[.nCurrentRow, 2] + ;
*!*	                VAL(lcText)
            ENDCASE
        ENDWITH
    ENDPROC

	* If we're supposed to draw a column chart, do so. Otherwise do the normal
	* rendering.
    PROCEDURE RENDER(tnFRXRecno, tnLeft, tnTop, tnWidth, tnHeight, tnObjectContinuationType, tcContentsToBeRendered, tiGDIPlusImage)
        WITH THIS
            IF .aRecords[m.tnFRXRecno, 2]
                .DrawPrint(m.tnLeft, m.tnTop, m.tnWidth, m.tnHeight)
                NODEFAULT
            ENDIF
        ENDWITH
    ENDPROC

	PROCEDURE DrawPrint(tnLeft, tnTop, tnWidth, tnHeight)
	LOCAL loColumnBrush AS OBJECT, loPen AS OBJECT, loPen_dot as Object, loFont AS OBJECT,;
		  loStringFormat AS OBJECT, loPoint AS OBJECT, loTextBrush AS OBJECT, lographchart as Object,;
		  loHatchBrush as Object
		WITH THIS
			* Create _GDIPlus objects we'll need for drawing.
			loColumnBrush=NEWOBJECT("_GDIPLUS.GPSolidBrush")
			loHatchBrush=NEWOBJECT("_GDIPLUS.GPHatchBrush", "_GDIPLUS.VCX")
		    loPen=NEWOBJECT("_GDIPLUS.GPPen")
		    loPen_dot=NEWOBJECT("_GDIPLUS.GPPen", "_GDIPLUS.VCX")
		    loFont=NEWOBJECT("_GDIPLUS.GPFont")
		    loStringFormat=NEWOBJECT("_GDIPLUS.GPStringFormat")
		    loPoint=NEWOBJECT("_GDIPLUS.GPPoint")
		    loTextBrush=NEWOBJECT("_GDIPLUS.GPSolidBrush")

	    	lographchart=NEWOBJECT("GraphGdi.ChartGdi", "GRAPHGDI.VCX", '', .NameAlias, .RowList, .ColumnList, .IdTypeGraph)
			lographchart.DrawDataChart(.oGDIGraphics, m.loColumnBrush, m.loHatchBrush, m.loPen, m.loPen_dot, m.loFont,;
										m.loStringFormat, m.loTextBrush, m.loPoint, m.tnLeft, m.tnTop, m.tnWidth, m.tnHeight, .NameReport)
			RELEASE lographchart

		    RELEASE loColumnBrush
		    RELEASE loHatchBrush
		    RELEASE loPen
		    RELEASE loPen_dot
		    RELEASE loFont
		    RELEASE loStringFormat
		    RELEASE loPoint
		    RELEASE loTextBrush
		ENDWITH
    ENDPROC

    PROCEDURE CreateColor(tnRGB, tnAlpha)
        LOCAL lnAlpha
        lnAlpha=IIF(PCOUNT()=1, 255, m.tnAlpha)
        RETURN BITLSHIFT(m.lnAlpha, 24)+BITAND(m.tnRGB, 0x00FF00)+BITLSHIFT(m.tnRGB, 16)+BITRSHIFT(m.tnRGB, 16)
    ENDPROC
ENDDEFINE