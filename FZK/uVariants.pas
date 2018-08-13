unit uVariants;

interface

type
  TData = record
    TableName: string;
    SQL: string;
    KeyField: string;
  end;

var
  oraHost, oraPort, oraSID, oraUser, oraPwd: string;
  sqlServer, sqlDBName, sqlUser, sqlPwd: string;
  FRunTime, ExportTime: string;

implementation

end.
