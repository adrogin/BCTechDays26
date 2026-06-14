page 50703 "Lock Stats"
{
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "Lock Stats";
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            repeater(Locks)
            {
                field(RowCount; Rec."Session Row Count")
                {
                    Caption = 'Row Count';
                    Visible = false;
                }
                field(ResourceType; Rec."Resource Type")
                {
                    Caption = 'Resource Type';
                }
                field(RequestMode; Rec."Request Mode")
                {
                    Caption = 'Request Mode';
                }
                field(RequestType; Rec."Request Type")
                {
                    Caption = 'Request Type';
                    Visible = false;
                }
                field(RequestStatus; Rec."Request Status")
                {
                    Caption = 'Request Status';
                }
                field(LocksCount; Rec."Locks Count")
                {
                    Caption = 'Lock Count';
                }
            }
        }
    }

    procedure SetSource(var LockStats: Record "Lock Stats")
    begin
        Rec.Reset();
        Rec.DeleteAll();
        if LockStats.FindSet() then
            repeat
                Rec.TransferFields(LockStats);
                Rec.Insert();
            until LockStats.Next() = 0;
    end;
}
