table 50706 "Marker Table 2"
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