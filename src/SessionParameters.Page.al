page 50702 "Session Parameters"
{
    PageType = ListPart;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Session Parameters";
    SourceTableView = where(Action = filter(<> "Set Table Mark"));
    AutoSplitKey = true;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(TransactionType; Rec."Transaction Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Sets the TransactionType property for the current transaction.';
                    Visible = false;
                }
                field(WaitBeforeLocking; Rec."Wait Time Before Locking")
                {
                    ApplicationArea = All;
                    ToolTip = 'Wait time in ms before the data access action.';
                }
                field(Action; Rec.Action)
                {
                    ApplicationArea = All;
                    ToolTip = 'Data access action: Read, Insert, Modify, or Delete.';
                    ValuesAllowed = Read, Insert, ModifyAll, DeleteAll, "Modify", ModifyInLoop, ReadOne;

                    trigger OnValidate()
                    begin
                        SetLockTypeEditable();
                    end;
                }
                field(LockType; Rec."Lock Type")
                {
                    ApplicationArea = All;
                    Editable = LockTypeEditable;
                    ToolTip = 'This setting applies to Read actions only. Specifies the locking type - one of the ReadIsolation options or LockTable.';
                }
                field(FirstRecordNo; Rec."First Record No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'An integer number identifying the first record in the range affected by the data access action.';
                }
                field(LastRecordNo; Rec."Last Record No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'An integer number identifying the last record in the range affected by the data access action.';
                }
                field(CommitAfterAction; Rec."Commit After Action")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the transaction must be committed after the action.';
                }
                field(WaitAfterLocking; Rec."Wait Time After Locking")
                {
                    ApplicationArea = All;
                    ToolTip = 'Wait time in ms after the data access action.';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SetLockTypeEditable();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        SetLockTypeEditable();
    end;

    local procedure SetLockTypeEditable()
    begin
        LockTypeEditable := Rec.Action = Rec.Action::Read;
    end;

    var
        LockTypeEditable: Boolean;
}