Option Explicit

Public newTrunk
Public TrunkData

Public Const MAX = 10
Public Const DB_MAX = 25
Public Const COMPANY_MAX = 50
Public Const REPEAT = 3

'---------------------------------------------------------------------------
' Function name: fBusLogin
' Description: Login to application and navigate to the required page
' Parameters: 
' Return value: Success - True, Failure - False
' Example:
'---------------------------------------------------------------------------
Public Function fBusLogin()

	Dim sUserName, sPassword

	'If browser is closed -> Open browser
	 If Browser("TG").Exist(1) <> "True" Then
		 Call SystemUtil.Run("C:\Program Files\Mozilla Firefox\firefox.exe",Environment("URL"))
	 End If

	'If application is opened and no user is sign in -> click sign in and sync
	 If Browser("TG").Page("All Pages").Link("Sign In").Exist(0) <> "False" Then
		 Browser("TG").Page("All Pages").Link("Sign In").Click
		 If fSyncByObject("fBusLogin","TG","Login","WebEdit","UserName",30) = False Then
			fBusLogin = False
			Exit Function
		 End If 
	 End If

	'Else - If application is opened and any user is sign in -> click sign out and sync
     If Browser("TG").Page("All Pages").Link("Sign Out").Exist(0)<> false Then
        Browser("TG").Page("All Pages").Link("Sign Out").Click
        If fSyncByObject("fBusLogin","TG","Login","WebEdit","UserName",30)= False Then 
		 	fBusLogin = False 
			Exit Function
		 End If
	 End If

	'Fill user name and password and click 'Sign In' (According test parameters or default user)
	If GlobalDictionary("USER_NAME") <> "" and GlobalDictionary("PASSWORD") <> "" Then
		sUserName = GlobalDictionary("USER_NAME")
		sPassword = GlobalDictionary("PASSWORD")
	Else
	    sUserName = Environment("USER")
		sPassword = Environment("PASSWORD")
	End If
	Browser("TG").Page("Login").WebEdit("UserName").Set(sUserName)
	Browser("TG").Page("Login").WebEdit("Password").Set(sPassword)
    Browser("TG").Page("Login").WebButton("Sign In Button").Click

'	'Wait (sync) to load main page (-Search)
'	'fSyncByObject-function that waiting to expected object to appear on the screen 
'    If fSyncByObject("fBusLogin","TG","Search","WebElement","ResultsTable",90)= False Then 
'		fBusLogin = False 
'		Exit Function
'	End If

	'Wait (sync) to load main page (-Create)
	'fSyncByObject-function that waiting to expected object to appear on the screen 
    If fSyncByObject("fBusLogin","TG","Create Trunk","WebElement","TrunkAttributesPortlet",90)= False Then 
		fBusLogin = False 
		Exit Function
	End If
    
    'Navigate to expected page
	If GlobalDictionary("LOGIN_TO_PAGE") <> "" Then
        
		Browser("TG").Page("All Pages").Link("Trunks").FireEvent("OnMouseOver")
		Select Case lcase(GlobalDictionary("LOGIN_TO_PAGE")) 
			Case "search"
				Browser("TG").Page("All Pages").Link("Search Trunk Groups").Click
			Case "create trunk" 
				Browser("TG").Page("All Pages").Link("Create Trunk Group").Click
		End Select

		'Sync to load expected page
		If fSyncByObjectForPage(GlobalDictionary("LOGIN_TO_PAGE"))= False Then 
			fBusLogin = False 
			Exit Function
		End If
	End If

	fBusLogin = True
	Call fReport("Login","Login to page " & GlobalDictionary("LOGIN_TO_PAGE"),"PASS","Login passed successfuly",0) 

End Function
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fCreateTrunkValidFlow
' Description: Valid flow of new trunk creation
' Parameters: 
' Return value: Success - True, Failure - False
' Example:
'---------------------------------------------------------------------------
Public Function fBusCreateTrunkValidFlow()

	Dim sReturnValue

'	If fBusLogin() <> True Then
'		fBusCreateTrunkValidFlow = False
'		Call fReport("fBusCreateTrunkValidFlow","fBusLogin","FAIL","Login failed",0)
'		Exit Function
'	End If
    
	'Create clsTrunk object
	Set newTrunk = [new newClsTrunk]

	
	Call fReport("Fill fields","","HEADER","",2)
'	'Fill iCentral_Company combo
'	Call fSelectRandomValueFromCombobox("TG","Create Trunk",iCentral_Company,"html tag:=TABLE", MAX, sReturnValue)
'	While Browser("TG").Page("Create Trunk").WebElement("Company combo").WebEdit("class:=.*v-filterselect-input.*").GetRoProperty("value") = ""
'		Call fSelectRandomValueFromCombobox("TG","Create Trunk", iCentral_Company, "html tag:=TABLE", MAX, sReturnValue)
'	Wend
'	newTrunk.sCompany = Left(sReturnValue,instr(1,sReturnValue,"-")-1)
'	newTrunk.iCompanyID = Right(sReturnValue, Len(sReturnValue) - instrRev(sReturnValue,"-"))

    'Fill Trunk Definition portlet
	If fGuiFillTrunkDefinition() <> True Then
		fBusCreateTrunkValidFlow = False
		Call fReport("fBusCreateTrunkValidFlow","fGuiFillTrunkDefinition","FAIL","Fill Trunk Definition portlet failed",0)
		Exit Function
	Else
		Call fReport("fBusCreateTrunkValidFlow","fGuiFillTrunkDefinition","PASS","Fill Trunk Definition portlet passed",0)
	End If

	'Fill Company overview portlet
	Wait 5
	If fGuiFillCompanyOverview() <> True Then
		fBusCreateTrunkValidFlow = False
		Call fReport("fBusCreateTrunkValidFlow","fGuiFillCompanyOverview","FAIL","Fill Company Overview portlet failed",0)
		Exit Function
	Else
		Call fReport("fBusCreateTrunkValidFlow","fGuiFillCompanyOverview","PASS","Fill Company Overview portlet passed",0)
	End If

	'Fill Base Attributes portlet
	If fGuiFillBaseAttributes() <> True Then
		fBusCreateTrunkValidFlow = False
		Call fReport("fBusCreateTrunkValidFlow","fGuiFillBaseAttributes","FAIL","Fill Base Attributes portlet failed",0)
		Exit Function
	Else
		Call fReport("fBusCreateTrunkValidFlow","fGuiFillBaseAttributes","PASS","Fill Base Attributes portlet passed",0)
	End If


	Call fReport("Verify correct trunk id population","","HEADER","",2)
	'Trunk id - Verification
	If fGuiCheckTrunkID() <> True Then
		fBusCreateTrunkValidFlow = False
		Call fReport("fBusCreateTrunkValidFlow","fGuiCheckTrunkID","FAIL","Trunk id verification failed",0)
		Exit Function
	End If

	Call fReport("Save","","HEADER","",2)
	'Save
'	hwnd = Browser("TG").GetROProperty("hwnd")
'	Window("hwnd:=" & hwnd).Type micPgUp
'	Browser("TG").Page("Create Trunk").Link("Create Trunk").Click
'	If fSyncByObjectForPage("Create Trunk") <> True Then
'		fBusCreateTrunkValidFlow = False
'		Exit Function
'	End If
'	wait(3)
	Browser("TG").Page("Create Trunk").WebElement("Save button").Click

	'Check If notification appear
	If fCheckNotification("fBusCreateTrunkValidFlow") = False Then
		fBusCreateTrunkValidFlow = False
		Exit Function
	End If

	'Sync to Editor page
	If fSyncByObjectForPage("Editor") <> True Then
		Call fReport("fBusCreateTrunkValidFlow","Save and navigate to editor" & sPage,"FAIL","Editor page was not opened",0)
		fBusCreateTrunkValidFlow = False
		Exit Function
	End If

	Call fReport("DB verification","","HEADER","",2)
	'DB verification - Verify that the new trunk details saved correctly on DB
	If fBusCreateDBVerification() <> True Then
		fBusCreateTrunkValidFlow = False
		Call fReport("fBusCreateTrunkValidFlow","fBusCreateDBVerification","FAIL","Creation DB verification failed",0)
		Exit Function
	End If

'	Call fReport("UI verification o Editor page","","HEADER","",2)
'	'Verify on Editor page
'	Call fBusCheckEditorPopulation()
	
	fBusCreateTrunkValidFlow = True

End Function 
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fBusCreateDBVerification
' Description: Verify that the new trunk details saved correctly on DB
' Parameters: 
' Return value: Success - True, Failure - False
' Example:
'---------------------------------------------------------------------------
Public Function fBusCreateDBVerification()

	If fGuiTrunkIdentifiersDB() <> True Then
		fBusCreateDBVerification = False
		Call fReport("fBusCreateDBVerification","Check creation on IDENTIFIERS table","FAIL","Trunk was NOT saved correctly on IDENTIFIERS",0)
		Exit Function
	Else
		Call fReport("fBusCreateDBVerification","Check creation on IDENTIFIERS table","PASS","Trunk was saved correctly on IDENTIFIERS",0)
	End If

	If fGuiTrunkOwnerDB() <> True Then
		fBusCreateDBVerification = False
		Call fReport("fBusCreateDBVerification","Check creation on IDENTIFIER_OWNER table","FAIL","Trunk was NOT saved correctly on IDENTIFIER_OWNER",0)
		Exit Function
	Else
		Call fReport("fBusCreateDBVerification","Check creation on IDENTIFIER_OWNER table","PASS","Trunk was saved correctly on IDENTIFIER_OWNER",0)
	End If

	If fGuiTrunkAttributes(newTrunk) <> True Then
		fBusCreateDBVerification = False
		Call fReport("fBusCreateDBVerification","Check creation on TRUNK_ATTRIBUTES table","FAIL","Trunk was NOT saved correctly on TRUNK_ATTRIBUTES",0)
		Exit Function
	Else
		Call fReport("fBusCreateDBVerification","Check creation on TRUNK_ATTRIBUTES table","PASS","Trunk was saved correctly on TRUNK_ATTRIBUTES",0)
	End If

	fBusCreateDBVerification = True
End Function 

'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fBusCreateFieldsDBVerification
' Description: Verify that the fields values correct (db verification)
' Parameters: 
' Return value: Success - True, Failure - False
' Example:
'---------------------------------------------------------------------------
Public Function fBusCreateFieldsDBVerification()

	Dim bFound
	bFound = True

	'Login
'	If fBusLogin() <> True Then
'		fBusCreateFieldsDBVerification = False
'		Call fReport("fBusCreateFieldsDBVerification","fBusLogin","FAIL","Login failed",0)
'		Exit Function
'	End If

	'SideBar
	Call fReport("Check SIDEBAR Fields VS DB","","HEADER","",2)
	If fGuiSideBarFields() <> True Then
		bFound = False
	Else
		Call fReport("fBusCreateFieldsDBVerification","Check SideBar Fields VS DB","PASS","Fields values match DB",0)
	End If

	'Company Overview
	Call fReport("Check COMPANY OVERVIEW Fields VS DB","","HEADER","",2)
	If fGuiCompanyOverviewFields() <> True Then
		bFound = False
	Else
		Call fReport("fBusCreateFieldsDBVerification","Check Company Overview Fields VS DB","PASS","Fields values match DB",0)
	End If

'	'Base attributes
'	Call fReport("Check BASE ATTRIBUTES Fields VS DB","","HEADER","",2)
'	If fGuiBaseAttributesFields("TG","Create Trunk") <> True Then
'		bFound = False
'	Else
'		Call fReport("fBusCreateFieldsDBVerification","Check Base attributes Fields VS DB","PASS","Fields types/values match DB",0)
'	End If

	'Results
	If bFound = False Then
		fBusCreateFieldsDBVerification = False
		Call fReport("fBusCreateFieldsDBVerification","Fields DB verification on Create screen","FAIL","Fields DB verification failed",0)
	Else
		fBusCreateFieldsDBVerification = True
	End If
End Function 
'---------------------------------------------------------------------------
'---------------------------------------------------------------------------
' Function name: fBusNewRMS
' Description: The function checks enabling and creation of RMS customer/vendor
' Parameters: 
' Return value: Success-True
' Example:
'---------------------------------------------------------------------------
Public Function fBusNewRMS()

	Dim sCompany

'	'Login
'	If fBusLogin() <> True Then
'		fBusNewRMS = False
'		Call fReport("fBusNewRMS","fBusLogin","FAIL","Login failed",0)
'		Exit Function
'	End If

	'Select company
	Call fSelectRandomValueFromCombobox("TG","Create Trunk",iCentral_Company,"html tag:=TABLE", MAX, sCompany)

	'Check enabling
	If fGuiNewRMS_Enabling(sCompany) = True Then
		Call fReport("fBusNewRMS","Check RMS customer/vendor enabling","PASS","RMS customer/vendor enabling-disabling is correct",0)
	Else
        Call fReport("fBusNewRMS","Create new RMS customer/Vendor","FAIL","Creation was not check because enabling-disabling verification failed",0)
		Exit Function
	End If

    'Create new RMS customer
	If fGuiNewRMS_Creation("Customer",sCompany) = True Then
		Call fReport("fBusNewRMS","Create new RMS customer","PASS","New RMS customer created successfully",0)	
	End If

	'Create new RMS vendor
	If fGuiNewRMS_Creation("Vendor",sCompany) = True Then
		Call fReport("fBusNewRMS","Create new RMS vendor","PASS","New RMS vendor created successfully",0)
	End If

	
   fBusNewRMS = True
End Function
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fBusColoFunctionality
' Description: The function checks all colo functionality
' Parameters: 
' Return value: Success-True
' Example:
'---------------------------------------------------------------------------
Public Function fBusColoFunctionality()

	Dim bCompanySeleced

'   	'--- Login
'	If fBusLogin() <> True Then
'		fBusColoFunctionality = False
'		Call fReport("fBusColoFunctionality","fBusLogin","FAIL","Login failed",0)
'		Exit Function
'	End If

	'--- Check colo code options when company is/isn't selected 
	Call fReport("fBusColoFunctionality","Check colo options when company is not selected","HEADER","",0)
	bCompanySeleced = False 'company is not selected 
	If fGuiColoOptions(bCompanySeleced) = True Then
		Call fReport("fBusColoFunctionality","Check colo options when company is not selected","PASS","All colo option are correct",0)
	Else
		fBusColoFunctionality = False
	End IF 

	Call fReport("fBusColoFunctionality","Check colo options when company is selected","HEADER","",0)
	bCompanySeleced = True 	'company is selected
	If fGuiColoOptions(bCompanySeleced) = True Then
		Call fReport("fBusColoFunctionality","Check colo options when company is selected","PASS","All colo option are correct",0)
	Else
		fBusColoFunctionality = False
	End IF 

	 '--- Check colo descriptor
	Call fReport("fBusColoFunctionality","Check colo descriptor population","HEADER","",0)
	If fGuiCheckColoDescriptor(REPEAT) = True Then
		Call fReport("fBusColoFunctionality","Check colo descriptor population","PASS","Colo description population and mandatory is correct",0)
	Else
		fBusColoFunctionality = False
	End IF 

'''''	'--- Check saving with 'null' descriptor
'''''	Call fReport("fBusColoFunctionality","Check saving with 'null' descriptor","HEADER","",0)
'''''	If fGuiNullColoDescriptor() = True Then
'''''		Call fReport("fBusColoFunctionality","Check saving with 'null' descriptor","PASS","Appropriate notification appears when trying to save colo with null descriptor",0)
'''''	Else
'''''		fBusColoFunctionality = False
'''''	End IF   

   fBusColoFunctionality = True
End Function
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fBusCheckEditorPopulation
' Description: The function checks correct population of editor page
' Parameters: trunk id
' Return value: Success-True, Failure-False
' Example:
'---------------------------------------------------------------------------
Public Function fBusCheckEditorPopulation()

	Dim ID
	fBusCheckEditorPopulation = True

	'Navigate to Editor page
	If IsEmpty(GlobalDictionary("TRUNK_ID")) Then 'Test editor population after creation
		ID = newTrunk.sTrunkID
	Else
		ID = GlobalDictionary("TRUNK_ID") 'Test editor population by quick search
		If fQuickSearch(ID,"Editor") <> True Then
            fBusCheckEditorPopulation = False
			Exit Function
		End If
	End If

	Call fReport("Check Editor page population for trunk <B>" & ID & "</B>","","HEADER","",2)

	'Create clsTrunk object
	Set TrunkData = [new newClsTrunk]
	TrunkData.sTrunkID = replace(ID,"-","")

	'Collect trunk's UI values and save it to the clsTrunk object
	If fGuiCollectTrunkDataFromUI(TrunkData, BaseAttributes & "','" & Media & "','" & Signaling) = True Then
		Call fReport("fBusCheckEditorPopulation","Collect Trunk's Data From UI","PASS","Trunk's data collection succeeded",0)
	Else
		fBusCheckEditorPopulation = False	
	End If

	'Compare UI and DB values

		'--SideBarAttributes
		If fGuiCheckTrunkSidebar(TrunkData) = True Then
			Call fReport("fBusCheckEditorPopulation","Compare trunk's data on UI and DB - of sidebar attributes","PASS","Comparing succeeded",0)
		Else
			fBusCheckEditorPopulation = False
		End If

		'--Other attributes
		If fGuiCheckTrunkAttributes(TrunkData, BaseAttributes & "','" & Media & "','" & Signaling) = True Then
			Call fReport("fBusCheckEditorPopulation","Compare trunk's data on UI and DB - of other attributes [Base/Media/Signaling]","PASS","Comparing succeeded",0)
		Else
			fBusCheckEditorPopulation = False
		End If

	'Summary
	If fBusCheckEditorPopulation = True Then
		Call fReport("fBusCheckEditorPopulation","Summary","PASS","Check editor page population for trunk id '" & ID & "' succeeded",0)
	Else
		Call fReport("fBusCheckEditorPopulation","Summary","FAIL","Check editor page population for trunk id '" & ID & "' failed",0)
	End If

End Function
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fBusEditTrunk
' Description: The function edit x attributes of trunk and verify saving on DB
' Parameters: trunk id
' Return value: Success-True, Failure-False
' Example:
'---------------------------------------------------------------------------
Public Function fBusEditTrunk()

	Dim sTrunkID, iNumToEdit, arrNewValues(),arrEditedAttributes()
	
	sTrunkID = GlobalDictionary("TRUNK_ID")
	If fQuickSearch(sTrunkID,"Editor") <> True Then
		fBusEditTrunk = False
		Exit Function
	End If
	
	iNumToEdit = cInt(GlobalDictionary("NUM_TO_EDIT"))
	ReDim arrNewValues(iNumToEdit-1)
	ReDim arrEditedAttributes(iNumToEdit-1)

	Call fReport("Check attributes editing for trunk <B>" & sTrunkID & "</B>","","HEADER","",2)

	Call fReport("Edit attributes on Editor page","","HEADER","",2)
	If fGuiEditAttributes(iNumToEdit, objRS, arrNewValues,arrEditedAttributes) = True Then
		Call fReport("fGuiEditAttributes","Editing " & iNumToEdit & " attributes on Editor page","PASS","Editing succeeded",0)
	Else
		Exit Function
	End If

	Call fReport("DB verification of the edited attributes","","HEADER","",2)
	If fGuiVerifyEditingOnDB(sTrunkID, arrNewValues,arrEditedAttributes) = True Then
		Call fReport("fGuiEditAttributes","Verify editing on DB","PASS","The edited values saved correctly on DB",0)
	End If

End Function
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fBusSearch
' Description: The function checks search results
' Parameters: 
' Return value: 
' Example:
'---------------------------------------------------------------------------
Public Function fBusSearch()

	Dim arrFilterData()
'   '--- Login
'	If fBusLogin() <> True Then
'		fBusSearch = False
'		Call fReport("fBusSearch","fBusLogin","FAIL","Login failed",0)
'		Exit Function
'	End If

	'Collect [default] filter data
	If fGuiCollectFilterData(arrFilterData) = False Then
		 Call fReport("fBusSearch","Collect filter data","FAIL", "Collect filter data failed",0)
		 Exit Function
	Else
		 Call fReport("fBusSearch","Collect filter data","PASS", "Collect filter data succeeded",0)
	End If

	'Build SQL query
	Call fGuiBuildFilterSQL(sFilterSQL, sResCountSQL, arrFilterData)
	Call fReport("fBusSearch","Build filter SQL","PASS", "Build filter SQL succeeded",0)
	
	'Apply search
	Browser("TG").Page("Search").WebElement("Apply").Click
	If fSyncByImage("TG", "All Pages", 60) <> True Then
		Call fReport("fBusSearch","Sync to refresh results table","FAIL", "Sync failed",0)
		Exit Function
	Else
		Call fReport("fBusSearch","Sync to refresh results table","PASS", "Sync succeded. Resutls table appears",0)
	End If

	'Compare results on table with query results (also compare num of results)
	If fGuiCompareSearchResults(sFilterSQL, sResCountSQL) = False Then
		 Call fReport("fBusSearch","Compare Search results","FAIL", "Compare Search results failed",0)
		 Exit Function
	Else
		 Call fReport("fBusSearch","Compare Search results","PASS", "Compare Search results succeeded",0)
	End If
	
End Function
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fBusQuickSearch
' Description: The function checks search results when searching by quick search
' Parameters: 
' Return value: 
' Example:
'---------------------------------------------------------------------------
Public Function fBusQuickSearch()

	Dim arrFilterData(), sFilterSQL, ResCountSQL, iResCount
   '--- Login
'	If fBusLogin() <> True Then
'		fBusSearch = False
'		Call fReport("fBusSearch","fBusLogin","FAIL","Login failed",0)
'		Exit Function
'	End If

	i = 1
	While GlobalDictionary("QUICK_SEARCH" & i) <> ""

		Call fReport("fBusQuickSearch","Quick search value: " & GlobalDictionary("QUICK_SEARCH" & i) ,"HEADER","",0)
		'Build SQL query
		Call fQuickSearchSQL(i, sFilterSQL, sResCountSQL, iResCount, sOneTrunkValue)
		Call fReport("fBusQuickSearch","Build filter SQL","PASS", "Build filter SQL succeeded",0)
		
		'Apply search
		If cLng(iResCount) = 1 Then
            sExpectedPage = "Editor"
		Else
			sExpectedPage = "Search"			
		End If

		'Navigate to expected page and check results
		Call fQuickSearch(GlobalDictionary("QUICK_SEARCH" & i), sExpectedPage) 
		wait 8
        Select Case sExpectedPage
            Case "Editor"
				Call Browser("TG").Page("Editor").WebElement("trunkID label").SetTOProperty("innerhtml",sOneTrunkValue)
				If fSyncByObject("fBusQuickSearch", "TG", "Editor", "WebElement", "trunkID label", 80) = True Then
					Call fReport("fBusQuickSearch","Navigate to Editor page","PASS","Editor page opened with the expected trunk id",0)
					Call fReport("fBusQuickSearch","Compare Search results","PASS", "Compare Search results succeeded",0)
				Else
					Call fReport("fBusQuickSearch","Compare Search results","FAIL", "Compare Search results failed (Editor page did not open with the expected trunk id)",0)
				End If

			Case "Search"
                If fSyncByObject("fBusQuickSearch", "TG", "Search", "WebEdit", "value:="&GlobalDictionary("QUICK_SEARCH" & i), 80) = True Then
					Call fReport("fBusQuickSearch","Navigate to Search page","PASS","Search page opened successfully",0)

                    Browser("TG").Page("Search").WebElement("Apply").Click
					wait 2
                    If fSyncByImage("TG", "All Pages", 80) <> True Then
						Call fReport("fBusSearch","Sync to refresh results table","FAIL", "Sync failed",0)
						Exit Function
					Else
						Call fReport("fBusSearch","Sync to refresh results table","PASS", "Sync succeded. Resutls table appears",0)
					End If
					'order by id key
					'msgbox "Please order table by id_key" '-- Remove when bug will be fixed

					'Compare results on table with query results (also compare num of results)
					If fGuiCompareSearchResults(sFilterSQL, sResCountSQL) = False Then
						 Call fReport("fBusQuickSearch","Compare Search results","FAIL", "Compare Search results failed",0)
						 Exit Function
					Else
						 Call fReport("fBusQuickSearch","Compare Search results","PASS", "Compare Search results succeeded",0)
					End If
				Else
					Call fReport("fBusQuickSearch","Compare Search results","FAIL", "Compare Search results failed",0)
				End If
        End Select
    
        i = i + 1
	Wend
	
End Function
'---------------------------------------------------------------------------

