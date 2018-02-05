Function CONVDUR(ByVal t As String) As String
    Dim num As Integer
    num = Val(firstDigits(t))
	
    If UCase(t) Like "*HOUR*" Then
        num = num * 3600
    End If
    If UCase(t) Like "*MINUTE*" Then
        num = num * 60
    End If
	
    CONVDUR = CStr(num)
End Function


Function firstDigits(s As String) As String
    Dim retval As String
	retval = ""
    Dim i As Integer    
    Dim f As Boolean
    f = False
                                           
    For i = 1 To Len(s)
        If Mid(s, i, 1) Like "[0-9]" Then
            f = True
            retval = retval + Mid(s, i, 1)
        Else
            If f Then
                Exit For
            End If
        End If
    Next

    onlyDigits = retval
End Function
