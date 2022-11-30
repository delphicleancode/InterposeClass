unit Editors.Interpose;

interface
  uses
    Winapi.Windows,
    Winapi.Messages,
    Winapi.CommCtrl,
    System.SysUtils,
    System.StrUtils,
    System.Variants,
    System.Classes,
    System.Threading,
    Vcl.Graphics,
    Vcl.StdCtrls,
    Vcl.ComCtrls,
    Vcl.Controls,
    Vcl.Forms,
    Vcl.Dialogs,
    Vcl.Mask,
    JvBaseEdits;

const
  Regex_EMail   = '([a-z][a-z0-9\-\_]+\.?[a-z0-9\-\_]+)@((?![0-9]+\.)([a-z][a-z0-9\-]{0,24}[a-z0-9])\.)[a-z]{3}(\.[a-z]{2,3})?';
  Regex_URL     = '(https?:\/\/)?((www|w3)\.)?([-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&\/=]*))';
  Regex_Celular = '^(?:[6-9]|9[1-9])[0-9]{3}[0-9]{4}$';
  Regex_CEP     = '[0-9]{5}-[0-9]{3}';

  DEFAULT_ENTER_COLOR    = TColor($00FFFF);
  DEFAULT_EXIT_COLOR     = TColor($FFFFFF);
  DEFAULT_REQUIRED_COLOR = TColor($F0CAA6);
  DEFAULT_ERROR_COLOR    = TColor($0000FF);

type
  TTipoValidacao = (tvNenhuma, tvEmail, tvURL, tvTelefone, tvCEP);

  TTipoValidacaoHelper = record helper for TTipoValidacao
  public
    function Regex: string;
    function MensagemErro: string;
    function GetLabel: string;
    function GetTextHint: string;
  end;

  TEdit = class(Vcl.StdCtrls.TEdit)
    private
      FTipoValidacao: TTipoValidacao;
      FErrorColor   : TColor;
      FExitColor    : TColor;
      FEnterColor   : TColor;
      FRequeridColor: TColor;
      FLabel        : TLabel;
      FValido       : Boolean;
      procedure SetTipoValidacao(const AValue: TTipoValidacao);
      procedure SetLabel;
    protected
      procedure KeyPress(var AKey: Char); override;

      procedure Change; override;
      procedure Validar;

      procedure DoEnter; override;
      procedure DoExit; override;

      property Valido: Boolean read FValido write FValido default True;
    public
      constructor Create(AOwner: TComponent); override;
      procedure Loaded; override;
    published
      property TipoValidacao: TTipoValidacao read FTipoValidacao write SetTipoValidacao;

      property ErrorColor    : TColor read FErrorColor    write FErrorColor;
      property EnterColor    : TColor read FEnterColor    write FEnterColor;
      property ExitColor     : TColor read FExitColor     write FExitColor;
      property RequiredColor : TColor read FRequeridColor write FRequeridColor;
  end;

{$REGION 'EditorsClass2 Interpose'}

  TMemo = class(Vcl.StdCtrls.TMemo)
    private
      FExitColor  : TColor;
      FEnterColor : TColor;
      FRequeridColor: TColor;
    protected
      procedure DoEnter; override;
      procedure DoExit; override;
    public
      constructor Create(AOwner: TComponent); override;
      procedure Loaded; override;
    published
      property EnterColor    : TColor read FEnterColor    write FEnterColor;
      property ExitColor     : TColor read FExitColor     write FExitColor;
      property RequiredColor : TColor read FRequeridColor write FRequeridColor;
  end;

  TComboBox = class(Vcl.StdCtrls.TComboBox)
    private
      FExitColor    : TColor;
      FEnterColor   : TColor;
      FRequeridColor: TColor;
    protected
      procedure DoEnter; override;
      procedure DoExit; override;
    public
      constructor Create(AOwner: TComponent); override;
      procedure Loaded; override;
    published
      property EnterColor    : TColor read FEnterColor    write FEnterColor;
      property ExitColor     : TColor read FExitColor     write FExitColor;
      property RequiredColor : TColor read FRequeridColor write FRequeridColor;
  end;

  TMaskEdit = class(Vcl.Mask.TMaskEdit)
    private
      FExitColor     : TColor;
      FEnterColor    : TColor;
      FRequeridColor : TColor;

      procedure CMEnter(var Message: TCMEnter); message CM_ENTER;
      procedure CMExit(var Message: TCMExit); message CM_EXIT;
    protected
      procedure Loaded; override;
    public
      constructor Create(AOwner: TComponent); override;
    published
      property EnterColor    : TColor read FEnterColor    write FEnterColor;
      property ExitColor     : TColor read FExitColor     write FExitColor;
      property RequiredColor : TColor read FRequeridColor write FRequeridColor;
  end;

  TDateTimePicker = class(Vcl.ComCtrls.TDateTimePicker)
    private
      FMoveCursor : Boolean;
    protected
      procedure WMKeyDown(var Message: TWMKeyDown); message WM_KEYDOWN;
      procedure Change; override;
  end;

  TJvCalcEdit = class(JvBaseEdits.TJvCalcEdit)
    private
      FExitColor    : TColor;
      FEnterColor   : TColor;
      FRequeridColor: TColor;
    protected
      procedure DoEnter; override;
      procedure DoExit; override;
    public
      constructor Create(AOwner: TComponent); override;
      procedure Loaded; override;
    published
      property EnterColor    : TColor read FEnterColor    write FEnterColor;
      property ExitColor     : TColor read FExitColor     write FExitColor;
      property RequiredColor : TColor read FRequeridColor write FRequeridColor;
  end;

  TCustomEdit = class(Vcl.StdCtrls.TCustomEdit)
    private
      FExitColor    : TColor;
      FEnterColor   : TColor;
      FRequeridColor: TColor;
    protected
      procedure DoEnter; override;
      procedure DoExit; override;
    public
      constructor Create(AOwner: TComponent); override;
      procedure Loaded; override;
    published
      property EnterColor    : TColor read FEnterColor    write FEnterColor;
      property ExitColor     : TColor read FExitColor     write FExitColor;
      property RequiredColor : TColor read FRequeridColor write FRequeridColor;
  end;
{$ENDREGION}

implementation
  uses System.RegularExpressions;

procedure TEdit.Validar;
var
  FTask : ITask;
begin
  if (TipoValidacao = tvNenhuma) or (Trim(Self.Text) = EmptyStr) then
  begin
    Self.Color := ExitColor;
    Self.Hint  := Self.TipoValidacao.GetTextHint;
    Exit;
  end;

  FTask := TTask.Create(
  procedure
  begin
    TThread.Synchronize(TThread.Current,
    procedure
    begin
      Self.Valido := True;
      if not TRegEx.IsMatch(Self.Text, Self.TipoValidacao.Regex) then
      begin
        Self.Valido := False;
        Self.Color  := ErrorColor;
        Self.Hint   := Self.TipoValidacao.MensagemErro;
      end
      else
      begin
        Self.Color  := EnterColor;
        Self.Hint   := Self.TipoValidacao.GetTextHint;
      end;
    end);
    Sleep(100);
  end);
  FTask.Start;
end;

constructor TEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
    FExitColor     := DEFAULT_EXIT_COLOR;
    FErrorColor    := DEFAULT_ERROR_COLOR;
    FEnterColor    := DEFAULT_ENTER_COLOR;
    FRequeridColor := DEFAULT_REQUIRED_COLOR;
end;

procedure TEdit.DoEnter;
begin
  inherited;
    Self.Color := EnterColor;
end;

procedure TEdit.DoExit;
begin
    if (Self.TipoValidacao <> tvNenhuma) and (Self.Text <> '') and (not Self.Valido) then
      Self.Color := ErrorColor
    else if Self.Tag > 0 then
      Self.Color := Self.RequiredColor
    else
      Self.Color := ExitColor;
  inherited;
end;

procedure TEdit.KeyPress(var AKey: Char);
begin
  if TipoValidacao = tvTelefone then
    if not CharInSet(AKey, ['0'..'9', #44, #8]) then
      Akey := #0;

  inherited;
end;

procedure TEdit.Loaded;
begin
  inherited Loaded;

  if Self.Tag > 0 then
    Self.Color := Self.RequiredColor
  else
    Self.Color := ExitColor;

   SetLabel;
end;

procedure TEdit.SetLabel;
var
   FComponentIndex: Integer;
begin
   for FComponentIndex := 0 to Pred(Self.Parent.ComponentCount) do
   begin
      if Self.Parent.Components[FComponentIndex] is TLabel then
      begin
         if TLabel(Self.Parent.Components[FComponentIndex]).FocusControl = Self then
         begin
            Self.FLabel := TLabel(Self.Parent.Components[FComponentIndex]);
            Break;
         end;
      end;
   end;
end;

procedure TEdit.SetTipoValidacao(const AValue: TTipoValidacao);
begin
  FTipoValidacao := AValue;

  if FTipoValidacao in [tvEmail, tvURL] then
    Self.CharCase := ecLowerCase;

  Self.TextHint := FTipoValidacao.GetTextHint;
  Self.Hint     := FTipoValidacao.GetTextHint;

  if Assigned(Self.FLabel) then
  begin
    if FTipoValidacao <> tvNenhuma then
    begin
      if System.StrUtils.StartsStr('Label', Self.FLabel.Caption)
      or System.StrUtils.StartsStr('lbl', Self.FLabel.Caption)then
         Self.FLabel.Caption := FTipoValidacao.GetLabel;
    end;

    if Self.Tag > 0 then
    begin
      Self.FLabel.Caption := '*' + Self.FLabel.Caption;
      Self.FLabel.Font.Style := [fsBold];
    end;
  end;
end;

procedure TEdit.Change;
begin
  Validar;

  inherited;
end;

function TTipoValidacaoHelper.GetLabel: string;
begin
  case Self of
    tvNenhuma : Result := '';
    tvEmail   : Result := 'E-&mail';
    tvURL     : Result := '&Site';
    tvTelefone: Result := 'Tele&fone';
    tvCEP     : Result := 'Informe o CE&P';
  end;
end;

function TTipoValidacaoHelper.GetTextHint: string;
begin
  case Self of
    tvNenhuma : Result := '';
    tvEmail   : Result := 'Informe o E-mail';
    tvURL     : Result := 'Digite o endereço do Site';
    tvTelefone: Result := 'Insira o Telefone';
    tvCEP     : Result := 'Informe o CEP do endereço';
  end;
end;

function TTipoValidacaoHelper.MensagemErro: string;
begin
  case Self of
    tvNenhuma : Result := '';
    tvEmail   : Result := 'E-mail inválido.';
    tvURL     : Result := 'Endereço do Site Inválido';
    tvTelefone: Result := 'Número de Telefone Inválido';
    tvCEP     : Result := 'Informe o CEP';
  end;
end;

function TTipoValidacaoHelper.Regex: string;
begin
  case Self of
    tvNenhuma : Result := '';
    tvEmail   : Result := Regex_EMail;
    tvURL     : Result := Regex_URL;
    tvTelefone: Result := Regex_Celular;
    tvCEP     : Result := Regex_CEP;
  end;
end;

{$REGION 'Editors2 Interpose'}

constructor TMemo.Create(AOwner: TComponent);
begin
  inherited;
    FEnterColor    := DEFAULT_ENTER_COLOR;
    FExitColor     := DEFAULT_EXIT_COLOR;
    FRequeridColor := DEFAULT_REQUIRED_COLOR;
end;

procedure TMemo.DoEnter;
begin
  inherited;
    Self.Color := EnterColor;
end;

procedure TMemo.DoExit;
begin
  if Self.Tag > 0 then
    Self.Color := Self.RequiredColor
  else
    Self.Color := ExitColor;

  inherited;
end;

procedure TMemo.Loaded;
begin
  inherited Loaded;

  if Self.Tag > 0 then
    Self.Color := Self.RequiredColor
  else
    Self.Color := ExitColor;
end;

constructor TComboBox.Create(AOwner: TComponent);
begin
  inherited;
    FEnterColor    := DEFAULT_ENTER_COLOR;
    FExitColor     := DEFAULT_EXIT_COLOR;
    FRequeridColor := DEFAULT_REQUIRED_COLOR;

    Items.AddObject('Todos',TObject(0));
end;

procedure TComboBox.DoEnter;
begin
  inherited;
    Self.Color := EnterColor;
end;

procedure TComboBox.DoExit;
begin
  if Self.Tag > 0 then
    Self.Color := Self.RequiredColor
  else
    Self.Color := ExitColor;

  inherited;
end;

procedure TComboBox.Loaded;
begin
  inherited Loaded;

  if Self.Tag > 0 then
    Self.Color := Self.RequiredColor
  else
    Self.Color := ExitColor;
end;

procedure TMaskEdit.CMEnter(var Message: TCMEnter);
begin
  inherited;
    Invalidate;

    Self.Color := EnterColor;
end;

procedure TMaskEdit.CMExit(var Message: TCMExit);
begin
  inherited;
    Invalidate;

  if Self.Tag > 0 then
    Self.Color := Self.RequiredColor
  else
    Self.Color := ExitColor;
end;

constructor TMaskEdit.Create(AOwner: TComponent);
begin
  inherited;
    FEnterColor    := DEFAULT_ENTER_COLOR;
    FExitColor     := DEFAULT_EXIT_COLOR;
    FRequeridColor := DEFAULT_REQUIRED_COLOR;
end;

procedure TMaskEdit.Loaded;
begin
  inherited Loaded;

  if Self.Tag > 0 then
    Self.Color := Self.RequiredColor
  else
    Self.Color := ExitColor;
end;

procedure TDateTimePicker.Change;
const
  CDtSep = '/';
var
  FEdit: TCustomEdit;
begin
  inherited;

  if not DroppedDown then
    if DateFormat = dfShort then
      if Format.Contains(CDtSep) then
        if FMoveCursor then
        begin
          FEdit := TCustomEdit(Self);
          if Trim(FEdit.Text)[FEdit.SelStart + 2] = CDtSep then
            Self.Perform($0100, $27, 0);
        end;
end;

procedure TDateTimePicker.WMKeyDown(var Message: TWMKeyDown);
begin
  if not DoKeyDown(Message) then
    inherited;

  UpdateUIState(Message.CharCode);
  FMoveCursor := Message.CharCode in [96 .. 105];
end;

constructor TJvCalcEdit.Create(AOwner: TComponent);
begin
  inherited;
    FEnterColor    := DEFAULT_ENTER_COLOR;
    FExitColor     := DEFAULT_EXIT_COLOR;
    FRequeridColor := DEFAULT_REQUIRED_COLOR;
end;

procedure TJvCalcEdit.DoEnter;
begin
  inherited;
    Self.Color := EnterColor;
end;

procedure TJvCalcEdit.DoExit;
begin
  if Self.Tag > 0 then
    Self.Color := Self.RequiredColor
  else
    Self.Color := ExitColor;

  inherited;
end;

procedure TJvCalcEdit.Loaded;
begin
  inherited Loaded;

  if Self.Tag > 0 then
    Self.Color := Self.RequiredColor
  else
    Self.Color := ExitColor;
end;

constructor TCustomEdit.Create(AOwner: TComponent);
begin
  inherited;
    FEnterColor    := DEFAULT_ENTER_COLOR;
    FExitColor     := DEFAULT_EXIT_COLOR;
    FRequeridColor := DEFAULT_REQUIRED_COLOR;
end;

procedure TCustomEdit.DoEnter;
begin
  inherited;
    Self.Color := EnterColor;
end;

procedure TCustomEdit.DoExit;
begin
  if Self.Tag > 0 then
    Self.Color := Self.RequiredColor
  else
    Self.Color := ExitColor;

  inherited;
end;

procedure TCustomEdit.Loaded;
begin
  inherited Loaded;

  if Self.Tag > 0 then
    Self.Color := Self.RequiredColor
  else
    Self.Color := ExitColor;
end;
{$ENDREGION}

end.
