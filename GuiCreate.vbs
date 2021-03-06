'===========================================================================
'========== This function library includes trunk creation tests ============
'===========================================================================
Public const BaseAttribueText = "test"

Public const Trunk_Type = "trunkTypeCombo"
Public const Site_Code = "siteCodeCombo"
Public const Network_Type = "networkTypeCombo"
Public const Direction = "directionCombo"
Public const iCentral_Company = "companyCombo"
Public const AQR_Carrier = "carrierCombo"
Public const RMS_Customer = "customerCombo"
Public const RMS_Vendor = "vendorCombo"
'Public const Colo_Combo = "colo-code-style"
Public const Colo_Combo = "ColoCodeCombo"
   

Public const ACTIVE = "Active"
Public const DEFAULT_TYPE = "-Select-"
'---------------------------------------------------------------------------
' Function name: fGuiFillCompanyOverview
' Description: The function fills randomized values on company overview fields and saves them to 'NewTrunk' (clsTrunk object).
' Parameters: 
' Return value: Success - True, Failure - False
' Example:
'---------------------------------------------------------------------------
Public Function fGuiFillCompanyOverview()

	Dim sReturnValue,sCompany

	'Fill iCentral_Company combo
	Call fSelectRandomValueFromCombobox("TG","Create Trunk",iCentral_Company,"html tag:=TABLE", MAX, sReturnValue)
	While Browser("TG").Page("Create Trunk").WebElement("Company combo").WebEdit("class:=.*v-filterselect-input.*").GetRoProperty("value") = ""
		Call fSelectRandomValueFromCombobox("TG","Create Trunk", iCentral_Company, "html tag:=TABLE", MAX, sReturnValue)
	Wend
	newTrunk.sCompany = Left(sReturnValue,instr(1,sReturnValue,"-")-1)
	newTrunk.iCompanyID = Right(sReturnValue, Len(sReturnValue) - instrRev(sReturnValue,"-"))
	Call fSyncByImage("TG", "Create Trunk", 10)

	'AQR Carrier
	'Call fSelectRandomValueFromCombobox("TG","Create Trunk",AQR_Carrier,"html tag:=TABLE",0,sReturnValue)		'Fill AQR_Carrier combo

	'RMS customer
    If fIsDisabled("TG","Create Trunk","WebElement","Customer combo") = False Then
	Browser("TG").Page("Create Trunk").WebElement("Customer combo").WebElement("customerButton").Click
        'Browser(sBrowser).Page(sPage).WebElement("innerhtml:=.*"& RMS_Customer &" .*","index:=0").WebElement("class:=.*v-filterselect-button.*").Click
		wait 3
		If Browser("TG").Page("Create Trunk").WebElement("table status").GetROProperty("innerhtml") = "" Then 
		'Create new RMS customer in case Empty List
			If fGuiNewRMS_Creation("Customer",sReturnValue) = True Then
				Call fReport("fBusNewRMS","Create new RMS customer","PASS","New RMS customer created successfully",0)	
			End If
		Else
    		Call fSelectRandomValueFromCombobox("TG","Create Trunk",RMS_Customer,"html tag:=TABLE",MAX,sReturnValue)        'Fill RMS_Customer combo
		End If

		'Customer Name
		If instr(1,sReturnValue,"-") > 0  Then
			newTrunk.sCustomer = Left(sReturnValue,instr(1,sReturnValue,"-")-1)
		Else              'in case that no '-' char in Cust Name (no short Name)
	        newTrunk.sCustomer = sReturnValue
		End If

		'Customer ID
		Browser("TG").Page("Create Trunk").WebElement("Customer combo").FireEvent ("OnMouseOver")
		sRmsID = Browser("TG").Page("Create Trunk").WebElement("class:=v-tooltip-text").GetROProperty("innertext")
		arr = Split(sRmsID,":")
		newTrunk.iCustomerID = Trim(mid(arr(1),1,InStr(1,arr(1),"Short")-1))
		
	End If

    'RMS vendor
	If fIsDisabled("TG","Create Trunk","WebElement","Vendor combo") = False Then
	Browser("TG").Page("Create Trunk").WebElement("Vendor combo").WebElement("vendorButton").Click
       'Browser(sBrowser).Page(sPage).WebElement("innerhtml:=.*"& RMS_Vendor &" .*","index:=0").WebElement("class:=.*v-filterselect-button.*").Click
		wait 3
		If Browser("TG").Page("Create Trunk").WebElement("table status").GetROProperty("innerhtml") = "" Then 
           'Create new RMS vendor in case Empty List
			If fGuiNewRMS_Creation("Vendor",sReturnValue) = True Then
				Call fReport("fBusNewRMS","Create new RMS vendor","PASS","New RMS vendor created successfully",0)
			End If
		Else
			Call fSelectRandomValueFromCombobox("TG","Create Trunk",RMS_Vendor,"html tag:=TABLE",MAX,sReturnValue) 'Fill RMS_Vendor combo
		End If

		'Vendor Name
		If instr(1,sReturnValue,"-") > 0  Then
			newTrunk.sVendor = Left(sReturnValue,instr(1,sReturnValue,"-")-1)
		Else               'in case that no '-' char in Vend Name (no short Name)
	        newTrunk.sVendor = sReturnValue
		End If

		'Vendor ID 
		Browser("TG").Page("Create Trunk").WebElement("Vendor combo").FireEvent ("OnMouseOver")
		sRmsID = Browser("TG").Page("Create Trunk").WebElement("class:=v-tooltip-text").GetROProperty("innertext")
		arr = Split(sRmsID,":")
		newTrunk.iVendorID = Trim(mid(arr(1),1,InStr(1,arr(1),"Short")-1))
		
	End If

	fGuiFillCompanyOverview = True
End Function

'---------------------------------------------------------------------------
' Function name: fGuiFillTrunkDefinition
' Description: The function fills all Trunk Definition fields
' Parameters: 
' Return value: Success - True, Failure - False
' Example:
'---------------------------------------------------------------------------
Public Function fGuiFillTrunkDefinition()

	Dim sReturnValue
	Call fSelectRandomValueFromCombobox("TG","Create Trunk",Trunk_Type,"html tag:=TABLE",0,sReturnValue)	'Fill Trunk Type combo
	newTrunk.sTrunkType = sReturnValue
	Call fSelectRandomValueFromCombobox("TG","Create Trunk",Site_Code,"html tag:=TABLE",0,sReturnValue)	  'Fill Site Code combo
	newTrunk.sSite = sReturnValue
	Call fGuiColoCode()  'Fill Colo Code and Description
	Call fSelectRandomValueFromCombobox("TG","Create Trunk",Network_Type,"html tag:=TABLE",0,sReturnValue)'Fill Network Type combo
	newTrunk.sNetworkType = sReturnValue
	Call fSelectRandomValueFromCombobox("TG","Create Trunk",Direction,"html tag:=TABLE",0,sReturnValue)	'Fill Direction combo
	newTrunk.sDirection = sReturnValue

	newTrunk.sStatus = "Pending Activation" 'Status

	fGuiFillTrunkDefinition = True
End Function

'---------------------------------------------------------------------------
' Function name: fGuiFillBaseAttributes
' Description: The function fills all base attributes fields
' Parameters: 
' Return value: Success - True, Failure - False
' Example:
'---------------------------------------------------------------------------
Public Function fGuiFillBaseAttributes()

	Dim sSQL, rc, iIndex

	sSQL = fGetQuery("Get_attributes_and_types_for_specific_attribute_group", BaseAttributes)
	rc = fDBGetRS ("TRUNKS", sSQL, objRS)
	If fCheckQueryResults("fGuiFillBaseAttributes","Get base attributes' attibutes", rc) <> True Then
		fGuiFillBaseAttributes = False
		Exit Function
	End If

	'Count attributes and init BaseAttributeArray 
	objRS.MoveFirst
	iRows = -1
	While Not objRS.EOF
		iRows = iRows + 1
		objRS.MoveNext
	Wend
	newTrunk.Init_BaseAttributeArray iRows
	
	objRS.MoveFirst
	iIndex = 0
	iRow = -1
	While Not objRS.EOF
		iRow = iRow + 1
		sType = objRS.Fields("TYPE_NAME").Value
		sName = objRS.Fields("ATTRIBUTE_NAME").Value

		If uCase(objRS.Fields("READ_ONLY").Value) = "N" Then
			If fFillField("TG", "Create Trunk", sType, sName, iIndex, iRow, sReturnValue) <> True Then
				fGuiFillBaseAttributes = False
				Exit Function
			End If
		End If
			
		iIndex = iIndex + 1
		objRS.MoveNext
	Wend

	fGuiFillBaseAttributes = True
End Function
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fFillField
' Description: The function fills a field on base attributes 
' Parameters: Browser, Page, Attribute Type, Attribute Name, iIndex, sReturnValue
' Return value: Success - True, Failure - False
' Example:
'---------------------------------------------------------------------------
Public Function fFillField(ByVal sBrowser, ByVal sPage, ByVal sType, ByVal sName, ByVal iIndex, ByVal iRow, ByRef sReturnValue)

	Dim iRnd

	Select Case lcase(sType)


		Case "text"
			Call fRandomize(1,20,iRnd)
			sReturnValue = BaseAttribueText & iRnd
			Browser(sBrowser).Page(sPage).WebEdit("Class:=.*field" & iIndex & " .*").Click
            Browser(sBrowser).Page(sPage).WebEdit("Class:=.*field" & iIndex & " .*").Set sReturnValue

		Case "longtext"
			Call fRandomize(1,20,iRnd)
			sReturnValue = BaseAttribueText & iRnd
			Browser(sBrowser).Page(sPage).WebEdit("Class:=.*textAreaAttribute" & iIndex & " .*").Click
			Browser(sBrowser).Page(sPage).WebEdit("Class:=.*textAreaAttribute" & iIndex & " .*").Set sReturnValue

		Case "date"
			sReturnValue = fFormatDate(Date) 
			Browser(sBrowser).Page(sPage).WebElement("outerhtml:=.*dateField" & iIndex & " .*","index:=0").WebEdit("Class:=.*datefield.*").Click
			Browser(sBrowser).Page(sPage).WebElement("outerhtml:=.*dateField" & iIndex & " .*","index:=0").WebEdit("Class:=.*datefield.*").Set sReturnValue

		Case "checkbox"
        	Call fRandomize(0,1,iRnd)
			wait 3
			If iRnd = 1 Then
				'Browser(sBrowser).Page(sPage).WebElement("innerhtml:=.*checkBox" & iIndex & " .*","index:=0").WebElement("type:=checkbox").Click
				Browser(sBrowser).Page(sPage).WebElement("outerhtml:=.*checkBox" & iIndex & " .*","index:=0").Click
			End If
			Wait 1
			If instr(1,Browser(sBrowser).Page(sPage).WebElement("outerhtml:=.*checkBox" & iIndex & " .*","index:=0").GetRoProperty("innerhtml"),"checked") <> 0 Then
				sReturnValue = "True"
			Else
				sReturnValue = "False"
			End If

		Case "list"
			sSQL = fGetQuery("Get_attribute_list_values_by_attribute_name", sName)
			rc = fDBGetRS ("TRUNKS", sSQL, objRS)
            If fCheckQueryResults("fFillField","Check if list is null", rc) = True Then 'Records returned by the query
				Call fSelectRandomValueFromCombobox("TG","All Pages","combo" & iIndex,"List values", MAX, sReturnValue)
				Browser(sBrowser).Page(sPage).WebEdit("Class:=.*field0 .*").Click
		    End If
	End Select

	If iRow <> -1 Then
		newTrunk.AddToBaseAttributesArray newTrunk, sName, sReturnValue, iRow
	End If

	fFillField = True
End Function
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fGuiCheckTrunkID
' Description: The function compare the UI trunk with the expected [DB] trunk id 
' Parameters: 
' Return value: Success - True, Failure - False
' Example:
'---------------------------------------------------------------------------
Public Function fGuiCheckTrunkID()

	Dim iSiteCode, iDirectionDigit, iNetworkDigit, iSequence, sTrunkDB, sTrunkUI
	
	'GetSiteCodeByName
	iSiteCode = fGetSiteCodeByName(newTrunk.sSite)
	If iSiteCode = False Then
		fGuiCheckTrunkID = False
		Exit Function
	End If

	'GetColo code - colo is saved on 'sColo' parameter

	'GetNetwokTypeDigit 
	iNetworkDigit = fGetAttributeDigitByValue (Trim(newTrunk.sNetworkType))
	If iNetworkDigit = False Then
		fGuiCheckTrunkID = False
		Exit Function
	End If

	'GetDirectionDigit
	iDirectionDigit = fGetAttributeDigitByValue (Trim(newTrunk.sDirection))
	If iDirectionDigit = False Then
		fGuiCheckTrunkID = False
		Exit Function
	End If

	newTrunk.sTrunkID = iSiteCode & "-" & newTrunk.sColo & "-" & iNetworkDigit & "-" & iDirectionDigit

	'GetSequence
	iSequence = fGetExpectedSequence(newTrunk.sTrunkID)
	If iSequence = False Then
		fGuiCheckTrunkID = False
		Exit Function
	End If
	newTrunk.sSequence = iSequence 

	'Save trunk id
	newTrunk.sTrunkID = newTrunk.sTrunkID & "-" & iSequence

	'Compare exected trunk id with UI trunk id
	sTrunkUI = Trim(Browser("TG").Page("Create Trunk").WebElement("Trunk ID label").GetROProperty ("innerhtml"))
	If sTrunkUI <> newTrunk.sTrunkID Then
		Call fReport("fGuiCheckTrunkID","Compare UI trunk id with expected [DB] trunk id","FAIL","UI trunk id is NOT equal to DB trunk id",0)
		fGuiCheckTrunkID = False
		Exit Function
	End If
    
	Call fReport("fGuiCheckTrunkID","Compare UI trunk id with expected [DB] trunk id","PASS","UI trunk id is equal to DB trunk id",0)

	fGuiCheckTrunkID = True
End Function
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fGuiTrunkIdentifiersDB
' Description: The function checks if the new trunk was saved correctly on IDENTIFIERS table
' Parameters: 
' Return value: Success - True, Failure - False
' Example:
'---------------------------------------------------------------------------
Public Function fGuiTrunkIdentifiersDB()

    'Check if new record added to IDENTIFIERS table
	sStrTrunkID = Replace(newTrunk.sTrunkID, "-", "")
    sSQL = fGetQuery("Get_trunk_data_from_IDENTIFIERS", sStrTrunkID)
	rc = fDBGetRS ("TRUNKS", sSQL, objRS)
	If fCheckQueryResults("fGuiTrunkIdentifiersDB","Check if record exist", rc) <> True Then 
		fGuiTrunkIdentifiersDB = False
		Exit Function
	End If

	'Verify that the record's status=Active, idType=1, date=today
	If objRS.Fields("status").Value <> ACTIVE OR cInt(objRS.Fields("id_type").Value) <> 1 OR cDate(objRS.Fields("active").Value) <> cDate(Date) Then
		fGuiTrunkIdentifiersDB = False
		Exit Function
	End If

	fGuiTrunkIdentifiersDB = True
End Function
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fGuiTrunkOwnerDB
' Description: The function checks if the new trunk was saved correctly on IDENTIFIER_OWNER table
' Parameters: 
' Return value: Success - True, Failure - False
' Example:
'---------------------------------------------------------------------------
Public Function fGuiTrunkOwnerDB()

    'Check if new record added to IDENTIFIERS table
   	sSQL = fGetQuery("Get_trunk_data_from_IDENTIFIER_OWNER", replace(newTrunk.sTrunkID,"-",""))
	rc = fDBGetRS ("TRUNKS", sSQL, objRS)
	If fCheckQueryResults("fGuiTrunkOwnerDB","Check if record exist", rc) <> True Then 
		fGuiTrunkOwnerDB = False
		Exit Function
	End If

	'Verify that the record's company, RMS customer and RMS vendor saved correctly
	If Trim(objRS.Fields("ICENTRAL_NAME").Value) <> Trim(newTrunk.sCompany) OR cLng(objRS.Fields("ICENTRAL_ID").Value) <> cLng(newTrunk.iCompanyID) Then
		Call fReport("fGuiTrunkOwnerDB","DB verification - iCentral company","FAIL","iCentral ID - DB: " & objRS.Fields("ICENTRAL_ID").Value & ", UI: " & newTrunk.iCompanyID & ".<br\> iCentral Name - DB: " & objRS.Fields("ICENTRAL_NAME").Value & ", UI: "& newTrunk.sCompany,0)
		fGuiTrunkOwnerDB = False 
		Exit Function 
	End If

	If IsNull(objRS.Fields("RMS_CUST_NAME").Value) = False Then
'		If objRS.Fields("RMS_CUST_NAME").Value <> newTrunk.sCustomer Then'OR cLng(objRS.Fields("RMS_CUST_ID").Value) <> cLng(newTrunk.iCustomerID) Then 	 
'			If Left(objRS.Fields("RMS_CUST_NAME").Value,instr(1,objRS.Fields("RMS_CUST_NAME").Value,"-")-1) <> newTrunk.sCustomer Then 'In case cust name contain more than one '-'
		If cLng(objRS.Fields("RMS_CUST_ID").Value) <> cLng(newTrunk.iCustomerID) Then 	 
				Call fReport("fGuiTrunkOwnerDB","DB verification - RMS customer","FAIL","RMS customer Name - DB: " & objRS.Fields("RMS_CUST_NAME").Value & ", UI: " & newTrunk.sCustomer,0)
				fGuiTrunkOwnerDB = False 
				Exit Function 
			'End If 
		End If
	End If

	If IsNull(objRS.Fields("RMS_VEND_NAME").Value) = False Then
'		If objRS.Fields("RMS_VEND_NAME").Value <> newTrunk.sVendor Then 'OR cLng(objRS.Fields("RMS_VEND_ID").Value) <> cLng(newTrunk.iVendorID) Then   
'			If Left(objRS.Fields("RMS_VEND_NAME").Value,instr(1,objRS.Fields("RMS_VEND_NAME").Value,"-")-1) <> newTrunk.sVendor Then 'In case vend name contain more than one '-'
		If cLng(objRS.Fields("RMS_VEND_ID").Value) <> cLng(newTrunk.iVendorID) Then   
				Call fReport("fGuiTrunkOwnerDB","DB verification - RMS vendor","FAIL","RMS vendor Name - DB: " & objRS.Fields("RMS_VEND_NAME").Value & ", UI: " & newTrunk.sVendor,0)
				fGuiTrunkOwnerDB = False 
				Exit Function 
		'	End If
		End If
	End If

	fGuiTrunkOwnerDB = True
End Function
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fGuiTrunkAttributes
' Description: The function check if the new trunk was saved correctly on TRUNK_ATTRIBUTES table
' Parameters: 
' Return value: Success - True, Failure - False
' Example:
'---------------------------------------------------------------------------
Public Function fGuiTrunkAttributes(ByVal objTrunk)

	Dim i, iCountOfRows, attributeName, attributeValue

    'Check if base attribues saved on TRUNK_ATTRIBUTES table
	sStrTrunkID = Replace(objTrunk.sTrunkID, "-", "")
   	sSQL = fGetQuery2Parameters("Get_Trunk's_attributes_and_values", sStrTrunkID, BaseAttributes)
	rc = fDBGetRS ("TRUNKS", sSQL, objRS)
	If fCheckQueryResults("fGuiTrunkAttributes","Check if records exist", rc) <> True Then 
		fGuiTrunkAttributes = False
		Exit Function
	End If


	For i = 0 to objTrunk.iBaseAttributesLength

		attributeName = objTrunk.arrBaseAttributes(i,0)
		attributeValue = objTrunk.arrBaseAttributes(i,1)

		If IsEmpty(attributeValue) = False Then

			str = objRS.Fields(0).Name & " Like '" & uCase(attributeName) & "' and " & objRS.Fields(1).Name & " Like '" & uCase(attributeValue) & "'"
			objRS.Filter = str
	
			'Verify that We have only one record
			iCountOfRows = 0
			objRS.MoveFirst
			While Not objRS.EOF
				iCountOfRows = iCountOfRows +1
				objRS.MoveNext
			Wend

			If iCountOfRows <> 1 Then
				Call fReport("fGuiTrunkAttributes","Compare UI and DB attribute values", "FAIL", "Atrribue: " & attributeName & ", Value: " & attributeValue & " - Failed", 0)
				fGuiTrunkAttributes = False
				Exit Function
			End If
    
		End If
		
	Next
   
	fGuiTrunkAttributes = True
End Function
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fGuiSideBarFields
' Description: The function check if sideBar comboboxes values match DB values
' Parameters: 
' Return value: Success - True, Failure - False
' Example:
'---------------------------------------------------------------------------
Public Function fGuiSideBarFields()

	Dim TrunkTypeValue, bFound
	bFound = False
    
	'Trunk Type
	TrunkTypeValue = Browser("TG").Page("Create Trunk").WebElement("TrunkType combo").WebEdit("TrunkType Value").GetROProperty ("Value")
	If lCase(TrunkTypeValue) <> lCase(DEFAULT_TYPE) Then
		Call fReport ("fGuiSideBarFields","Check trunk type values","FAIL","Trunk type value is not the defalut type " & lCase(DEFAULT_TYPE),0)
	End If

	'Site Code
	sSQL = fGetQuery("Get_site_code_combo_values", "")
	rc = fDBGetRS ("TRUNKS", sSQL, objRS)
	If fCheckQueryResults("fGuiSideBarFields","Check if records exist", rc) <> True Then 
		bFound = True
	End If
	If fCompareComboValuesVsDB("TG", "Create Trunk", Site_Code, "html tag:=TABLE", 0, objRS) <> True Then
		bFound = True
	Else
		Call fReport ("fGuiSideBarFields","Check site values","PASS","Site values match to DB values",0)
	End If 

	'Network Type
	sSQL = fGetQuery("Get_network_type_combo_values", "")
	rc = fDBGetRS ("TRUNKS", sSQL, objRS)
	If fCheckQueryResults("fGuiSideBarFields","Check if records exist", rc) <> True Then 
		bFound = True
	End If
	If fCompareComboValuesVsDB("TG", "Create Trunk", Network_Type, "html tag:=TABLE", 0, objRS) <> True Then
		bFound = True
	Else
		Call fReport ("fGuiSideBarFields","Check network type values","PASS","Network type values match to DB values",0)
	End If

	'Direction
	sSQL = fGetQuery("Get_direction_combo_values", "")
	rc = fDBGetRS ("TRUNKS", sSQL, objRS)
	If fCheckQueryResults("fGuiSideBarFields","Check if records exist", rc) <> True Then 
		bFound = True
	End If
	If fCompareComboValuesVsDB("TG", "Create Trunk", Direction, "html tag:=TABLE", 0, objRS) <> True Then
		bFound = True
	Else
		Call fReport ("fGuiSideBarFields","Check direction values","PASS","Direction values match to DB values",0)
	End If

	If bFound = True Then
		fGuiSideBarFields = False
	Else
		fGuiSideBarFields = True
	End If
End Function
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fGuiCompanyOverviewFields
' Description: The function check if company overview comboboxes values match DB values
' Parameters: 
' Return value: Success - True, Failure - False
' Example:
'---------------------------------------------------------------------------
Public Function fGuiCompanyOverviewFields()

	Dim bFound
	bFound = True

	'iCentral Company
'	sSQL = fGetQuery("Get_icentral_company_combo_values", "")
'	rc = fDBGetRS ("TRUNKS", sSQL, objRS)
' 	If fCheckQueryResults("fGuiCompanyOverviewFields","Check if records exist", rc) <> True Then 
'		bFound = False
'	End If
'	If fCompanyValuesVsDB("TG", "Create Trunk", "Company combo", COMPANY_MAX, objRS) <> True Then
'		bFound = False
'	Else
'		Call fReport ("fGuiCompanyOverviewFields","Check iCentral company values","PASS","ICetnral Company values match to DB values",0)
'	End If 

	'Set Direction combo value to 'Bidirectional' and select company
	Call fSelectDirectionValue("Bidirectional")
	Call fSelectRandomValueFromCombobox("TG","Create Trunk",iCentral_Company,"html tag:=TABLE", 10, sReturnValue)
	wait 1
	Call fSyncByImage("TG", "All Pages", 60)
	iCompanyID = Right(sReturnValue, Len(sReturnValue) - instrRev(sReturnValue,"-"))
    
	'RMS Customer
	sSQL = fGetQuery("Get_rms_customer_combo_values", iCompanyID)
	rc = fDBGetRS ("TRUNKS", sSQL, objRS)
 	If fCheckQueryResults("fGuiCompanyOverviewFields","Check if records exist", rc) <> True Then 
		bFound = False
	End If
	If fCompanyValuesVsDB("TG", "Create Trunk", "Customer combo", COMPANY_MAX, objRS) <> True Then
		bFound = False
	Else
		Call fReport ("fGuiCompanyOverviewFields","Check RMS Customer values","PASS","RMS Customer values match to DB values",0)
	End If 


	'RMS Vendor
	sSQL = fGetQuery("Get_rms_vendor_combo_values", iCompanyID)
	rc = fDBGetRS ("TRUNKS", sSQL, objRS)
 	If fCheckQueryResults("fGuiCompanyOverviewFields","Check if records exist", rc) <> True Then 
		bFound = False
	End If
	If fCompanyValuesVsDB("TG", "Create Trunk", "Vendor combo", COMPANY_MAX, objRS) <> True Then
		bFound = False
	Else
		Call fReport ("fGuiCompanyOverviewFields","Check RMS Vendor values","PASS","RMS Vendor values match to DB values",0)
	End If 
	
	If 	bFound = False Then
		fGuiCompanyOverviewFields = False
	Else
    	fGuiCompanyOverviewFields = True
	End If
End Function
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fGuiBaseAttributesFields
' Description: 	The function checks if all Base Attributes fields are displayed correctly according to their type. 
'				For lists attributes – checks also if combo boxes values match DB values. 
' Parameters: 
' Return value: Success - True, Failure - False
' Example:
'---------------------------------------------------------------------------
Public Function fGuiBaseAttributesFields(ByVal sBrowser, ByVal sPage)

	Dim rc, sSQL, iIndex, sType, bFound
	bFound = True

	sSQL = fGetQuery("Get_attributes_and_types_for_specific_attribute_group", BaseAttributes)
	rc = fDBGetRS ("TRUNKS", sSQL, objRS)
	If fCheckQueryResults("fGuiBaseAttributesFields","Check if records exist", rc) <> True Then 
		bFound = False
	End If

	iIndex = 0
	objRS.MoveFirst
	While not objRS.EOF

		sType = objRS.Fields("TYPE_NAME").Value
		sName = objRS.Fields("ATTRIBUTE_NAME").Value

		Select Case lcase(sType)
			Case "text"
				bExist = Browser(sBrowser).Page(sPage).WebEdit("Class:=.*field" & iIndex & ".*").Exist(0)
        	Case "longtext"
				bExist = Browser(sBrowser).Page(sPage).WebEdit("Class:=.*textAreaAttribute" & iIndex & ".*").Exist(0)
			Case "date"
				bExist = Browser(sBrowser).Page(sPage).WebElement("outerhtml:=.*dateField" & iIndex & ".*","index:=0").Exist(0)
			Case "checkbox"
				bExist = Browser(sBrowser).Page(sPage).WebElement("innerhtml:=.*checkBox" & iIndex & ".*","index:=0").Exist(0)
			Case "list"
                bExist = cStr(Browser(sBrowser).Page(sPage).WebElement("innerhtml:=.*combo"& iIndex &".*","index:=0").Exist(0))
				bListValues = cStr(fListWithValues(sName))

				'--------------------
				If bListValues = "True" Then 'Compare list values VS DB, if list has values
					sSQLlist =  fGetQuery("Get_attributes'_list_values", sName)
					rc = fDBGetRS ("TRUNKS", sSQLlist, objRSlist)
					bCompareListbValues = fCompareComboValuesVsDB("TG","Create Trunk", "combo" & iIndex , "html tag:=TABLE", DB_MAX, objRSlist)
					If bCompareListbValues <> True Then 'list values not match DB
						bFound = False
						Call fReport("fGuiBaseAttributesFields", "Compare list values VS DB", "FAIL", "Attribute '" & sName & "' - Values NOT match DB", 0)
					End If

					If Browser(sBrowser).Page(sPage).WebTable("html tag:=TABLE").Exist(1) = "True" Then   'If any list is open -> close
						Browser(sBrowser).Page(sPage).WebEdit("Class:=.*field0.*").Click
						'Wait 1 (sListDesc)
					End If
    			End If
				'--------------------

				If bListValues = bExist Then ' with values - appear / with no values - Not appear
					bExist = True
                Else ' with values - not appear / with no values - appear
					bExist = False
				End If 
		End Select

		If bExist = "False" Then
			bFound = False
			Call fReport("fGuiBaseAttributesFields","Check attribute's type and value","FAIL","Attribute - '" & sName & "', Type - " & sType &". Not found",0)
		End If

		iIndex = iIndex + 1
		objRS.MoveNext
	Wend


	If bFound = False Then
		fGuiBaseAttributesFields = False
	Else
		fGuiBaseAttributesFields = True
	End If

End Function
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fGuiNewRMS_Enabling
' Description: The function check RMS disabling/enabling according selection and New RMS creation.
' Parameters: 
' Return value: Success-True, Failure- False. Return the selected customer on 'sSelectedCompany'
' Example:
'---------------------------------------------------------------------------
Public Function fGuiNewRMS_Enabling(byRef sSelectedCompany)

	Dim bFound
	bFound = True

	'Verify RMS customer/vendor are disabled before selecting company
	'If Browser("TG").Page("Create Trunk").WebElement("Direction combo").WebEdit("DirectionValue").GetRoProperty("value") = "" Then
	If Browser("TG").Page("Create Trunk").WebElement("Direction combo").WebEdit("DirectionValue").GetRoProperty("value") = "-Select-" Then
		If fCheckDisabledAllRMS() <> True Then
			bfound = False
			Call fReport("fGuiNewRMS_Enabling","Check that RMS customer/vendor are disabled before selecting company","FAIL","RMS customer/vendor are NOT disabled",0)
		End If
	End If

	'Call fSelectRandomValueFromCombobox("TG","Create Trunk", iCentral_Company,"html tag:=TABLE", 10, sSelectedCompany)
	'Call fSelectRandomValueFromCombobox("TG","Create Trunk", iCentral_Company, "CompanyComboList", 10, sSelectedCompany)
	While Browser("TG").Page("Create Trunk").WebElement("Company combo").WebEdit("class:=.*v-filterselect-input.*").GetRoProperty("value") = ""
		'Call fSelectRandomValueFromCombobox("TG","Create Trunk", iCentral_Company, "html tag:=TABLE", 10, sSelectedCompany)
		Call fSelectRandomValueFromCombobox("TG","Create Trunk", iCentral_Company, "CompanyComboList", 10, sSelectedCompany)
	Wend
	
	'Verify RMS customer/vendor are disabled before selecting direction
'	If Browser("TG").Page("Create Trunk").WebElement("Direction combo").WebEdit("DirectionValue").GetRoProperty("value") = "" Then
	If Browser("TG").Page("Create Trunk").WebElement("Direction combo").WebEdit("DirectionValue").GetRoProperty("value") = "-Select-" Then
		If fCheckDisabledAllRMS() <> True Then
			bfound = False
			Call fReport("fGuiNewRMS_Enabling","Check that RMS customer/vendor are disabled before selecting direction","FAIL","RMS customer/vendor are NOT disabled",0)
		End If
	End If

	'Set Direction to 'Origination'
	Call fSelectDirectionValue("Origination") 'Expected: customer - enable, vendor - disable
	wait 3
    If fCheckDisabledCustomer_Vendor("Customer") <> False OR fCheckDisabledCustomer_Vendor("Vendor") <> True Then 		
		bfound = False
		Call fReport("fGuiNewRMS_Enabling","Check enabling according Direction = 'Origination'","FAIL","Expected: customer - enable, vendor - disable -> FAILED",0)
	End If 

	'Set Direction to 'Termination'
	Call fSelectDirectionValue("Termination") 'Expected: customer - disable, vendor - enable
	wait 3
    If fCheckDisabledCustomer_Vendor("Customer") <> True OR fCheckDisabledCustomer_Vendor("Vendor") <> False Then 		
		bfound = False
		Call fReport("fGuiNewRMS_Enabling","Check enabling according Direction = 'Termination'","FAIL","Expected: customer - disable, vendor - enable -> FAILED",0)
	End If 

	'Set Direction to 'Bidirectional'
	Call fSelectDirectionValue("Bidirectional") 'Expected: customer - enable, vendor - enable
	wait 3
    If fCheckDisabledCustomer_Vendor("Customer") <> False OR fCheckDisabledCustomer_Vendor("Vendor") <> False Then 		
		bfound = False
		Call fReport("fGuiNewRMS_Enabling","Check enabling according Direction = 'Bidirectional'","FAIL","Expected: customer - enable, vendor - enable -> FAILED",0)
	End If

	If bFound = False Then
		fGuiNewRMS_Enabling = False
	Else
		fGuiNewRMS_Enabling = True     
	End If
	
End Function
'--------------------------------------------------------------------------- 

'---------------------------------------------------------------------------
' Function name: fGuiNewRMS_Creation
' Description: 	The function verifies correct initial population of the RMS creation modal window.
'				The function creates new RMS customer/vendor and verifies creation. 
' Parameters: 	sRMS – Type of RMS to create: Customer or Vendor
'				sCompany – The selected iCentral company
' Return value: Success-True, Failure- False
' Example:
'---------------------------------------------------------------------------
Public Function fGuiNewRMS_Creation(ByVal sRMS, ByVal sCompany)

	Dim  newFullName, newShortName

	'Find expected initial data
	Dim sCompanyFullName, sCompanyShortName, sSourceNetwork

	Select Case lcase(sRMS)
		Case "customer"
			sRMS = "Customer"
		Case "vendor"
			sRMS = "Vendor"
	End Select

	'If notification appear -> Click to disappear
	If Browser("TG").Page("All Pages").WebElement("class:=.*v-Notification.*").Exist(0) = "True" Then
		Browser("TG").Page("All Pages").WebElement("class:=.*v-Notification.*").Click
		Wait 1
	End If

    
	'Open modal window, Sync to open
	Browser("TG").Page("Create Trunk").WebElement(sRMS &" New").Click
	If fSyncByObject("fGuiNewRMS_Creation - " & sRMS, "TG", "Create Trunk", "WebElement", "Create New RMS", 30) = False Then
		Call fReport("fGuiNewRMS_Creation - " & sRMS,"Sync to modal window to be open","FAIL","Window did not open",0)
		Exit function
	End If


    '---Fill Fields---
		Call fRandomize(100,999,iNum)'random 3-digits number
		newFullName = "test_" & iNum
		Call fRandomize(100,999,iNum)'random 3-digits number
		newShortName = "test_" & iNum

		Browser("TG").Page("Create Trunk").WebEdit("RMS FullName").Click
		Browser("TG").Page("Create Trunk").WebEdit("RMS FullName").Set newFullName
		wait(2)

		Browser("TG").Page("Create Trunk").WebEdit("RMS ShortName").Click
		Browser("TG").Page("Create Trunk").WebEdit("RMS ShortName").Set newShortName
		wait(2)
	
		'Apply and sync to close modal window
		Browser("TG").Page("Create Trunk").WebElement("Apply").Click
		i = 0
		While Browser("TG").Page("Create Trunk").WebElement("Create New RMS").exist = "True"
            i = i + 1
			If i = 30 Then
				Call fReport("fGuiNewRMS_Creation - " & sRMS,"Sync to modal window to be closed","FAIL","Window did not close",0)
				Exit Function
			End If
		Wend

		'--- Check if error notification appear --
		If Browser("TG").Page("All Pages").WebElement("ErrorNotification").Exist(3) = "True" Then
			sNotification = Browser("TG").Page("All Pages").WebElement("ErrorNotification").GetRoProperty ("innertext")
			Call fReport("fGuiNewRMS_Creation - " & sRMS,"Check if notification appears","FAIL","Following notification appears: " & sNotification, 0)
			Exit Function
		End If
            
'	---Check on UI and DB---
		'UI
		ValUI = Browser("TG").Page("Create Trunk").WebElement("innerhtml:=.*"& lcase(sRMS) &"Combo.*","index:=0").WebElement("class:=.*v-filterselect-input.*").GetRoProperty("value")
		'If instr(1, ValUI, newFullName & "-" & newShortName & "-") = 0 Then 'not found
		If instr(1, ValUI, newFullName & "-" & newShortName) = 0 Then 'not found
			Call fReport("fGuiNewRMS_Creation - " & sRMS, "Check creation on UI", "FAIL", "UI verification failed",0)
		Else 'found
			Call fReport("fGuiNewRMS_Creation - " & sRMS, "Check creation on UI", "PASS", "UI verification passed",0)
		End If

		'DB
		sSQL =  fGetQuery2Parameters("Find_" & lcase(sRMS) & "_in_mis", newFullName, newShortName)
		rc = fDBGetRS ("TRUNKS", sSQL, objRS)
		If fCheckQueryResults("fGuiNewRMS_Creation - " & sRMS,"Check if records exist", rc) <> True Then 'not found
        	Call fReport("fGuiNewRMS_Creation - " & sRMS, "Check creation on DB", "FAIL", "DB verification failed",0)
		Else 'found
			Call fReport("fGuiNewRMS_Creation - " & sRMS, "Check creation on DB", "PASS", "DB verification passed",0)
		End If
	
	fGuiNewRMS_Creation = True
End Function
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fGuiColoOptions
' Description: The function checks colo options before and after company selection
' Parameters: bCompanySeleced [If bCompanySeleced = true, Select company first]
' Return value: Success-True, Failure - False
' Example:
'---------------------------------------------------------------------------
Public Function fGuiColoOptions(ByVal bCompanySeleced)

	Dim bFound, sNextAvailable, ValUI, sSelectedCompany
	bFound = True

	'Select random company first if bCompanySeleced = True
	If bCompanySeleced = True Then
		Call fSelectRandomValueFromCombobox("TG", "Create Trunk", iCentral_Company,"html tag:=TABLE", COMPANY_MAX, sSelectedCompany)
    	While Browser("TG").Page("Create Trunk").WebElement("Company combo").WebEdit("class:=.*v-filterselect-input.*").GetRoProperty("value") = "" OR sSelectedCompany = "" OR isEmpty(sSelectedCompany)
			Call fSelectRandomValueFromCombobox("TG", "Create Trunk", iCentral_Company, "html tag:=TABLE",COMPANY_MAX, sSelectedCompany)
		Wend
	End If

	'-- Next available option --
'		'Get expected next available
'		sSQL = fGetQuery("Get_next_available_colo", "")
'		rc = fDBGetOneValue ("TRUNKS", sSQL, sNextAvailable)
'		If fCheckQueryResults("fGuiColoOptions - Get expected next available","Check if records exist", rc) <> True Then 
'			fGuiColoOptions = False
'			Exit Function
'		End If
'
'		'Check next available on main form and on modal window
'		  'Main Form
'		ValUI = Trim(Browser("TG").Page("Create Trunk").WebElement("coloLabel").GetRoProperty("innertext"))
'		If ValUI <> Trim(sNextAvailable) Then 
'			bFound = False
'			Call fReport("fGuiColoOptions","Check next available on the main form","FAIL","Failed. UI: '" & ValUI & "', Expected: " & sNextAvailable & "'",0)
'		End If
'		  'Modal window
'		Browser("TG").Page("Create Trunk").WebElement("AssignColo button").Click
'		If Browser("TG").Page("Create Trunk").WebElement("AssignColoHeaders").Exist(30) <> "True" Then
'			Call fReport("fGuiColoOptions","Sync to open colo window","FAIL","'Assign colo' window did not open",0)
'			fGuiColoOptions = False
'			Exit Function
'		End If
'		Call fSyncByImage("TG", "All Pages", 60) 
'		Wait 2
'
'		ValUI = Trim(Browser("TG").Page("Create Trunk").WebElement("ColoCode").WebEdit("ColoCodeValue").GetRoProperty("Value"))
'		If ValUI <> Trim(sNextAvailable) Then 
'			bFound = False
'			Call fReport("fGuiColoOptions","Check next available on the modal window","FAIL","Failed. UI: '" & ValUI & "', Expected: " & sNextAvailable & "'",0)
'		End If

	
	'-- Check open colos --
		Browser("TG").Page("Create Trunk").WebElement("AssignColo button").Click
		If Browser("TG").Page("Create Trunk").WebElement("AssignColoHeaders").Exist(30) <> "True" Then
			Call fReport("fGuiColoOptions","Sync to open colo window","FAIL","'Assign colo' window did not open",0)
			fGuiColoOptions = False
			Exit Function
		End If
		'Call fSyncByImage("TG", "All Pages", 60) 
		Wait 2

		'Open list
		Browser("TG").Page("Create Trunk").WebElement("ColoCodeCOmbo").WebElement("CoLoCodeButton").Click
		wait 1
		a = Browser("TG").GetROProperty("hwnd")	
		Window("hwnd:=" & a).Type micDel  
		

		'Compare list values VS DB
		sSQL = fGetQuery("Get_opened_colos", "")
		rc = fDBGetRS ("TRUNKS", sSQL, objRS)
		If fCheckQueryResults("fGuiColoOptions","Check if records exist", rc) <> True Then 
			bFound = False
		End If
		If fCompareComboValuesVsDB("TG", "Create Trunk", Colo_Combo, "coloOpensList", MAX, objRS) <> True Then
		'If fCompareComboValuesVsDB("TG", "Create Trunk", Colo_Combo, "AssignColo Table", MAX, objRS) <> True Then
			bFound = False
			Call fReport("fGuiColoOptions","Check open colos table","FAIL","comparing open colos VS DB failed.",0)
		End If

	'-- Check assigned colos --    
	Select Case bCompanySeleced
		Case False 'check table is empty
			If Browser("TG").Page("Create Trunk").WebTable("AssignColoTable").RowCount <> 0 Then 'table is not empty
				bFound = False
				Call fReport("fGuiColoOptions","Check assigned colos table when company is not selected","FAIL","Assigned colos records were found",0)
			End If
			Browser("TG").Page("Create Trunk").WebElement("Cancel Colo").Click
			wait 1

		Case True 'Check tables' values
			If fGuiCheckAssigned(sSelectedCompany,REPEAT) <> True Then 
				bFound = False
			End If 
	End Select


	If 	bFound = False Then
		fGuiColoOptions = False
	Else
    	fGuiColoOptions = True
	End If
End Function
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fGuiColoAssigned
' Description: The function compares VS DB the assigned colo that are displayed for a specific company
' Parameters: sCompanyName
' Return value: Success-True Failure - False
' Example:
'---------------------------------------------------------------------------
Public Function fGuiColoAssigned(ByVal sCompanyName)

	Dim bFound, sCompany, iColoNumberDB, sColoDescriptorDB, sColoDescriptorUI, iCounter, iRowsUI
	bFound = False
	sCompanyID = Right(sCompanyName, Len(sCompanyName) - instrRev(sCompanyName,"-"))
	
 	sSQL = fGetQuery("Get_assigned_colos", sCompanyID)
	rc = fDBGetRS ("TRUNKS", sSQL, objRS)

	If  rc = NO_RECORDS_FOUND Then 
		iRowCount = Browser("TG").Page("Create Trunk").WebTable("AssignColoTable").RowCount
		If iRowCount <> 0 Then
			Call fReport("fGuiColoAssigned","compare DB and UI assigned colos for company: " & sCompanyName,"FAIL","No records found on DB. " & iRowCount & " rows found on UI",0)
			fGuiColoAssigned = False
		Else
			Call fReport("fGuiColoAssigned","compare DB and UI assigned colos for company: " & sCompanyName,"PASS","There are no assigned colo for this company",0)
			fGuiColoAssigned = True	
		End If
		Exit Function
	End If

	If rc = False Then
		Call fReport("fGuiColoAssigned","compare DB and UI assigned colos for company: " & sCompanyName,"FAIL","DB connection / Query execution failed",0)
		fGuiColoAssigned = False
		Exit Function
	End If

	iCounter = 0
	While Not objRS.EOF
        iColoNumberDB = objRS.Fields(0).Value
		sColoDescriptorDB = objRS.Fields(1).Value

		iRow = Browser("TG").Page("Create Trunk").WebTable("AssignColoTable").GetRowWithCellText(iColoNumberDB)
		If iRow < 0 Then 'Colo was not found
        	bFound = True
			Call fReport("fGuiColoAssigned","compare DB and UI assigned colos for company: " & sCompanyName,"FAIL","Colo " & iColoNumberDB & " was not found in UI" ,0)
		End If
		sColoDescriptorUI = Trim(Browser("TG").Page("Create Trunk").WebTable("AssignColoTable").GetCellData(iRow,2))
		If  sColoDescriptorUI <> Trim(sColoDescriptorDB) Then 'Check colo descriptor
			bFound = True
			Call fReport("fGuiColoAssigned","compare DB and UI assigned colos for company: " & sCompanyName,"FAIL","Colo UI descriptor: " & sColoDescriptorUI & " is was not equal to DB descriptor: " & sColoDescriptorDB ,0)
		End If

		iCounter = iCounter + 1
		objRS.MoveNext
	Wend

	'Compare num of rows UI and DB
	iRowsUI = Browser("TG").Page("Create Trunk").WebTable("AssignColoTable").RowCount
	If  iRowsUI <> iCounter Then
		bFound = True
		Call fReport("fGuiColoAssigned","compare DB and UI assigned colos for company: " & sCompanyName,"FAIL","Rows number on UI and DB in not equal. [DB: " & iCounter & " rows, UI: " & iRowsUI & " rows]" ,0)
	End If

	If bFound = True Then
		fGuiColoAssigned = False
	Else
		Call fReport("fGuiColoAssigned","compare DB and UI assigned colos for company: " & sCompanyName,"PASS","All assigned colos displayed correctly",0)
		fGuiColoAssigned = True
	End If
	
End Function
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fGuiCheckAssigned
' Description: The function checks assigned colos for 'iRepeat' companies
' Parameters: sCompanyName, iReapet
' Return value: Success-True Failure - False
' Example:
'---------------------------------------------------------------------------
Public Function fGuiCheckAssigned(ByVal sCompanyName, ByVal iReapet)

	Dim bFound
	bFound = True

	'--- first
	If fGuiColoAssigned(sCompanyName) <> True Then
		bFound  = False
	End If

	'Close modal
	Browser("TG").Page("Create Trunk").WebElement("Cancel Colo").Click
	wait 1

	'--- Second to iReapet
 	For i = 2 to iReapet
        'Select company
    	Call fSelectRandomValueFromCombobox("TG", "Create Trunk", iCentral_Company,"html tag:=TABLE", COMPANY_MAX, sCompanyName)
        While Browser("TG").Page("Create Trunk").WebElement("Company combo").WebEdit("class:=.*v-filterselect-input.*").GetRoProperty("value") = ""
			Call fSelectRandomValueFromCombobox("TG","Create Trunk", iCentral_Company,"html tag:=TABLE", COMPANY_MAX, sSelectedCompany)
		Wend

		'Open modal
		Browser("TG").Page("Create Trunk").WebElement("AssignColo button").Click
		If Browser("TG").Page("Create Trunk").WebElement("AssignColoHeaders").Exist(30) <> "True" Then
			Call fReport("fGuiCheckAssigned","Sync to open colo window","FAIL","'Assign colo' window did not open",0)
			fGuiCheckAssigned = False
			Exit Function
		End If

		'check assigned
        If fGuiColoAssigned(sCompanyName) <> True Then
			bFound  = False
		End If

		'Close modal
		Browser("TG").Page("Create Trunk").WebElement("Cancel Colo").Click
		wait 1
	Next

	If bFound = False Then
		fGuiCheckAssigned = False
	Else
		fGuiCheckAssigned = True
	End If
End Function
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fGuiCheckColoDescriptor
' Description: The function verify correct colo descriptor population.
' Parameters: iReapet
' Return value: Success-True Failure - False
' Example:
'---------------------------------------------------------------------------
Public Function fGuiCheckColoDescriptor(ByVal iRepeat)

	Dim sColo, sDescriptorUI, sDescriptorDB, bFound
	bFound = True


	'Open modal window and colos list
	  'Modal window
		Browser("TG").Page("Create Trunk").WebElement("AssignColo button").Click
		If Browser("TG").Page("Create Trunk").WebElement("AssignColoHeaders").Exist(30) <> "True" Then
			Call fReport("fGuiCheckColoDescriptor","Sync to open colo window","FAIL","'Assign colo' window did not open",0)
			fGuiCheckColoDescriptor = False
			Exit Function
		End If
		Call fSyncByImage("TG", "All Pages", 60) 
		Wait 2

	   'Colos list
		'Browser("TG").Page("Create Trunk").WebElement("COLO Code").Click
		'Browser("TG").Page("Create Trunk").WebEdit("ColoCodeCombo").Click
		Browser("TG").Page("Create Trunk").WebElement("ColoCodeCOmbo").WebElement("CoLoCodeButton").Click
		If Browser("TG").Page("Create Trunk").WebElement("ColoCodeComboList").Exist(1) <> "True" Then
			Browser("TG").Page("Create Trunk").WebElement("ColoCodeCOmbo").WebElement("CoLoCodeButton").Click
		End If
		a = Browser("TG").GetROProperty("hwnd")
		Window("hwnd:=" & a).Type micDel  


	'-- Check correct population of the colo descriptor
	    a = Browser("TG").GetROProperty("hwnd")
	   For i = 0 to iRepeat  
        
		Call fSelectRandomValueFromCombobox("TG", "Create Trunk", Colo_Combo, "coloOpensList", 20, sColo)
		'Call fSelectRandomValueFromCombobox("TG", "Create Trunk", Colo_Combo, "ColoCodeComboList", 20, sColo) 
 

		'Get DB colo descriptor
		sSQL = fGetQuery("Get_descriptor_by_colo_name", sColo)
		rc = fDBGetOneValue ("TRUNKS", sSQL, sDescriptorDB)
		If rc = NO_RECORDS_FOUND Then
			sDescriptorDB = ""  
		End If

		'Get UI colo descriptor
		sDescriptorUI = Browser("TG").Page("Create Trunk").WebEdit("ColoDescriptor").GetROProperty ("value")

		'Compare UI and DB
        If Trim(sDescriptorUI) <> Trim(sDescriptorDB) Then
			bFound = False
			Call fReport("fGuiCheckColoDescriptor","Check colo descriptor population fro colo " & sColo,"FAIL","Mismatch. UI: '" & sDescriptorUI & "', DB: '" & sDescriptorDB & "'", 0)
		End If

		'Colos list
        'Browser("TG").Page("Create Trunk").WebElement("COLO Code").Click
		'Browser("TG").Page("Create Trunk").WebEdit("ColoCodeCombo").Click
		For j = 1 to 4
			Window("hwnd:=" & a).Type micBack  	
		Next

	  Next

	'-- Check errors when trying to save without colo descriptor

	If bFound = False Then
		fGuiCheckColoDescriptor = False
	Else
		fGuiCheckColoDescriptor = True 
	End If

	'Close modal
	Browser("TG").Page("Create Trunk").WebElement("Cancel Colo").Click
	wait 1

End Function
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fGuiNullColoDescriptor
' Description: The function checks that error notification appear when trying to save without colo descriptor
' Parameters: 
' Return value: Success-True Failure - False
' Example:
'---------------------------------------------------------------------------
Public Function fGuiNullColoDescriptor()

	'Set next available colo's descriptor null
	sSQL = fGetQuery("Set_next_available_colo_null", "")
	rc = fDBGetRS ("TRUNKS", sSQL, objRS)
	If rc <> True Then
		Call fReport("fGuiNullColoDescriptor","Set next available colo's descriptor null","FAIL","DB connenction / Query execution failed",0)
		fGuiNullColoDescriptor = False
		Exit Function
	End If
'	Browser("TG").Page("All Pages").Link("Sign Out").Click  'Sign Out
'	Wait 4
'	Call fBusLogin()'Sign In
	'msgbox "Stop - Please logut-login"
		
	'On modal window
	   'Open modal window
		Browser("TG").Page("Create Trunk").WebElement("AssignColo button").Click
		If Browser("TG").Page("Create Trunk").WebElement("AssignColoHeaders").Exist(30) <> "True" Then
			Call fReport("fGuiNullColoDescriptor","Sync to open colo window","FAIL","'Assign colo' window did not open",0)
			fGuiNullColoDescriptor = False
			Exit Function
		End If
		Call fSyncByImage("TG", "All Pages", 60) 
		Wait 2

		'Fill next available colo and click on 'Save'
		'Browser("TG").Page("Create Trunk").WebEdit("ColoCodeCombo").Set("")
		'Browser("TG").Page("Create Trunk").WebEdit("ColoCodeCombo").Click
		Browser("TG").Page("Create Trunk").WebElement("ColoCodeCOmbo").WebElement("CoLoCodeButton").Click
		a = Browser("TG").GetROProperty("hwnd")
		Window("hwnd:=" & a).Type micDwn
		Window("hwnd:=" & a).Type micDwn
		wait 1
		Window("hwnd:=" & a).Type micReturn
		wait 2 
		Browser("TG").Page("Create Trunk").WebEdit("ColoDescriptor").Set("") 
		Browser("TG").Page("Create Trunk").WebElement("Save Colo").Click

		'check If notification appear
		If Browser("TG").Page("All Pages").WebElement("Success_Notification").exist(3) <> "True"  Then 'Notifiction did not appear
			Call fReport("fGuiNullColoDescriptor","Trying to save with null descriptor on the modal window","FAIL","Notification did not appear",0)
			fGuiNullColoDescriptor = False
			Exit Function
		Else 'notification appeared -> Close notification and window
			Browser("TG").Page("All Pages").WebElement("Success_Notification").Click
			wait 1
			Browser("TG").Page("Create Trunk").WebElement("Cancel Colo").Click
			wait 1
		End If
        
	'On main form
		Browser("TG").Page("Create Trunk").WebElement("Save button").Click
		'check If notification appear
		If Browser("TG").Page("All Pages").WebElement("Success_Notification").exist(3) <> "True"  Then 'Notifiction did not appear
			Call fReport("fGuiNullColoDescriptor","Trying to save with null descriptor on the main form","FAIL","Notification did not appear",0)
			fGuiNullColoDescriptor = False
			Exit Function
		Else 'notification appeared -> Close notification and window
			Browser("TG").Page("All Pages").WebElement("Success_Notification").Click
			wait 1
			Browser("TG").Page("Create Trunk").WebElement("Cancel Colo").Click
			wait 1
       	End If		

	fGuiNullColoDescriptor = True
End Function
'---------------------------------------------------------------------------
'---------------------------------------------------------------------------
' Function name: fGuiColoCode
' Description: The function Extracts one Colo Code value frome DB
' Parameters: 
' Return value: Success-True Failure - False
' Example:
'---------------------------------------------------------------------------
Public Function fGuiColoCode()

	 Dim rc
	'Open colo code window
	   Browser("TG").Page("Create Trunk").WebElement("AssignColo button").Click
	If Browser("TG").Page("Create Trunk").WebElement("AssignColoHeaders").Exist(30) <> "True" Then
		Call fReport("fGetColoDesc","Sync to open colo window","FAIL","'Assign colo' window did not open",0)
		fGetColoDesc = False
		Exit Function
	End If
    'fill colo code specific value frome DB
	 sSQL = fGetQuery("Get_opened_colos","")
	'select one colo code 
	 sSQL = "select * from (" & sSQL & ") where rownum = 1"

	 rc = fDBGetOneValue("TRUNKS",sSQL,sColo)
     If rc <> False Then
         	  fGuiColoCode = True
	 Else
			  fGuiColoCode = False
	 End If
	 'Browser("TG").Page("Create Trunk").WebEdit("ColoCodeCombo").Click
	 Browser("TG").Page("Create Trunk").WebElement("ColoCodeCOmbo").WebElement("CoLoCodeButton").Click
	 a = Browser("TG").GetROProperty("hwnd")
	 a = Browser("TG").GetROProperty("hwnd")
	 Window("hwnd:=" & a).Type micDwn
     Window("hwnd:=" & a).Type micReturn


	 'Browser("TG").Page("Create Trunk").WebEdit("ColoCodeCombo").Set(sColo)
	 newTrunk.sColo = sColo
'	 If newTrunk.sColo  Then
'	 End If
	 newTrunk.sColoDesc = fGetColoDesc(newTrunk.sColo)
	 'Close modal
	 Browser("TG").Page("Create Trunk").WebElement("Save Colo").Click
   	 wait 1
End Function	
