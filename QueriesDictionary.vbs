Public Const SideBar = "SideBar"
Public Const BaseAttributes = "Base Attributes"
Public Const Signaling = "Signaling"
Public Const Media = "Media"

'----------------------------------------------------------------
' Function name: fCheckQueryResults
' Description: The function check the query results
' Parameters: sStepName, sStepDesc, rc
' Return value: Success - True, Failure - False
'----------------------------------------------------------------
Public Function fCheckQueryResults (ByVal sStepName, ByVal sStepDesc, ByVal rc)

	Dim sResult
    If rc = False Then					'DB connection failed /Ouery execution failed
		Call fReport(sStepName,sStepDesc,"FAIL","DB connection failed /Ouery execution failed",0)
		fCheckQueryResults = False
		Exit Function		
	ElseIf rc = NO_RECORDS_FOUND Then	'NO_RECORDS_FOUND
		Call fReport(sStepName,sStepDesc,"INFO","No records return by the query",1)
		fCheckQueryResults = False
		Exit Function
    End If

	fCheckQueryResults = True
End Function
'----------------------------------------------------------------
'----------------------------------------------------------------
' Function name: fGetQuery
' Description: The function reutrns sql query by query name. And replace parameter in query [optional]
' Parameters: sQueryName - Name on QueriesDictionary, [optional]sParamValue - parameter value 
' Return value: Success - SQL query
'----------------------------------------------------------------
Public Function fGetQuery (ByVal sQueryName, ByVal sParamValue)
	Dim sSQL

	sSQL = QueriesDictionary(sQueryName)
	If instr (1,sSQL, "<<parameter>>") > 0 Then
        sSQL = Replace(sSQL, "<<parameter>>",sParamValue)
	End If

	fGetQuery = sSQL
End Function
'----------------------------------------------------------------

'----------------------------------------------------------------
' Function name: fGetQuery2Parameters
' Description: The function reutrns sql query by query name. And replace parameter in query [optional]
' Parameters: sQueryName - Name on QueriesDictionary, [optional]sParamValue - parameter value 
' Return value: Success - True, Failure - False
'----------------------------------------------------------------
Public Function fGetQuery2Parameters (ByVal sQueryName, ByVal sParamValue1, ByVal sParamValue2)
	'Dim sSQL

	sSQL = QueriesDictionary(sQueryName)
	If instr (1,sSQL, "<<parameter1>>") > 0 Then
        sSQL = Replace(sSQL, "<<parameter1>>",sParamValue1)
	End If

	If instr (1,sSQL, "<<parameter2>>") > 0 Then
        sSQL = Replace(sSQL, "<<parameter2>>",sParamValue2)
	End If

	fGetQuery2Parameters = sSQL
End Function
'----------------------------------------------------------------
'----------------------------------------------------------------
' Function name: fGetQuery3Parameters
' Description: The function reutrns sql query by query name. And replace parameters in query [optional]
' Parameters: sQueryName - Name on QueriesDictionary, [optional]sParamValue - parameter value 
' Return value: Success - True, Failure - False
'----------------------------------------------------------------
Public Function fGetQuery3Parameters (ByVal sQueryName, ByVal sParamValue1, ByVal sParamValue2, ByVal sParamValue3)

	Dim sSQL

	sSQL = fGetQuery2Parameters(sQueryName,sParamValue1, sParamValue2)

	'sSQL = QueriesDictionary(sQueryName)
	If instr (1,sSQL, "<<parameter3>>") > 0 Then
        sSQL = Replace(sSQL, "<<parameter3>>",sParamValue3)
	End If

	fGetQuery3Parameters = sSQL
End Function

'----------------------------------------------------------------
'---------------------  Queries dictionary  ---------------------
'----------------------------------------------------------------
'NOTE! Parameters format is <<parameter>>
'----------------------------------------------------------------
Set QueriesDictionary = CreateObject("Scripting.Dictionary")

QueriesDictionary("Get_attributes_and_types_for_specific_attribute_group") = "" & _	
"select a.attribute_group, a.attribute_name, d.type_name, a.read_only " & _
"from ATTRIBUTE_TYPES a join data_types d on a.data_type_id = d.data_type_id " & _
"where a.attribute_group in('<<parameter>>') and a.hidden_field is  null " & _
"order by a.attribute_group, a.data_type_id, NLSSORT(a.attribute_name, 'NLS_SORT=BINARY')"
'-- Replace <<parameter>> with attribute group name

QueriesDictionary("Get_attribute_list_values_by_attribute_name") = "" & _
"select l.attribute_value " & _
"from ATTRIBUTE_LIST_VALUES l join ATTRIBUTE_TYPES a on l.attribute_type_id = a.attribute_type_id " & _
"where a.attribute_name like '<<parameter>>'"
'-- Replace <<parameter>> with attribute name

QueriesDictionary("Get_site_code_by_site_short_name") = "" & _
"select s.attribute_value as SITE_CODE " & _
"from Identifiers i join SITE_ATTRIBUTES s on i.id_key = s.id_key " & _
"where i.id_type = 3 and i.status = 'Active' and s.attribute_name = 'Site Code' and i.id_name like '<<parameter>>'"
'-- Replace <<parameter>> with site short name

QueriesDictionary("Get_attribute_digit_by_value") = "" & _
"select METADATA_VALUE as digit From ATTRIBUTE_METADATA " & _
"Where metadata_key like 'DIGIT_VALUE' and attribute_value like '<<parameter>>'"
'-- Replace <<parameter>> with attribute value


QueriesDictionary("Get_expected_sequence_by_first_9_trunk_digits") = "" & _
"select * from ( " & _
"  select id_name from Identifiers where id_type = 1 " & _ 
"  and id_name like '<<parameter>>%' " & _ 
"  order by id_name desc " & _
") where rownum = 1"
'-- Replace <<parameter>> with  first 9 trunk digits

QueriesDictionary("Get_trunk_data_from_IDENTIFIERS") = "" & _
"select * from identifiers " & _ 
"where id_name like '<<parameter>>'"'and id_type = 1 and status like 'Active' " & _ 
'"and  active = TO_CHAR (SYSDATE, 'DD-MON-YY')"
'-- Replace <<parameter>> with trunk id

QueriesDictionary("Get_trunk_data_from_IDENTIFIER_OWNER") = "" & _
"select * from ( " & _ 
"select * from identifier_owner where id_key = (select id_key from identifiers where id_name like '<<parameter>>') " & _ 
"order by owner_id desc " & _
") where rownum = 1"
'-- Replace <<parameter>> with trunk id

', a.start_date, and a.end_date is null 
QueriesDictionary("Get_Trunk's_attributes_and_values") = "" & _	
"select upper(t.attribute_name) as attribute_name, upper(a.attribute_value) as attribute_value " & _	
"from trunk_attributes a join attribute_types t on a.attribute_type_id = t.attribute_type_id " & _	
"where a.id_key like (select i.id_key from identifiers i where i.id_name like " & _	 
"'<<parameter1>>') " & _	
"and a.end_date is null and t.attribute_group in ('<<parameter2>>')"
'-- Replace <<parameter1>> with trunk id and <<parameter2>> by attributes group name


QueriesDictionary("Get_site_code_combo_values") = "" & _
"select concat(concat(i.id_name, ' - '),s.attribute_value) as site " & _
"from Identifiers i join SITE_ATTRIBUTES s on i.id_key = s.id_key " & _
"where i.id_type = 3 and i.status = 'Active' and s.attribute_name = 'Full Name' " & _
"order by NLSSORT(concat(concat(i.id_name, ' - '),s.attribute_value), 'NLS_SORT=BINARY')"

QueriesDictionary("Get_network_type_combo_values") = "" & _
"select am.attribute_value " & _
"from ATTRIBUTE_METADATA am " & _
"where am.attribute_type_id =( select distinct ATTRIBUTE_TYPE_ID from ATTRIBUTE_TYPES t where t.attribute_name like  'Network Type') " & _
"and am.metadata_key = 'DIGIT_VALUE' " & _
"order by am.metadata_value" 

QueriesDictionary("Get_direction_combo_values") = "" & _
"select am.attribute_value " & _
"from ATTRIBUTE_METADATA am " & _
"where am.attribute_type_id =( select distinct ATTRIBUTE_TYPE_ID from ATTRIBUTE_TYPES t where t.attribute_name like  'Direction') " & _
"and am.metadata_key = 'DIGIT_VALUE' " & _
"order by am.metadata_value" 

QueriesDictionary("Get_icentral_company_combo_values") = "" & _
"Select ch.name, ch.short_name, ch.id, cd.source_network_id " & _
"From ICENTRAL_EXCHANGE.COMPANY_HEADER ch " & _
"join ICENTRAL_EXCHANGE.COMPANY_DETAIL cd " & _
"on ch.id = cd.company_id " & _
"Where PARENT_ID is not null and source_network_id != 3 " & _
"order by NLSSORT(ch.name, 'NLS_SORT=BINARY')"

QueriesDictionary("Get_rms_customer_combo_values") = "" & _
"Select c.customer_name, c.shortname, c.customer_id " & _ 
"From CUSTOMER c join company_header ch on c.ICENTRAL_COMPANY_ID = ch.id " & _ 
"where ch.parent_id = (select parent_id from company_header ch where id = <<parameter>>) " & _
"order by NLSSORT(c.customer_name, 'NLS_SORT=BINARY')"
'--Replace by iCentral company id

QueriesDictionary("Get_rms_vendor_combo_values") = "" & _
"Select v.vendor_name, v.shortname, v.vendor_id " & _ 
"From VENDOR v join company_header ch on v.ICENTRAL_COMPANY_ID = ch.id " & _ 
"where ch.parent_id = (select parent_id from company_header ch where id = <<parameter>>) " & _
"order by NLSSORT(v.vendor_name, 'NLS_SORT=BINARY')"

QueriesDictionary("Get_attributes'_list_values") = "" & _
"select DISTINCT l.attribute_value " & _
"from ATTRIBUTE_LIST_VALUES l join ATTRIBUTE_TYPES a on l.attribute_type_id = a.attribute_type_id " & _
"where a.attribute_name like '<<parameter>>' " & _
"ORDER BY NLSSORT(l.attribute_value,'NLS_SORT=BINARY')"
'-- Replace <<parameter>> with list attribute name
'--MISSING ORDER ON BASE ATTRIBUTES COMBO-BOXES!!!

QueriesDictionary("Find_customer_in_mis") = "" & _
"Select * from CUSTOMER where customer_name like '<<parameter1>>' and shortname like '<<parameter2>>'"
'-- Replace <<parameter1>> with new customer's full name and <<parameter2>> with new customer's short name

QueriesDictionary("Find_vendor_in_mis") = "" & _
"Select * from VENDOR where vendor_name like '<<parameter1>>' and shortname like '<<parameter2>>'"
'-- Replace <<parameter1>> with new vendor's full name and <<parameter2>> with new vendor's short name

QueriesDictionary("Get_next_available_colo") = "" & _
"select colo_code from( " & _
	"select colo_code from CURRENT_COLO_STATE where colo_status like 'Open' " & _
	"order by colo_code " & _
") where rownum = 1"

QueriesDictionary("Get_assigned_colos") = "" & _
"select distinct colo_code, colo_descriptor from current_colo_state " & _
"where icentral_parent_id = (select parent_id from ICENTRAL_EXCHANGE.company_header where id = <<parameter>>) " & _
"and colo_status like 'Assign%' " & _
"order by colo_code"
'--Replace <<parameter>> by iCentral company name

QueriesDictionary("Get_opened_colos") = "" & _
"select colo_code from CURRENT_COLO_STATE where colo_status like 'Open' order by colo_code"

QueriesDictionary("Get_descriptor_by_colo_name") = "" & _
"select attribute_value from colo_attributes where id_key = ( " & _
"  select id_key from identifiers where id_name like '<<parameter>>' " & _
") and attribute_name like 'Descriptor'"
'--Replace <<parameter>> by colo name

QueriesDictionary("Set_next_available_colo_null") = "" & _
"Update colo_attributes set attribute_value = null where " & _
"id_key = (select id_key from( " & _
"           select id_key, colo_code from CURRENT_COLO_STATE where colo_status like 'Open' " & _
"           order by colo_code " & _
"          )where rownum = 1) " & _
"and attribute_name like 'Descriptor'"

QueriesDictionary("Get_attribute_type_by_attribute_name") = "" & _
"select t.type_name " & _
"from DATA_TYPES t join ATTRIBUTE_TYPES a on t.data_type_id = a.data_type_id " & _
"where attribute_name like '<<parameter>>'"
'--Replace <<parameter>> by attribute name

QueriesDictionary("Get_trunk's_expected_source_network") = "" & _
"select network from source_network where id =(" & _
"select metadata_value from attribute_metadata " & _
"where attribute_value like '<<parameter>>' and metadata_key like 'SOURCE_NETWORK')"
'--Replace <<parameter>> by trunk's network type


QueriesDictionary("Random_attributes_to_edit") = "" & _
"select * from ( " & _ 
"(select a.attribute_group, a.attribute_name, t.type_name " & _ 
"from attribute_types a join data_types t on A.DATA_TYPE_ID = T.DATA_TYPE_ID " & _
"Where A.READ_ONLY like 'N' " & _ 
"and attribute_group in ('Base Attributes', 'Media', 'Signaling') " & _ 
"OR attribute_name in ('Activation Date','Colo Descriptor') " & _
"ORDER BY dbms_random.value) " & _  
") where rownum <= <<parameter>> " & _ 
"order by attribute_group"
'--Replace <<parameter>> by num of attributes to edit

'QueriesDictionary("Random_attributes_to_edit") = "" & _
'"select * from ( " & _
'"(select a.attribute_group, a.attribute_name, t.type_name " & _
'"from attribute_types a join data_types t on A.DATA_TYPE_ID = T.DATA_TYPE_ID " & _ 
'"where attribute_name in ('Activation Date','Colo Descriptor') " & _
'"ORDER BY dbms_random.value) " & _
'") where rownum <= 2 " & _
'"order by attribute_group"
''--Replace <<parameter>> by num of attributes to edit
'
QueriesDictionary("Get_field_index") = "" & _
"select attribute_order-1 from (select attribute_type_id,attribute_name,rownum AS attribute_order from (select * from (select att.attribute_type_id, att.attribute_name, att.base_priority AS priority, NULL AS field_priority FROM ATTRIBUTE_TYPES att  where att.attribute_group='<<parameter1>>' and att.hidden_field IS NULL and att.attribute_group NOT IN (select attribute_group FROM attribute_types where lower(hidden_Group) LIKE 'y') and att.layout_panel_id IS NULL union select ap.attribute_type_id,ap.attribute_name, al.priority, ap.field_priority from ATTRIBUTE_LAYOUT_PANEL al join ATTRIBUTE_TYPES ap on al.panel_id= ap.layout_panel_id where al.attribute_group='<<parameter2>>' and al.attribute_group NOT IN (select att.attribute_group from attribute_types att where lower(att.hidden_Group) LIKE 'y'))order by priority, field_priority))where attribute_name = '<<parameter3>>'" 

'QueriesDictionary("Get_field_index") = "" & _     
'"select ind from " & _
'"(select rownum-1 as ind, res.* from " & _
'"(select a.attribute_name " & _
'"from ATTRIBUTE_TYPES a join data_types d on a.data_type_id = d.data_type_id  " & _
'"where a.attribute_group in('Base Attributes','Media','Signaling') and a.hidden_field is  null " & _
'"order by a.attribute_group, a.data_type_id, NLSSORT(a.attribute_name, 'NLS_SORT=BINARY') " & _
'")res " & _
'")where attribute_name like '<<parameter>>'" 
''--Replace <<parameter>> by attribute name

'"select attribute_order from " &_ 
'"(select attribute_type_id,attribute_name,rownum AS attribute_order" &_
'"from" &_
'"(select * from" &_
'"(select att.attribute_type_id, att.attribute_name, att.base_priority AS priority, NULL AS field_priority" &_
'"FROM ATTRIBUTE_TYPES att" &_
'"where att.attribute_group='Base Attributes'" &_
'"and att.hidden_field IS NULL" &_
'"and att.attribute_group NOT IN" &_
'"(select attribute_group" &_
'"FROM attribute_types" &_
'"where lower(hidden_Group) LIKE 'y')" &_
'"and att.layout_panel_id IS NULL" &_
'"union" &_
'"select ap.attribute_type_id,ap.attribute_name, al.priority, ap.field_priority" &_
'"from ATTRIBUTE_LAYOUT_PANEL al" &_
'"join ATTRIBUTE_TYPES ap" &_
'"on al.panel_id= ap.layout_panel_id" &_
'"where al.attribute_group='Base Attributes'" &_
'"and al.attribute_group NOT IN" &_
'"(select att.attribute_group" &_
'"from attribute_types att" &_
'"where lower(att.hidden_Group) LIKE 'y'))" &_
'"order by priority, field_priority))" &_
'"where attribute_name = '<<parameter>>'" 
'--Replace <<parameter>> by attribute name

QueriesDictionary("Get_trunks_with_specific_attribute") = "" & _
"select id_key from trunk_attributes where ATTRIBUTE_TYPE_ID = ( " & _
"select ATTRIBUTE_TYPE_ID from ATTRIBUTE_TYPES where UPPER(ATTRIBUTE_NAME) like '<<parameter1>>') " & _
"and UPPER(attribute_value) like '<<parameter2>>' and end_date is null"
'--Replace <<parameter1>> by attribute name and <<parameter2>> by attribute value

'----------------------------------------------------------------

'-------------------------- DB Queries - Yael -----------------
QueriesDictionary("Get_site_code") = "" & _ 
"select attribute_value from site_attributes " & _
"where id_key = (select id_key from identifiers where id_name like '<<parameter>>') " & _
"and attribute_name like 'Site Code'"

QueriesDictionary("Get_Network_Type") = "" & _
"select metadata_value from attribute_metadata " & _
"where attribute_type_id = (select attribute_type_id from attribute_types where attribute_name like 'Network Type') " & _
"and metadata_key like 'DIGIT_VALUE' " & _
"and attribute_value like '<<parameter>>'" 
'--Replace <<parameter>> by Network Type


QueriesDictionary("Get_Direction") = "" & _
"select metadata_value from attribute_metadata " & _
"where attribute_type_id = (select attribute_type_id from attribute_types where attribute_name like 'Direction') " & _
"and metadata_key like 'DIGIT_VALUE' " & _
"and attribute_value like '<<parameter>>'"
'--Replace <<parameter>> by Direction
