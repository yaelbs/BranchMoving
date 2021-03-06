
'===========================================================================
'=========== This function library includes trunk editing tests ============
'===========================================================================

'---------------------------------------------------------------------------
' Function name: fGuiCollectTrunkDataFromUI
' Description: The function collects trunk's data that populated on UI [on editor page] 
' Parameters: 	objTrunk - Output parameter to return all trunk's collected data,
'				attributesGroup - Name of attribute group(s) to collect their data (in additional to SideBar) 
' Return value: Success - True, Failure - False
' Example:
'---------------------------------------------------------------------------
Public Function fGuiCollectTrunkDataFromUI(ByRef objTrunk, ByVal attributesGroup)

	Dim sSQL, rc, bFound,iRows

	'Collect sidebar data
	objTrunk.sTrunkType = Trim(Browser("TG").Page("Editor").WebElement("TrunkType label").GetROProperty("innertext"))
	objTrunk.sNetworkType = Trim(Browser("TG").Page("Editor").WebElement("NetworkType label").GetROProperty("innertext"))
	objTrunk.sSite = Trim(Browser("TG").Page("Editor").WebElement("Site label").GetROProperty("innertext"))
	objTrunk.sDirection = Trim(Browser("TG").Page("Editor").WebElement("Direction label").GetROProperty("innertext"))
	objTrunk.sSourceNetwork = Trim(Browser("TG").Page("Editor").WebElement("SourceNetwork label").GetROProperty("innertext"))
	objTrunk.sColo = Trim(Browser("TG").Page("Editor").WebElement("ColoCode label").GetROProperty("innertext"))
	objTrunk.sColoDesc = Trim(Browser("TG").Page("Editor").WebEdit("ColoDescriptor").GetROProperty("value"))
	objTrunk.sStatus = Trim(Browser("TG").Page("Editor").WebElement("Status Combo").WebEdit("class:=.*v-filterselect-input.*").GetROProperty("value"))

	'Collect other attributes (of the 'attributesGroup')
    sSQL = fGetQuery("Get_attributes_and_types_for_specific_attribute_group", attributesGroup)
	rc = fDBGetRS ("TRUNKS", sSQL, objRS)
	If fCheckQueryResults("fGuiCollectTrunkDataFromUI","Get " & attributesGroup & " attributes", rc) <> True Then
		fGuiCollectTrunkDataFromUI = False
		Exit Function
	End If


	'Count attributes and init AttributeArray 
	objRS.MoveFirst
	iRows = -1
	While Not objRS.EOF
		iRows = iRows + 1
		objRS.MoveNext
	Wend
	objTrunk.Init_AttributesArray iRows
	
	objRS.MoveFirst
	iRow = -1
    While Not objRS.EOF
		iRow = iRow + 1
		sType = objRS.Fields("TYPE_NAME").Value
		sName = objRS.Fields("ATTRIBUTE_NAME").Value

		'Navigate to attribute tab
		If fNavigateToTab("Editor",objRS.Fields("ATTRIBUTE_GROUP").Value) <> True Then
			Call fReport("fGuiCollectTrunkDataFromUI","Navigate to tab "& objRS.Fields("ATTRIBUTE_GROUP").Value,"FAIL","Navigation Failed",0)
		End If 

		'Get field index
		If fGetFieldIndex(objRS.Fields("ATTRIBUTE_GROUP").Value,objRS.Fields("ATTRIBUTE_NAME").Value, iFieldInd) <> True Then  'Flag to sign if BaseAttribute query Or Media/Signaling query
				bFound = False
		End If
									
		'Get and save attribute value
		If fGetFieldValue("TG", "Editor", sType, sName, iFieldInd, iRow, objTrunk) <> True Then
			Call fReport("fGuiCollectTrunkDataFromUI","Get field value","FAIL","Get value of field '" & sName & "' failed",0)
			fGuiCollectTrunkDataFromUI = False
		End If
                	
		objRS.MoveNext
	Wend

	fGuiCollectTrunkDataFromUI = True
End Function
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fGetFieldValue
' Description: The function gets field value and enters it into clsTrunk object's attributes array 
' Parameters: 	sBrowser, sPage, sName – Parameter to describe the object,
'				sType – Type of object: text/date/checkbox/list etc,
'				iIndex – Index of the field,
'				objTrunk – Output value.
' Return value: Success - True, Failure - False
' Example:
'---------------------------------------------------------------------------
Public Function fGetFieldValue(ByVal sBrowser, ByVal sPage, ByVal sType, ByVal sName, ByVal iIndex, ByVal iRow, ByRef objTrunk)

	Dim sValue

	Select Case lcase(sType)
		Case "text"
            sValue = Trim(Browser(sBrowser).Page(sPage).WebEdit("Class:=.*field" & iIndex & " .*").GetRoProperty("Value"))

		Case "longtext"
			sValue =Browser(sBrowser).Page(sPage).WebEdit("Class:=.*textAreaAttribute" & iIndex & " .*").GetRoProperty("Value")

		Case "date"
			sValue = Browser(sBrowser).Page(sPage).WebElement("outerhtml:=.*dateField" & iIndex & " .*","index:=0").WebEdit("Class:=.*datefield.*").GetRoProperty("Value")

		Case "checkbox"
			If instr(1,Browser(sBrowser).Page(sPage).WebElement("innerhtml:=.*checkBox" & iIndex & " .*","index:=0").GetRoProperty("innerhtml"),"checked") <> 0 Then
				sValue = "True"
			Else
				sValue = "False"
			End If

		Case "list"
			sSQL = fGetQuery("Get_attribute_list_values_by_attribute_name", sName)
			rc = fDBGetRS ("TRUNKS", sSQL, objRS)
            If fCheckQueryResults("fGetFieldValue","Check if list is null", rc) = True Then 'Records returned by the query
               sValue = Browser(sBrowser).Page(sPage).WebElement("innerhtml:=.*combo"& iIndex &" .*","index:=0").WebElement("class:=.*v-filterselect-input.*").GetRoProperty("Value")
		    End If
            		
	End Select

	If sValue = "-Empty-" or sValue = "-Select-" Then
		sValue = Empty
	End If

	objTrunk.AddToAttributesArray objTrunk, sName, sValue, iRow

	If err.Number = 0 Then
		fGetFieldValue = True
	Else
		fGetFieldValue = False
	End If
	
End Function
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fGuiCheckTrunkAttributes
' Description: The function compares the objTrunk attributes of attributeGroup to DB
' Parameters: 	objTrunk – clsTrunk object that contains trunks data that collected from UI.
'				attributesGroup - Name of attribute group(s) to collect their data (in additional to SideBar).
' Return value: Success - True, Failure - False
' Example:
'---------------------------------------------------------------------------
Public Function fGuiCheckTrunkAttributes(ByVal objTrunk, ByVal attributesGroup)

	Dim i, iCountOfRows, attributeName, attributeValue

	fGuiCheckTrunkAttributes = True

    'Compare UI and DB values
	sStrTrunkID = Replace(objTrunk.sTrunkID, "-", "")
   	sSQL = fGetQuery2Parameters("Get_Trunk's_attributes_and_values", sStrTrunkID, attributesGroup)
	rc = fDBGetRS ("TRUNKS", sSQL, objRS)
	If fCheckQueryResults("fGuiCheckTrunkAttributes","Check if records exist", rc) <> True Then 
		fGuiCheckTrunkAttributes = False
		Exit Function
	End If

	For i = 0 to objTrunk.iAttributesLength

		attributeName = objTrunk.arrAttributes(i,0)
		attributeValue = objTrunk.arrAttributes(i,1)

		str = objRS.Fields("ATTRIBUTE_NAME").Name & " Like '" & uCase(attributeName) & "' and " & objRS.Fields("ATTRIBUTE_VALUE").Name & " Like '" & uCase(attributeValue) & "'"
		objRS.Filter = str

		If IsEmpty(attributeValue) = False Then
			'If attribute is checkbox and value is 'false', The row may not be saved on DB.
			If lcase(fGetAttributeTypeByName(attributeName)) = "checkbox" and lcase(attributeValue) = "false" and objRS.EOF Then
				fGuiCheckTrunkAttributes = True
			Else
				'Verify that we have only one record
				iCountOfRows = 0
				objRS.MoveFirst
				While Not objRS.EOF
					iCountOfRows = iCountOfRows + 1
					objRS.MoveNext
				Wend
	
				If iCountOfRows <> 1 Then
					Call fReport("fGuiCheckTrunkAttributes","Compare UI and DB attribute values", "FAIL", "Atrribute: " & attributeName & ", Value: " & attributeValue & " - Comparing  failed", 0)
					fGuiCheckTrunkAttributes = False
				End If
			End If
		Else
			'Verify that no rows were found
			If Not objRS.EOF Then
				Call fReport("fGuiCheckTrunkAttributes","Compare UI and DB attribute values", "FAIL", "Atrribute: " & attributeName & ", Value: " & attributeValue & " - Attribute value was found only on DB (UI value is null)", 0)
				fGuiCheckTrunkAttributes = False
			End If
		End If
	Next
 	
End Function
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fGuiCheckTrunkSidebar
' Description: The function compares the objTrunk sidebar attributes vs DB
' Parameters: objTrunk – clsTrunk object that contains trunks data that collected from UI.
' Return value: Success - True, Failure - False
' Example:
'---------------------------------------------------------------------------
Public Function fGuiCheckTrunkSidebar(ByVal objTrunk)

	Dim sStrTrunkID, sSQL, rc, bFound,sSourceNetworkDB
	bFound = True

	'Compare UI and DB values for trunk's SideBar attributes
	sTrunkID = Replace(objTrunk.sTrunkID, "-", "")
   	sSQL = fGetQuery2Parameters("Get_Trunk's_attributes_and_values", sTrunkID, SideBar)
	rc = fDBGetRS ("TRUNKS", sSQL, objRS)
	If fCheckQueryResults("fGuiCheckTrunkSidebar","Check if records exist", rc) <> True Then 
		fGuiCheckTrunkSidebar = False
		Exit Function
	End If

    Call fFindAttributeOnDB(objRS,"TRUNK TYPE", objTrunk.sTrunkType, bFound)
	Call fFindAttributeOnDB(objRS,"COLO CODE", objTrunk.sColo, bFound)
	Call fFindAttributeOnDB(objRS,"COLO DESCRIPTOR", objTrunk.sColoDesc, bFound)
	Call fFindAttributeOnDB(objRS,"SITE", objTrunk.sSite, bFound)
	Call fFindAttributeOnDB(objRS,"NETWORK TYPE", objTrunk.sNetworkType, bFound)
	Call fFindAttributeOnDB(objRS,"DIRECTION", objTrunk.sDirection, bFound)
    Call fFindAttributeOnDB(objRS,"STATUS", objTrunk.sStatus, bFound)

	'Check source network population
	sSQL = fGetQuery("Get_trunk's_expected_source_network", objTrunk.sNetworkType)
	rc = fDBGetOneValue ("TRUNKS", sSQL, sSourceNetworkDB)
	If fCheckQueryResults("fGuiCheckTrunkSidebar - Get expected source network","Check if records exist", rc) <> True Then 
		fGuiCheckTrunkSidebar = False
		Exit Function
	End If
	If lcase(Trim(sSourceNetworkDB)) <> lcase(Trim(objTrunk.sSourceNetwork)) Then
		Call fReport("fGuiCheckTrunkSidebar","Compare UI and DB  values of source network [on sideBar]", "FAIL", "Comparing failed. Expected[DB]: " & sSourceNetworkDB & ", Actual[UI]: " & objTrunk.sSourceNetwork, 0)
		bFound = False
	End If

    'Summary
	If bFound = False Then
		fGuiCheckTrunkSidebar = False
	Else
		fGuiCheckTrunkSidebar = True
	End If

End Function
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fFindAttributeOnDB
' Description: The function checks if an attribute & value exist in DB (objRS object)
' Parameters: 	objRS - RS object to search the attribute & value in.
' 				sAttributeName, sAttributeValue - attribute & value to search in objRS
' 				bFound - Output value.
' Return value: Success - True, Failure - False, 
'				bFound - Returns the result - 'True' is found and 'False' if not.
' Example:
'---------------------------------------------------------------------------
Public Function fFindAttributeOnDB(ByVal objRS, ByVal sAttributeName, ByVal sAttributeValue, ByRef bFound)

	str = objRS.Fields("ATTRIBUTE_NAME").Name & " Like '" & sAttributeName & "' and " & objRS.Fields("ATTRIBUTE_VALUE").Name & " Like '" & uCase(sAttributeValue) & "'"
	objRS.Filter = str
	'Verify that we have only one record
	iCountOfRows = 0
	objRS.MoveFirst
	While Not objRS.EOF
		iCountOfRows = iCountOfRows + 1
		objRS.MoveNext
	Wend

	If iCountOfRows = 0 and lcase(sAttributeValue) = "false" Then
		fFindAttributeOnDB = True 'It's OK if checkbox attribute with false value does not appear on DB (it wasn't updated)
	Else 
		If iCountOfRows <> 1 Then
			Call fReport("fFindAttributeOnDB","Compare UI and DB attribute values", "FAIL", "Atrribute: " & sAttributeName & ", Value: " & sAttributeValue & " - Comparing  failed", 0)
			bFound = False
			fFindAttributeOnDB = False
		End If
	End If

    fFindAttributeOnDB = True

End Function
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fGuiEditAttributes
' Description: The function edits iNumToEdit randomized attributes on Editor page and saves the new values to an array
' Parameters: 	iNumToEdit - Number of attributes to be edited.
'				objRS - Output parameter. RS object contains the randomized attributes.
'				arrNewValues, arrEditedAttributes - Output parameters. Arrayes to save the edited attributes names & and new values.
' Return value: Success - True, Failure - False
' Example:
'---------------------------------------------------------------------------
Public Function fGuiEditAttributes(ByVal iNumToEdit, ByRef objRS, ByRef arrNewValues, ByRef arrEditedAttributes)

	Dim sSQL, rc, iIndex, sReturnValue,bFound
	fGuiEditAttributes = True

	sSQL = fGetQuery("Random_attributes_to_edit", iNumToEdit)
	rc = fDBGetRS ("TRUNKS", sSQL, objRS)
	If fCheckQueryResults("fGuiEditAttributes - Random attributes to edit","Check if records exist", rc) <> True Then 
		fGuiEditAttributes = False
		Exit Function
	End If


	iIndex = 0
    objRS.MoveFirst
	While Not objRS.EOF
		bFound = True
		sReturnValue = Empty

		'Sidebar attribute editing
		If lcase(objRS.Fields("ATTRIBUTE_GROUP").Value) = "sidebar" Then
			If fGuiEditSideBarAttribute(objRS.Fields("ATTRIBUTE_NAME").Value,sReturnValue) = False Then
				bFound = False
			End If
		Else

		'Other attribute editing
		If fNavigateToTab("Editor", objRS.Fields("ATTRIBUTE_GROUP").Value) <> True Then 
				bFound = False
				Else
					If fGetFieldIndex(objRS.Fields("ATTRIBUTE_GROUP").Value,objRS.Fields("ATTRIBUTE_NAME").Value, iFieldInd) <> True Then  'Flag to sign if BaseAttribute query Or Media/Signaling query
						bFound = False
					End If
					If fFillField("TG", "Editor", objRS.Fields("TYPE_NAME").Value, objRS.Fields("ATTRIBUTE_NAME").Value, iFieldInd , -1, sReturnValue) <> True Then 
							bFound = False										
					End If
				End If	
		End If
		

        'Save sReturnValue to the array
        arrEditedAttributes(iIndex) = objRS.Fields("ATTRIBUTE_NAME").Value
		arrNewValues(iIndex) = sReturnValue	
								
        If bFound = False Then
			Call fReport("fGuiEditAttributes","Attribute editing on UI fails","FAIL","Attribute: '" & objRS.Fields("ATTRIBUTE_NAME").Value & "' ["& objRS.Fields("TYPE_NAME").Value &"] of group '"& objRS.Fields("ATTRIBUTE_GROUP").Value &"'",0)
		Else
			Call fReport("fGuiEditAttributes","Attribute editing on UI succeeded","PASS","Attribute: '" & objRS.Fields("ATTRIBUTE_NAME").Value & "' ["& objRS.Fields("TYPE_NAME").Value &"] of group '"& objRS.Fields("ATTRIBUTE_GROUP").Value &"'. <br/> New Value: " & sReturnValue,0)
		End If

		iIndex = iIndex + 1
		objRS.MoveNext
	Wend

	'Save all changes	
	If fGuiEditAttributes = True Then
		Browser("TG").Page("Editor").WebElement("Save").Click
		If Browser("TG").Page("Editor").WebElement("class:=.*v-notification.*").Exist(5) = "True" Then
			Call fReport("fGuiEditAttributes","Save changes succeeded.","PASS","Following notification appear:<br/ ><b>" & Browser("TG").Page("Editor").WebElement("class:=.*v-notification.*").GetROProperty("innertext")& "<b/>",0)
		End If	
	End If

End Function
'---------------------------------------------------------------------------
'---------------------------------------------------------------------------
' Function name: fGuiEditSideBarAttribute
' Description: The function edits an attribute on SideBar portlet
' Parameters: 	sAttributeName - Name of SideBar attribute to be edited.
'				sReturnValue - Output parameter. Returns the new value of the edited attribute.
' Return value: Success - True, Failure - False
' Example:
'---------------------------------------------------------------------------
Public Function fGuiEditSideBarAttribute(ByVal sAttributeName, ByRef sReturnValue)

    fGuiEditSideBarAttribute = True

	Select Case lcase(sAttributeName)
		Case "activation date"
			sReturnValue = fFormatDate(Date) 
			Browser("TG").Page("Editor").WebElement("ActivationDate combo").WebEdit("ActivationDate value").Click
			wait 1
			Browser("TG").Page("Editor").WebElement("ActivationDate combo").WebEdit("ActivationDate value").Set sReturnValue

		Case "colo descriptor"
			sReturnValue = "Colo " & Browser("TG").Page("Editor").WebElement("ColoCode label").GetROProperty("innerhtml")
			Browser("TG").Page("Editor").WebEdit("ColoDescriptor").Click
			wait 1
			Browser("TG").Page("Editor").WebEdit("ColoDescriptor").Set sReturnValue
	End Select
	
End Function
'---------------------------------------------------------------------------

'---------------------------------------------------------------------------
' Function name: fGuiVerifyEditingOnDB
' Description: The function verifies that the edited attributes were saved correctly on DB
' Parameters: 	sTrunkID - Trunk Id of the edited trunk.
'				arrNewValues,arrEditedAttributes - Arrayes contains the edited attributes names & and new values.
' Return value: Success - True, Failure - False
' Example:
'---------------------------------------------------------------------------
Public Function fGuiVerifyEditingOnDB(ByVal sTrunkID, ByVal arrNewValues, ByVal arrEditedAttributes)

	Dim iIndex,bFound
	fGuiVerifyEditingOnDB = True

	sSQL = fGetQuery2Parameters("Get_Trunk's_attributes_and_values", sTrunkID, BaseAttributes & "','" & Media & "','" & Signaling & "','" & SideBar)
	rc = fDBGetRS ("TRUNKS", sSQL, objRSAttributes)
	If fCheckQueryResults("fGuiVerifyEditingOnDB","Check if records exist", rc) <> True Then 
		fGuiVerifyEditingOnDB = False
		Exit Function
	End If

	
    For iIndex = 0 to uBound(arrNewValues)
		bFound = True
	
		sAttributeName = uCase(arrEditedAttributes(iIndex))
		sAttributeValue = uCase(arrNewValues(iIndex))
		Call fFindAttributeOnDB(objRSAttributes, sAttributeName, sAttributeValue, bFound)
		If bFound = False Then
			'Call fReport("fGuiVerifyEditingOnDB","Verify attribute editing on DB - Following wasn't found on DB:","FAIL","Attribute: '" & sAttributeName & "', Value: '" & sAttributeValue & "'",0)
			fGuiVerifyEditingOnDB = False
		Else
			Call fReport("fGuiVerifyEditingOnDB","Verify attribute editing on DB - Following was found on DB:","PASS","Attribute: '" & sAttributeName & "', Value: '" & sAttributeValue & "'",0)
		End If
	
	Next

End Function
'---------------------------------------------------------------------------
''---------------------------------------------------------------------------
'' Function name: fReadFromFile
'' Description: The function read text from file and put it in objRS.
'' Parameters: objRS				
'' Return value: objRS - containse all attribute
'' Example:
''---------------------------------------------------------------------------
'Public Function fReadFromFile(byRef objRS)
'
'    Set objFs = CreateObject("scripting.filesystemobject")  
'                               
'	set objDbFile = createobject("adodb.connection")
'	sPath = "T:\Matrix-QA\QTP-Aoutomation\QTP\TG\Phase 2.5\STORAGE\file\"
'	objDbFile.connectionstring = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source="& sPath &";Extended Properties=""text;HDR=Yes;FMT=Delimited"";"
'	objDbFile.CursorLocation = 3
'	objDbFile.Open
'	
'	Set objRS = CreateObject("ADODB.recordset")
'	sSQL = "select * from file.txt"
'	Set objRS = objDbFile.Execute(sSQL)
'
'End Function
''----------------------------------------------------------------------------------
