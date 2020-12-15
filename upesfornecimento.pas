unit upesfornecimento;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, sqldb, db, FileUtil, Forms, Controls, Graphics, Dialogs,
	ExtCtrls, StdCtrls, Buttons, DBGrids, MaskEdit, LCLType, ucadfornecimento;

type

	{ TFPesFornecimento }

    TFPesFornecimento = class(TForm)
		BtnAdicionar: TBitBtn;
		BtnAlterar: TBitBtn;
		BtnExcluir: TBitBtn;
		BtnPesquisar: TBitBtn;
		BtnVoltar: TBitBtn;
		DBGrid1: TDBGrid;
		DFornecimento: TDataSource;
		EdtIngrediente: TEdit;
		EdtFornecedor: TEdit;
		EdtMarca: TEdit;
		Label1: TLabel;
		Label2: TLabel;
		Label3: TLabel;
		Label4: TLabel;
		EdtData: TMaskEdit;
		PBottom: TPanel;
		PTop: TPanel;
		Q: TSQLQuery;
		QFornecimento: TSQLQuery;
		Transaction: TSQLTransaction;
		procedure BtnAdicionarClick(Sender: TObject);
		procedure BtnAlterarClick(Sender: TObject);
        procedure BtnExcluirClick(Sender: TObject);
        procedure BtnPesquisarClick(Sender: TObject);
        procedure BtnVoltarClick(Sender: TObject);
        procedure FormCreate(Sender: TObject);
        procedure FormKeyPress(Sender: TObject; var Key: char);
        procedure AtualizaBotoes(Sender: TObject);
    private
        { private declarations }
    public
        { public declarations }
    end;

var
    FPesFornecimento: TFPesFornecimento;

implementation

{$R *.lfm}

{ TFPesFornecimento }


procedure TFPesFornecimento.AtualizaBotoes(Sender: TObject);
begin
    try
	    QFornecimento.Close;
	    QFornecimento.Open;
	    if QFornecimento.RecNo=0 then
	    begin
	        BtnAlterar.Enabled:=false;
	        BtnExcluir.Enabled:=false;
		end
	    else
	    begin
	        BtnAlterar.Enabled:=true;
	        BtnExcluir.Enabled:=true;
		end;
    except
        on E : Exception do
	    begin
            Application.MessageBox(PChar('ERRO '+E.Message),'ERRO',0);
			Screen.Cursor:=crDefault;
			Exit;
	    end;
    end;
end;

procedure TFPesFornecimento.FormKeyPress(Sender: TObject; var Key: char);
begin
    try
        if ActiveControl.ClassName='TBitBtn' then
        Exit;
        if key=#13 then
        begin
            key:=#0;
            SelectNext(ActiveControl,True,True);
        end;
    except
    end;
end;

procedure TFPesFornecimento.BtnVoltarClick(Sender: TObject);
begin
    Close;
end;

procedure TFPesFornecimento.FormCreate(Sender: TObject);
begin
    AtualizaBotoes(Sender);
end;

procedure TFPesFornecimento.BtnPesquisarClick(Sender: TObject);
var filtro: string;
begin
    Screen.Cursor:=crHourGlass;
    filtro:='';

    if (EdtData.Text<>'  /  /    ') then
        filtro:=' where data='+QuotedStr(FormatDateTime('yyyy-mm-dd',StrToDate(EdtData.Text)));

    if (Trim(EdtFornecedor.Text)<>'') then
    begin
        if (filtro='') then
            filtro:=' where '
        else
            filtro:=filtro+' or ';
        filtro:=filtro+' lower(F.nome) like '+QuotedStr(AnsiLowerCase(Trim(EdtFornecedor.Text))+'%');
	end;

    if (EdtIngrediente.Text<>'') then
    begin
        if (filtro='') then
            filtro:=' where '
        else
            filtro:=filtro+' or ';
        filtro:=filtro+' lower(I.nome) like '+QuotedStr(AnsiLowerCase(Trim(EdtIngrediente.Text))+'%');
	end;

    if (Trim(EdtMarca.Text)<>'') then
      begin
          if (filtro='') then
              filtro:=' where '
          else
              filtro:=filtro+' or ';
          filtro:=filtro+' lower(FFI.marca) like '+QuotedStr(AnsiLowerCase(Trim(EdtMarca.Text))+'%');
  	end;

    try
	    QFornecimento.Close;
	    QFornecimento.SQL.Clear;
	    QFornecimento.SQL.Text:='select FFI.cod_ingrediente, I.nome as ingrediente, FFI.cod_fornecedor, '+
								'F.nome as fornecedor, FFI.data, FFI.marca, FFI.valor_unitario, FFI.medida, '+
	                            'FFI.quantidade from fornecedor_fornece_ingrediente FFI '+
								'left join fornecedor F on F.cod_fornecedor=FFI.cod_fornecedor '+
								'left join ingrediente I on I.cod_ingrediente=FFI.cod_ingrediente '+
								filtro+' order by data desc, fornecedor, ingrediente, marca ';
	    QFornecimento.Open;
	    EdtData.SetFocus;
	    AtualizaBotoes(Sender);
	    Screen.Cursor:=crDefault;
    except
        on E : Exception do
	    begin
            Application.MessageBox(PChar('ERRO '+E.Message),'ERRO',0);
			Screen.Cursor:=crDefault;
			Exit;
	    end;
    end;
end;

procedure TFPesFornecimento.BtnExcluirClick(Sender: TObject);
begin
    Screen.Cursor:=crHourGlass;
    try
		if (Application.MessageBox(PChar('Deseja realmente excluir o fornecimento de '+
	        AnsiUpperCase(QFornecimento.FieldByName('ingrediente').AsString)+' (marca '+
	        AnsiUpperCase(QFornecimento.FieldByName('marca').AsString)+') do fornecedor '+
	        AnsiUpperCase(QFornecimento.FieldByName('fornecedor').AsString)+' do dia '+
	        QFornecimento.FieldByName('data').AsString+'?'),'EXCLUIR FORNECIMENTO',
			MB_ICONQUESTION+MB_YESNO)=IDYES) then
		begin
		  Q.SQL.Text:='delete from fornecedor_fornece_ingrediente where '+
	                    ' cod_fornecedor='+QFornecimento.FieldByName('cod_fornecedor').AsString+
	                    ' and cod_ingrediente='+QFornecimento.FieldByName('cod_ingrediente').AsString+
	                    ' and marca like '+QuotedStr(QFornecimento.FieldByName('marca').AsString)+
	                    ' and data='+QuotedStr(FormatDateTime('yyyy-mm-dd',QFornecimento.FieldByName('data').AsDateTime));
		  Q.ExecSQL;
		  Transaction.Commit;
		  AtualizaBotoes(Sender);
		end;
		Screen.Cursor:=crDefault;
    except
        on E : Exception do
	    begin
            Application.MessageBox(PChar('ERRO '+E.Message),'ERRO',0);
			Screen.Cursor:=crDefault;
			Exit;
	    end;
    end;
end;

procedure TFPesFornecimento.BtnAdicionarClick(Sender: TObject);
begin
  Application.CreateForm(TFCadFornecimento,FCadFornecimento);
  with FCadFornecimento do
  begin
      cod_fornecedor:=-1;
      EdtData.Text:=FormatDateTime('dd/mm/yyyy', Now);
      Caption:='Novo Fornecimento';
      ShowModal;
      Destroy;
  end;
  AtualizaBotoes(Sender);
end;

procedure TFPesFornecimento.BtnAlterarClick(Sender: TObject);
begin
    Screen.Cursor:=crHourGlass;
    try
	    Application.CreateForm(TFCadFornecimento,FCadFornecimento);
	    with FCadFornecimento do
	    begin
			cod_fornecedor:=QFornecimento.FieldByName('cod_fornecedor').AsInteger;
			cod_ingrediente:=QFornecimento.FieldByName('cod_ingrediente').AsInteger;
	        data:=FormatDateTime('dd/mm/yyyy',QFornecimento.FieldByName('data').AsDateTime);
	        marca:=QFornecimento.FieldByName('marca').AsString;
		    Caption:='Alterar Fornecimento';
	        EdtData.Text:=FormatDateTime('dd/mm/yyyy',QFornecimento.FieldByName('data').AsDateTime);
	        EdtCodFornecedor.Text:=QFornecimento.FieldByName('cod_fornecedor').AsString;
	        EdtCodIngrediente.Text:=QFornecimento.FieldByName('cod_ingrediente').AsString;
	        EdtValor.Value:=QFornecimento.FieldByName('valor_unitario').AsFloat;
	        EdtQtde.Value:=QFornecimento.FieldByName('quantidade').AsFloat;
	        EdtMedida.Text:=QFornecimento.FieldByName('medida').AsString;
	        EdtMarca.Text:=QFornecimento.FieldByName('marca').AsString;
	        Screen.Cursor:=crDefault;
		    ShowModal;
		    Destroy;
		end;
		AtualizaBotoes(Sender);
    except
        on E : Exception do
	    begin
            Application.MessageBox(PChar('ERRO '+E.Message),'ERRO',0);
			Screen.Cursor:=crDefault;
			Exit;
	    end;
    end;
end;

end.

