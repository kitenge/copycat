unit TestCcConfStorage;
{

  Delphi DUnit Test Case
  ----------------------
  This unit contains a skeleton test case class generated by the Test Case Wizard.
  Modify the generated code to correctly setup and call the methods from the unit 
  being tested.

}

interface

uses
  TestFramework, CcConfStorage, CCat, Registry, Classes, IniFiles, DB, CcProviders, Contnrs,
  CcmemDS;
type
  // Test methods for class TCcConfigStorage
  
  TestTCcConfigStorage = class(TTestCase)
  strict private
    FCcConfigStorage: TCcConfigStorage;
  private
    procedure TestDBConnector(dbConfig: TCcConnectionConfig);
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestLocalDBConnector;
    procedure TestRemoteDBConnector;
  end;

implementation

uses
  Forms, CcProvIBX, SysUtils;

procedure TestTCcConfigStorage.SetUp;
begin
  FCcConfigStorage := TCcConfigStorage.Create(Application);
  DeleteFile('c:\temp\config.ini');
  FCcConfigStorage.Path := 'c:\temp\config.ini';
  FCcConfigStorage.UseRegistry := false;
  FCcConfigStorage.LoadFields;
end;

procedure TestTCcConfigStorage.TearDown;
begin
  DeleteFile('c:\temp\config.ini');
  FCcConfigStorage.Free;
  FCcConfigStorage := nil;
end;

procedure TestTCcConfigStorage.TestDBConnector(dbConfig: TCcConnectionConfig);
begin
  Check(dbConfig.Connection = nil, 'DB Connection should be initially nil');

  FCcConfigStorage.Open;
  FCcConfigStorage.Edit;
  Check(dbConfig.Connection = nil, 'DB Connection should be nil until the DBConnector field has been set');

  dbConfig.ConnectorName := 'IBX';
  Check(Assigned(dbConfig.Connection), 'DB Connection should have a value');
  Check(dbConfig.Connection is TCcConnectionIBX, 'DB Connection should have a value');

  dbConfig.Param['SQLDialect'] := IntToStr(3);
  CheckEquals(3, (dbConfig.Connection as TCcConnectionIBX).SQLDialect, 'DB Connection property values not preserved');
  FCcConfigStorage.Post;

  FCcConfigStorage.Close;
  Check(dbConfig.Connection = nil, 'DB Connection should be nil when dataset is closed');
  FCcConfigStorage.Open;

  CheckEquals('IBX', dbConfig.ConnectorName);
  Check(Assigned(dbConfig.Connection), 'DB Connection should have a value');
  Check(dbConfig.Connection is TCcConnectionIBX, 'DB Connection should have a value');
  CheckEquals(3, (dbConfig.Connection as TCcConnectionIBX).SQLDialect, 'DB Connection property values not preserved');
end;

procedure TestTCcConfigStorage.TestLocalDBConnector;
begin
  TestDBConnector(FCcConfigStorage.LocalDB);
end;

procedure TestTCcConfigStorage.TestRemoteDBConnector;
begin
  TestDBConnector(FCcConfigStorage.RemoteDB);
end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TestTCcConfigStorage.Suite);
end.
