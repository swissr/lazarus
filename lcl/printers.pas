{
 /***************************************************************************
                                Printers.pas
                                ------------
                            Basic Printer object
                               
 ****************************************************************************/

 *****************************************************************************
 *                                                                           *
 *  This file is part of the Lazarus Component Library (LCL)                 *
 *                                                                           *
 *  See the file COPYING.LCL, included in this distribution,                 *
 *  for details about the copyright.                                         *
 *                                                                           *
 *  This program is distributed in the hope that it will be useful,          *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
 *                                                                           *
 *****************************************************************************

  Author: Olivier Guilbaud
}
unit Printers;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,Graphics;
type
  TPrinter = Class;
  EPrinter = class(Exception);

  TPrinterOrientation = (poPortrait,poLandscape,poReverseLandscape,poReversePortrait);
  TPrinterCapability  = (pcCopies, pcOrientation, pcCollation);
  TPrinterCapabilities= Set of TPrinterCapability;
  TPrinterState       = (psNoDefine,psReady,psPrinting,psStopped);
  TPrinterType        = (ptLocal,ptNetWork);

  {
   This object it's a base class for TCanvas for TPrinter Object.
   Few properties it's replicate for can create an TPrinterCavas not
   associated with TPrinter or override few values.
   
   BeginDoc,NewPage and EndDoc it's called in Printer.BeginDoc ...
  }
  TPrinterCanvas = class(TCanvas)
  private
    fPrinter      : TPrinter;
    fTitle        : String;
    fPageHeight   : Integer;
    fPageWidth    : Integer;
    fPageNum      : Integer;
    fTopMarging   : Integer;
    fLeftMarging  : Integer;
    
    function GetPageHeight: Integer;
    function GetPageWidth: Integer;
    function GetTitle: string;
    procedure SetPageHeight(const AValue: Integer);
    procedure SetPageWidth(const AValue: Integer);
    procedure SetTitle(const AValue: string);
  protected
    procedure BeginDoc; virtual;
    procedure NewPage;  virtual;
    procedure EndDoc; virtual;

  public
    constructor Create(APrinter: TPrinter); virtual;
    procedure Changing; override;

    property Printer : TPrinter read fPrinter;
    
    property Title : string read GetTitle write SetTitle;
    property PageHeight : Integer read GetPageHeight write SetPageHeight;
    property PageWidth  : Integer read GetPageWidth write SetPageWidth;
    property PageNumber : Integer read fPageNum;
    property TopMarging : Integer read fTopMarging write fTopMarging;
    property LeftMarging: Integer read fLeftMarging write fLeftMarging;

  end;

  TPrinterCanvasRef = Class of TPrinterCanvas;
  
  TPaperRect = Record
    PhysicalRect : TRect;
    WorkRect     : TRect;
  end;

  TPaperSize = Class(TObject)
  private
    //The width and length are in points;
    //there are 72 points per inch.

    fOwnedPrinter      : TPrinter;
    fSupportedPapers   : TStringList;  //List of Paper supported by the current printer
    fLastPrinterIndex  : Integer;      //Last index of printer used

    function GetDefaultPaperName: string;
    function GetPaperName: string;
    function GetPaperRect: TPaperRect;
    function GetSupportedPapers: TStrings;
    procedure SetPaperName(const AName: string);
    function PaperRectOfName(const AName: string) : TPaperRect;
  protected
  public
    constructor Create(aOwner : TPrinter); overload;
    destructor Destroy; override;

    property PaperName       : string read GetPaperName write SetPaperName;
    property DefaultPaperName: string read GetDefaultPaperName;

    property PaperRect       : TPaperRect read GetPaperRect;
    property SupportedPapers : TStrings read GetSupportedPapers;

    property PaperRectOf[aName : string] : TPaperRect read PaperRectOfName;
  end;

  { TPrinter }

  TPrinter = class(TObject)
  private
    fCanvas      : TCanvas;      //Active canvas object
    fFonts       : TStrings;     //Accepted font by printer
    fPageNumber  : Integer;      //Current page number
    fPrinters    : TStrings;     //Printers names list
    fPrinterIndex: Integer;      //selected printer index
    fTitle       : string;       //Title of current document
    fPrinting    : Boolean;      //Printing
    fAborted     : Boolean;      //Abort  process
    //fCapabilities: TPrinterCapabilities;
    fPaperSize   : TPaperSize;
    
    function GetCanvas: TCanvas;
    procedure CheckPrinting(Value: Boolean);
    function GetCopies: Integer;
    function GetFonts: TStrings;
    function GetOrientation: TPrinterOrientation;
    function GetPageHeight: Integer;
    function GetPageWidth: Integer;
    function GetPaperSize: TPaperSize;
    function GetPrinterIndex: integer;
    function GetPrinters: TStrings;
    procedure SetCopies(AValue: Integer);
    procedure SetOrientation(const AValue: TPrinterOrientation);
    procedure SetPrinterIndex(AValue: integer);
  protected
     procedure SelectCurrentPrinterOrDefault;
     
     function GetCanvasRef : TPrinterCanvasRef; virtual;
     
     procedure DoBeginDoc; virtual;
     procedure DoNewPage; virtual;
     procedure DoEndDoc(aAborded : Boolean); virtual;
     procedure DoAbort; virtual;
     procedure DoResetPrintersList; virtual;
     procedure DoResetFontsList; virtual;
     
     procedure DoEnumPrinters(Lst : TStrings); virtual;
     procedure DoEnumFonts(Lst : TStrings); virtual;
     procedure DoEnumPapers(Lst : TStrings); virtual;
     function DoSetPrinter(aName : string): Integer; virtual;
     function DoGetCopies : Integer; virtual;
     procedure DoSetCopies(aValue : Integer); virtual;
     function DoGetOrientation: TPrinterOrientation; virtual;
     procedure DoSetOrientation(aValue : TPrinterOrientation); virtual;
     function DoGetDefaultPaperName: string; virtual;
     function DoGetPaperName: string; virtual;
     procedure DoSetPaperName(aName : string); virtual;
     function DoGetPaperRect(aName : string; Var aPaperRc : TPaperRect) : Integer; virtual;
     function DoGetPrinterState: TPrinterState; virtual;
     function GetPrinterType : TPrinterType; virtual;
     function GetCanPrint : Boolean; virtual;
     function GetXDPI: Integer; virtual;
     function GetYDPI: Integer; virtual;
  public
     constructor Create; virtual;
     destructor Destroy; override;

     procedure Abort;
     procedure BeginDoc;
     procedure EndDoc;
     procedure NewPage;
     procedure Refresh;
     procedure SetPrinter(aName : String);

     function PrintDialog : Boolean;  virtual; abstract;
     function PrinterSetup: Boolean; virtual; abstract;
     
     property PrinterIndex : integer read GetPrinterIndex write SetPrinterIndex;
     property PaperSize : TPaperSize read GetPaperSize;
     property Orientation: TPrinterOrientation read GetOrientation write SetOrientation;
     property PrinterState : TPrinterState read DoGetPrinterState;
     property Copies : Integer read GetCopies write SetCopies;
     property Printers: TStrings read GetPrinters;
     property Fonts: TStrings read GetFonts;
     property Canvas: TCanvas read GetCanvas;
     property PageHeight: Integer read GetPageHeight;
     property PageWidth: Integer read GetPageWidth;
     property PageNumber : Integer read fPageNumber;
     property Aborted: Boolean read fAborted;
     property Printing: Boolean read FPrinting;
     property Title: string read fTitle write fTitle;
     property PrinterType : TPrinterType read GetPrinterType;
     property CanPrint : Boolean read GetCanPrint;
     
     property XDPI : Integer read GetXDPI;
     property YDPI : Integer read GetYDPI;
  end;
  
var
  Printer : TPrinter;
  
implementation

{ TPrinter }

constructor TPrinter.Create;
begin
  Inherited Create;
  fPrinterIndex:=-1;  //By default, use the default printer
  fCanvas:=nil;
  fPaperSize:=nil;
  fTitle:='';
end;

destructor TPrinter.Destroy;
begin
  if Printing then
    Abort;

  Refresh;

  if Assigned(fCanvas) then
    fCanvas.Free;
    
  if Assigned(fPaperSize) then
    fPaperSize.Free;
    
  inherited Destroy;
end;

//Abort the current document
procedure TPrinter.Abort;
begin
  //Check if Printer print otherwise, exception
  CheckPrinting(True);

  DoAbort;
  
  fAborted:=True;
  EndDoc;
end;

//Begin a new document
procedure TPrinter.BeginDoc;
begin
  //Check if Printer not printing otherwise, exception
  CheckPrinting(False);
  
  //If not selected printer, set default printer
  SelectCurrentPrinterOrDefault;
  
  Canvas.Refresh;
  fPrinting := True;
  fAborted := False;
  fPageNumber := 1;
  TPrinterCanvas(Canvas).BeginDoc;
  //Call the specifique Begindoc
  DoBeginDoc;
end;

//End the current document
procedure TPrinter.EndDoc;
begin
  //Check if Printer print otherwise, exception
  CheckPrinting(True);

  TPrinterCanvas(Canvas).EndDoc;
  
  DoEndDoc(fAborted);

  fPrinting := False;
  fAborted := False;
  fPageNumber := 0;
end;

//Create an new page
procedure TPrinter.NewPage;
begin
  CheckPrinting(True);
  Inc(fPageNumber);
  
  TPrinterCanvas(Canvas).NewPage;
  DoNewPage;
end;

//Clear Printers & Fonts list
procedure TPrinter.Refresh;
begin
  //Check if Printer not printing otherwise, exception
  CheckPrinting(False);

  if Assigned(fPrinters) then
  begin
    DoResetPrintersList;
    FreeAndNil(fPrinters);
  end;
  
  if Assigned(fFonts) then
  begin
    DoResetFontsList;
    FreeAndNil(fFonts);
  end;
    
  fPrinterIndex:=-1;
end;

//Set the current printer
procedure TPrinter.SetPrinter(aName: String);
var i : Integer;
begin
  if (Printers.Count>0) then
  begin
    if (aName<>'') then
    begin
      //Printer changed ?
      if fPrinters.IndexOf(aName)<>fPrinterIndex then
      begin
        i:=DoSetPrinter(aName);
        if i<0 then
          raise EPrinter.Create(Format('Printer "%s" does''t exists.',[aName]));
        fPrinterIndex:=i;
      end;
    end;
  end
end;

//Return an Canvas object
function TPrinter.GetCanvas: TCanvas;
begin
  if not Assigned(fCanvas) then
  begin
    if not Assigned(GetCanvasRef) then
      raise Exception.Create('TCanvas not defined.');

    fCanvas:=GetCanvasRef.Create(Self);
  end;
  
  Result:=fCanvas;
end;

//Raise error if Printer.Printing is not Value
procedure TPrinter.CheckPrinting(Value: Boolean);
begin
  if Printing<>Value then
  begin
    if Value then
      raise EPrinter.Create('Printer not printing')
    else
      raise Eprinter.Create('Printer print');
  end;
end;

//Get current copies number
function TPrinter.GetCopies: Integer;
Var i : Integer;
begin
  Result:=1;
  i:=DoGetCopies;
  if i>0 then
    Result:=i;
end;

//Return & initialize the Fonts list
function TPrinter.GetFonts: TStrings;
begin
  if not Assigned(fFonts) then
    fFonts:=TStringList.Create;
  Result:=fFonts;

  //Only 1 initialization
  if fFonts.Count=0 then
    DoEnumFonts(fFonts);
end;

function TPrinter.GetOrientation: TPrinterOrientation;
begin
  Result:=poPortrait;
  if Printers.Count>0 then
    Result:=DoGetOrientation;
end;

function TPrinter.GetPageHeight: Integer;
begin
  Result:=0;
  if (Printers.Count>0) then
    Result:=PaperSize.PaperRect.PhysicalRect.Bottom;
end;

function TPrinter.GetPageWidth: Integer;
begin
  Result:=0;
  if (Printers.Count>0) then
    Result:=PaperSize.PaperRect.PhysicalRect.Right;
end;

function TPrinter.GetPaperSize: TPaperSize;
begin
  if not Assigned(fPaperSize)  then
    fPaperSize:=TPaperSize.Create(self);
  Result:=fPaperSize;
end;

//Return the current selected printer
function TPrinter.GetPrinterIndex: integer;
begin
  Result:=fPrinterIndex;
  if (Result<0) and (Printers.Count>0) then
     Result:=0; //printer by default
end;

//Return & initialize the printers list
function TPrinter.GetPrinters: TStrings;
begin
  if not Assigned(fPrinters) then
    fPrinters:=TStringList.Create;
  Result:=fPrinters;
  
  //Only 1 initialization
  if fPrinters.Count=0 then
    DoEnumPrinters(fPrinters);
end;

//Return XDPI
function TPrinter.GetXDPI: Integer;
begin
  Result:=1;
end;

//Return YDPI
function TPrinter.GetYDPI: Integer;
begin
  Result:=1;
end;


//Set the copies numbers
procedure TPrinter.SetCopies(AValue: Integer);
begin
  CheckPrinting(False);
  if aValue<1 then aValue:=1;
  if Printers.Count>0 then
     DoSetCopies(aValue)
  else raise EPrinter.Create('zero printer definied !');
end;

procedure TPrinter.SetOrientation(const AValue: TPrinterOrientation);
begin
  CheckPrinting(False);
  if Printers.Count>0 then
    DoSetOrientation(aValue);
end;

//Set the selected printer
procedure TPrinter.SetPrinterIndex(AValue: integer);
Var aName : String;
begin
  CheckPrinting(False);
  if Printers.Count>0 then
  begin
    aName:='*';
    if AValue=-1 then
      AValue:=0 {Default printer}
    else
      if AValue<Printers.Count then
           aName:=Printers.Strings[AValue];

    SetPrinter(aName);
  end
  else raise EPrinter.Create('zero printer definied !');
end;

//If not Printer selected, Select the default printer
procedure TPrinter.SelectCurrentPrinterOrDefault;
begin
  if fPrinterIndex<0 then
    PrinterIndex:=0;
end;

//Specify here the Canvas class used by your TPrinter object
function TPrinter.GetCanvasRef: TPrinterCanvasRef;
begin
  Result:=TPrinterCanvas;
end;


procedure TPrinter.DoBeginDoc;
begin
  //Override this methode
end;

procedure TPrinter.DoNewPage;
begin
  //Override this methode
end;

procedure TPrinter.DoEndDoc(aAborded : Boolean);
begin
  //Override this methode
end;

procedure TPrinter.DoAbort;
begin
 //Override this methode
end;

procedure TPrinter.DoResetPrintersList;
begin
 //Override this methode
end;

procedure TPrinter.DoResetFontsList;
begin
 //Override this methode
end;

//Initialize the Lst with all definied printers
procedure TPrinter.DoEnumPrinters(Lst: TStrings);
begin
 //Override this methode
 //Warning : The default printer must be the first printer
 //          (fPrinters[0])
end;

//Initialize the Lst with all supported fonts
procedure TPrinter.DoEnumFonts(Lst: TStrings);
begin
 //Override this methode
end;

//Initialize the Lst with all supported papers names
procedure TPrinter.DoEnumPapers(Lst: TStrings);
begin
 //Override this methode
end;


//Set the current printer
function TPrinter.DoSetPrinter(aName : string): Integer;
begin
  //Override this methode. The result must be
  //the index of aName printer in Printers list
  //if the aName doesn't exists, return -1
  Result:=-1;
end;

//Get the current copies nulbers
function TPrinter.DoGetCopies: Integer;
begin
 //Override this methode
 Result:=1;
end;

//Set the copies numbers
procedure TPrinter.DoSetCopies(aValue: Integer);
begin
 //Override this methode
end;

//Return the current paper orientation
function TPrinter.DoGetOrientation: TPrinterOrientation;
begin
  Result:=poPortrait;
  //Override this methode
end;

//Set the paper Orientation
procedure TPrinter.DoSetOrientation(aValue: TPrinterOrientation);
begin
 //Override this methode
end;

//Return the default paper name for the selected printer
function TPrinter.DoGetDefaultPaperName: string;
begin
  Result:='';
  //Override this methode
end;

//Return the selected paper name for the current printer
function TPrinter.DoGetPaperName: string;
begin
  Result:='';
  //Override this methode
end;

procedure TPrinter.DoSetPaperName(aName: string);
begin
  //Override this methode
end;

//Initialise aPaperRc with the aName paper rect
//Result : -1 no result
//          0 aPaperRc.WorkRect is a margins
//          1 aPaperRc.WorkRect is really the work rect
function TPrinter.DoGetPaperRect(aName : string; var aPaperRc: TPaperRect): Integer;
begin
  Result:=-1;
  //Override this methode
end;

//Get a state of current printer
function TPrinter.DoGetPrinterState: TPrinterState;
begin
  //Override this methode
  Result:=psNoDefine;
end;

//Return the type of selected printer
function TPrinter.GetPrinterType: TPrinterType;
begin
  Result:=ptLocal;
end;

//Return True if selected printer can printing
function TPrinter.GetCanPrint: Boolean;
begin
  Result:=True;
end;

{ TPaperSize }

function TPaperSize.GetDefaultPaperName: string;
begin
  Result:=fOwnedPrinter.DoGetDefaultPaperName;
end;

function TPaperSize.GetPaperName: string;
begin
  Result:=fOwnedPrinter.DoGetPaperName;
  if Result='' then
    Result:=DefaultPaperName;
end;

function TPaperSize.GetPaperRect: TPaperRect;
begin
  Result:=PaperRectOfName(PaperName);
end;

function TPaperSize.GetSupportedPapers: TStrings;
begin
  if (fOwnedPrinter.Printers.Count>0) and
     ((fSupportedPapers.Count=0) or (fLastPrinterIndex<>fOwnedPrinter.PrinterIndex)) then
  begin
    fOwnedPrinter.SelectCurrentPrinterOrDefault;
    
    fSupportedPapers.Clear;
    fOwnedPrinter.DoEnumPapers(fSupportedPapers);
    fLastPrinterIndex:=fOwnedPrinter.PrinterIndex;
  end;
  Result:=fSupportedPapers;
end;

procedure TPaperSize.SetPaperName(const AName: string);
begin
  if SupportedPapers.IndexOf(aName)<>-1 then
  begin
    if aName<>DefaultPaperName then
      fOwnedPrinter.DoSetPaperName(aName)
  end
  else raise EPrinter.Create(Format('Paper "%s" not supported !',[aName]));
end;

//Return an TPaperRect corresponding at an paper name
function TPaperSize.PaperRectOfName(const AName: string): TPaperRect;
var TmpPaperRect : TPaperRect;
    Margins      : Integer;
begin
  FillChar(Result,SizeOf(Result),0);

  if SupportedPapers.IndexOf(AName)<>-1 then
  begin
    Margins:=fOwnedPrinter.DoGetPaperRect(aName,TmpPaperRect);
    if Margins>=0 then
    begin
      if fOwnedPrinter.Orientation in [poPortrait,poReversePortrait] then
      begin
        Result.PhysicalRect:=TmpPaperRect.PhysicalRect;

        if Margins=1 then
          Result.WorkRect:=TmpPaperRect.WorkRect
        else
        begin
          Result.WorkRect.Left:=Result.PhysicalRect.Left+TmpPaperRect.WorkRect.Left;
          Result.WorkRect.Right:=Result.PhysicalRect.Right-TmpPaperRect.WorkRect.Right;
          Result.WorkRect.Top:=Result.PhysicalRect.Top+TmpPaperRect.WorkRect.Top;
          Result.WorkRect.Bottom:=Result.PhysicalRect.Bottom-TmpPaperRect.WorkRect.Bottom;
        end;
      end
      else
      begin
        //If the selected orientation is not normal, reverse
        //length with width
        Result.PhysicalRect.Right:=TmpPaperRect.PhysicalRect.Bottom;
        Result.PhysicalRect.Bottom:=TmpPaperRect.PhysicalRect.Right;

        if Margins=1 then
        begin
          Result.WorkRect.Right:=TmpPaperRect.WorkRect.Bottom;
          Result.WorkRect.Left:=TmpPaperRect.WorkRect.Top;
          Result.WorkRect.Bottom:=TmpPaperRect.WorkRect.Left;
          Result.WorkRect.Top:=TmpPaperRect.WorkRect.Right;
        end
        else
        begin
          Result.WorkRect.Left:=Result.PhysicalRect.Left+TmpPaperRect.WorkRect.Top;
          Result.WorkRect.Right:=Result.PhysicalRect.Right-TmpPaperRect.WorkRect.Bottom;
          Result.WorkRect.Top:=Result.PhysicalRect.Top+TmpPaperRect.WorkRect.Right;
          Result.WorkRect.Bottom:=Result.PhysicalRect.Bottom-TmpPaperRect.WorkRect.Left;
        end;
      end;
    end
    else raise EPrinter.Create(Format('The paper "%s" as not definied rect ! ',[aName]));
  end
  else raise EPrinter.Create(Format('Paper "%s" not supported !',[aName]));
end;

constructor TPaperSize.Create(aOwner: TPrinter);
begin
  if not assigned(aOwner) then
    raise Exception.Create('TMediaSize.Create, aOwner must be defined !');
  Inherited Create;

  fLastPrinterIndex:=-2;
  fOwnedPrinter:=aOwner;
  fSupportedPapers:=TStringList.Create;
end;

destructor TPaperSize.Destroy;
begin
  fSupportedPapers.Free;

  inherited Destroy;
end;

{ TPrinterCanvas }

function TPrinterCanvas.GetTitle: string;
begin
  if Assigned(fPrinter) then
    Result:=fPrinter.Title
  else
    Result:=fTitle;
end;

function TPrinterCanvas.GetPageHeight: Integer;
begin
  if Assigned(fPrinter) and (fPageHeight=0) then
     Result:=fPrinter.PageHeight
  else
    Result:=fPageHeight;
end;

function TPrinterCanvas.GetPageWidth: Integer;
begin
  if Assigned(fPrinter) and (fPageWidth=0) then
     Result:=fPrinter.PageWidth
  else
    Result:=fPageWidth;
end;

procedure TPrinterCanvas.SetPageHeight(const AValue: Integer);
begin
  fPageHeight:=aValue;
end;

procedure TPrinterCanvas.SetPageWidth(const AValue: Integer);
begin
  fPageWidth:=aValue;
end;

procedure TPrinterCanvas.SetTitle(const AValue: string);
begin
  if Assigned(fPrinter) then
    fPrinter.Title:=aValue
  else
    fTitle:=aValue;
end;

constructor TPrinterCanvas.Create(APrinter: TPrinter);
begin
  Inherited Create;
  fPageWidth      :=0;
  fPageHeight     :=0;
  fTopMarging :=0;
  fLeftMarging:=0;
  fPrinter:=aPrinter;
end;

procedure TPrinterCanvas.Changing;
begin
  if Assigned(fPrinter)  then
    fPrinter.CheckPrinting(True);
  inherited Changing;
end;

procedure TPrinterCanvas.BeginDoc;
begin
  fPageNum:=1;
end;

procedure TPrinterCanvas.NewPage;
begin
  Inc(fPageNum);
end;

procedure TPrinterCanvas.EndDoc;
begin
  //No special action
end;

INITIALIZATION
  //TPrinter it's an basic object. If you override this object,
  //you must create an instance.
  Printer:=nil;
  
FINALIZATION
  If Assigned(Printer) then
    Printer.Free;
end.

