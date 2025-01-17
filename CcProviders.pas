// CopyCat replication suite<p/>
// Copyright (c) 2015 Microtec Communications<p/>
// For any questions or technical support, contact us at contact@copycat.fr
unit CcProviders;

{$I CC.INC}

interface

uses Classes, Sysutils, DB {$IFDEF CLR}, Borland.Vcl.Variants{$ENDIF};

type

  TCcExceptionNotifyEvent = procedure(Sender: TObject; var RaiseException: Boolean) of object;
  TCcQuery = class;
  TCcConnection = class;
  TCcConnectionClass = class of TCcConnection;

  TCcCustomKeyRing = class
    protected
      FConnection: TCcConnection;
    public
      property Connection: TCcConnection read FConnection;
      constructor Create(conn: TCcConnection); virtual;
  end;

  // Description:
  // \Internal query field or parameter object.
  TCcField = class
  private
    FQuery: TCcQuery;
    FSize: Integer;
    FDataType: TFieldType;
  protected
    // \ \
    FIsParam: Boolean;
    FFieldName: string;
    FIndex: Integer;

    function GetValue: Variant;
    procedure SetValue(Val: Variant);

    function GetIsNull: Boolean;
    function GetAsString: string;
    procedure SetAsString(Val: string);
    function GetAsInteger: Integer;
    procedure SetAsInteger(Val: Integer);
    function GetAsFloat: Double;
    procedure SetAsFloat(Val: Double);
    function GetAsDateTime: TDateTime;
    procedure SetAsDateTime(Val: TDateTime);
    function GetAsCurrency: Currency;
    procedure SetAsCurrency(Val: Currency);
  public
    // Set this field to null
    procedure Clear;
    procedure SetValueAsType(Val: Variant; AFieldType: TFieldType);
    // IsParam indicates whether this TCcField is a field or a param
    property IsParam: Boolean read FIsParam;
    property index: Integer read FIndex;
    property IsNull: Boolean read GetIsNull;
    property Value: Variant read GetValue write SetValue;
    property AsString: string read GetAsString write SetAsString;
    property AsInteger: Integer read GetAsInteger write SetAsInteger;
    property AsFloat: Double read GetAsFloat write SetAsFloat;
    property AsDateTime: TDateTime read GetAsDateTime write SetAsDateTime;
    property AsCurrency: Currency read GetAsCurrency write SetAsCurrency;
    property DataType: TFieldType read FDataType;
    property Size: Integer read FSize;
    property FieldName: string read FFieldName;
    constructor Create(Query: TCcQuery; cFieldName: string; FieldType: TFieldType; nSize: Integer; lParam: Boolean);
  end;

  // Represents a query macro. This is an internal object, not needed by application
  // developers.
  TCcMacro = class
  private
    FValue: string;
    FName: string;
    FQuery: TCcQuery;
    procedure SetValue(const Value: string);
  protected
    procedure ApplyToSQL(var SQLText: string);
    constructor Create(Query: TCcQuery; Name: string);
  public
    // Name of the macro.
    property name: string read FName;
    // Current value of the macro. Macros may only be set before the TCcQuery has been
    // prepared.
    property Value: string read FValue write SetValue;
  end;

  TCcSqlParser = class
  private
    FTokenChar: string;
    FTokens: TStringList;
    function GetOffset(nIndex: Integer): Integer;
    function GetToken(index: Integer): string;
    function GetTokenCount: Integer;
    function GetQuoteCount(nIndex: Integer): Integer;
  public
    property TokenChar: string read FTokenChar write FTokenChar;
    property Token[index: Integer]: string read GetToken;
    property TokenCount: Integer read GetTokenCount;
    property Offset[nIndex: Integer]: Integer read GetOffset;
    property QuoteCount[nIndex: Integer]: Integer read GetQuoteCount;
    procedure Parse(SQLText: string);
    constructor Create;
    destructor Destroy; override;
  end;

  TCcAbstractQueryObject = class
  private
    FConnection: TCcConnection;
    FID: Integer;
    FQuery: TCcQuery;
    FSelectStatement: Boolean;
    FAfterClose: TDataSetNotifyEvent;
  protected
    function GetRowsAffected: Integer; virtual; abstract;
    function GetEof: Boolean; virtual; abstract;
    procedure DoInitParams(ParamList: TStringList); virtual; abstract;
    procedure DoInitFields(FieldList: TStringList); virtual; abstract;
    procedure DoExec; virtual; abstract;
    procedure DoPrepare(SQLText: string); virtual; abstract;
    procedure DoUnPrepare; virtual; abstract;
    procedure SetParamCheck(lParamCheck: Boolean); virtual; abstract;
    procedure DoClose; virtual; abstract;
    procedure DoNext; virtual; abstract;
    function GetFieldType(FieldName: string; IsParam: Boolean): TFieldType; virtual; abstract;
    function GetFieldSize(FieldName: string; IsParam: Boolean): Integer; virtual; abstract;
    function GetFieldValue(Field: TCcField): Variant; virtual; abstract;
    procedure SetFieldValue(Field: TCcField; Val: Variant); virtual; abstract;
    property Connection: TCcConnection read FConnection;
    property ID: Integer read FID;
  public
    property SelectStatement: Boolean read FSelectStatement;
    property Query: TCcQuery read FQuery;
    constructor Create(Conn: TCcConnection; qry: TCcQuery; nID: Integer; Select: Boolean); virtual;
    property AfterClose: TDataSetNotifyEvent read FAfterClose write FAfterClose;
  end;

  // Description:
  // Represents a database query. TCcQuery is used internally in CopyCat, and can also
  // be used in your applications as a general purpose query object using a TCcConnection.
  // This allows a total abstraction of the underlying data-access components, while
  // still providing all the basic functionality needed for executing queries,
  // including named parameters, macros, etc.<p/>
  TCcQuery = class(TComponent)
  private
    FOldSQLText: string;
    FActive: Boolean;
    FRecordCount: Integer;
    FParamCheck: Boolean;
    FOnExecute: TNotifyEvent;
    FMacroParser: TCcSqlParser;
    FQueryObject: TCcAbstractQueryObject;
    FProperties: TStringList;
    FSelectStatement: Boolean;
    procedure SQLChanged(Sender: TObject);
    procedure SetActive(const Value: Boolean);
    procedure SetConnection(const Value: TCcConnection);
    function GetParamByIndex(index: Integer): TCcField;
    function GetFieldByIndex(index: Integer): TCcField;

    function GetMacro(MacroName: string): TCcMacro;
    function GetParam(Param: string): TCcField;
    function GetField(FieldName: string): TCcField;

    function GetMacroCount: Integer;
    function GetParamCount: Integer;
    function GetFieldCount: Integer;
    // This function parses the SQL, sets the value of each macro, and returns the resulting SQL with macros applied
    function ApplyMacros(cSQL: string): string;
    function DoFindParam(Param: string): TCcField;
  protected
    FFields: TStringList;
    FParams: TStringList;
    FMacros: TStringList;
    FConnection: TCcConnection;
    FQueryID: Integer;

    // This variable doesn't necessarily mean that the query has been prepared
    // It merely means that a parameter has been accessed, and that the SQL
    // therefore cannot be changed any more until the query is closed
    FSQLPrepared: Boolean;
    FSQLWithMacros: TStrings;
    FRealSQL: string;
    FQueryName: string;

    procedure CheckMacros(SQLText: string);

    procedure FreeMacros;
    procedure FreeParams;
    procedure FreeFields;

    procedure CreateField(cFieldName: string; FieldType: TFieldType; nSize: Integer);
    procedure CreateParam(cFieldName: string; FieldType: TFieldType; nSize: Integer);

    // After accessing the parameters, the SQL can no longer be modified. This is
    // a lowest common denominator approach, some DACs support it while others don't
    procedure SetSQL(Value: TStrings);
    procedure SetParamCheck(Value: Boolean);

    function GetRecordCount: Integer;
    function GetRowsAffected: Integer;
    function GetEof: Boolean;

    procedure InitFields;
    procedure ClearFields;

    procedure InitParams;
    procedure ClearParams;
    property OnExecute: TNotifyEvent read FOnExecute write FOnExecute;

    // Called by TCcConnection in order to signal that the DBType or DBVersion have changed
    procedure ClearQueryObject;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    function GetQueryObject: TCcAbstractQueryObject;
    procedure CheckInactive;

    // A unique ID identifying this query among all the queries of this connection
    // QueryID is attributed when the Connection is assigned and set to -1 when there is no Connection
    property QueryID: Integer read FQueryID;

    // The SQL text with macros expanded, as it will be sent to the server
    property RealSQL: string read FRealSQL;
    procedure Close;
    procedure Next;
    procedure Prepare;
    procedure UnPrepare;

    // Execute the query (synchronously). If the database connection is inactive, or if
    // it gets cut during execution, the OnConnectionLost event of the database is called
    procedure Exec;

    // Indicates whether a macro by the specified name exists
    function MacroExists(MacroName: string): Boolean;
    // Find a macro by its name. Returns nil if the macro is not found.
    function FindMacro(MacroName: string): TCcMacro;
    // Find a macro by its name. Throws an exception if the macro is not found.
    property Macro[ParamName: string]: TCcMacro read GetMacro;
    // The number of macros defined in the query
    property MacroCount: Integer read GetMacroCount;

    // Indicates whether a parameter by the specified name exists
    function ParamExists(ParamName: string): Boolean;
    // Find a parameter by its name. Returns nil if the parameter is not found.
    function FindParam(Param: string): TCcField;
    // Find a parameter by its index. Throws an exception if the parameter is not found.
    property ParamByIndex[index: Integer]: TCcField read GetParamByIndex;
    // Find a parameter by its name. Throws an exception if the parameter is not found.
    property Param[ParamName: string]: TCcField read GetParam;
    // The number of parameters defined in the query
    property ParamCount: Integer read GetParamCount;

    // Indicates whether a field by the specified name exists
    function FieldExists(FieldName: string): Boolean;
    // Find a field by its name. Returns nil if the field is not found.
    function FindField(FieldName: string): TCcField;
    // Find a field by its index. Throws an exception if the field is not found.
    property FieldByIndex[index: Integer]: TCcField read GetFieldByIndex;
    // Find a field by its name. Throws an exception if the field is not found.
    property Field[FieldName: string]: TCcField read GetField;
    // The number of fields returned by the query
    property FieldCount: Integer read GetFieldCount;

    // Number or rows touched by the last insert, update or delete statement.
    // Returns -1 for select statements or for connectors that don't support it.
    property RowsAffected: Integer read GetRowsAffected;

    // Number of rows returned by the query
    property RecordCount: Integer read GetRecordCount;

    // Eof is true after Next is called on the last record.
    property Eof: Boolean read GetEof;

    property Prepared: Boolean read FSQLPrepared;

    // Set Active to true in order to execute the query. Same as Exec.
    property Active: Boolean read FActive write SetActive;

    // Properties is an all-purpose list of name/value pairs, that can be used for storing
    // and retrieving user properties associated with the query.
    property Properties: TStringList read FProperties;

    constructor Create(AOwner: TComponent); overload; override;
    constructor Create(Conn: TCcConnection; cName: string; Select: Boolean); overload; virtual;
    destructor Destroy; override;
  published
    // Indicates whether this query is returns a result set or not.
    // If your query is a select statement (i.e. returns a result set), you need to set
    // SelectStatement to true
    property SelectStatement: Boolean read FSelectStatement write FSelectStatement;

    // The CopyCat database connection to be used with this query
    property Connection: TCcConnection read FConnection write SetConnection;

    // Set ParamCheck to false for executing DDL statements, so that CopyCat won't attempt to
    // detect parameters in the SQL text
    property ParamCheck: Boolean read FParamCheck write SetParamCheck;

    // The SQL text of the query. The SQL can contain parameters, defined with a semi-colon (:param_name),
    // or macros, defined with a percentage (%macro_name). The difference is that a parameter is sent to the
    // server and allows the statement to be prepared once and executed multiple times with different values
    // of the parameter. A macro on the other hand is simply a place-holder in the SQL text and is replaced
    // by its value on the client side before getting sent to the server.
    property SQL: TStrings read FSQLWithMacros write SetSQL;
  end;

  TCcSysTable = (tabLog, tabConflicts, tabUsers);

  TCcDBAdaptor = class;
  TCcDBAdaptorClass = class of TCcDBAdaptor;

  // Summary:
  // Abstract database connection class.
  // Description:
  // TCcConnection is used by TCcReplicator and TCcConfig in order to acheive database
  // access component independence. Descendants of TCcConnection override the
  // NewDatabase, NewTransaction and NewQuery methods in order to provide database
  // connectivity for CopyCat.<p/>
  // <p/>
  // Thus, CopyCat can be used interchangeably with any database access components for
  // which a TCcConnection descendant has been written. Currently, FIBPlus, IBX, IBO and UIB
  // have been implemented. Support for other component sets (such as Zeos and DBX)
  // is also possible, and planned for future versions.
  TCcConnection = class(TComponent)
  private
    FDBName: TFileName;
    FOnConnectionLost: TCcExceptionNotifyEvent;
    FOnDestroyQueries: TNotifyEvent;
    FQueries: TStringList;
    FDBTypes: TStringList;
    FDBType: string;
    FDBVersion: string;
    FDBAdaptor: TCcDBAdaptor;
    FOnQueryExecute: TNotifyEvent;
    lStreamedDBType: Boolean;
    lStreamedDBVersion: Boolean;
    FConnectionParams: TStringList;
    FPooledQueries: TStringList;
    FQueryIDCounter: Integer;
    slReturnList: TStringList;
    procedure SetConnected(const Value: Boolean);
    procedure SetConnectionParams(const Value: TStringList);
    procedure QueryExecute(Sender: TObject);
    function GetDDLQuery(qryName: string): TCcQuery;
    function GetSelectQuery(qryName: string): TCcQuery;
    function GetUpdateQuery(qryName: string): TCcQuery;
    function GetDBType(cName: string): TCcDBAdaptorClass;
    function GetCanUseRowsAffected: Boolean;
    function GetQuery(qryName: string; SelectStatement: Boolean): TCcQuery;
  protected
    FReplicatingNode: string;
    FReplicatingNodePassword: string;
    FConnectionLost: Boolean;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    function GetConnected: Boolean;
    function GetConnectorConnected: Boolean; virtual;
    function GetInTransaction: Boolean; virtual;
    procedure AddQuery(qry: TCcQuery);
    procedure RemoveQuery(qry: TCcQuery);
    procedure ResetQueryObjects;
    procedure DoResetQueryObjects(NewValue: string); virtual;
    procedure SetDBType(const Value: string);
    procedure SetDBVersion(const Value: string);

    // Override to indicate whether of not this connector supports use
    // of rowsAffected property. Default value is true. This value may
    // be overridden by the adaptor if it does not support RowsAffected
    // See also: TCcDBAdaptor.UseRowsAffected, CanUseRowsAffected
    function RowsAffectedSupported: Boolean; virtual;

    // SignalConnectLost is called internally whenever the database connection is lost,
    // in order to reset the state of the connection object.
    procedure SignalConnectLost; virtual;

    // Descendant classes must call this procedure in order to register which database types they support
    procedure AddDBAdaptor(Adaptor: TCcDBAdaptorClass);
    procedure AddDBAdaptors(Adaptors: array of TCcDBAdaptorClass);

    procedure DoDisconnect; virtual;
    procedure DoConnect; virtual;
    procedure DoCommit; virtual;
    procedure DoCommitRetaining; virtual;
    procedure DoRollback; virtual;
    procedure DoRollbackRetaining; virtual;
    procedure DoStartTransaction; virtual;

    // DoCleanup is called just before the connection is destroyed
    // It should be over-ridden by descendants instead of the destructor for performing cleanup,
    // because the destructor of TCcConnection may perform database operations (if the connection is
    // still active), which descendants must still be able to perform.
    procedure DoCleanup; virtual;

    // Instantiates and returns a concrete TCcAbstractQueryObject descendant.
    // Note: This method must be over-ridden by TCcConnection descendants.
    function NewQueryObject(qry: TCcQuery; nID: Integer): TCcAbstractQueryObject; virtual;

    // Called immediately before opening the connection
    // Descendants can over-ride this method to provide special functionality before connecting
    procedure DoBeforeConnect; virtual;

  public

    function GetFieldType(tableName: string; FieldName: string): TFieldType;

    // Returns a managed query by name
    function FindQuery(cName: string): TCcQuery;

    // Name of the database
    // The exact format will depend on the underlying database type
    property DBName: TFileName read FDBName write FDBName;

    // Summary: Call ExecQuery to execute a query directly.
    // Description: ExecQuery creates a query with default options, executes the provided SQL,
    // and returns the number of rows affected.
    function ExecQuery(SQL: string): Integer;

    // Call RefreshNodes after inserting new nodes into RPL$USERS, in order to register them.
    // If you create nodes using TCcConfig.RegisterNode, this step is unnecessary.
    procedure RefreshNodes;

    procedure CheckDisconnected;
    // Clear the query cache associated with this connection
    procedure ClearQueries;

    procedure Loaded; override;
    procedure Assign(Source: TPersistent); override;
    function Gen_Id(GenName: string; Increment: Integer):
      {$IFDEF CC_D2K9}
     Int64;
  {$ELSE}
     Integer;
  {$ENDIF}

    // Maximum length of meta-data names for the selected database type
    function MaxDDLNameLength: Integer;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    // The currently selected database adaptor object
    property DBAdaptor: TCcDBAdaptor read FDBAdaptor;

    // Returns the list of supported database types.
    procedure DatabaseTypes(Databases: TStrings);

    // Returns the list of supported versions of the current database type.
    procedure DatabaseVersions(Versions: TStrings);

    // Get a query object by name
    // Description:
    // TCcConnection maintains a pool of TCcQuery objects for the current database
    // connection. Attempting to access a non-existing query will result in a new
    // TCcQuery object being created and returned.
    // This property returns select queries (to be used for SQL statement returning a result-set)
    // Note: This property is used internally in CopyCat, and shouldn't normally be needed
    // by application developpers.
    property SelectQuery[qryName: string]: TCcQuery read GetSelectQuery;

    // Get a query object by name
    // Description:
    // TCcConnection maintains a pool of TCcQuery objects for the current database
    // connection. Attempting to access a non-existing query will result in a new
    // TCcQuery object being created and returned.
    // This property returns update queries (to be used for SQL statement returning no result-set)
    // Note: This property is used internally in CopyCat, and shouldn't normally be needed
    // by application developpers.
    property UpdateQuery[qryName: string]: TCcQuery read GetUpdateQuery;

    // Gets a DDL managed query object by name, that is, a query with ParamCheck set to false.
    // Note: This property is used internally in CopyCat, and shouldn't normally be needed
    // by application developpers.
    property DDLQuery[qryName: string]: TCcQuery read GetDDLQuery;

    // Returns the list of tables in the database, including temporary tables.
    // Note: The TStringList returned is managed by the TCcConnection, and shouldn't be freed.
    function ListAllTables: TStringList;

    // Returns the list of tables in the database.
    // Note: The TStringList returned is managed by the TCcConnection, and shouldn't be freed.
    function ListTables: TStringList;

    // Returns the list of fields in the specified table
    // Note: The TStringList returned is managed by the TCcConnection, and shouldn't be freed.
    function ListTableFields(cTableName: string): TStringList;

    // Returns the list of fields in the specified table, excluding read-only fields
    // Note: The TStringList returned is managed by the TCcConnection, and shouldn't be freed.
    function ListUpdatableTableFields(cTableName: string): TStringList;

    // Returns the list of primary key fields in the specified table
    // Note: The TStringList returned is managed by the TCcConnection, and shouldn't be freed.
    function ListPrimaryKeys(cTableName: string): TStringList;

    // Returns the list of triggers in the database
    // Note: The TStringList returned is managed by the TCcConnection, and shouldn't be freed.
    function ListTriggers: TStringList;

    // Returns the list of fields to use as keys in tables with no primary keys.
    // Note: The TStringList returned is managed by the TCcConnection, and shouldn't be freed.
    function ListFieldsForNoPK(cTableName: string): TStringList;

    // Lists stored procedures that can be replicated, that is, procedures that don't return
    // any value.
    // Note: The TStringList returned is managed by the TCcConnection, and shouldn't be freed.
    function ListProcedures: TStringList;

    // Lists all stored procedures in the database.
    // Note: The TStringList returned is managed by the TCcConnection, and shouldn't be freed.
    function ListAllProcedures: TStringList;

    // Lists all the generators (sequences) defined in the database.
    // Note: The TStringList returned is managed by the TCcConnection, and shouldn't be freed.
    function ListGenerators: TStringList;

    // Lists the database-specific keywords that can't be used as field names
    // Any existing fields named using these keywords are excluded from replication
    function ListKeywordsForbiddenAsFieldNames: TStringList;

    // Commit transaction and disconnect from database
    procedure Disconnect;

    // Connect to database and start transaction
    procedure Connect;

    // Connect to database and start transaction, specifying the name of the
    // currently replicating node.
    procedure ConnectAsNode(NodeName: string; NodePassword: string);

    procedure Commit;
    procedure CommitRetaining;
    procedure Rollback;
    procedure RollbackRetaining;
    procedure StartTransaction;
    property InTransaction: Boolean read GetInTransaction;

    // Fired when the internal pool of database queries is about to be emptied.
    // Any pointers to these queries must be cleared, in order to avoid invalid references.
    // Note: TCcConnection handles actually destroying the queries.
    property OnDestroyQueries: TNotifyEvent read FOnDestroyQueries write FOnDestroyQueries;

    // Summary:
    // Node that is currently being replicated
    // Description:
    // ReplicatingNode hold the name of the node that is being replicated. If no
    // replication is active, ReplicatingNode will be empty.
    property ReplicatingNode: string read FReplicatingNode;
    // Summary:
    // Password of the replicating node
    // Description:
    // The password of this node when connecting to a remote CopyCat server (PHP or
    // Java). This is not the database connection password, but the password stored in
    // RPL$USERS on the remote server.
    property ReplicatingNodePassword: string read FReplicatingNodePassword;

    // List of database-specific connection parameters to use when opening a connection.
    // Descendants should add values to this list for every additional connection parameter that is needed.
    property ConnectionParams: TStringList read FConnectionParams write SetConnectionParams;

    // Type of database to connect to.
    property DBType: string read FDBType write SetDBType;
    // Version of the database.
    property DBVersion: string read FDBVersion write SetDBVersion;

    // Determines whether the current combination of connector and db adaptor can
    // support use of rowsaffected property
    property CanUseRowsAffected: Boolean read GetCanUseRowsAffected;
  published
    // Return the name of the database access component set for which this connection type is designed.
    // Note: This method must be over-ridden by TCcConnection descendants.
    class function ConnectorName: string; virtual;
    property Connected: Boolean read GetConnected write SetConnected stored False;
    { ******************************************************************
      * Summary:                                                      *
      * Fired upon database connection loss.                          *
      * Description:                                                  *
      * OnConnectionLost gets called when the database connection gets*
      * abruptly cut. It does not occur however if the connection is  *
      * closed explicitly with the Connected property.                *
      ***************************************************************** }
    property OnConnectionLost: TCcExceptionNotifyEvent read FOnConnectionLost write FOnConnectionLost;
    // This event is fired whenever a query is executed using this connection.
    property OnQueryExecute: TNotifyEvent read FOnQueryExecute write FOnQueryExecute;
  end;

  ECcLostConnection = class(Exception)
  private
    FConnection: TCcConnection;
  public
    constructor Create(Conn: TCcConnection);
    property Connection: TCcConnection read FConnection;
  end;

  // TCcDBAdaptor is the abstract ancestor class for the adaptor classes providing database-specific features
  // for each of the supported database types. You can access the DBAdaptor of your database connection by using
  // the TCcConnection.DBAdaptor property.
  TCcDBAdaptor = class
  private
    FVersion: string;
    FSupportedVersions: TStringList;
  protected
    Query: TStringList;
    FConnection: TCcConnection;
    procedure ExecConfQuery;
    procedure SetVersion(const Value: string); virtual;
    procedure RegisterVersions(Versions: array of string);
    function MaxDDLNameLength: Integer; virtual;

    function ListFieldNames(slFields: TStringList; SourceDBAdaptor: TCcDBAdaptor; prefix: String): String;
    function GetFieldTypeSQLText(FieldName, TableName : String): String;virtual;

    // Override to detect error messages that should be interpreted as a connection loss
    function CheckConnectionLossException(E: Exception): Boolean; virtual;

    // Should be implemented by descending classes in order to indicate whether to use RowsAffected during replication or not.
    // See also: UseRowsAffected
    function GetUseRowsAffected: Boolean; virtual;

    // InitConnection is called by the TCcConnection as soon as a connection
    // has been established, in order to allow database-specific connection initialization.
    procedure InitConnection; virtual;

    // InitTransaction is called by the TCcConnection immediately after a new transaction
    // has been started, in order to allow database-specific transaction initialization.
    procedure InitTransaction; virtual;

    // CleanupConnection is called by the TCcConnection before dropping a connection,
    // in order to allow database-specific connection cleanup.
    procedure CleanupConnection; virtual;

    // CleanupTransaction is called by the TCcConnection before closing a transaction,
    // in order to allow database-specific transaction cleanup.
    procedure CleanupTransaction; virtual;

    function GetCurrentTimeStampSQL: string; virtual;

    // Descendants can override GetQuoteMetadata to indicate whether this database requires quoted meta-data or not
    // By default, if not overridden, we assume that it's unnecessary
    function GetQuoteMetadata: Boolean; virtual;

    // BeforeConnect is called just before connecting to the database, in order for
    // descendants set any necessary to database-specific connection parameters
    // See also: TCcConnection.ConnectionParams
    procedure BeforeConnect; virtual;

    function GetGeneratorValue(GenName: string; Increment: Integer):
      {$IFDEF CC_D2K9}
     Int64;
  {$ELSE}
     Integer;
  {$ENDIF}virtual;

    // Override DoMetaQuote to change the way identifiers are quoted.
    // By default, if QuoteMetadata is true, identifiers (table and field names) are surrounded by double quotes,
    // unless the identifier is in all-caps.
    function DoMetaQuote(Identifier: string): string; virtual;

    // DoRegisterNode is called every time a new node is created by calling TCcConfig.RegisterNode,
    // or whenever a newly created node has been discovered using TCcConnection.RefreshNodes.
    // Descendants should override this method if they need to do special database-specific
    // processing to register a new node (other than inserting it into RPL$USERS, which is done by TCcConfig.RegisterNode).
    procedure DoRegisterNode(NodeName: string); virtual;

    procedure DoListTables(list: TStringList; IncludeTempTables: Boolean); virtual;
    procedure DoListTableFields(cTableName: string; list: TStringList); virtual;
    procedure DoListUpdatableTableFields(cTableName: string; list: TStringList); virtual;
    procedure DoListPrimaryKeys(cTableName: string; list: TStringList); virtual;
    procedure DoListTriggers(list: TStringList); virtual;
    procedure DoListProcedures(list: TStringList); virtual;
    procedure DoListAllProcedures(list: TStringList); virtual;
    procedure DoListGenerators(list: TStringList); virtual;
    procedure DoListFieldsForNoPK(cTableName: string; list: TStringList); virtual;

    procedure DoListKeywordsForbiddenAsFieldNames(list: TStringList); virtual;
  public
    function SubStringFunction(str: String; start, length: Integer): String; virtual;
    function ConcatenationOperator: String; virtual;

    procedure ExecutingReplicationQuery(cTableName, queryType: String;
      fieldList: TStringList);virtual;
    procedure ExecutedReplicationQuery(cTableName, queryType: String;
      fieldList: TStringList);virtual;
    procedure ExecutingReplicationQuerySQL(cTableName, queryType: String;
      query: TCcQuery);virtual;

    // Override SupportsInsertOrUpdate if this database type supports the insert INSERT OR UPDATE statement, or some other equivalent
    // Override GetInsertOrUpdateSQL as well to provide an implementation
    function SupportsInsertOrUpdate: Boolean;virtual;

    // Override GetInsertOrUpdateSQL if this database type supports the insert INSERT OR UPDATE statement, or some other equivalent
    // Returns a full SQL statement if supported.
    function GetInsertOrUpdateSQL(slFields: TStringList; sourceDBAdaptor: TCcDBAdaptor; keys: TCcCustomKeyRing; tableName: String): string;virtual;

    // Grants full rights to specified table to public
    // Used internally to give rights to RPL$ tables
    // Override if necessary to provide database-specific syntax
    procedure GrantRightsToTable(tableName: string); virtual;

    procedure DropGenerator(cGeneratorName: string); virtual;

    // Indicates whether this database type supports the RowsAffected property
    // If so, as with Interbase/Firebird, the RowsAffected property will be used during replication
    // to determine whether an update or an insert should be performed (i.e. an update will be performed, and
    // if RowsAffected = 0, an insert will be performed as well).
    // If not, as with MySQL, a query will systematically be executed first in order to determine whether the record exists or not
    // in the destination database, thus slightly hurting performance.
    property UseRowsAffected: Boolean read GetUseRowsAffected;

    // Indicates whether this database type supports SQL generators (sequences)
    function SupportsGenerators: Boolean; virtual;

    // Used internally for quoting meta-data identifiers.
    class function GetAdaptorName: string; virtual;
    // MetaQuote surrounds the provided identifier with the quote marks required by this database (double-quote by default),
    // if it's supported by this database. If not, the identifier is simply returned.
    function MetaQuote(Identifier: string): string; overload;
    function MetaQuote(Identifier: string; SourceDBAdaptor: TCcDBAdaptor): string; overload;

    // QuoteMetadata indicates whether this database supports quoted metadata.
    // Description: If QuoteMetadata is false, all table and field names will be handled case-insensitively.
    // If QuoteMetadata is true, the case and special characters of the identifier names are preserved and used quoted in queries.
    property QuoteMetadata: Boolean read GetQuoteMetadata;

    // Returns the unquoted name of the identifier
    // On most databases, that means the uppercase identifier, on others it's lowercase
    // This method is used internally for the CopyCat system tables and fields
    function UnQuotedIdentifier(Identifier: string): string; virtual;

    // This method is called when TCcConfig connects to a database, so as to allow
    // the database adaptor to create any necessary database-specific meta-data
    // (such as user-defined functions, etc).
    procedure CheckCustomMetadata; virtual;

    // This method is called after TCcConfig creates meta-data for a database, so as to allow
    // the database adaptor to create any necessary database-specific meta-data.
    // See also: CheckCustomMetadata
    procedure CheckExtraCustomMetadata; virtual;

    procedure RemoveCustomMetadata; virtual;
    procedure RemoveExtraCustomMetadata; virtual;

    function DeclareField(FieldName: string; FieldType: TFieldType;
      Length: Integer; NotNull: Boolean; PK: Boolean; AutoInc: Boolean): string; virtual;
    function DeclarePK(FieldNames: string): string; virtual;

    function FieldExists(cTableName, cFieldName: string): Boolean;
    function TableExists(cTableName: string): Boolean;
    function ProcedureExists(cProcName: string): Boolean;
    function TriggerExists(cTriggerName: string): Boolean;

    property CurrentTimeStampSQL: string read GetCurrentTimeStampSQL;
    property Version: string read FVersion write SetVersion;

    function GenDeclared(GenName: string): Boolean; virtual;
    procedure DeclareGenerator(GenName: string); virtual;

    // Called after the replication tables have been created, so that stored procedures,
    // or other dependant objects, can be declared.
    procedure CreateProcedures; virtual;

    procedure DropProcedures; virtual;

    procedure RemoveTriggers(qTable: TCcQuery); virtual;
    function GenerateTriggers(qTable: TCcQuery; qTableConf: TCcQuery; FailIfNoPK: Boolean; TrackFieldChanges: Boolean): Integer; virtual;

    function SQLFormatValue(Data: Variant; FieldType: TFieldType): string; virtual;

    function GetProcGenerator(ProcName: string; Params: TDataSet;
      OutputParam: string; FieldNames: TStringList): string; virtual;

    function GetGenerator(GenName: string; Increment: Integer): string; virtual;
    procedure GetProcParams(ProcName: string; Params: TDataSet; InputParam: Boolean); virtual;

    constructor Create(Conn: TCcConnection); virtual;
    destructor Destroy; override;

    function ConvertValue(Val: Variant; DataType: TFieldType): Variant; virtual;
    property SupportedVersions: TStringList read FSupportedVersions;
  end;

  TCcClassInfo = class
  public
    Name: string;
    ClassReference: TClass;
  end;

procedure RegisterDBConnector(ConnectorClass: TCcConnectionClass; ConnectorName: string);
function GetDBConnectorClass(cConnectorName: string): TCcConnectionClass;

var
  CcAvailableDBConnectors: TStringList;
  CcAvailableAdaptors: TList;

implementation

uses CCat, CcInterbase, CcMySQL, CcSQLServer, CcSQLite, CcNexusDB {$IFDEF CC_USEVARIANTS}, Variants {$ENDIF}
    , CcOracle;

procedure TCcQuery.ClearFields;
var
  i: Integer;
begin
  with FFields do
  begin
    for i := Count - 1 downto 0 do
    begin
      TCcField(Objects[i]).Free;
      Delete(i);
    end;
  end;
end;

procedure TCcQuery.ClearParams;
var
  i: Integer;
begin
  with FParams do
    for i := Count - 1 downto 0 do
    begin
      TCcField(Objects[i]).Free;
      Delete(i);
    end;
end;

procedure TCcQuery.Close;
begin
  if Assigned(Connection) then
    GetQueryObject.DoClose;
  FActive := False;
end;

constructor TCcQuery.Create(Conn: TCcConnection; cName: string; Select: Boolean);
begin
  Create(Conn);
  FQueryName := cName;
  SetConnection(Conn);
  SelectStatement := Select;
end;

constructor TCcQuery.Create(AOwner: TComponent);
begin
  inherited;
  FQueryID := -1;
  // FMetaSQL := sqlNone;
  FSQLPrepared := False;
  FParamCheck := True;
  FFields := TStringList.Create;
  FParams := TStringList.Create;
  FMacros := TStringList.Create;
  FProperties := TStringList.Create;

  FSQLWithMacros := TStringList.Create;
  TStringList(FSQLWithMacros).OnChange := SQLChanged;

  FMacroParser := TCcSqlParser.Create;
  FMacroParser.TokenChar := '%';

  SelectStatement := False;
end;

procedure TCcQuery.CreateField(cFieldName: string; FieldType: TFieldType;
  nSize: Integer);
var
  fField: TCcField;
begin
  fField := TCcField.Create(Self, cFieldName, FieldType, nSize, False);
  fField.FIndex := FFields.AddObject(cFieldName, fField);
end;

procedure TCcQuery.CreateParam(cFieldName: string; FieldType: TFieldType;
  nSize: Integer);
var
  fField: TCcField;
begin
  fField := TCcField.Create(Self, cFieldName, FieldType, nSize, True);
  fField.FIndex := FParams.AddObject(cFieldName, fField);
end;

procedure TCcQuery.ClearQueryObject;
begin
  if FActive then
    Close;
  UnPrepare;
  FQueryObject.Free;
  FQueryObject := nil;
end;

destructor TCcQuery.Destroy;
begin
  if FSQLPrepared and Assigned(Connection) then
    if Connection.Connected then
      UnPrepare;

  if Assigned(Connection) then
    Connection.RemoveQuery(Self);

  FreeFields;
  FreeParams;
  FreeMacros;

  FProperties.Free;
  FFields.Free;
  FParams.Free;
  FMacros.Free;
  if Assigned(FQueryObject) then
    FreeAndNil(FQueryObject);

  FreeAndNil(FSQLWithMacros);
  FreeAndNil(FMacroParser);
  inherited;
end;

procedure TCcQuery.Exec;
begin
  if Active then
    raise Exception.Create('Query already open!');
  if not FConnection.Connected then
  begin
    FConnection.SignalConnectLost;
  end;
  try
  if not FConnection.InTransaction then
    FConnection.StartTransaction;

    if not FSQLPrepared then
      Prepare;

    // Execute the query
    GetQueryObject.DoExec;

    FActive := True;

    if Eof then
      FRecordCount := 0
    else
      FRecordCount := 1;

    { //We now create the fields just after preparing }
    // Create the field objects
    InitFields;

    if Assigned(FOnExecute) then
      FOnExecute(Self);
  except
    on E: Exception do begin
      if not FConnection.Connected or FConnection.DBAdaptor.CheckConnectionLossException(e) then begin
        Close;
        FConnection.SignalConnectLost;
      end
      else
        raise;
    end;
  end;
end;

function TCcQuery.FieldExists(FieldName: string): Boolean;
begin
  Result := (FindField(FieldName) <> nil);
end;

function TCcQuery.GetEof: Boolean;
begin
  Result := GetQueryObject.GetEof;
end;

function TCcQuery.GetField(FieldName: string): TCcField;
begin
  Result := FindField(FieldName);
  if Result = nil then
    if name <> '' then
      raise Exception.Create('Field ' + FieldName + ' not found')
    else
      raise Exception.Create(Self.Name + ': Field ' + FieldName + ' not found');
end;

function TCcQuery.FindField(FieldName: string): TCcField;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to FFields.Count - 1 do
    if Trim(Uppercase(FFields[i])) = Trim(Uppercase(FieldName)) then
    begin
      Result := TCcField(FFields.Objects[i]);
      Break;
    end;
end;

function TCcQuery.GetFieldByIndex(index: Integer): TCcField;
begin
  Result := TCcField(FFields.Objects[index]);
end;

function TCcQuery.GetFieldCount: Integer;
begin
  Result := FFields.Count;
end;

function TCcQuery.GetParam(Param: string): TCcField;
begin
  if not FSQLPrepared then
    Prepare;

  Result := DoFindParam(Param);
  if Result = nil then
    if name <> '' then
      raise Exception.Create(Self.Name + ': Param ' + Param + ' not found!')
    else
      raise Exception.Create('Param ' + Param + ' not found!');
end;

function TCcQuery.FindParam(Param: string): TCcField;
begin
  if not FSQLPrepared then
    Prepare;
  Result := DoFindParam(Param);
end;

function TCcQuery.DoFindParam(Param: string): TCcField;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to FParams.Count - 1 do
    if Trim(Uppercase(FParams[i])) = Trim(Uppercase(Param)) then
    begin
      Result := TCcField(FParams.Objects[i]);
      Break;
    end;
end;

function TCcQuery.GetParamCount: Integer;
begin
  if not FSQLPrepared then
    Prepare;
  Result := FParams.Count;
end;

function TCcQuery.GetQueryObject: TCcAbstractQueryObject;
begin
  if not Assigned(FConnection) then
    raise Exception.Create('Database connection not assigned');
  if not Assigned(FQueryObject) then
    FQueryObject := FConnection.NewQueryObject(Self, FQueryID);

  Result := FQueryObject;
end;

function TCcQuery.GetRecordCount: Integer;
begin
  Result := FRecordCount;
end;

function TCcQuery.GetRowsAffected: Integer;
begin
  Result := GetQueryObject.GetRowsAffected;
end;

procedure TCcQuery.InitFields;
var
  slFieldList: TStringList;
  cFieldName: string;
  i: Integer;
begin
  ClearFields;
  slFieldList := TStringList.Create;
  try
    GetQueryObject.DoInitFields(slFieldList);
    for i := 0 to slFieldList.Count - 1 do
    begin
      cFieldName := slFieldList[i];
      if cFieldName <> '' then
        CreateField(cFieldName, GetQueryObject.GetFieldType(cFieldName, False), GetQueryObject.GetFieldSize(cFieldName, False));
    end;
  finally
    slFieldList.Free;
  end;
end;

procedure TCcQuery.InitParams;
var
  slParamList: TStringList;
  cParamName: string;
  lQuotesStripped: Boolean;
  cOrigParamName: string;
  i: Integer;
begin
  ClearParams;
  slParamList := TStringList.Create;
  try
    GetQueryObject.DoInitParams(slParamList);
    for i := 0 to slParamList.Count - 1 do
    begin
      lQuotesStripped := False;
      cParamName := slParamList[i];
      cOrigParamName := cParamName;
      if (Copy(cParamName, 1, 1) = '"') and (Copy(cParamName, Length(cParamName), 1) = '"') then begin
        cParamName := Copy(cParamName, 2, Length(cParamName)-2);
      end;

      if (cParamName <> '') and (DoFindParam(cParamName) = nil) then
        CreateParam(cParamName, GetQueryObject.GetFieldType(cOrigParamName, True), GetQueryObject.GetFieldSize(cOrigParamName, True));
    end;
  finally
    slParamList.Free;
  end;
end;

procedure TCcQuery.Next;
begin
  GetQueryObject.DoNext;
  if not Eof then
    Inc(FRecordCount);
end;

procedure TCcQuery.Notification(AComponent: TComponent; Operation: TOperation);
begin
  if Operation = opRemove then
  begin
    if AComponent = FConnection then
      SetConnection(nil);
  end;
  inherited;
end;

procedure TCcConnection.Notification(AComponent: TComponent; Operation: TOperation);
var
  i: Integer;
begin
  if Operation = opRemove then
  begin
    if FQueries <> nil then
      for i := 0 to FQueries.Count - 1 do
      begin
        if AComponent = FQueries.Objects[i] then
        begin
          FQueries.Delete(i);
          Break;
        end;
      end;

    if FPooledQueries <> nil then
      for i := 0 to FPooledQueries.Count - 1 do
      begin
        if AComponent = FPooledQueries.Objects[i] then
        begin
          FPooledQueries.Delete(i);
          Break;
        end;
      end;
  end;
  inherited;
end;

function TCcQuery.ParamExists(ParamName: string): Boolean;
begin
  Result := (FindParam(ParamName) <> nil);
end;

procedure TCcQuery.SetActive(const Value: Boolean);
begin
  if FActive = Value then
    Exit;
  if Value then
    Exec
  else
    Close;
end;

procedure TCcQuery.SetConnection(const Value: TCcConnection);
begin
  if FConnection = Value then
    Exit;

  if Active then
    Close;

  if FSQLPrepared then
    UnPrepare;

  if Assigned(FConnection) then
    FConnection.RemoveQuery(Self);

  FConnection := Value;

  // We clear the query object, because a new one has to be created with the new connection
  ClearQueryObject;

  if Assigned(FConnection) then
    FConnection.AddQuery(Self)
end;

procedure TCcQuery.CheckInactive;
begin
  if Active then
    raise Exception.Create('Cannot perform this operation on an active query');
end;

procedure TCcQuery.SetParamCheck(Value: Boolean);
begin
  FParamCheck := Value;
end;

procedure TCcQuery.SQLChanged(Sender: TObject);
begin
  // We want to avoid unpreparing if the SQL hasn't even changed
  if FSQLWithMacros.Text <> FOldSQLText then
  begin
    FOldSQLText := FSQLWithMacros.Text;
    if FSQLPrepared then
      UnPrepare;

    // Find Macros, if any
    CheckMacros(FSQLWithMacros.Text);
  end;
end;

procedure TCcQuery.SetSQL(Value: TStrings);
begin
  if FSQLWithMacros.Text <> Value.Text then
    FSQLWithMacros.Assign(Value);
end;

constructor TCcSqlParser.Create;
begin
  FTokens := TStringList.Create;
end;

destructor TCcSqlParser.Destroy;
begin
  FTokens.Free;
  inherited;
end;

function TCcSqlParser.GetOffset(nIndex: Integer): Integer;
var
  cValue: string;
begin
  cValue := Copy(FTokens[nIndex], Pos('=', FTokens[nIndex]) + 1, Length(FTokens[nIndex]));
  Result := StrToInt(Copy(cValue, 1, Pos(',', cValue) - 1));
end;

function TCcSqlParser.GetQuoteCount(nIndex: Integer): Integer;
var
  cValue: string;
begin
  cValue := Copy(FTokens[nIndex], Pos('=', FTokens[nIndex]) + 1, Length(FTokens[nIndex]));
  Result := StrToInt(Copy(cValue, Pos(',', cValue) + 1, Length(cValue)));
end;

function TCcSqlParser.GetToken(index: Integer): string;
begin
  Result := FTokens.Names[index];
end;

function TCcSqlParser.GetTokenCount: Integer;
begin
  Result := FTokens.Count;
end;

procedure TCcSqlParser.Parse(SQLText: string);
var
  CurrentChar: Char;
  MacroName: string;
  InMacroName: Boolean;
  NewToken: Boolean;
  i: Integer;
  InQuote: Boolean;
  nQuoteCount: Integer;

const
  TokenChars = ['a' .. 'z', 'A' .. 'Z', '0' .. '9', '_', '$'];

  procedure MacroFinished;
  var
    nOffset: Integer;
  begin
    if InMacroName then
    begin
      nOffset := i - Length(MacroName) - 1 - nQuoteCount;

      // On NextGen compilers (iOS / Android), strings are 0-indexed, but since Copy and Pos
      // are still 1-indexed, we need to add 1 to the offset
{$IFDEF NEXTGEN}
      nOffset := nOffset + 1;
{$ENDIF}
      // The current value of i corresponds to the first character after the macro name
      // So we take i - length(MacroName) - 1, so as to correspond to the '%' before the macro name.
      FTokens.Add(MacroName + '=' + IntToStr(nOffset) + ',' + IntToStr(nQuoteCount));
    end;
  end;

begin
  FTokens.Clear;
  InMacroName := False;
  NewToken := True;
  InQuote := False;
  nQuoteCount := 0;
  for i := {$IFDEF NEXTGEN}0 to high({$ELSE}1 to Length({$ENDIF}SQLText) do
  begin
    CurrentChar := SQLText[i];

    if (CurrentChar = '%') and NewToken then
    begin
      InMacroName := True;
      NewToken := False;
      InQuote := False;
      nQuoteCount := 0;
      Continue;
    end;

    if (CurrentChar = '"') or (CurrentChar = '[') or (CurrentChar = ']') then
    begin
      InQuote := not InQuote;
      Inc(nQuoteCount);
    end
{$IFDEF CC_D2K9}
    else if CharInSet(CurrentChar, TokenChars) or InQuote
{$ELSE}
    else if (CurrentChar in TokenChars) or InQuote
{$ENDIF CC_D2K9}
    then
    begin
      if InMacroName then
        MacroName := MacroName + CurrentChar;
      NewToken := False;
    end
    else
    begin
      NewToken := True;
      MacroFinished;
      MacroName := '';
      InMacroName := False;
    end;
  end;
  MacroFinished;
end;

function TCcQuery.ApplyMacros(cSQL: string): string;
var
  nCurrentOffset, Offset, QuoteCount, i: Integer;
  MacroName: string;
begin
  nCurrentOffset := 1;
  Result := '';
  FMacroParser.Parse(cSQL);

  for i := 0 to FMacroParser.TokenCount - 1 do
  begin
    MacroName := FMacroParser.Token[i];
    Offset := FMacroParser.Offset[i];
    QuoteCount := FMacroParser.QuoteCount[i];

    // Set the value of the macro
    Result := Result + Copy(cSQL, nCurrentOffset, Offset - nCurrentOffset) + Macro[MacroName].Value;
    nCurrentOffset := Offset + Length(MacroName) + 1 + QuoteCount;
  end;

  // Add the remaning SQL after the last macro
  Result := Result + Copy(cSQL, nCurrentOffset, Length(cSQL));
end;

procedure TCcQuery.FreeMacros;
var
  i: Integer;
begin
  for i := FMacros.Count - 1 downto 0 do
  begin
    TCcMacro(FMacros.Objects[i]).Free;
    FMacros.Delete(i);
  end;
end;

procedure TCcQuery.FreeParams;
var
  i: Integer;
begin
  for i := FParams.Count - 1 downto 0 do
  begin
    TCcField(FParams.Objects[i]).Free;
    FParams.Delete(i);
  end;
end;

procedure TCcQuery.FreeFields;
var
  i: Integer;
begin
  for i := FFields.Count - 1 downto 0 do
  begin
    TCcField(FFields.Objects[i]).Free;
    FFields.Delete(i);
  end;
end;

procedure TCcQuery.Prepare;
begin
  if not FConnection.Connected then
    FConnection.SignalConnectLost;

  try
  FRealSQL := FSQLWithMacros.Text;

  // Apply macro values to SQL
  if MacroCount > 0 then
    FRealSQL := ApplyMacros(FRealSQL);

  // Apply the real SQL text, with Macros replaced by their values, to the underlying query,
  // and let the statement be prepared, if necessary, by the underlying provider
  GetQueryObject.SetParamCheck(FParamCheck);
  GetQueryObject.DoPrepare(FRealSQL);

  // Initialise the list of TCcParam objects
  InitParams;

  // From this point on, the user can't change the macros any more, nor change the SQL
  FSQLPrepared := True;
  except
    on E: Exception do begin
      if not FConnection.Connected or FConnection.DBAdaptor.CheckConnectionLossException(e) then begin
        FConnection.SignalConnectLost;
      end
      else
        raise;
    end;
  end;
end;

function TCcQuery.GetMacro(MacroName: string): TCcMacro;
begin
  Result := FindMacro(MacroName);
  if Result = nil then
    if name <> '' then
      raise Exception.Create(Self.Name + ': Macro ' + MacroName + ' not found!')
    else
      raise Exception.Create('Macro ' + MacroName + ' not found!');
end;

function TCcQuery.FindMacro(MacroName: string): TCcMacro;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to FMacros.Count - 1 do
    if Trim(Uppercase(FMacros[i])) = Trim(Uppercase(MacroName)) then
    begin
      Result := TCcMacro(FMacros.Objects[i]);
      Break;
    end;
end;

function TCcQuery.GetMacroCount: Integer;
begin
  Result := FMacros.Count;
end;

function TCcQuery.MacroExists(MacroName: string): Boolean;
begin
  Result := (FindMacro(MacroName) <> nil);
end;

procedure TCcQuery.UnPrepare;
begin
  if FSQLPrepared then
  begin
    GetQueryObject.DoUnPrepare;
    FreeParams;
    FRealSQL := '';
    FSQLPrepared := False;
  end;
end;

procedure TCcField.Clear;
begin
  SetValue(Null);
end;

constructor TCcField.Create(Query: TCcQuery; cFieldName: string;
  FieldType: TFieldType; nSize: Integer; lParam: Boolean);
begin
  FQuery := Query;
  FSize := nSize;
  FDataType := FieldType;
  FFieldName := cFieldName;
  FIsParam := lParam;
  FIndex := -1;
end;

function TCcField.GetAsCurrency: Currency;
begin
  Result := 0;
  if not IsNull then
    Result := Value;
end;

function TCcField.GetAsDateTime: TDateTime;
begin
  Result := 0;

  // SQLite doesn't know what a datatype is...
  // Aggregate non-table fields in a select are returned by FireDAC as ftWideString
  // cf. http://docwiki.embarcadero.com/RADStudio/XE5/en/SQLite_Database_Questions_(FireDAC)
  if not(FDataType in [ftDateTime, {$IFDEF CC_D6} ftTimeStamp,{$ENDIF} {$IFDEF CC_D2K6}ftOraTimeStamp, ftOraInterval,{$ENDIF}
    {$IFDEF CC_D2K13}ftTimeStampOffset, {$ENDIF}ftDate, ftTime]) then
    FDataType := ftDateTime;

  if not IsNull then
    Result := Value;
end;

function TCcField.GetAsFloat: Double;
begin
  Result := 0;
  if not IsNull then
    Result := Value;
end;

function TCcField.GetAsInteger: Integer;
begin
  Result := 0;
  if not IsNull then
    Result := Value;
end;

function TCcField.GetAsString: string;
begin
  Result := '';
  if not IsNull then
    Result := Value;
end;

function TCcField.GetIsNull: Boolean;
begin
  Result := VarIsNull(Value) or VarIsEmpty(Value);
end;

function TCcField.GetValue: Variant;
begin
  if (not FIsParam) and (not FQuery.Active) then
    Result := Null
  else
    Result := FQuery.GetQueryObject.GetFieldValue(Self);
  Result := FQuery.Connection.DBAdaptor.ConvertValue(Result, DataType);
end;

procedure TCcField.SetAsCurrency(Val: Currency);
begin
  Value := Val;
end;

procedure TCcField.SetAsDateTime(Val: TDateTime);
begin
  Value := Val;
end;

procedure TCcField.SetAsFloat(Val: Double);
begin
  Value := Val;
end;

procedure TCcField.SetAsInteger(Val: Integer);
begin
  Value := Val;
end;

procedure TCcField.SetAsString(Val: string);
begin
  Value := Val;
end;

procedure TCcField.SetValue(Val: Variant);
begin
  FQuery.GetQueryObject.SetFieldValue(Self, FQuery.Connection.DBAdaptor.ConvertValue(Val, DataType));
end;

procedure TCcField.SetValueAsType(Val: Variant; AFieldType: TFieldType);
begin
  FDataType := AFieldType;
  SetValue(Val);
end;

{ TCcConnection }

procedure TCcConnection.AddQuery(qry: TCcQuery);
begin
  Inc(FQueryIDCounter);
  qry.OnExecute := QueryExecute;
  qry.FQueryID := FQueryIDCounter;

  // We set FQueryName to reflect the unique name of the query, considering that
  // there may be multiple queries with the same Name in the TCcConnection
  FQueries.AddObject(IntToStr(qry.QueryID), qry);
  qry.FreeNotification(Self);
end;

procedure TCcConnection.Assign(Source: TPersistent);
begin
  if Source is TCcConnection then
    with TCcConnection(Source) do
    begin
      // Copy all published properties from source to Self
      Self.ConnectionParams.Assign(ConnectionParams);
      Self.DBType := DBType;
      Self.DBVersion := DBVersion;
      Self.OnConnectionLost := OnConnectionLost;
      Self.OnQueryExecute := OnQueryExecute;
      Self.OnDestroyQueries := OnDestroyQueries;
    end
  else
    inherited;
end;

procedure TCcConnection.Disconnect;
var
  i: Integer;
  qry: TCcQuery;
begin
  if Connected then
  begin
    try
      if InTransaction then
        Commit;
      for i := 0 to FQueries.Count - 1 do
      begin
        qry := TCcQuery(FQueries.Objects[i]);
        if qry.Prepared
        then
          qry.UnPrepare;
      end;

      FDBAdaptor.CleanupConnection;
      DoDisconnect;
      FReplicatingNode := '';
      FReplicatingNodePassword := '';
    finally
      // FConnected := False;
    end;
  end
  else
    // Even if Connected is false, we try to force disconnection anyway, just in case
    // the underlying connector is still connected.
    DoDisconnect;
end;

procedure TCcConnection.Commit;
begin
  if not Connected then
    SignalConnectLost;
  try
    if InTransaction then
    begin
      FDBAdaptor.CleanupTransaction;
      DoCommit;
      // FInTransaction := False;
    end;
  except
    on E: Exception do begin
      if not Connected or DBAdaptor.CheckConnectionLossException(e) then begin
        SignalConnectLost;
      end
    else
      raise;
  end;
end;
end;

procedure TCcConnection.CommitRetaining;
begin
  if not Connected then
    SignalConnectLost;
  try
    if InTransaction then begin
      FDBAdaptor.CleanupTransaction;
      DoCommitRetaining;
    end;
  except
    on E: Exception do begin
      if not Connected or DBAdaptor.CheckConnectionLossException(e) then begin
        SignalConnectLost;
      end
    else
      raise;
  end;
end;
end;

procedure TCcConnection.Connect;
begin
  ConnectAsNode('', '');
end;

procedure TCcConnection.ConnectAsNode(NodeName: string; NodePassword: string);
var
  InitOk: Boolean;
begin
  if not Connected then
  begin
    if FConnectionLost then begin
      FConnectionLost := False;
      try
        DoDisconnect;
      except
      end;
    end;

    // We call DoBeforeConnect to let descendants add before connection behavior, if necessary
    DoBeforeConnect;

    if not Assigned(FDBAdaptor) then
      raise Exception.Create('Database type must be set before connecting to database');

    FReplicatingNode := NodeName;
    FReplicatingNodePassword := NodePassword;

    InitOk := True;
    try
      // We call BeforeConnect to let the adaptor know that we're about to open a connection
      // in case there are any database-specific operations to do
      FDBAdaptor.BeforeConnect;

      DoConnect;

      StartTransaction;
      FDBAdaptor.InitConnection;
      InitOk := True;
    finally
      if not InitOk then
        Disconnect;
    end;
  end;
end;
                                                                                                     
constructor TCcConnection.Create(AOwner: TComponent);
begin
  inherited;
  FConnectionLost := False;
  FQueryIDCounter := 0;
  FDBTypes := TStringList.Create;
  FPooledQueries := TStringList.Create;
  FQueries := TStringList.Create;
  FConnectionParams := TStringList.Create;
  slReturnList := TStringList.Create;
end;

procedure TCcConnection.DatabaseTypes(Databases: TStrings);
var
  i: Integer;
begin
  Databases.Clear;
  for i := 0 to FDBTypes.Count - 1 do
    Databases.Add(FDBTypes[i]);
end;

procedure TCcConnection.DatabaseVersions(Versions: TStrings);
begin
  Versions.Clear;
  if not Assigned(FDBAdaptor) then
    Exit;
  Versions.Assign(FDBAdaptor.SupportedVersions);
end;

procedure TCcConnection.ResetQueryObjects;
var
  i: Integer;
begin
  DoResetQueryObjects(FDBType);
  for i := 0 to FQueries.Count - 1 do
    TCcQuery(FQueries.Objects[i]).ClearQueryObject;
end;

destructor TCcConnection.Destroy;
var
  i: Integer;
begin
  if InTransaction and Connected then
    try
      Commit;
    except
      // We ignore exceptions here because it doesn't really matter:
      // there's little sense in raising an exception inside the destructor.
    end;

  for i := FDBTypes.Count - 1 downto 0 do
    TCcClassInfo(FDBTypes.Objects[i]).Free;

  // NOTE: We do not own the queries referenced in FQueries.
  // Therefore, we must not free them, but we must notify them
  // that their Connection is invalid...
  for i := FQueries.Count - 1 downto 0 do
    // Setting the connection to nil implicitly calls RemoveQuery it from FQueries
    TCcQuery(FQueries.Objects[i]).Connection := nil;

  // However, we DO own the queries in FPooledQueries, and we must
  // therefore free them
  for i := FPooledQueries.Count - 1 downto 0 do
    TCcQuery(FPooledQueries.Objects[i]).Free;
  FreeAndNil(FPooledQueries);

  // Now we can safely free FQueries
  FreeAndNil(FQueries);

  FDBTypes.Free;
  FConnectionParams.Free;
  DoCleanup;
  FreeAndNil(FDBAdaptor);
  slReturnList.Clear;
  slReturnList.Free;
  inherited;
end;

procedure TCcConnection.DoResetQueryObjects(NewValue: string);
begin

end;

procedure TCcConnection.DoDisconnect;
begin

end;

procedure TCcConnection.DoCommit;
begin

end;

procedure TCcConnection.DoCommitRetaining;
begin

end;

procedure TCcConnection.DoConnect;
begin

end;

procedure TCcConnection.DoRollback;
begin

end;

procedure TCcConnection.DoRollbackRetaining;
begin

end;

procedure TCcConnection.DoStartTransaction;
begin

end;

function TCcConnection.ExecQuery(SQL: string): Integer;
var
  q: TCcQuery;
begin
  q := TCcQuery.Create(Self);
  try
    q.Connection := Self;
    q.SQL.Text := SQL;
    q.ParamCheck := False;
    q.Exec;
    Result := q.RowsAffected;
  finally
    q.Free;
  end;
end;

function TCcConnection.NewQueryObject(qry: TCcQuery; nID: Integer): TCcAbstractQueryObject;
begin
  raise Exception.Create('TCcConnection.NewQueryObject must be over-ridden by descendant class!');
end;

procedure TCcConnection.AddDBAdaptors(Adaptors: array of TCcDBAdaptorClass);
var
  i: Integer;
begin
  for i := 0 to high(Adaptors) do
    AddDBAdaptor(Adaptors[i]);
end;

procedure TCcConnection.AddDBAdaptor(Adaptor: TCcDBAdaptorClass);
var
  DBType: TCcClassInfo;
begin
  DBType := TCcClassInfo.Create;
  DBType.Name := Adaptor.GetAdaptorName;
  DBType.ClassReference := Adaptor;
  FDBTypes.AddObject(DBType.Name, DBType);
end;

procedure TCcConnection.RemoveQuery(qry: TCcQuery);
var
  nIndex: Integer;
begin
  qry.RemoveFreeNotification(Self);
  nIndex := FQueries.IndexOfObject(qry);
  if nIndex > -1 then
    FQueries.Delete(nIndex);
  qry.FQueryID := -1;
end;

procedure TCcConnection.Rollback;
begin
  if not Connected then
    SignalConnectLost;
  try
    if InTransaction then
    begin
      DoRollback;
      // FInTransaction := False;
    end;
  except
    on E: Exception do begin
      if not Connected or DBAdaptor.CheckConnectionLossException(e) then begin
        SignalConnectLost;
      end
    else
      raise;
  end;
end;
end;

procedure TCcConnection.RollbackRetaining;
begin
  if not Connected then
    SignalConnectLost;
  try
    if InTransaction then
      DoRollbackRetaining;
  except
    on E: Exception do begin
      if not Connected or DBAdaptor.CheckConnectionLossException(e) then begin
        SignalConnectLost;
      end
    else
      raise;
  end;
end;
end;

function TCcConnection.RowsAffectedSupported: Boolean;
begin
  Result := True;
end;

procedure TCcConnection.SetConnected(const Value: Boolean);
begin
  if Value = Connected then
    Exit;
  if Value then
    Connect
  else
    Disconnect;
end;

procedure TCcConnection.SetConnectionParams(const Value: TStringList);
begin
  with FConnectionParams do
  begin
    BeginUpdate;
    try
      Assign(Value);
    finally
      EndUpdate;
    end;
  end;
end;

procedure TCcConnection.CheckDisconnected;
begin
  if Connected then
    raise Exception.Create('Cannot perform this operation on an open connection');
end;

procedure TCcConnection.ClearQueries;
begin

end;

procedure TCcConnection.SetDBType(const Value: string);
var
  AdaptorClass: TCcDBAdaptorClass;
begin
  if (FDBType = Value) and (not lStreamedDBType) then
    Exit;

  if not(csLoading in ComponentState) then
  begin
    CheckDisconnected;

    AdaptorClass := GetDBType(Value);
    if AdaptorClass = nil then
      Exit;

    FreeAndNil(FDBAdaptor);
    // EmptyPool;
    FDBAdaptor := AdaptorClass.Create(Self);
    FDBAdaptor.Version := FDBVersion;
    lStreamedDBType := False;
    FDBType := Value;
    ResetQueryObjects;
  end
  else
  begin
    FDBType := Value;
    lStreamedDBType := True;
  end;
end;

procedure TCcConnection.SetDBVersion(const Value: string);
begin
  if (Value = FDBVersion) and (not lStreamedDBVersion) then
    Exit;

  if not(csLoading in ComponentState) then
  begin
    if Assigned(FDBAdaptor) then
    begin
      FDBAdaptor.Version := Value;
      ResetQueryObjects;
      lStreamedDBVersion := False;
    end;
  end
  else
    lStreamedDBVersion := True;
  FDBVersion := Value;
end;

procedure TCcConnection.SignalConnectLost;
var
  RaiseException: Boolean;
begin
  // Close connection and transaction
  // FConnected := False;
  // FInTransaction := False;

  // Destroy all queries, so as to avoid them keeping an erroneous state
  ResetQueryObjects;

  FConnectionLost := True;

  // Launch the OnConnectionLost event
  RaiseException := True;
  if Assigned(FOnConnectionLost) then
    FOnConnectionLost(Self, RaiseException);
  if RaiseException then
    raise ECcLostConnection.Create(Self);
end;

procedure TCcConnection.StartTransaction;
begin
  if not Connected then
    SignalConnectLost;
  try
    if not InTransaction then
    begin
      DoStartTransaction;
      // FInTransaction := True;
      FDBAdaptor.InitTransaction;
    end;
  except
    on E: Exception do begin
      if not Connected or DBAdaptor.CheckConnectionLossException(e) then begin
        SignalConnectLost;
      end
    else
      raise;
  end;
end;
end;

function TCcConnection.Gen_Id(GenName: string; Increment: Integer):
      {$IFDEF CC_D2K9}
     Int64;
  {$ELSE}
     Integer;
  {$ENDIF}
begin
  if not InTransaction then
    StartTransaction;
  if not DBAdaptor.GenDeclared(GenName) then
    raise Exception.Create('Generator ' + GenName + ' does not exist!');
  Result := DBAdaptor.GetGeneratorValue(GenName, Increment);
end;

class function TCcConnection.ConnectorName: string;
begin
  raise Exception.Create('Connector must provide a connector name');
end;

function TCcConnection.GetDBType(cName: string): TCcDBAdaptorClass;
var
  i: Integer;
  classinf: TCcClassInfo;
begin
  for i := 0 to FDBTypes.Count - 1 do
  begin
    if FDBTypes[i] = cName then
    begin
      classinf := TCcClassInfo(FDBTypes.Objects[i]);
      Result := TCcDBAdaptorClass(classinf.ClassReference);
      Exit;
    end;
  end;
  Result := nil;
end;

function TCcConnection.GetDDLQuery(qryName: string): TCcQuery;
begin
  Result := UpdateQuery[qryName];
  Result.ParamCheck := False;
end;

function TCcConnection.GetFieldType(tableName, FieldName: string): TFieldType;
var
  q: TCcQuery;
begin
  q := TCcQuery.Create(Self);
  try
    q.SelectStatement := True;
    q.Connection := Self; // SelectQuery['TCcConnection.GetFieldType'];
    q.Close;
    q.SQL.Text := DBAdaptor.GetFieldTypeSQLText(FieldName, tableName);
    q.Exec;
    Result := q.Field[FieldName].DataType;
  finally
    q.Free;
  end;
end;

function TCcConnection.GetQuery(qryName: string; SelectStatement: Boolean): TCcQuery;
var
  i: Integer;
begin
  i := FPooledQueries.IndexOf(qryName);
  if i = -1 then
  begin
    Result := TCcQuery.Create(Self, qryName, SelectStatement);
    FPooledQueries.AddObject(qryName, Result);
  end
  else
    Result := (FPooledQueries.Objects[i] as TCcQuery);
end;

procedure TCcConnection.Loaded;
begin
  inherited;
  SetDBType(DBType);
  SetDBVersion(DBVersion);
end;

procedure TCcConnection.QueryExecute(Sender: TObject);
begin
  if Assigned(OnQueryExecute) then
    OnQueryExecute(Sender);
end;

function TCcConnection.MaxDDLNameLength: Integer;
begin
  if Assigned(DBAdaptor) then
    Result := DBAdaptor.MaxDDLNameLength
  else
    Result := -1;
end;

function TCcConnection.ListTables: TStringList;
begin
  slReturnList.Clear;
  FDBAdaptor.DoListTables(slReturnList, False);
  Result := slReturnList;
end;

function TCcConnection.ListAllTables: TStringList;
begin
  slReturnList.Clear;
  FDBAdaptor.DoListTables(slReturnList, True);
  Result := slReturnList;
end;

function TCcConnection.ListGenerators: TStringList;
begin
  slReturnList.Clear;
  FDBAdaptor.DoListGenerators(slReturnList);
  Result := slReturnList;
end;

function TCcConnection.ListProcedures: TStringList;
begin
  slReturnList.Clear;
  FDBAdaptor.DoListProcedures(slReturnList);
  Result := slReturnList;
end;

function TCcConnection.ListTriggers: TStringList;
begin
  slReturnList.Clear;
  FDBAdaptor.DoListTriggers(slReturnList);
  Result := slReturnList;
end;

function TCcConnection.ListPrimaryKeys(cTableName: string): TStringList;
begin
  slReturnList.Clear;
  FDBAdaptor.DoListPrimaryKeys(cTableName, slReturnList);
  Result := slReturnList;
end;

function TCcConnection.ListTableFields(cTableName: string): TStringList;
begin
  slReturnList.Clear;
  FDBAdaptor.DoListTableFields(cTableName, slReturnList);
  Result := slReturnList;
end;

function TCcConnection.ListUpdatableTableFields(
  cTableName: string): TStringList;
begin
  slReturnList.Clear;
  FDBAdaptor.DoListUpdatableTableFields(cTableName, slReturnList);
  Result := slReturnList;
end;

function TCcConnection.ListAllProcedures: TStringList;
begin
  slReturnList.Clear;
  FDBAdaptor.DoListAllProcedures(slReturnList);
  Result := slReturnList;
end;

function TCcConnection.ListKeywordsForbiddenAsFieldNames: TStringList;
begin
  slReturnList.Clear;
  FDBAdaptor.DoListKeywordsForbiddenAsFieldNames(slReturnList);
  Result := slReturnList;
end;

function TCcConnection.ListFieldsForNoPK(cTableName: string): TStringList;
var
  slExcludedFields: TStringList;
begin
  slReturnList.Clear;
  slExcludedFields := TStringList.Create;
  try
    FDBAdaptor.DoListKeywordsForbiddenAsFieldNames(slExcludedFields);
    FDBAdaptor.DoListFieldsForNoPK(cTableName, slReturnList);
    RemoveItemsInCommon(slReturnList, slExcludedFields);
  finally
    slExcludedFields.Free;
  end;
  Result := slReturnList;
end;

function TCcConnection.GetCanUseRowsAffected: Boolean;
begin
  Result := DBAdaptor.UseRowsAffected and RowsAffectedSupported;
end;

function TCcConnection.GetConnected: Boolean;
begin
  Result := (not FConnectionLost) and GetConnectorConnected;
end;

function TCcConnection.GetConnectorConnected: Boolean;
begin
  Result := False;
end;

function TCcConnection.GetInTransaction: Boolean;
begin
  Result := False;
end;

function TCcConnection.FindQuery(cName: string): TCcQuery;
var
  i: Integer;
begin
  i := FPooledQueries.IndexOf(cName);
  if i <> -1 then
    Result := (FPooledQueries.Objects[i] as TCcQuery)
  else
    Result := nil;
end;

function TCcConnection.GetSelectQuery(qryName: string): TCcQuery;
begin
  Result := GetQuery(qryName, True);
end;

function TCcConnection.GetUpdateQuery(qryName: string): TCcQuery;
begin
  Result := GetQuery(qryName, False);
end;

{ TCcDBAdaptor }

function TCcDBAdaptor.CheckConnectionLossException(E: Exception): Boolean;
begin
  Result := False;
end;

procedure TCcDBAdaptor.CheckCustomMetadata;
begin

end;

procedure TCcDBAdaptor.CheckExtraCustomMetadata;
begin

end;

constructor TCcDBAdaptor.Create(Conn: TCcConnection);
begin
  Query := TStringList.Create;
  FConnection := Conn;
  FSupportedVersions := TStringList.Create;
end;

procedure TCcDBAdaptor.CreateProcedures;
begin

end;

function TCcDBAdaptor.DeclareField(FieldName: string; FieldType: TFieldType;
  Length: Integer; NotNull: Boolean; PK: Boolean; AutoInc: Boolean): string;
begin

end;

procedure TCcDBAdaptor.DeclareGenerator(GenName: string);
begin

end;

destructor TCcDBAdaptor.Destroy;
begin
  FSupportedVersions.Free;
  Query.Free;
  inherited;
end;

function TCcDBAdaptor.GenDeclared(GenName: string): Boolean;
begin
  Result := False;
end;

function TCcDBAdaptor.GenerateTriggers(qTable: TCcQuery; qTableConf: TCcQuery; FailIfNoPK: Boolean; TrackFieldChanges: Boolean): Integer;
begin

end;

function TCcDBAdaptor.GetCurrentTimeStampSQL: string;
begin

end;

function TCcDBAdaptor.GetFieldTypeSQLText(FieldName, TableName : String): String;
begin
  Result := 'select ' + MetaQuote(FieldName) + ' from ' + MetaQuote(tableName) + ' where 0=1';
end;

function TCcDBAdaptor.GetGenerator(GenName: string;
  Increment: Integer): string;
begin

end;

function TCcDBAdaptor.GetGeneratorValue(GenName: string;
  Increment: Integer):
       {$IFDEF CC_D2K9}
     Int64;
  {$ELSE}
     Integer;
  {$ENDIF}
begin
  raise Exception.Create('Function not implemented: GetGeneratorValue');
end;

function TCcDBAdaptor.GetInsertOrUpdateSQL(slFields: TStringList;
  sourceDBAdaptor: TCcDBAdaptor; keys: TCcCustomKeyRing; tableName: String): string;
begin

end;

function TCcDBAdaptor.GetProcGenerator(ProcName: string; Params: TDataSet;
  OutputParam: string; FieldNames: TStringList): string;
begin
  raise Exception.Create('Function not implemented: GetProcGenerator');
end;

procedure TCcDBAdaptor.GetProcParams(ProcName: string; Params: TDataSet; InputParam: Boolean);
begin

end;

{ function TCcDBAdaptor.GetSQL(SQLType: TCcMetaSQL): String;
  begin

  end; }

procedure TCcDBAdaptor.InitConnection;
begin

end;

procedure TCcDBAdaptor.InitTransaction;
begin

end;

function TCcDBAdaptor.MaxDDLNameLength: Integer;
begin
  Result := 31;
end;

procedure TCcDBAdaptor.ExecConfQuery;
begin
  try
    with FConnection.UpdateQuery['qConfigQuery'] do
    begin
      Close;
      SQL.Text := Query.Text;
      ParamCheck := False;
      Exec;
    end;
  finally
    Query.Clear;
  end;
end;

procedure TCcDBAdaptor.ExecutedReplicationQuery(cTableName, queryType: String;
  fieldList: TStringList);
begin

end;

procedure TCcDBAdaptor.ExecutingReplicationQuery(cTableName, queryType: String;
  fieldList: TStringList);
begin

end;

procedure TCcDBAdaptor.ExecutingReplicationQuerySQL(cTableName,
  queryType: String; query: TCcQuery);
begin

end;

function TCcDBAdaptor.FieldExists(cTableName, cFieldName: string): Boolean;
var
  list: TStringList;
  i: Integer;
begin
  list := FConnection.ListTableFields(cTableName);
  Result := False;
  for i := 0 to list.Count - 1 do
  begin
    if QuoteMetadata then
      Result := AnsiSameStr(list[i], cFieldName)
    else
      Result := AnsiSameText(list[i], cFieldName);
    if Result then
      Break;
  end;

  { with FConnection.MetaQuery[sqlFindTableField] do begin
    Close;
    Param['table_name'].AsString := Trim(cTableName);
    Param['field_name'].AsString := Trim(cFieldName);
    Exec;
    if Field['rec_Count'].AsInteger > 0 then
    Result := True
    else
    Result := False;
    end; }
end;

function TCcDBAdaptor.TriggerExists(cTriggerName: string): Boolean;
var
  list: TStringList;
  i: Integer;
begin
  list := FConnection.ListTriggers;
  Result := False;
  for i := 0 to list.Count - 1 do
  begin
    if QuoteMetadata then
      Result := AnsiSameStr(list[i], cTriggerName)
    else
      Result := AnsiSameText(list[i], cTriggerName);
    if Result then
      Break;
  end;
  { with FConnection.MetaQuery[sqlFindTrigger] do begin
    Close;
    Param['trigger_name'].AsString := Trim(cTriggerName);
    Exec;
    if Field['rec_Count'].AsInteger > 0 then
    Result := True
    else
    Result := False;
    end; }
end;

function TCcDBAdaptor.UnQuotedIdentifier(Identifier: string): string;
begin
  Result := Uppercase(Identifier);
end;

function TCcDBAdaptor.ProcedureExists(cProcName: string): Boolean;
var
  list: TStringList;
  i: Integer;
begin
  list := FConnection.ListAllProcedures;
  Result := False;
  for i := 0 to list.Count - 1 do
  begin
    if QuoteMetadata then
      Result := AnsiSameStr(list[i], cProcName)
    else
      Result := AnsiSameText(list[i], cProcName);
    if Result then
      Break;
  end;
  { with FConnection.MetaQuery[sqlFindProc] do begin
    Close;
    Param['proc_name'].AsString := Trim(cProcName);
    Exec;
    if Field['rec_COUNT'].AsInteger > 0 then
    Result := True
    else
    Result := False;
    end; }
end;

function TCcDBAdaptor.TableExists(cTableName: string): Boolean;
var
  list: TStringList;
  i: Integer;
begin
  list := FConnection.ListAllTables;
  Result := False;
  for i := 0 to list.Count - 1 do
  begin
    if QuoteMetadata then
      Result := AnsiSameStr(list[i], cTableName)
    else
      Result := AnsiSameText(list[i], cTableName);
    if Result then
      Break;
  end;

  { with FConnection.MetaQuery[sqlFindTable] do begin
    Close;
    Param['table_name'].AsString := Trim(cTableName);
    Exec;
    if Field['rec_COUNT'].AsInteger > 0 then
    Result := True
    else
    Result := False;
    end; }
end;

procedure TCcDBAdaptor.RegisterVersions(Versions: array of string);
var
  i: Integer;
begin
  for i := 0 to high(Versions) do
    FSupportedVersions.Add(Versions[i]);
end;

procedure TCcDBAdaptor.RemoveCustomMetadata;
begin

end;

procedure TCcDBAdaptor.RemoveExtraCustomMetadata;
begin

end;

procedure TCcDBAdaptor.RemoveTriggers(qTable: TCcQuery);
begin

end;

procedure TCcDBAdaptor.BeforeConnect;
begin

end;

procedure TCcDBAdaptor.SetVersion(const Value: string);
begin
  if FSupportedVersions.IndexOf(Value) > -1 then
    FVersion := Value;
end;

function TCcDBAdaptor.SQLFormatValue(Data: Variant;
  FieldType: TFieldType): string;
begin

end;

function TCcDBAdaptor.SubStringFunction(str: String; start,
  length: Integer): String;
begin
  Result := 'substring(' + str + ' from ' +  IntToStr(start) + ' for ' + IntToStr(length) + ')';
end;

function TCcDBAdaptor.SupportsGenerators: Boolean;
begin
  Result := False;
end;

function TCcDBAdaptor.SupportsInsertOrUpdate: Boolean;
begin
  Result := False;
end;

procedure TCcConnection.DoCleanup;
begin

end;

procedure TCcConnection.RefreshNodes;
begin
  with TCcQuery.Create(Self, '', True) do
  begin
    SQL.Text := 'select login from RPL$USERS';
    Exec;
    while not Eof do
    begin
      DBAdaptor.DoRegisterNode(Field['login'].AsString);
      Next;
    end;
    Free;
  end;
end;

procedure TCcConnection.DoBeforeConnect;
begin

end;

procedure TCcDBAdaptor.DoListGenerators(list: TStringList);
begin

end;

procedure TCcDBAdaptor.DoListKeywordsForbiddenAsFieldNames(list: TStringList);
begin

end;

procedure TCcDBAdaptor.DoListPrimaryKeys(cTableName: string;
  list: TStringList);
begin

end;

procedure TCcDBAdaptor.DoListProcedures(list: TStringList);
begin

end;

procedure TCcDBAdaptor.DoListTableFields(cTableName: string;
  list: TStringList);
begin

end;

procedure TCcDBAdaptor.DoListTables(list: TStringList; IncludeTempTables: Boolean);
begin

end;

procedure TCcDBAdaptor.DoListTriggers(list: TStringList);
begin

end;

procedure TCcDBAdaptor.DoListUpdatableTableFields(cTableName: string;
  list: TStringList);
begin

end;

procedure TCcDBAdaptor.DoListAllProcedures(list: TStringList);
begin

end;

procedure TCcDBAdaptor.DoListFieldsForNoPK(cTableName: string;
  list: TStringList);
begin

end;

function TCcDBAdaptor.DeclarePK(FieldNames: string): string;
begin
  Result := 'primary key (' + FieldNames + ')';
end;

{ TCcMacro }

procedure TCcMacro.ApplyToSQL(var SQLText: string);
begin
  SQLText := ReplaceString(SQLText, '%' + FName, FValue);
end;

constructor TCcMacro.Create(Query: TCcQuery; Name: string);
begin
  FQuery := Query;
  FName := name;
end;

procedure TCcMacro.SetValue(const Value: string);
begin
  if FValue <> Value then
  begin
    if FQuery.FSQLPrepared then
      FQuery.UnPrepare;
    FValue := Value;
  end;
end;

function TCcQuery.GetParamByIndex(index: Integer): TCcField;
begin
  Result := TCcField(FParams.Objects[index]);
end;

procedure RegisterDBConnector(ConnectorClass: TCcConnectionClass; ConnectorName: string);
var
  clsInfo: TCcClassInfo;
begin
  if not Assigned(CcAvailableDBConnectors) then
    CcAvailableDBConnectors := TStringList.Create;

  RegisterClass(ConnectorClass);
  clsInfo := TCcClassInfo.Create;
  clsInfo.Name := ConnectorName;
  clsInfo.ClassReference := ConnectorClass;
  CcAvailableDBConnectors.AddObject(clsInfo.Name, clsInfo);
end;

function GetDBConnectorClass(cConnectorName: string): TCcConnectionClass;
var
  nIndex: Integer;
begin
  nIndex := CcAvailableDBConnectors.IndexOf(cConnectorName);
  if nIndex > -1 then
    Result := TCcConnectionClass(TCcClassInfo(CcAvailableDBConnectors.Objects[nIndex]).ClassReference)
  else
    raise Exception.Create('No such CopyCat database connector registered: ' + cConnectorName);
end;

procedure TCcDBAdaptor.CleanupConnection;
begin

end;

procedure TCcDBAdaptor.CleanupTransaction;
begin

end;

function TCcDBAdaptor.ConcatenationOperator: String;
begin
  Result := '||';
end;

function TCcDBAdaptor.ConvertValue(Val: Variant;
  DataType: TFieldType): Variant;
begin
  Result := Val;
end;

procedure TCcQuery.CheckMacros(SQLText: string);
var
  i: Integer;
begin
  FreeMacros;
  FMacroParser.Parse(SQLText);
  for i := 0 to FMacroParser.TokenCount - 1 do
    FMacros.AddObject(FMacroParser.Token[i], TCcMacro.Create(Self, FMacroParser.Token[i]));
end;

{ TCcAbstractQueryObject }

constructor TCcAbstractQueryObject.Create(Conn: TCcConnection; qry: TCcQuery; nID: Integer; Select: Boolean);
begin
  FConnection := Conn;
  FQuery := qry;
  FID := nID;
  FSelectStatement := Select;
end;

class function TCcDBAdaptor.GetAdaptorName: string;
begin

end;

function TCcDBAdaptor.ListFieldNames(slFields: TStringList; SourceDBAdaptor: TCcDBAdaptor; prefix: String): String;
var
  I: Integer;
  cFields, cFieldName: string;
begin
  for I := 0 to slFields.Count - 1 do
  begin
    cFieldName := slFields.Strings[I];
    if (Trim(cFields) <> '') then
      cFields := cFields + ', ';

    cFields := cFields + prefix + MetaQuote(cFieldName, sourceDBAdaptor);
  end;
  Result := cFields;
end;

function TCcDBAdaptor.GetQuoteMetadata: Boolean;
begin
  Result := False;
end;

function TCcDBAdaptor.MetaQuote(Identifier: string): string;
begin
  if QuoteMetadata then
    Result := DoMetaQuote(Identifier)
  else
    Result := Identifier;
end;

function TCcDBAdaptor.MetaQuote(Identifier: string; SourceDBAdaptor: TCcDBAdaptor): string;
begin
  if ((not SourceDBAdaptor.QuoteMetadata) or (SourceDBAdaptor.UnQuotedIdentifier(Identifier) = Identifier)) then
    Result := DoMetaQuote(UnQuotedIdentifier(Identifier))
  else
    Result := DoMetaQuote(Identifier)
end;

function TCcDBAdaptor.DoMetaQuote(Identifier: string): string;
begin
  if QuoteMetadata then
    Result := '"' + Identifier + '"'
  else
    Result := Identifier;
end;

procedure TCcDBAdaptor.DoRegisterNode(NodeName: string);
begin
end;

procedure TCcDBAdaptor.DropGenerator(cGeneratorName: string);
begin
  if GenDeclared(cGeneratorName) then
  begin
    FConnection.ExecQuery('DROP SEQUENCE ' + cGeneratorName);
    FConnection.CommitRetaining;
  end;
end;

procedure TCcDBAdaptor.DropProcedures;
begin

end;

function TCcDBAdaptor.GetUseRowsAffected: Boolean;
begin
  Result := False;
end;

procedure TCcDBAdaptor.GrantRightsToTable(tableName: string);
begin
  Query.Add('GRANT ALL ON ' + MetaQuote(tableName) + ' TO PUBLIC');
  ExecConfQuery;
end;

{ ECcLostConnection }

constructor ECcLostConnection.Create(Conn: TCcConnection);
begin
  if Assigned(Conn) then
    inherited Create('Connection lost to database : ' + Conn.DBName)
  else
    inherited Create('Connection lost to database!');
  FConnection := Conn;
end;

{ TCcCustomKeyRing }

constructor TCcCustomKeyRing.Create(conn: TCcConnection);
begin
  FConnection := Conn;
end;

initialization

if not Assigned(CcAvailableDBConnectors) then
  CcAvailableDBConnectors := TStringList.Create;
if not Assigned(CcAvailableAdaptors) then
  CcAvailableAdaptors := TList.Create;
CcAvailableAdaptors.Add(TCcInterbaseAdaptor);
CcAvailableAdaptors.Add(TCcMySQLAdaptor);
CcAvailableAdaptors.Add(TCcSQLServerAdaptor);
CcAvailableAdaptors.Add(TCcSQLiteAdaptor);
CcAvailableAdaptors.Add(TCcNexusDBAdaptor);
CcAvailableAdaptors.Add(TCcOracleAdaptor);

finalization

if Assigned(CcAvailableDBConnectors) then
begin
  while CcAvailableDBConnectors.Count > 0 do
  begin
    if Assigned(CcAvailableDBConnectors.Objects[0]) then
      CcAvailableDBConnectors.Objects[0].Free;
    CcAvailableDBConnectors.Delete(0);
  end;
  FreeAndNil(CcAvailableDBConnectors);
end;
FreeAndNil(CcAvailableAdaptors);

end.
