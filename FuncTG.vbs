'===========================================================================
'============ This function library includes general functions =============
'===========================================================================

'---------------------------------------------------------------------------
' Function name: fGetFieldIndex
' Description: The function returns the index of an attribute
' Parameters: sAttributeName, iFieldInd-Output parameter
' Return value: Success - Field index
'				Failure - False
' Example:
'---------------------------------------------------------------------------
Public Function fGetFieldIndex(ByVal sAttributeGroup,ByVal sAttributeName, ByRef iFieldInd)

	sSQL = fGetQuery3Parameters("Get_field_index",sAttributeGroup, sAttributeGroup, sAttributeName) 
	rc = fDBGetOneValue("TRUNKS", sSQL, iFieldInd)         
	If fCheckQueryResults("fGetFieldIndex","Check if records exist", rc) <> True Then 
	fGetFieldIndex = False
		Exit Function
	End If

	fGetFieldIndex = True
End function
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fGetColoDesc
' Description: The function returns the colo descriptor (from UI). If empty - Fills it
' Parameters: Colo number
' Return value: Success - Colo descriptor
'				Failure - False
' Example:
'---------------------------------------------------------------------------
Public Function fGetColoDesc(ByVal sColo)

	Dim sColoDesc

	'Open modal
'	Browser("TG").Page("Create Trunk").WebElement("AssignColo button").Click
'	If Browser("TG").Page("Create Trunk").WebElement("AssignColoHeaders").Exist(30) <> "True" Then
'		Call fReport("fGetColoDesc","Sync to open colo window","FAIL","'Assign colo' window did not open",0)
'		fGetColoDesc = False
'		Exit Function
'	End If

	'Get Colo description
	sColoDesc = Browser("TG").Page("Create Trunk").WebEdit("ColoDescriptor").GetROProperty("value")
	'If colo has no value -> fill it
	If sColoDesc = "" Then
		sColoDesc = "Colo " & sColo
		Browser("TG").Page("Create Trunk").WebEdit("ColoDescriptor").Set sColoDesc		
	End If

'	'Close modal
'	Browser("TG").Page("Create Trunk").WebElement("Save Colo").Click
'	wait 1

	fGetColoDesc = sColoDesc
End function
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fGetAttributeTypeByName
' Description: The function returns the type of a specific attribute name
' Parameters: Attribute name
' Return value: Success - Attribute type
'				Failure - False
' Example:
'---------------------------------------------------------------------------
Public Function fGetAttributeTypeByName(ByVal sAttributeName)

	Dim sSQL, rc, sType

    sSQL = fGetQuery("Get_attribute_type_by_attribute_name", sAttributeName)
	rc = fDBGetOneValue ("TRUNKS", sSQL, sType)
	If fCheckQueryResults("fGetAttributeTypeByName","Check if records exist", rc) <> True Then 
		fGetAttributeTypeByName = False
		Exit Function
	End If
	
	fGetAttributeTypeByName = sType
End function
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fGetTabIndex
' Description: The function returns the tab index in editor page
' Parameters: Tab name
' Return value: Success - Tab index
'				Failure - False
' Example:
'---------------------------------------------------------------------------
Public Function fGetTabIndex(ByVal sTab)

    fGetTabIndex = False

	Select Case lcase(sTab)
		Case BaseAttributes
			fGetTabIndex = 0
		Case Media
			fGetTabIndex = 1
		Case Signaling
			fGetTabIndex = 2
	End Select

End function
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fNavigateToTab
' Description: The function navigate to specific tab 
' Parameters: Page, tab name
' Return value: Success - True, Failure - False
' Example:
'---------------------------------------------------------------------------
Public Function fNavigateToTab(ByVal sPage, ByVal sTab)

	If lcase(sTab) = "sidebar"  Then
		fNavigateToTab = True
		Exit Function
	End If

	Call Browser("TG").Page(sPage).WebElement("TabSelected").SetTOProperty("innertext",sTab)

	'If tab is already open
	If Browser("TG").Page(sPage).WebElement("TabSelected").Exist(1) = "True" Then
	  fNavigateToTab = True
	  Exit Function
	End If

	'If tab is not opened -> Open tab and sync
	Browser("TG").Page(sPage).WebElement("Class:=v-captiontext","innerText:=" & sTab).Click
	If fSyncByObject("fNavigateToTab", "TG", sPage, "WebElement", "TabSelected", 15) <> True Then
		fNavigateToTab = False
		Exit Function
	End If

    fNavigateToTab = True

End function
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fQuickSearch
' Description: The function search the trunk id by quick search and checks if the expected page was opened
' Parameters: sTrunkID - Value to search by quick search, [Optional] sExpectedPage - Editor/Search
' Return value: Success - True, Failure - False
' Example:
'---------------------------------------------------------------------------
Public Function fQuickSearch(ByVal sTrunkID, ByVal sExpectedPage)

	Browser("TG").Page("All Pages").WebEdit("QuickSearch").Click
	Browser("TG").Page("All Pages").WebEdit("QuickSearch").Set sTrunkID
	Browser("TG").Page("All Pages").WebElement("View").Click

	If sExpectedPage <> "" Then
		If fSyncByObjectForPage(sExpectedPage) <> True Then
			fQuickSearch = False
			Call fReport("fQuickSearch","Navigate to " & sExpectedPage & " by quick search","FAIL","Navigation failed",0)
			Exit Function
		End If
	End If

	fQuickSearch = True

End function
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fSelectDirectionValue
' Description: The function selects specific value from direction combo-box
' Parameters: ValToSelect
' Return value: Success-True, Failure- False
' Example:
'---------------------------------------------------------------------------
Public Function fSelectDirectionValue(ByVal ValToSelect)

	Dim iRow

	Wait 4
	Browser("TG").Page("Create Trunk").WebElement("Direction combo").WebElement("DirectionButton").Click
	If fSyncByObject("fSelectDirectionValue","TG","Create Trunk","WebTable","html tag:=TABLE",30) <> True Then
		fSelectDirectionValue = False
		Exit Function
	End If

	iRow = Browser("TG").Page("Create Trunk").WebTable("html tag:=TABLE").GetRowWithCellText(ValToSelect,1,1)
	Browser("TG").Page("Create Trunk").WebTable("html tag:=TABLE").ChildItem(iRow,1,"WebElement",0).Click

	fSelectDirectionValue = True
End function
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fListWithValues
' Description: The function check if the base attributes' list has values
' Parameters: sComboName
' Return value: list has values - True, list has not values - False
' Example:
'---------------------------------------------------------------------------
Public Function fListWithValues(ByVal sComboName)

	Dim sSQL, rc
	sSQL = fGetQuery("Get_attribute_list_values_by_attribute_name", sComboName)
	rc = fDBGetRS("TRUNKS", sSQL, objRS)
         
	fListWithValues = fCheckQueryResults("fListWithValues","Check if list is null", rc)			
End Function

'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fCompanyValuesVsDB
' Description: The function gets company overview combo name and objRS and compare combo values on UI with objRS values from DB
' Parameters: Browser, Page, comboname (in the innerhtml), iLimit: 0-No limit, other - num to limit
' Return value: Success - True, Failure - False.
' Example:
'---------------------------------------------------------------------------
Public Function fCompanyValuesVsDB(ByVal sBrowser,ByVal sPage,ByVal sComboName, ByVal iLimit, byVal objRS)

	Dim iRnd, iMin, iMax, bFound, iRow, iRowsIndex
	bFound = True

	'Open list
	Browser(sBrowser).Page(sPage).WebElement(sComboName).WebElement("class:=.*v-filterselect-button.*").Click
	If fSyncByObject("fCompanyValuesVsDB",sBrowser,sPage,"WebTable","html tag:=TABLE",30) <> True Then
		fCompanyValuesVsDB = False
		Exit Function
	End If

	iMin = 1
	iMax = Browser(sBrowser).Page(sPage).WebElement("class:=.*v-filterselect-status.*").GetROProperty("innertext")
    iMax = right(iMax,len(iMax)-instr(1,iMax,"/"))

	'limit max val
	If iLimit <> 0 Then
		iMax = iLimit
	End If


   	objRS.MoveFirst
	If instr(1,lcase(sComboName),"company") > 0 Then
		iRow = 1    '2	
	Else
		iRow = 1
    End If

	iRowsIndex = 1
	While NOT objRS.EOF and iRowsIndex < iMax

		'Get DB Value
		sFullName = Trim(objRS.Fields(0).Value)
		sShortName = Trim(objRS.Fields(1).Value)
		sID = Trim(objRS.Fields(2).Value)
		ValDB = sFullName & "-" & sShortName '& "-" & sID
		If isNull(sShortName) Then
			ValDB = sFullName '& "-" & sID
		End If

		'Get UI Value and compare with DBVal
		ValUI = Trim(Browser(sBrowser).Page(sPage).WebTable("html tag:=TABLE").GetCellData(iRow,1))
		If ValDB <> ValUI Then

			ValUI = replace(ValUI, " ", "") '---Remove after fixing bug - combo-boxes deletes extra spaces between words
			ValDB = replace(ValDB, " ", "") '---Remove
			If ValDB <> ValUI  Then '---Remove
				bFound = False
				Call fReport("fCompanyValuesVsDB","Comparing combo '" & sComboName & "' VS DB","FAIL","Comparing fail. DB value: " & ValDB & ", UI value: " & ValUI,0)
			End If '---Remove
        End If

		iRowsIndex = iRowsIndex + 1
		iRow = iRow + 1
		If iRow mod 10 = 1 Then
			Browser(sBrowser).Page(sPage).WebElement("class:=.*v-filterselect-nextpage.*").Click
			iRow = 1
			Wait 1
		End If

        objRS.MoveNext
	Wend

    'Close list
	Browser(sBrowser).Page(sPage).WebElement(sComboName).WebElement("class:=.*v-filterselect-button.*").Click
	wait 1

	If bFound = False Then
		fCompanyValuesVsDB = False
	Else
		fCompanyValuesVsDB = True 
	End If
    
End Function
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fCompareComboValuesVsDB
' Description: The function gets combo name and objRS and compares combo values on UI with objRS values from DB
' Parameters: Browser, Page, comboname (in the innerhtml), iLimit: 0-No limit, other - num to limit
' Return value: Success - True, Failure - False.
' Example:
'---------------------------------------------------------------------------
Public Function fCompareComboValuesVsDB(ByVal sBrowser,ByVal sPage,ByVal sComboName, ByVal sListDesc, ByVal iLimit, byVal objRS)

	Dim iRnd, iMin, iMax, bFound, iRow, iRowsIndex
	bFound = True

	'Open list
	If Browser(sBrowser).Page(sPage).WebTable(sListDesc).Exist(1) <> "True" Then
		Browser(sBrowser).Page(sPage).WebElement("innerhtml:=.*"& sComboName &".*","index:=0").WebElement("class:=.*v-filterselect-button.*").Click
		If fSyncByObject(fCompareComboValuesVsDB,sBrowser,sPage,"WebTable",sListDesc,30) <> True Then
			fCompareComboValuesVsDB = False
			Exit Function
		End If
	End If

	iMin = 1
	iMax = Browser(sBrowser).Page(sPage).WebElement("class:=.*v-filterselect-status.*").GetROProperty("innertext")
    iMax = right(iMax,len(iMax)-instr(1,iMax,"/"))

	'limit max val
	If iLimit <> 0 Then
		iMax = iLimit
	End If

	objRS.MoveFirst
	iRowsIndex = 1
	iRow = 1
	While Not objRS.EOF and iRowsIndex < iMax

		ValDB = Trim(objRS.Fields(0).Value)
		ValUI = Trim(Browser(sBrowser).Page(sPage).WebTable(sListDesc).GetCellData(iRow,1))

		If ValDB <> ValUI Then
			ValUI = replace(ValUI, " ", "") '---Remove after fixing bug - combo-boxes deletes extra spaces between words
			ValDB = replace(ValDB, " ", "") '---Remove
			If ValDB <> ValUI  Then '---Remove
				bFound = False
				Call fReport("fCompareComboValuesVsDB","Comparing combo '" & sComboName & "' VS DB","FAIL","Comparing fail. DB value: " & ValDB & ", UI value: " & ValUI,0)
			End If '---Remove
        End If

		iRowsIndex = iRowsIndex + 1
		iRow = iRow + 1
		If iRow mod 10 = 1 Then
			Browser(sBrowser).Page(sPage).WebElement("class:=.*v-filterselect-nextpage.*").Click
			iRow = 1
			Wait 1
		End If
		objRS.MoveNext
	Wend

	'Close list
	Browser(sBrowser).Page(sPage).WebElement("innerhtml:=.*"& sComboName &".*","index:=0").WebElement("class:=.*v-filterselect-button.*").Click
	wait 1

	If bFound = False Then
		fCompareComboValuesVsDB = False
	Else
		fCompareComboValuesVsDB = True 
	End If
    
End Function
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fCheckNotification
' Description: The function Checks if notification appears and report about it
' Parameters: function name (of the calling function)
' Return value: Success - True, Failure - False. 
' Example: 
'---------------------------------------------------------------------------
Public Function fCheckNotification(ByVal sFuncName)
	If Browser("TG").Page("All Pages").WebElement("Notification").exist = "True" Then
		sNotification = Browser("TG").Page("All Pages").WebElement("Notification").GetRoProperty ("innertext")
		Call fReport(sFuncName,"Check if notification appears","FAIL","Following notification appears: " & sNotification, 0)
		fCheckNotification = False
		Exit Function
	End If
	fCheckNotification = True
End Function
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fFormatDate
' Description: The function formats a date (See example)
' Parameters: Date to format
' Return value: Success - Formatted date string value, Failure - False. 
' Example: "25/7/2012" -> "07/25/2012", "3/3/2010" -> "03/03/2010"
'---------------------------------------------------------------------------
Public Function fFormatDate(ByVal DateVal)
	Dim iDay, iMonth, iYear, strDate
	DateVal = cDate(DateVal)
	iDay = Day(DateVal)
	iMonth = Month(DateVal)
	iYear = Year(DateVal)

	If iDay < 10 Then
		iDay = "0" & iDay
	End If
	If iMonth < 10 Then
		iMonth = "0" & iMonth
	End If

	strDate = iMonth & "/" & iDay & "/" & iYear
	
	fFormatDate = strDate
End Function
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fGetColoFromTrunkID
' Description: The function 'cuts' the colo digits from full trunk id
' Parameters: Full trunk id, ByRef-sColo
' Return value: Success - True, sColo returns the colo digits
'				Failure - False. 
' Example:
'---------------------------------------------------------------------------
Public Function fGetColoFromTrunkID(Byval sTrunkId, ByRef sColo)

	If Len(sTrunkId) <> 10 Then
		Call fReport ("fGetColoFromTrunkID", "Get colo from trunk id " & sTrunkId, "FAIL", "Colo does not include 10 digits",0)
		fGetColoFromTrunkID = False
		Exit Function
	End If

	sColo = Mid(sTrunkId,4,4)
    
	fGetColoFromTrunkID = True
End Function
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fGetExpectedSequence
' Description: The function returns the expected sequence (from DB) by trunk id string
' Parameters: sStrTrunkID
' Return value: Success - The expected sequence, Failure - False. 
' Example:
'---------------------------------------------------------------------------
Public Function fGetExpectedSequence (ByVal sStrTrunkID)

	sStrTrunkID = Replace(sStrTrunkID,"-","")

	Dim iSequence
	'Get last trunk created with these details
	sSQL = fGetQuery("Get_expected_sequence_by_first_9_trunk_digits",sStrTrunkID)
	rc = fDBGetOneValue("TRUNKS", sSQL, iSequence)
	If rc = NO_RECORDS_FOUND Then
		iSequence = "0"
	ElseIf rc = False Then
		fGetExpectedSequence = False
		Exit Function
	End If

	iSequence = cInt(Right(Trim(iSequence),1))
	iSequence = iSequence + 1
	If iSequence = 10 Then
		call fReport("fGetExpectedSequence","Check if there are same 9 trunks","WARNING","Can not create another trunk with these details",0)
		FunctionfGetExpectedSequence = False
	End If
	
	fGetExpectedSequence = iSequence

End Function
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fGetAttributeDigitByValue
' Description: The function returns the digit value (from DB) by Attribute Value
' Parameters: AttributeValue
' Return value: Success - Digit value, Failure - False. 
' Example:
'---------------------------------------------------------------------------
Public Function fGetAttributeDigitByValue (ByVal AttributeValue)

	Dim iDigit
	sSQL = fGetQuery("Get_attribute_digit_by_value",AttributeValue)
	rc = fDBGetOneValue("TRUNKS", sSQL, iDigit)
	If fCheckQueryResults ("Trunk id verification", "GetAttributeDigitByValue", rc) <> True Then
		fGetAttributeDigitByValue = False
		Exit Function
	End If

	fGetAttributeDigitByValue = iDigit
End Function
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fGetSiteCodeByName
' Description: The function returns the site code (from DB) by site full name
' Parameters: site full name
' Return value: Success - site code, Failure - False. 
' Example:
'---------------------------------------------------------------------------
Public Function fGetSiteCodeByName(ByVal sSite)

	Dim iSiteCode
	
	sSite = Trim(Left(sSite, instr(1,sSite,"-") - 1))
	sSQL = fGetQuery("Get_site_code_by_site_short_name",sSite)
	rc = fDBGetOneValue("TRUNKS", sSQL, iSiteCode)
	If fCheckQueryResults ("Trunk id verification", "GetSiteCodeByName", rc) <> True Then
		fGetSiteCodeByName = False
		Exit Function
	End If

	fGetSiteCodeByName = iSiteCode

End Function
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fCheckDisabledRMS
' Description: The function check if all RMS fields and buttons are disabled
' Parameters: 
' Return value: All disable - True. Else - False
' Example:
'---------------------------------------------------------------------------
Public Function fCheckDisabledAllRMS()
	
	Dim bCustField, bVendField, bCustButton, bVendButton

	bCustField = fIsDisabled("TG","Create Trunk","WebElement","Customer combo")
	bVendField = fIsDisabled("TG","Create Trunk","WebElement","Vendor combo")
	bCustButton = fIsDisabled("TG","Create Trunk","WebElement","Customer New")
	bVendButton = fIsDisabled("TG","Create Trunk","WebElement","Vendor New")
	If bCustField <> True OR bVendField <> True OR bCustButton <> True OR bVendButton <> True Then
		fCheckDisabledAllRMS = False
	Else
		fCheckDisabledAllRMS = True 'all disabled
	End If

End Function
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fCheckDisabledCustomer_Vendor
' Description: The function check if RMS customer/vendor fields and buttons are disabled
' Parameters: Customer/Vendor
' Return value: Customer/vendor disable - True, Else - False
' Example:
'---------------------------------------------------------------------------
Public Function fCheckDisabledCustomer_Vendor(ByVal sRMS)
	
	Dim bCustField, bVendField, bCustButton, bVendButton

	bCustField = fIsDisabled("TG","Create Trunk","WebElement","Customer combo")
	bCustButton = fIsDisabled("TG","Create Trunk","WebElement","Customer New")

	bVendField = fIsDisabled("TG","Create Trunk","WebElement","Vendor combo")
	bVendButton = fIsDisabled("TG","Create Trunk","WebElement","Vendor New")

	Select Case lcase(sRMS)
    	Case "customer" 
			If  bCustField <> True OR bCustButton <> True Then
				fCheckDisabledCustomer_Vendor = False
			Else
				fCheckDisabledCustomer_Vendor = True 
			End If

		Case "vendor"	
			If  bVendField <> True OR bVendButton <> True Then
				fCheckDisabledCustomer_Vendor = False
			Else
				fCheckDisabledCustomer_Vendor = True 
			End If
	End Select

End Function
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fIsDisabled
' Description: The function checks if an object is disabled
' Parameters: sBrowser, sPage, sObjType, sObjName
' Return value: Success - True, Failure - False. 
' Example:
'---------------------------------------------------------------------------
Public Function fIsDisabled(ByVal sBrowser, ByVal sPage, ByVal sObjType, ByVal sObjName)

	Dim sStr, sInnerHTML, sClass

	'Get object's innerhtml
	sStr = "sInnerHTML = Browser(sBrowser).Page(sPage).sObjType(sObjName).GetRoProperty(""innerhtml"")"
	sStr = replace(sStr,"sObjType",sObjType)
    Execute sStr 

	'Get object's class
	sStr = "sClass = Browser(sBrowser).Page(sPage).sObjType(sObjName).GetRoProperty(""class"")"
	sStr = replace(sStr,"sObjType",sObjType)
    Execute sStr 

	If instr(1,sInnerHTML,"disable") = 0 AND instr(1,sClass,"disable") = 0 Then
		fIsDisabled = False
	Else
        fIsDisabled = True
	End If

End Function
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fSelectRandomValueFromCombobox
' Description: The function select randomize value from combobox list
' Parameters: Browser, Page, comboname (in the innerhtml), iLimit: 0-No limit, other - num to limit
' Return value: Success - True, Failure - False. The parameter sReturnValue returns to text of the selected value
' Example:
'---------------------------------------------------------------------------
Public Function fSelectRandomValueFromCombobox(ByVal sBrowser,ByVal sPage,ByVal sComboName,ByVal sListDesc,ByVal iLimit,ByRef sReturnValue)

	Dim iRnd, iMin, iMax,iTest
    	
	'If Browser(sBrowser).Page(sPage).WebTable(sListDesc).Exist(1) <> "True" Then
	'If Browser(sBrowser).Page(sPage).WebElement("innerhtml:=.*"& sComboName &" .*","index:=0").WebElement("class:=.* v-filterselect-suggestpopup-combo.*").Exist(1) <> "True" Then																																			
		'If fSyncByObject("fSelectRandomValueFromCombobox","TG","All Pages","WebTable",sListDesc,30) <> True Then
		'	fSelectRandomValueFromCombobox = False
		'	Exit Function
		'End If
	'End If

	wait 5
	Browser(sBrowser).Page(sPage).WebElement("innerhtml:=.*"& sComboName &".*","index:=0").WebElement("class:=.*v-filterselect-button.*").Click
	wait 1

	iMin = 2
	iMax = Browser(sBrowser).Page(sPage).WebElement("class:=.*v-filterselect-status.*").GetROProperty("innertext")
	'iMax = Browser(sBrowser).Page(sPage).WebElement("PagingNum").GetROProperty("innertext")
	If iMax = "" Then
		iMax = 2
	Else
		iMax = cdbl(right(iMax,len(iMax)-instr(1,iMax,"/")))
	End If

	'limit max val
	If iLimit <> 0 and iMax > iLimit Then
		iMax = iLimit
	End If

	Call fRandomize(iMin,iMax,iRnd)
	
	iRow = iRnd
	If iRnd > 10 and Browser(sBrowser).Page(sPage).WebElement("class:=.*v-filterselect-nextpage.*").Exist(0) = "True" Then
		If iRnd mod 10 <> 0 Then
			Browser(sBrowser).Page(sPage).WebElement("class:=.*v-filterselect-nextpage.*").Click
		End If
		For i=2 to iRnd\10
			Browser(sBrowser).Page(sPage).WebElement("class:=.*v-filterselect-nextpage.*").Click
		Next
	End If

	Wait 1
	
	iRow = iRow mod 10
	If iRow =0 Then
		iRow = 10
	End If
	sReturnValue = Trim(Browser(sBrowser).Page(sPage).WebTable(sListDesc).GetCellData(iRow,1))

	'Errors handling
	If instr(1,ucase(sReturnValue),"ERROR") <> 0 Then
		'iRow = 1
       	sReturnValue = Trim(Browser(sBrowser).Page(sPage).WebTable(sListDesc).GetCellData(iRow,1))
	End If
    wait 3

	err.clear
    Browser(sBrowser).Page(sPage).WebTable(sListDesc).ChildItem(iRow,1,"WebElement",0).Click
	'Browser(sBrowser).Page(sPage).WebElement("innerhtml:=.*"& sComboName &".*","index:=0").Set sReturnValue
	'Browser(sBrowser).Page(sPage).WebElement("innerhtml:=.*"& sComboName &".*","index:=0").SetTOProperty("innerhtml",sReturnValue).value
	'Browser("TG").Page("Search").WebElement(sFilterTable).WebTable(sFilterTable).ChildItem(i,1,"WebEdit",0).GetROProperty("value")
	wait 1
	If err.description <> "" Then
		Call fReport("irow","","FAIL","iRow: "&iRow, " iRnd: " & iRnd,0)
	End If
    
   	fSelectRandomValueFromCombobox = True 

End Function
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fSyncByImage
' Description: The function wait for synchronization by the loading-indicator image
' Parameters: iTime - Max time [in seconds] to wait to sync
' Return value: Success - True, Failure - Time over - False
' Example:
'---------------------------------------------------------------------------
Public Const allPagesDesc = "Welcome.*|Create.*|Edit.*|Search.*"

Public Function fSyncByImage(sBrowser, sPage, iTime)

   	iCounter = 1
	wait 2
	While (Ucase(Browser(sBrowser).Page(sPage).WebElement("class:=v-loading-indicator.*","index:=0").Object.style.display) = "BLOCK" OR Ucase(Browser(sBrowser).Page(sPage).WebElement("class:=v-loading-indicator.*","index:=1").Object.style.display) = "BLOCK" OR Ucase(Browser(sBrowser).Page(sPage).WebElement("class:=v-loading-indicator.*","index:=2").Object.style.display) = "BLOCK") And iCounter <= iTime
		iCounter = iCounter + 1
		Wait 1
	Wend

	If iCounter > iTime Then
		fSyncByImage = False
	Else
		fSyncByImage = True
	End If

End Function
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fSyncByObjectForPage
' Description: The function calls fSyncByObject and sends it the object to sync by on the page 
' Parameters: sPage - Page to sync for.			
' Return value: Success - True, Failure - Time over - False
' Example: 
'---------------------------------------------------------------------------
Public Function fSyncByObjectForPage(ByVal sPage)

Select Case lcase(sPage)
	Case "welcome"
		If fSyncByObject ("fSyncByObjectForPage","TG","Welcome","WebElement","Welcome Breadcrumbs",60) <> True Then
			fSyncByObjectForPage = False
			Exit Function
		End If	

	Case "create trunk"
		If fSyncByObject ("fSyncByObjectForPage","TG","Create Trunk","WebElement","Sequence",60) <> True Then
			fSyncByObjectForPage = False
			Exit Function
		End If	

	Case "search"
		If fSyncByObject ("fSyncByObjectForPage","TG","Search","WebElement","Apply",60) <> True Then
			fSyncByObjectForPage = False
			Exit Function
		End If	

	Case "editor"
		If fSyncByObject ("fSyncByObjectForPage","TG","Editor","WebElement","trunkID label",60) <> True Then
			fSyncByObjectForPage = False
			Exit Function
		End If	
End Select

	fSyncByObjectForPage = True

End Function
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fSyncByObject
' Description: The function wait for synchronization by object – Wait to the object to appear on UI.
' Parameters: iTime - Max time [in seconds] to wait to sync, Object to sync by [name and type]					
' Return value: Success - True, Failure - Time over - False
' Example: Call fSyncByObject("fSelectCustomer","iBasis Customer Portal","Finance","Link", "Welcome",30)
'---------------------------------------------------------------------------
Public Function fSyncByObject(sFuncName, sBrowser, sPage, sObjType, sObjName, iTime)

	Dim sStr, sRes

    sStr = "sRes = Browser(sBrowser).Page(sPage).sObjType(sObjName).Exist(iTime)"
	sStr = replace(sStr,"sObjType",sObjType)
    Execute sStr 

	If sRes = False Then
		Call fReport (sFuncName & " - " & "fSyncByObject", "Sync By Object", "FAIL","Object: " & sObjName & " on page: " & sPage & " was not found",0)
        fSyncByObject = False
		Exit Function
	End If

	fSyncByObject = True

End Function
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fRandomize
' Description: The function random a number between iMimVal and iMaxVal values
' Parameters: iMimVal, iMaxVal, iNum
' Return value: iNum - The randomized number (ByRef)
' Example: fRandomize(1,10,num)
'---------------------------------------------------------------------------
Public Function fRandomize (ByVal iMimVal, ByVal iMaxVal, ByRef iNum)

	Randomize
	iNum = int((iMaxVal - iMimVal + 1) * rnd) + iMimVal

End Function
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fRandDigit
' Description: The function rand digit
' Parameters: 
' Return value: The randomized digits
' Example: 
'---------------------------------------------------------------------------
Public Function fRandDigit()
	Randomize
	fRandDigit = int((9 - 0 + 1) * rnd) + 0

End Function
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fReport
' Description: The function writes row to the HTML Report
' Parameters: sStepName, sStepDesc, sStatus, sStatusReason, iReportTo
'				sStatus: "PASS" / "FAIL" / "INFO" / "" (- for header etc.)
'				iReportTo: 0 = Both, 1 = Only QTP report, 2 = Only HTML report
' Return value: 
' Example:
'---------------------------------------------------------------------------
Public Function fReport(ByVal sStepName, ByVal sStepDesc, ByVal sStatus, ByVal sStatusReason, ByVal iReportTo)

	If iReportTo <> 2 Then
		'Write to QTP resutls report
		Select Case sStatus
			Case uCase("PASS")
				Reporter.ReportEvent micPass, sStepName, sStatusReason
			Case uCase("FAIL")
				Reporter.ReportEvent micFail, sStepName, sStatusReason
			Case uCase("INFO")
				Reporter.ReportEvent micWarning, sStepName, sStatusReason
		End Select
	End If

	If iReportTo <> 1 Then
		'Write to HTML results Report
		Call fWriteHtmlReportRow(sStepName, sStepDesc, sStatus, sStatusReason)
	End If

End Function
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fCreateHtmlReport
' Description: The function creates HTML Report
' Parameters: sTestName
' Return value: 
' Example:
'---------------------------------------------------------------------------			  			
Public sResultFile, iReportRow
iReportRow = 0

Public Function fCreateHtmlReport(ByVal sTestName)

            Dim sDate, sFileName

            sDate = Now
            sDate = Replace(sDate, " ", "_")
            sDate = Replace(sDate, "/", "_")
            sDate = Replace(sDate, ":", "_")

            sFileName = sTestName & "_" & sDate & ".html"
            sResultFile = "T:\Matrix-QA\QTP-Aoutomation\QTP-TG\TG\Phase 2.5\Results\" & sFileName
            'sResultFile = "C:\Users\ibases\Desktop\QTP\TG\Phase 2.5\Results\" & sFileName
			'sResultFile = "C:\Documents and Settings\Administrator\Desktop\QTP\TG\Phase 2.5\Results\" & sFileName
			'sResultFile = "W:\projects\TG\QA\QTP - Files\QTP\TG\Phase 2.5\Results\" & sFileName

            Set objFSO = CreateObject("Scripting.FileSystemObject")
            Set objFile = objFSO.CreateTextFile(sResultFile, True)

            objFile.WriteLine("<HTML>")
            objFile.WriteLine("<HEAD>")

            objFile.WriteLine("<SCRIPT language=vbscript>")
            objFile.WriteLine("Public Function fFilterByStatus()")
            objFile.WriteLine("Dim i")

            objFile.WriteLine("For i = 1 to Document.GetElementById(""tblReports"").Rows.Length")

            objFile.WriteLine("If Trim(Document.GetElementById(""lstStatus"").Value) = ""Status"" Or Trim(Document.GetElementById(""tdStatus"" & i).InnerText) = Trim(Document.GetElementById(""lstStatus"").Value) Then")
            objFile.WriteLine("Document.GetElementById(""trElement"" & i).Style.Display=""block""")
            objFile.WriteLine("Else")
            objFile.WriteLine("Document.GetElementById(""trElement"" & i).Style.Display=""none""")
            objFile.WriteLine("End If")
            objFile.WriteLine("Next")
                                                            
            objFile.WriteLine("End Function")
            objFile.WriteLine("</SCRIPT>")
            
            objFile.WriteLine("</HEAD>")

            objFile.WriteLine("<TITLE>QTP Execution Report - " & sDate & "</TITLE>")
            objFile.WriteLine("<BODY>")
            
            objFile.WriteLine("<TABLE style='FONT-FAMILY: Verdana; font-size: 12px; border: 1px black solid; border-bottom: 0px'>")
            objFile.WriteLine("<TR style='background-color: #607B8B'>")
            objFile.WriteLine("<TD>")
            objFile.WriteLine("<FONT color=white>Test Name:</FONT>")
            objFile.WriteLine("</TD>")
            objFile.WriteLine("<TD>")
            objFile.WriteLine("<FONT color=white>" & sTestName & "</FONT>")
            objFile.WriteLine("</TD>")
            objFile.WriteLine("</TR>")
            objFile.WriteLine("</TABLE>")
              
            objFile.WriteLine("<TABLE width=100% style='FONT-FAMILY: Verdana; font-size: 12px; border: 1px black solid'>")
            objFile.WriteLine("<TR style='background-color: FAEBD7'>")
            objFile.WriteLine("<TD width=5%>")
            objFile.WriteLine("Step ID")
            objFile.WriteLine("</TD>")
            objFile.WriteLine("<TD width=10%>")
            objFile.WriteLine("Step Name")
            objFile.WriteLine("</TD>")
            objFile.WriteLine("<TD width=50%>")
            objFile.WriteLine("Step Description")
            objFile.WriteLine("</TD>")
            objFile.WriteLine("<TD width=5%>")
            objFile.WriteLine("<select id=lstStatus OnChange=""fFilterByStatus()""><option value=Status>Status</option><option value=FAIL>FAIL</option><option value=PASS>PASS</option></select>")
            objFile.WriteLine("</TD>")
            objFile.WriteLine("<TD width=30%>")
            objFile.WriteLine("Status Reason")
            objFile.WriteLine("</TD>")
            objFile.WriteLine("</TR>")
            objFile.WriteLine("<TBODY id=tblReports>")

			objFile.WriteLine("</TBODY>")
            objFile.WriteLine("</TABLE>")
            objFile.WriteLine("<BR>")
            
            objFile.WriteLine("</BODY>")
            objFile.WriteLine("</HTML>")
            objFile.Close
            
End Function
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fWriteHtmlReportRow
' Description: The function writes row to the HTML Report
' Parameters: sStepName, sStepDesc, sStatus, sStatusReason
'			  sStatus: "PASS" / "FAIL" / "INFO" / "" (- for header etc.) 
' Return value: 
' Example:
'---------------------------------------------------------------------------
Public Function fWriteHtmlReportRow(ByVal sStepName, ByVal sStepDesc, ByVal sStatus, ByVal sStatusReason)

           Dim sTr, sSaveStatus

		   sSaveStatus = sStatus
           iReportRow = iReportRow + 1


           Set objFSO = CreateObject("Scripting.FileSystemObject")
           Set objFile = objFSO.OpenTextFile(sResultFile, 1)

           sStr = objFile.ReadAll
           objFile.Close

           If sStatus = "TITLE" Then
				sTr = "<TR id=trElement" & iReportRow & " style='background-color: #236B8E; color: white; height: 25px;'>"
		   ElseIf sStatus = "HEADER" Then
				sTr = "<TR id=trElement" & iReportRow & " style='background-color: EECFA1'>"
		   Else
				If iReportRow Mod 2 = 0 Then
							sTr = "<TR id=trElement" & iReportRow & " style='background-color: C0C0C0'>"
				Else
							sTr = "<TR id=trElement" & iReportRow & ">"
				End If
		   End If
           
            If sStatus = "FAIL" Then
                        sStatus = "<TD id=tdStatus" & iReportRow & " style='background-color: FF0000'>" & sStatus & "</TD>"
            ElseIf sStatus = "PASS" Then
                        sStatus = "<TD id=tdStatus" & iReportRow & " style='background-color: 00FF00'>" & sStatus & "</TD>"
			ElseIf sStatus = "INFO" Then
						sStatus = "<TD id=tdStatus" & iReportRow & " style='background-color: FFFF00'>" & sStatus & "</TD>"
			ElseIf sStatus = "HEADER"  Then'Header
						sStatus = "<TD id=tdStatus" & iReportRow & " style='background-color:'></TD>" '& sStatus & "</TD>"
			ElseIf sStatus = "TITLE" Then'Function Name header
						sStatus = "<TD id=tdStatus" & iReportRow & " style='background-color:'></TD>" '& sStatus & "</TD>"
            End If

			If sSaveStatus = "" Then
				sStr = Replace(sStr, "</TBODY>", sTr & "<TD>" & iReportRow & "</TD><TH>" & sStepName & "</TH><TH id=tdStatus666>" & sStepDesc & "</TH>" & sStatus & "<TD>" & sStatusReason & "</TD></TR></TBODY>")
			Else
				sStr = Replace(sStr, "</TBODY>", sTr & "<TD>" & iReportRow & "</TD><TD>" & sStepName & "</TD><TD id=tdStatus666>" & sStepDesc & "</TD>" & sStatus & "<TD>" & sStatusReason & "</TD></TR></TBODY>")
			End If

            Set objFile = objFSO.OpenTextFile(sResultFile, 2)
            objFile.Write sStr
            objFile.Close

End Function
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: clsProgressBar
' Description: The class includes functions to create progress bar
' Parameters: 
' Return value: 
' Example:
'---------------------------------------------------------------------------
Class clsProgressBar
	Private Function fGetScreenResolution(ByRef intHorizontal, ByRef intVertical)
		Dim objWMIService, colItems, objItem
		Set objWMIService = GetObject("Winmgmts:\\.\root\cimv2")
		Set colItems = objWMIService.ExecQuery("Select * From Win32_DesktopMonitor where DeviceID = 'DesktopMonitor1'",,0)
		For Each objItem in colItems
				intHorizontal = objItem.ScreenWidth
				intVertical = objItem.ScreenHeight
		Next 
	End Function

	Public Function fInitForm(ByVal sTitle)
		Dim MyForm, intHorizontal, intVertical
        Set MyForm = DotNetFactory.CreateInstance("System.Windows.Forms.Form", "System.Windows.Forms")
        MyForm.Height = 80
        MyForm.MinimizeBox = False
		MyForm.MaximizeBox = False
        MyForm.Text = sTitle
        ' Location not working.
        fGetScreenResolution intHorizontal, intVertical
        MyForm.Location.X = Cint(intHorizontal/2)
        MyForm.Location.Y = Cint(intVertical/2)
        MyForm.Show
        Set fInitForm = MyForm
	End Function

	Public Function fInitProgressBar(ByRef MyForm, ByVal iMin, ByVal iMax, ByVal iStep)
		Dim MyProgressBar, Pos
        Set MyProgressBar = DotNetFactory.CreateInstance("System.Windows.Forms.ProgressBar", "System.Windows.Forms")
        Set Pos = DotNetFactory.CreateInstance("System.Drawing.Point", "System.Drawing")

		'Set d = DotNetFactory.CreateInstance("System.Drawing.SystemColors", "System.Drawing")
        

        Pos.X = 1
        Pos.Y = 10
        With MyProgressBar
			.Text = "ff"
            .Minimum = iMin
            .Maximum = iMax
            .Step = iStep
            .Location = Pos
            .Width = Cint(MyForm.Width) - 10
			'.BackColor = d
		End with

        MyForm.Controls.Add MyProgressBar
        MyForm.Show
        MyForm.Activate
        Set fInitProgressBar = MyProgressBar
	End Function

End Class

Dim objPB
Set objPB = New clsProgressBar
'---------------------------------------------------------------------------

