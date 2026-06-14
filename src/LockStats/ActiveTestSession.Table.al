table 50704 "Active Test Session"
{
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "BC Session ID"; Integer) { }
        field(2; "SQL Session ID"; Integer) { }
    }

    keys
    {
        key(PK; "BC Session ID")
        {
            Clustered = true;
        }
    }
}