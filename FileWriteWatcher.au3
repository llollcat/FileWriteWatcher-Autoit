#include <Misc.au3>
#include <Date.au3>
#include <Crypt.au3>


$fileName = "l.log"

$WMI = ObjGet("winmgmts:" & "{impersonationLevel=impersonate}!\\" & ".\root\cimv2")
  If @error Then
   ConsoleWrite("Error: " & @error)
   Exit
EndIf


While 1
 $colItems = $WMI.ExecQuery("Select * from Win32_LogicalDisk")
 For $objItem In $colItems
    If $objItem.DriveType = 2 Then
	   $strDrive = $objItem.DeviceID
	   
		$intInterval = "1"
		$query = "Select * From __InstanceOperationEvent" & " Within " & $intInterval  & " Where Targetinstance Isa 'CIM_DataFile'"  & " And TargetInstance.Drive='" &  $strDrive & "'"

		$colEvents = $WMI.ExecNotificationQuery ($query)

		$objEvent = $colEvents.NextEvent()

		$objTargetInst = $objEvent.TargetInstance
		
		Select
			
		Case $objEvent.Path_.Class  = "__InstanceCreationEvent" 
			
			$hash = _Crypt_HashFile($objTargetInst.Name, $CALG_SHA1)
			$attributes = FileGetAttrib($objTargetInst.Name)
			FileWrite($fileName, _Now() & " Created: " & $objTargetInst.Name  & " attributes: " & $attributes & " Hash: " & $hash & @CRLF)
		EndSelect 

	   
   EndIf
Next
WEnd