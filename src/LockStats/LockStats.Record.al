table 50703 "Lock Stats"
{
    DataClassification = SystemMetadata;
    TableType = Temporary;

    fields
    {
        field(1; ID; Integer) { }
        field(2; "Session ID"; Integer) { }
        field(3; "Session Row Count"; Integer) { }
        field(4; "Resource Type"; Text[30]) { }
        field(5; "Request Mode"; Text[50]) { }
        field(6; "Request Type"; Text[50]) { }
        field(7; "Request Status"; Text[50]) { }
        field(8; "Locks Count"; Integer) { }
    }

    keys
    {
        key(PK; "Session ID", ID)
        {
            Clustered = true;
        }
    }
}