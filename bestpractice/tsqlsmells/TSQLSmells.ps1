
param(  
	[string]$FolderPath,  
	[string]$FileSpec,
	[string]$ConfigFolder,
	[string]$ExcludeErrors,
	[switch]$SupressGUI,
	[int]$MinSeverity=9999999
)

if(-not([System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.TransactSql.ScriptDom") )){
	Write-Host "Unable to Load component Microsoft.SqlServer.TransactSql.ScriptDom" -BackgroundColor Red -ForegroundColor white
	Write-Host "Reason 1 : It has not been installed :)" -BackgroundColor Red -ForegroundColor white
	Write-Host "Reason 2 : It is .Net 4 component which means that powershell 3 is required. Powergui from quest works fine too"	-BackgroundColor Red -ForegroundColor white
	exit
		

}
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 

cls
$OutputText = New-Object System.Windows.Forms.RichTextBox
$SmellListBox = new-object System.Windows.Forms.ListBox 

$script:SmellItemArr =@();
function Process-GUI($PrcXml){

	$objForm = New-Object System.Windows.Forms.Form 
	$objForm.Text = "Select a File"
	$objForm.Size = New-Object System.Drawing.Size(1000,400) 
	$objForm.StartPosition = "CenterScreen"

	$SmellArr =@()	
	$objForm.KeyPreview = $True
	$objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
	    {$x=$objListBox.SelectedItem;$objForm.Close()}})
	$objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
	    {$objForm.Close()}})

	$OKButton = New-Object System.Windows.Forms.Button
	$OKButton.Location = New-Object System.Drawing.Size(75,320)
	$OKButton.Size = New-Object System.Drawing.Size(75,23)
	$OKButton.Text = "OK"
	$OKButton.Add_Click({$x=$objListBox.SelectedItem;$objForm.Close()})
	$objForm.Controls.Add($OKButton)

	$CancelButton = New-Object System.Windows.Forms.Button
	$CancelButton.Location = New-Object System.Drawing.Size(150,320)
	$CancelButton.Size = New-Object System.Drawing.Size(75,23)
	$CancelButton.Text = "Cancel"
	$CancelButton.Add_Click({$objForm.Close()})
	$objForm.Controls.Add($CancelButton)

	$objLabel = New-Object System.Windows.Forms.Label
	$objLabel.Location = New-Object System.Drawing.Size(10,20) 
	$objLabel.Size = New-Object System.Drawing.Size(280,20) 
	$objLabel.Text = "Please select a file:"
	$objForm.Controls.Add($objLabel) 

	$objListBox = New-Object System.Windows.Forms.ListBox 
	$objListBox.Location = New-Object System.Drawing.Size(10,40) 
	$objListBox.Size = New-Object System.Drawing.Size(260,220) 
	$objListBox.Height = 280
	$objListBox.add_SelectedIndexChanged({
		Populate-Text $SmellArr[$objListBox.SelectedIndex]
	
	})

	foreach($smellfile in $PrcXml.Smells.SmellFile){
		$Item =$objListBox.Items.Add($smellfile.Name);
		$SmellArr +=$smellfile
	}
	$objForm.Controls.Add($objListBox) 

	$SmellListBox.Location = New-Object System.Drawing.Size(310,40) 
	$SmellListBox.Size = New-Object System.Drawing.Size(660,40) 
	$SmellListBox.Height = 50
	$objForm.Controls.Add($SmellListBox) 
	$SmellListBox.add_SelectedIndexChanged({
	$Item = $SmellListBox.SelectedIndex
	Highlight-SmellText $Item
	})
	
	$OutputText.Multiline=$true
	$OutputText.location = New-Object System.Drawing.Size(310,95) 
	$OutputText.size = New-Object System.Drawing.Size(660,225) 
	$objForm.Controls.Add($OutputText) 
	
	
	$objForm.Topmost = $True

	$objForm.Add_Shown({$objForm.Activate()})
	
	Populate-Text $SmellArr[0]
	[void] $objForm.ShowDialog()

	
}

function Highlight-SmellText($item){
#	Write-Host $Item
	$OutputText.SelectAll()
	$Font = $OutputText.get_SelectionFont()
	$NewFont  = New-Object system.Drawing.Font($Font.FontFamily,$Font.Size,[Drawing.FontStyle]'Regular',$Font.Unit)
	$OutputText.set_SelectionFont($NewFont)
	$Colour = [System.Drawing.Color]::Black
	$OutputText.set_SelectionColor($Colour)	
	
	$smell = $script:SmellItemArr[$Item]
#	Write-host $smell.msg
	$Text = $OutputText.Text.Substring(0,$smell.Offset)
	
	$CrCount =0
	if($smell.Offset -gt 0){
		$CrCount=[regex]::matches($text,"`n").count
	}
	$OutputText.Select($smell.Offset-$CrCount,$smell.Length)
	$Font = $OutputText.get_SelectionFont()
	$NewFont  = New-Object system.Drawing.Font($Font.FontFamily,$Font.Size,[Drawing.FontStyle]'Bold',$Font.Unit)
	$OutputText.set_SelectionFont($NewFont)
	$Colour = [System.Drawing.Color]::Red
	$OutputText.set_SelectionColor($Colour)	
}
function Populate-Text($smell){

	$FileName =$smell.Folder+"\"+$smell.Name
	$TextIn = Get-Content $FileName 
	$rtfBuild ="{\rtf1\ansi{\fonttbl\f0\fconsolas;}\f0\pard "
	foreach($Line in $TextIn){
		$rtfBuild+=$Line+"\par "
	}
	$OutputText.Multiline=$true
	$OutputText.Rtf = $rtfbuild	
	
	$SmellListBox.Items.Clear()
	
	$script:SmellItemArr =@()
	foreach($smellOn in $Smell.Smell){
		$Item =$SmellListBox.Items.Add($smellOn.Msg);
		$script:SmellItemArr +=$smellOn
	}
	$SmellListBox.SelectedIndex =0
	#HighLight-smelltext 0
}
function Start-FeedBack(){
	Out-File -FilePath $OutputFile -InputObject "<Smells>" -Append
}
function End-FeedBack(){

	Out-File -FilePath $OutputFile -InputObject "</Smells>" -Append
}

function Start-FileFeedback($FileName,$FolderName){
	Out-File -FilePath $OutputFile -InputObject "<SmellFile Name=`"$FileName`" Folder=`"$FolderName`">" -Append

}

function End-FileFeedback()
{
	Out-File -FilePath $OutputFile -InputObject "</SmellFile>" -Append


}

function Send-FeedBack($ErrorNo,$ObjectOn){
#	if($ObjectOn -eq $null){
#		Write-Host  "Object not passed to send feedback BAAAAAANNNNNNNGGGG" -BackgroundColor Red -ForegroundColor White
#		exit;
#	
#	}
#	
	if($Script:Supress -contains $ErrorNo){
		return;
	
	}
	$First = $ObjectOn.FirstTokenIndex
	$Last  = $ObjectOn.LastTokenIndex
	$Offset = $ObjectOn.Offset
	if($Offset -eq $null){
		$Offset = $ObjectOn.StartOffset
	}
	$Length = $ObjectOn.FragmentLength
	$ErrorDetail = $Script:Errors | Where-Object -FilterScript {$_.ErrorNum-eq $ErrorNo}
	if($MinSeverity -ge $ErrorDetail.Severity){
		$ErrorDesc = $ErrorDetail.Description
		Out-File -FilePath $OutputFile -InputObject "<Smell><Msg>$ErrorDesc</Msg><Offset>$Offset</Offset><Length>$Length</Length></Smell>" -Append
		Write-Host "$ErrorNo - $ErrorDesc" -BackgroundColor Blue -ForegroundColor white
	}


}
function Reform-Fragments($TokenStream,$Start,$End){
	$Ret =""
	foreach($Token in $TokenStream[$Start..$End]){
		$Ret+=$Token.text
	}
	return $ret
	

}

function Reform-SQL($fragment){
	return(Reform-Fragments $fragment.ScriptTokenStream $fragment.FirstTokenIndex $fragment.LastTokenIndex)
}

function Process-cte($Cte){
	foreach($cteDef in $Cte.CommonTableExpressions){
		Process-SelectStatement $cteDef
	}
}

function Is-CteName($Testval,$CteDef){
	if($CteDef -eq $null){ return($false)}
	foreach($cte in $Ctedef.CommonTableExpressions){
		if($cte.ExpressionName.value -eq $Testval){
			return($true)
		}
	}
	return($false)
}
function Process-DerivedTable($DerivedTable){
	$TopFilter = $DerivedTable.QueryExpression.TopRowFilter
 	if($TopFilter.Percent){
		$expr = $TopFilter.Expression.Expression
		if($expr.LiteralType -eq "Integer" -and $expr.Value -eq "100"){
			Send-FeedBack 32 $expr
		
		}
	}else{
		if([int]$TopFilter.Expression.Expression.value -ge 9999){
			Send-FeedBack 32 $expr
		
		
		}
	
	}
	
	

}
function Process-FromClause($FromClause,$Cte){
	foreach($TableRef in $FromClause.TableReferences){
#		Write-Host $TableRef
		if($TableRef.Variable -eq $null){   # Not a table variable
			$ObjectName = $TableRef.SchemaObject.BaseIdentifier.Value
			if($ObjectName -ne $null){
				if(-not($ObjectName -like '#*') -and -not($ObjectName -like '@*')){
					if($TableRef.SchemaObject.ServerIdentifier -ne $null){
						Send-FeedBack 1 $TableRef
					}
					if($TableRef.SchemaObject.SchemaIdentifier -eq $null){
						if(-not(is-CteName $ObjectName $Cte)){
							Send-FeedBack 2 $TableRef
						}
					}else{
						$Schema = $TableRef.SchemaObject.SchemaIdentifier.Value
					}
					#$Object = $TableRef.SchemaObject.BaseIdentifier.Value
				}
			}
		}
		if($TableRef.FirstTableReference -ne $null -and $TableRef.FirstTableReference.tostring() -eq "Microsoft.SqlServer.TransactSql.ScriptDom.QueryDerivedTable"){
			Process-DerivedTable $TableRef.FirstTableReference
		}
		if($TableRef.SecondTableReference -ne $null -and $TableRef.SecondTableReference.tostring() -eq "Microsoft.SqlServer.TransactSql.ScriptDom.QueryDerivedTable"){
			Process-DerivedTable $TableRef.SecondTableReference
		}
		foreach($TableHint in $TableRef.TableHints){
			if($TableHint -eq $null){
				break;
			}
			if($TableHint.HintKind -eq "NOLOCK"){
				Send-FeedBack 3 $TableHint
			}else{
				if($TableHint.HintKind -ne "ReadPast"){
					Send-FeedBack 4 $TableHint
				}
			}
		}
	}

}

function Process-SelectColumn($Column){
	if($Column.tostring() -eq "Microsoft.SqlServer.TransactSql.ScriptDom.SelectStarExpression"){
		Send-FeedBack 5 $Column
	}
	$ColumnOut = Reform-Fragments $Column.ScriptTokenStream $Column.FirstTokenIndex $Column.LastTokenIndex

	$WindowClause = $Column.Expression.OverClause.WindowFrameClause
	if($WindowClause.WindowFrameType -eq "Range"){  #Explicit RANGE window clause
		Send-FeedBack 25 $WindowClause
	
	}
	if(@("row_number","rank","dense_rank","ntile","LAG","LEAD") -notcontains $Column.Expression.FunctionName.Value){
		$PartitionOrder = $Column.Expression.OverClause.OrderByClause
		if($WindowClause -eq $null -and $PartitionOrder -ne $null){
			Send-FeedBack 26 $Column
		
		}
	
	}
}


function Process-SelectColumns($SelectColumns){
	foreach($Column in $SelectColumns){
#		Write-Host $Column
		Process-SelectColumn $Column	
	}
}

function Process-OptimizerHints($OptimizerHints){
	foreach($Hint in $OptimizerHints){
		if(@("OrderGroup","MergeJoin","HashJoin","LoopJoin","ConcatUnion","HashUnion","MergeUnion","KeepUnion",
			"HashGroup","forceorder") -contains $Hint.HintKind){
			Send-FeedBack 4 $Hint
		}
	}
}

function Process-IfPredicate($IfPredicate){
	if($IfPredicate.FirstExpression.QueryExpression.SelectElements -ne $null -and $IfPredicate.FirstExpression.QueryExpression.SelectElements[0].Expression.FunctionName.value -eq "count"){
		if($IfPredicate.SecondExpression.ToString() -eq "Microsoft.SqlServer.TransactSql.ScriptDom.IntegerLiteral"){
			if($IfPredicate.SecondExpresion.value -eq "1" -or $IfPredicate.SecondExpresion.value -eq "0"){
				Send-FeedBack 
			}
		}
	
	}
}
function Process-SearchCondition($SearchCondition){
	$ConditionType = $SearchCondition.ToString().split(".")[-1]
	if($ConditionType -eq "BooleanComparisonExpression"){
		if($SearchCondition.FirstExpression -ne $null){
			Process-SearchCondition $SearchCondition.FirstExpression
		}
		if($SearchCondition.SecondExpression -ne $null){
			Process-SearchCondition $SearchCondition.SecondExpression
		}
		return;
	}
	if($ConditionType -eq "ConvertCall" -or
		$ConditionType -eq "CastCall"){
		$ParamType = $SearchCondition.Parameter.ToString().split(".")[-1]
		if($ParamType -eq "ColumnReferenceExpression"){
			Send-FeedBack 6 $SearchCondition
		}
		return;
	}
	if($ConditionType -eq "StringLiteral"){
		return;
	
	}
	if($ConditionType -eq "BooleanBinaryExpression"){
		
		if($SearchCondition.FirstExpression -ne $null){
			Process-SearchCondition $SearchCondition.FirstExpression
		}
		if($SearchCondition.SecondExpression -ne $null){
			Process-SearchCondition $SearchCondition.SecondExpression
		}
		return;
	}
	#Write-Host $ConditionType
	return;
	
}
function Process-WhereClause($WhereClause)
{
	Process-SearchCondition $WhereClause.SearchCondition
}

function Process-OrderByClause($OrderByClause)
{
	foreach($OrderElement in $OrderByClause.OrderByElements){
		$Expression =$OrderElement.Expression.ToString().split(".")[-1]
		if($Expression -eq "IntegerLiteral"){
			Send-FeedBack 7 $OrderElement		
		}
	}
}
function Process-QueryExpression($QueryExpression){
	$FromClause = $QueryExpression.FromClause
	if($FromClause -ne $null){
		Process-FromClause $FromClause $Cte
	}
	Process-SelectColumns $QueryExpression.SelectElements
	if($QueryExpression.WhereClause -ne $null){
		Process-WhereClause $QueryExpression.WhereClause
	}
	if($Stmt.OptimizerHints -ne $null){
		Process-OptimizerHints $Stmt.OptimizerHints
	}
	if($QueryExpression.OrderByClause -ne $null){
		Process-OrderByClause $QueryExpression.OrderByClause
	}
}

function Process-BinaryQueryExpression($Query){
	$FirstQuery = $Query.FirstQueryExpression 
	$SecondQuery = $Query.SecondQueryExpression
	
	$FirstQueryType = $FirstQuery.ToString().split(".")[-1]
	$SecondQueryType = $SecondQuery.ToString().split(".")[-1]
	
	if($FirstQueryType -eq "BinaryQueryExpression"){
		Process-BinaryQueryExpression $FirstQuery
	}else{
		Process-QueryExpression $FirstQuery
	}
	
	if($SecondQueryType -eq "BinaryQueryExpression"){
		Process-BinaryQueryExpression $SecondQuery
	}else{
		Process-QueryExpression $SecondQuery
	}

}


function Process-SelectStatement($Stmt , $Cte,$TestTop){
#CTEs can be passed in for syntax
#with cte() INSERT () SELECT....
	if($TestTop -eq $null){
		$TestTop=$false
	}
    if($Cte -eq $null){
		$Cte = $Stmt.WithCtesAndXmlNamespaces
		if($Cte -ne $null){
			Process-cte $Cte
		}
	}
	$ExpressionType = $Stmt.QueryExpression.ToString().split(".")[-1]
	$Query =$null
	switch($ExpressionType){
		QuerySpecification {$Query = $Stmt.QueryExpression;
							Process-FromClause $Stmt.QueryExpression.FromClause $cte
							break}
		QueryParenthesisExpression{$Query=$Stmt.QueryExpression.QueryExpression;break}
		BinaryQueryExpression{Process-BinaryQueryExpression $Stmt.QueryExpression;break;}

		default{Write-Host "BANNNNNNGGGGGG" -BackgroundColor Red -ForegroundColor White;exit}
	}
	if($TestTop){
		if($Query.TopRowFilter -ne $null -and $Query.OrderByClause -ne $null){
			Send-FeedBack 28 $Query.OrderByClause
		}
	
	}
	if($Query -ne $null){
		Process-QueryExpression $Query
	}
	if($Stmt.OptimizerHints -ne $null){
		Process-OptimizerHints $Stmt.OptimizerHints
	}
}
function Process-SetCmd($SetCmd){
	$SetType = $SetCmd.ToString().split(".")[-1]
	$CommandType = $SetCmd.CommandType.ToString().split(".")[-1]
	if($SetCmd.CommandType -eq "DateFormat"){
		Send-FeedBack 8 $SetCmd
	}
	if($SetCmd.CommandType -eq "DateFirst"){
		Send-FeedBack 9 $SetCmd
	}
}


function Process-IsolationLevel($IsolLevel){
	if($IsolLevel.Level -eq "ReadUncommitted"){
		Send-FeedBack 10 $IsolLevel
	}
}

function Process-SetRowCount($RowCountStmt){
	Send-FeedBack 11 $RowCountStmt
}

function Process-InsertStatement( $Stmt )
{
	$Source = $Stmt.InsertSpecification.InsertSource.ToString().Split(".")[-1]
	if($Stmt.InsertSpecification.Columns.count -eq 0){
		Send-FeedBack 12 $Stmt
	
	}
	if($Source -eq "SelectInsertSource"){
		if($Stmt.InsertSpecification.InsertSource.Select.FromClause -ne $null){
			Process-FromClause $Stmt.InsertSpecification.InsertSource.Select.FromClause $Stmt.WithCtesAndXmlNamespaces
		}
		if($Stmt.InsertSpecification.InsertSource.Select.SelectElements -ne $null){
			Process-SelectColumns $Stmt.InsertSpecification.InsertSource.Select.SelectElements
		}
		#Process-SelectStatement $Stmt.InsertSpecification.InsertSource.Select
		#Process-SelectColumns $Stmt.InsertSpecification.InsertSource.Select.SelectElements
	}


}
function 	Process-PredicateSetStatement($Stmt){
	
	if($Stmt.Options-eq"ConcatNullYieldsNull" -and -not $Stmt.IsOn){
		Send-FeedBack 13  $Stmt
		return
	}
	if($Stmt.Options-eq"AnsiNulls" -and -not $Stmt.IsOn){
		Send-FeedBack 14 $Stmt
		return
	}
	if($Stmt.Options-eq"AnsiPadding" -and -not $Stmt.IsOn){
		Send-FeedBack 15 $Stmt
		return
	}
	if($Stmt.Options-eq"AnsiWarnings" -and -not $Stmt.IsOn){
		Send-FeedBack 16 $Stmt
		return
	}
	if($Stmt.Options-eq"ArithAbort" -and -not $Stmt.IsOn){
		Send-FeedBack 17 $Stmt
		return
	}
	if($Stmt.Options-eq"NumericRoundAbort" -and $Stmt.IsOn){
		Send-FeedBack 18 $Stmt
		return
	}
	if($Stmt.Options-eq"QuotedIdentifier" -and -not $Stmt.IsOn){
		Send-FeedBack 19 $Stmt
		return
	}
	if($Stmt.Options-eq"ForcePlan" -and $Stmt.IsOn){
		Send-FeedBack 20 $Stmt
		return
	}	
	if($Stmt.Options -eq "NoCount" -and $Stmt.IsOn -eq "True"){
		$Script:SetNoCount = $True
	}
}

function Process-DeclareCursor($Stmt){
	if($Stmt.CursorDefinition -eq $null -or $Stmt.CursorDefinition.options.Count -eq 0){
		Send-FeedBack 29 $Stmt
	}
	

}


function Process-ExecStatement($Stmt){
	
	$ExecEntity = $Stmt.ExecuteSpecification.ExecutableEntity
	$ExecType = $ExecEntity.ToString().Split('.')[-1]
	if($ExecType -eq "ExecutableProcedureReference"){
		$ProcObject = $ExecEntity.ProcedureReference.ProcedureReference
		if($ProcObject -ne $null){
			
			$SchemaID = $ProcObject.Name.SchemaIdentifier
			$PrcName = $ProcObject.Name.BaseIdentifier.Value
			if($SchemaID -eq $null){
				Send-FeedBack 21 $Stmt
			}
		}	
	}
}


function Process-Statement($Stmt){
#	write-host $Stmt.ToString() -ForegroundColor red
	$StmtType = $Stmt.ToString().Split(".")[-1]
	
	if($StmtType -eq "DeclareCursorStatement"){
		Process-DeclareCursor $Stmt
	}
	if(@("CreateViewStatement","AlterViewStatement") -contains $StmtType){
		$Script:ObjectContext="VW"
		Extract-Statements $Stmt.StatementList $true
	}
	if($StmtType -eq "CreateProcedureStatement"){
		$Script:SetNoCount = $False
		Extract-Statements $Stmt.StatementList $true
		if(-not $Script:SetNoCount){
			Send-FeedBack 30 $null
		}
		
	}
	if(@("BeginEndBlockStatement","AlterProcedureStatement") -contains $StmtType){
		Extract-Statements $Stmt.StatementList
	}
	if(@("CreateFunctionStatement","AlterFunctionStatement") -contains $StmtType){
		$RetType = $Stmt.ReturnType.ToString().Split(".")[-1]
		if($Stmt.MethodSpecifier -eq $null) {   # CLR function
			switch($RetType){
				
				SelectFunctionReturnType {Process-Statement $Stmt.ReturnType.SelectStatement;}
				TableValuedFunctionReturnType{Extract-Statements $Stmt.StatementList;}
				ScalarFunctionReturnType{Extract-Statements $Stmt.StatementList;}
				default{write-host BAAAAAAAAAAANNNNG $RetType -BackgroundColor Red -ForegroundColor White;exit;}
			}
		}
		
	}
	if($StmtType -eq "SetTransactionIsolationLevelStatement"){
		Process-IsolationLevel $Stmt
	}
	if($StmtType -eq "WhileStatement"){
		if($Stmt.Statement.StatementList -ne $null){
			Extract-Statements $Stmt.Statement.StatementList
		}else{
			Process-Statement $Stmt.Statement
		}
	}
	if($StmtType -eq "InsertStatement"){
		Process-InsertStatement $Stmt
	}
	if($StmtType -eq "SelectStatement"){
		Process-SelectStatement $Stmt
	}
	if($StmtType -eq "SetRowCountStatement"){
		Process-SetRowCount $Stmt
	}
	if($StmtType -eq "IfStatement"){
		Process-IfPredicate $Stmt.Predicate
		Process-Statement $Stmt.ThenStatement
		if($Stmt.ElseStatement -ne $null){
			Process-Statement $Stmt.ElseStatement
		}
	}
	if($StmtType -eq "PredicateSetStatement"){
		Process-PredicateSetStatement $Stmt
	}
	if($StmtType -eq "ExecuteStatement"){
		Process-ExecStatement $Stmt
	}
	if($StmtType -eq "SetIdentityInsertStatement"){
		Send-FeedBack 22 $Stmt
	}
	if($StmtType -eq "SetCommandStatement"){
		$CmdList = $Stmt.Commands
		if($CmdList -ne $null){
			foreach($c in $Stmt.Commands ){
				$cStmtType = $c.ToString().Split(".")[-1]
				if($cStmtType -eq "GeneralSetCommand"){
					Process-SetCmd $c
				}
			}
		}	
	}
	
}

function Extract-Statements($Batch){
	
#	if($Batch -eq $null){
#		Write-Host "ddd"
#	
#	}
	foreach($Stmt in $Batch.Statements){
		Process-Statement $Stmt
	}
}

function Process-File($File){
	$StreamReader = New-Object System.IO.StreamReader($FileOn.FullName)
	$Parser = new-object Microsoft.SqlServer.TransactSql.ScriptDom.TSQL110parser($true)  

	$errors = $null 
	$SQLFragment = $parser.Parse($StreamReader,([ref]$errors))  
	$StreamReader.close()
	if($errors -ne $null){
		Send-FeedBack 0 
		foreach($err in $errors){		
			Write-Host $err.Message
		}	
		return;
	}
	$Script:ObjectContext=""
	$SQLFragment.ScriptTokenStream | Where-Object -FilterScript {$_.TokenType-eq"SingleLineComment"} | foreach{ Send-FeedBack 23 $_}
	foreach($Batch in $SQLFragment.Batches){
		$FirstStmt = $Batch.Statements[0]
		$Type = $FirstStmt.ToString()
		$StmtType = $FirstStmt.ToString().Split(".")[-1]
		
		if($StmtType -eq "CreateTableStatement"){
			if($FirstStmt.SchemaObjectName.SchemaIdentifier -eq $null){
				Send-FeedBack 27 $FirstStmt.BaseIdentifier
			
			}
		
		}
		if($StmtType -eq "CreateProcedureStatement" -or
			$StmtType -eq "AlterProcedureStatement"){
			
			$Schema = $null	
			if($FirstStmt.get_ProcedureReference().Name.SchemaIdentifier -ne $null){
				$Schema = $FirstStmt.get_ProcedureReference().Name.SchemaIdentifier.Value
			}
			if($Schema -eq $null){
				Send-FeedBack 24 $FirstStmt
			}
			$PrcName = $FirstStmt.get_ProcedureReference().Name.BaseIdentifier.Value
		}
		if($StmtType -eq "CreateViewStatement" -or
		   $StmtType -eq "AlterViewStatement"){
		   $Schema = $null
		   $Schema = $FirstStmt.SchemaObjectName.SchemaIdentifier.Value
		   $View   = $FirstStmt.SchemaObjectName.BaseIdentifier.Value
		   $Script:ObjectContext="VW"
		   if($Schema -eq $null){
				Send-FeedBack 24 $FirstStmt
			}
		   Process-SelectStatement $FirstStmt.SelectStatement $null $True
		   continue
		}
		Extract-Statements $Batch		
	}
}


Set-StrictMode -off
$Folder = Split-path $script:MyInvocation.MyCommand.Path
if($ConfigFolder -eq $null -or $ConfigFolder-eq ""){
	$ConfigFolder = $Folder
}
$Script:Errors = $null
$Script:Errors = Import-Csv $ConfigFolder"\errors.txt" -ErrorAction SilentlyContinue 
if($Script:Errors -eq $null){
	Write-Host "Unable to open $ConfigFolder errors.txt" -BackgroundColor Red -ForegroundColor white
	exit

}
$Script:WhiteListFiles = $null
$Script:WhiteListFiles= Import-Csv $ConfigFolder"\WhiteListFiles.txt"
if($Script:WhiteListFiles -eq $null){
	Write-Host "Unable to open $ConfigFolder WhiteListFiles.txt" -BackgroundColor Red -ForegroundColor white
	exit

}

$Script:SetNoCount = $False
if($FolderPath -eq $null -or $FolderPath -eq ""){  
   $FolderPath = $Folder
}else{
	if( -not(Test-Path $FolderPath)){
		Write-Host "$FolderPath - unable to open" -BackgroundColor Red -ForegroundColor white
		exit
	}
}
if($FileSpec -eq $null){
	$FileSpec="*.sql"
}
$Script:Supress = $ExcludeErrors.Split(",")
$OutputFile= $Folder+"\Smells.xml"
Remove-Item $OutputFile -ErrorAction SilentlyContinue
Start-FeedBack 
try{
	foreach($Spec in $FileSpec.Split(',')){
		foreach($FileOn in Get-ChildItem $FolderPath -Filter $Spec -Recurse ){
			if($FileOn.Extension -eq ".sql" -and $FileOn.BaseName.IndexOf(".") -eq -1){
				$WhiteList =$Script:WhiteListFiles | Where-Object -FilterScript {$_.FileName -eq $FileOn.Name}
				if($WhiteList -eq $null){
					Start-FileFeedback $FileOn.Name $FileOn.get_DirectoryName()
					$FileName = $FileOn
					Write-Host "In File $FileOn" -BackgroundColor Red -ForegroundColor white
					Process-File $FileOn
					End-FileFeedback
				}
			}
		}
	}
}catch{
	Write-Host $_
	Write-Host $_.InvocationInfo.PositionMessage

}
End-FeedBack
[xml]$PrcXml = Get-Content $OutputFile
if (-not $SupressGUI){
	Process-GUI $PrcXml
}
