'===========================================================================
'========== This function library includes trunk searching tests ===========
'===========================================================================

'---------------------------------------------------------------------------
' Function name: fGuiCollectFilterData
' Description: The function collect [default] filter data - attributes and values
' Parameters: array to return filter data
' Return value: success - True, Failure - False, on arrFilterData - returns the filter data collection
' Example:
'---------------------------------------------------------------------------
Public Function fGuiCollectFilterData(ByRef arrFilterData)

 	ind = -1
	If fGuiAddFilterAttributesToArray(arrFilterData, ind, "FilterTextTable") = False Then
		fGuiCollectFilterData = False
		Exit Function
	End If
	If fGuiAddFilterAttributesToArray(arrFilterData, ind, "FilterDateTable") = False Then
		fGuiCollectFilterData = False
		Exit Function
	End If
	If fGuiAddFilterAttributesToArray(arrFilterData, ind, "FilterBoolTable") = False Then
		fGuiCollectFilterData = False
		Exit Function
	End If

    fGuiCollectFilterData = True
	
End Function
'---------------------------------------------------------------------------
'---------------------------------------------------------------------------
' Function name: fGuiAddFilterAttributesToArray
' Description: The function collect filter data (- attributes and values) of specific table
' Parameters: 	arrFilterData - array to return filter data, 
'				ind - Index in the array to start save the attributes from it,
'				sFilterTable - Table name (in the object repository)
' Return value: success - True, Failure - False, on arrFilterData - returns the filter data collection
' Example:
'---------------------------------------------------------------------------
Public Function fGuiAddFilterAttributesToArray(ByRef arrFilterData, ByRef ind, ByVal sFilterTable)

	Dim iRowCount
	iRowCount = Browser("TG").Page("Search").WebElement(sFilterTable).WebTable(sFilterTable).RowCount
	For i = 1 to iRowCount 
		ind = ind + 2
		ReDim Preserve arrFilterData(ind)

		'arrFilterData(ind-1) = uCase(Browser("TG").Page("Search").WebElement(sFilterTable).WebTable(sFilterTable).ChildItem(i,1,"WebEdit",0).GetROProperty("value"))	
		FilterAttributeName = uCase(Browser("TG").Page("Search").WebElement(sFilterTable).WebTable(sFilterTable).ChildItem(i,1,"WebElement",0).GetROProperty("outertext"))	
		arrFilterData(ind-1) = Left(FilterAttributeName,Len(FilterAttributeName)-3)
		If sFilterTable = "FilterBoolTable" Then
			If Browser("TG").Page("Search").WebElement(sFilterTable).WebTable(sFilterTable).ChildItem(1,2,"WebCheckbox",0).GetROProperty("checked") = 1 Then
				arrFilterData(ind) = "TRUE"
			Else
				arrFilterData(ind) = "FALSE"
			End If
		Else
    		arrFilterData(ind) = uCase(Browser("TG").Page("Search").WebElement(sFilterTable).WebTable(sFilterTable).ChildItem(i,2,"WebEdit",0).GetROProperty("value"))
		End If

        If IsEmpty(arrFilterData(ind-1)) OR IsEmpty(arrFilterData(ind)) Then
			fGuiAddFilterAttributesToArray = False
			Exit Function
		End If	
	Next

	fGuiAddFilterAttributesToArray = True
End Function
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fGuiBuildFilterSQL
' Description: The function builds SQL query to get filter results
' Parameters: 	sFilterSQL – Output parameter. Returns the built query that returns the search results.
'				sResCountSQL - Output parameter. Returns the built query that returns the count of search results.
'				arrFilterData – Array of attributes and values to filter by. 
' Return value: 
' Example:
'---------------------------------------------------------------------------
Public Function fGuiBuildFilterSQL(ByRef sFilterSQL, ByRef sResCountSQL, ByVal arrFilterData)

    'Concatenate parameters of filter data
	sFilterSQL = sFilterSQL & fGetQuery2Parameters ("Get_trunks_with_specific_attribute", arrFilterData(0), arrFilterData(1))

	For i = 2 to uBound(arrFilterData)
		sFilterSQL = sFilterSQL & " INTERSECT " & fGetQuery2Parameters ("Get_trunks_with_specific_attribute", arrFilterData(i), arrFilterData(i+1))
		i = i + 1
	Next

	'Concatenate end of query
	sFilterSQL = sFilterSQL & " " &_
		"INTERSECT select id_key from trunk_attributes where ATTRIBUTE_TYPE_ID = 16 " & _ 
		"INTERSECT select id_key from trunk_attributes where ATTRIBUTE_TYPE_ID = 22 " & _  
		"INTERSECT select id_key from trunk_attributes where ATTRIBUTE_TYPE_ID = 42 " & _ 
		"INTERSECT select id_key from trunk_attributes where ATTRIBUTE_TYPE_ID = 45 " & _
		"INTERSECT select id_key from trunk_attributes where ATTRIBUTE_TYPE_ID = 31 " & _
		"INTERSECT select id_key from trunk_attributes where ATTRIBUTE_TYPE_ID = 35 " & _
	")order by id_key"

	'Add Begin of query
	sResCountSQL = "select Count(id_key) from identifiers where id_key in( " & sFilterSQL
	sFilterSQL = "select id_key from identifiers where id_key in( " & sFilterSQL

    fGuiBuildFilterSQL = True
End Function
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fGuiCompareSearchResults
' Description: The function compares the query search results with UI results table.
' Parameters:	sFilterSQL - SQL query of the filter results(returns all expected id_key's),
'				sResCountSQL - SQL query of the expected count of filter results.
' Return value: Success - True, Failure - False
' Example:
'---------------------------------------------------------------------------
Public Function fGuiCompareSearchResults(ByVal sFilterSQL, ByVal sResCountSQL)

	Dim iRowCountDB, iRowCountUI, arr, iRows, idKeyUI, idKeyDB
	fGuiCompareSearchResults = True

   'Compare count of results
	Call fDBGetOneValue ("TRUNKS", sResCountSQL, iRowCountDB)
	arr = split(Browser("TG").Page("Search").WebElement("ResultsStatus").GetROProperty("innertext")," ")
	iRowCountUI = arr(1)
	If cdbl(iRowCountUI) = cdbl(iRowCountDB) Then
		Call fReport("fGuiCompareSearchResults","Compare count of results","PASS","DB value: " & iRowCountDB & ", UI value: " & iRowCountUI,0)
	Else
		Call fReport("fGuiCompareSearchResults","Compare count of results","FAIL","DB value: " & iRowCountDB & ", UI value: " & iRowCountUI,0)
		fGuiCompareSearchResults = False
	End If

	'Compare search result with UI results table
		'--Get table rows count 
		iRows = Browser("TG").Page("Search").WebElement("ResultsTable").WebTable("ResultsTable").RowCount

		'--If no results found
		If cdbl(iRows) = 0 and cdbl(iRowCountUI) = 0 and cdbl(iRowCountDB) = 0 Then
			Call fReport("fGuiCompareSearchResults","Compare search result with UI results table","PASS","No results found for current filter",0)
            Exit Function
		End If
		
		'--Get query results
		rc = fDBGetRS ("TRUNKS", sFilterSQL, objRS)
		If rc = False Then
			Call fReport("fGuiCompareSearchResults","Compare search result with UI results table","FAIL","DB connenction / Query execution failed",0)
			fGuiCompareSearchResults = False
			Exit Function
		End If

		objRS.MoveFirst
		For i = 1 to cdbl(iRows)
			idKeyUI = Trim(Browser("TG").Page("Search").WebElement("ResultsTable").WebTable("ResultsTable").ChildItem(i,1,"WebElement",0).GetROProperty("innerhtml"))
			idKeyDB = Trim(cStr(objRS.Fields(0).Value))

			If idKeyUI <> idKeyDB Then
				Call fReport("fGuiCompareSearchResults","Compare search result with UI results table","FAIL","DB value: " & idKeyDB & ", UI value: " & idKeyUI,0)
				fGuiCompareSearchResults = False
			End If

			objRS.MoveNext
		Next


End Function
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fQuickSearchSQL
' Description: The function build SQL query to quick search
' Parameters: 	i - loop iteration(to get GlobalDictionary("QUICK_SEARCH" & i)),
'				sFilterSQL – Output parameter. Returns the built query that returns the search results.
'				sResCountSQL - Output parameter. Returns the built query that returns the count of search results.
'				iResCount - Output parameter. Returns the number of search results [sResCountSQL query result]
'				sOneTrunkValue - Output parameter. Returns the trunk ID name if there is only one result.
' Return value: Success - True. 
'				sSQLFilter, sResCountSQL, iResCount, sOneTrunkValue - Output values.
' Example:
'---------------------------------------------------------------------------
Public Function fQuickSearchSQL(ByVal i, ByRef sSQLFilter, ByRef sResCountSQL, ByRef iResCount, ByRef sOneTrunkValue)

	sSearchStr = GlobalDictionary("QUICK_SEARCH" & i)

	'Based-colo quick search
	If IsNumeric(sSearchStr) and len(sSearchStr) = 4 Then
        sSQLFilter = "select id_key from trunk_attributes where ATTRIBUTE_TYPE_ID = ( " & _ 
		"select ATTRIBUTE_TYPE_ID from ATTRIBUTE_TYPES where UPPER(ATTRIBUTE_NAME) like 'COLO CODE') " & _
		"and UPPER(attribute_value) like '" & sSearchStr & "' and end_date is null " & _
		"INTERSECT select id_key from trunk_attributes where ATTRIBUTE_TYPE_ID = 16 " & _
		"INTERSECT select id_key from trunk_attributes where ATTRIBUTE_TYPE_ID = 22 " & _  
		"INTERSECT select id_key from trunk_attributes where ATTRIBUTE_TYPE_ID = 42 " & _ 
		"INTERSECT select id_key from trunk_attributes where ATTRIBUTE_TYPE_ID = 45 " & _
		"INTERSECT select id_key from trunk_attributes where ATTRIBUTE_TYPE_ID = 31 " & _
		"INTERSECT select id_key from trunk_attributes where ATTRIBUTE_TYPE_ID = 35 " & _
		")order by id_key"

		'Begin of of query
		sResCountSQL = "select count(id_key) from identifiers where id_key in( " & sSQLFilter
		sSQLFilter =  "select id_key, id_name from identifiers where id_key in( " & sSQLFilter

		

	'Based-trunkID quick serach
	Else
		sSQLFilter = "select id_key from trunk_attributes where ATTRIBUTE_TYPE_ID = 16 " & _ 
		"INTERSECT select id_key from trunk_attributes where ATTRIBUTE_TYPE_ID = 22 " & _  
		"INTERSECT select id_key from trunk_attributes where ATTRIBUTE_TYPE_ID = 42 " & _ 
		"INTERSECT select id_key from trunk_attributes where ATTRIBUTE_TYPE_ID = 45 " & _
		"INTERSECT select id_key from trunk_attributes where ATTRIBUTE_TYPE_ID = 31 " & _
		"INTERSECT select id_key from trunk_attributes where ATTRIBUTE_TYPE_ID = 35 " & _
		") and id_name like '" & sSearchStr & "' " & _
		"order by id_key" 

		'Begin of of query
		sResCountSQL = "select count(id_key) from identifiers where id_key in( " & sSQLFilter
		sSQLFilter =  "select id_key, id_name from identifiers where id_key in( " & sSQLFilter
	End If

	Call fDBGetOneValue ("TRUNKS", sResCountSQL, iResCount)
    If cInt(iResCount) = 1 Then
		Call fDBGetRS ("TRUNKS", sSQLFilter, objRS)
		objRS.MoveFirst
		sOneTrunkValue = objRS.Fields("ID_NAME").Value
	End If
	fQuickSearchSQL = True

End Function
'---------------------------------------------------------------------------
