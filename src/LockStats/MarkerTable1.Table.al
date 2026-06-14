table 50705 "Marker Table 1"
{
    DataClassification = SystemMetadata;

    fields
    {
        field(1; ID; Integer)
        {
            Caption = 'ID';
        }
    }

    keys
    {
        key(PK; ID)
        {
            Clustered = true;
        }
    }
}