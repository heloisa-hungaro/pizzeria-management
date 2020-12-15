unit upesfornecedor;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, sqldb, db, FileUtil, Forms, Controls, Graphics, Dialogs,
	ExtCtrls, StdCtrls, Buttons, DBGrids, LCLType, Menus, ucadfornecedor;

type

	{ TFPesFornecedor }

    TFPesFornecedor = class(TForm)
		BtnAdicionar: TBitBtn;
		BtnAlterar: TBitBtn;
		BtnExcluir: TBitBtn;
		BtnPesquisar: TBitBtn;
		BtnVoltar: TBitBtn;
		GridFornecedores: TDBGrid;
		DFornecedor: TDataSource;
		EdtCodigo: TEdit;
		EdtCNPJ: TEdit;
		EdtNome: TEdit;
		Label1: TLabel;
		Label2: TLabel;
		Label3: TLabel;
		Label4: TLabel;
		LabelInfo: TLabel;
		PBottom: TPanel;
		PTop: TPanel;
		Q: TSQLQuery;
		QFornecedor: TSQLQuery;
		Transaction: TSQLTransaction;
		procedure BtnAdicionarClick(Sender: TObject);
        procedure BtnAlterarClick(Sender: TObject);
        procedure BtnExcluirClick(Sender: TObject);
        procedure BtnPesquisarClick(Sender: TObject);
        procedure BtnVoltarClick(Sender: TObject);
        procedure AtualizaBotoes(Sender: TObject);
		procedure GridFornecedoresDblClick(Sender: TObject);
		procedure FormCreate(Sender: TObject);
        procedure FormKeyPress(Sender: TObject; var Key: char);
    private
        { private declarations }
    public
        { public declarations }
        retorna: string;
    end;

var
    FPesFornecedor: TFPesFornecedor;

implementation

{$R *.lfm}

{ TFPesFornecedor }

procedure TFPesFornecedor.AtualizaBotoes(Sender: TObject);
begin
    try
	    QFornecedor.Close;
	    QFornecedor.Open;
	    if QFornecedor.RecNo=0 then
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

procedure TFPesFornecedor.GridFornecedoresDblClick(Sender: TObject);
begin
    if (BtnAdicionar.Visible) or (QFornecedor.RecNo=0) then
        Exit;
    try
	    retorna:=QFornecedor.FieldByName('cod_fornecedor').AsString;
	    Close;
    except
        on E : Exception do
	    begin
            Application.MessageBox(PChar('ERRO '+E.Message),'ERRO',0);
			Screen.Cursor:=crDefault;
			Exit;
	    end;
    end;
end;

procedure TFPesFornecedor.FormCreate(Sender: TObject);
begin
    AtualizaBotoes(Sender);
end;

procedure TFPesFornecedor.FormKeyPress(Sender: TObject; var Key: char);
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



procedure TFPesFornecedor.BtnVoltarClick(Sender: TObject);
begin
    Close;
end;

procedure TFPesFornecedor.BtnExcluirClick(Sender: TObject);
var straviso: string;
begin
    straviso:='';
    if QFornecedor.RecNo=0 then
        Exit;
    Screen.Cursor:=crHourGlass;
    try
	    Q.Close;
		    Q.SQL.Text:='select cod_fornecedor from fornecedor_fornece_ingrediente '+
	                ' where cod_fornecedor='+QFornecedor.FieldByName('cod_fornecedor').AsString;
	    Q.Open;
	    if (Q.RecNo>0) then
	    begin
	        if (Application.MessageBox(PChar('Este fornecedor possui fornecimentos cadastrados'+#10+
	                                    'Ao removê-lo, seus fornecimentos também serão removidos.'+#10+#10+
	                                    'Deseja REALMENTE continuar?'),'AVISO IMPORTANTE',MB_ICONQUESTION+MB_YESNO)=IDNO) then
		    begin
	            Screen.Cursor:=crDefault;
	            Exit;
		    end;
		end;
		if (Application.MessageBox(PChar('Deseja realmente excluir o fornecedor '+
	        AnsiUpperCase(QFornecedor.FieldByName('nome').AsString)+'?'),'EXCLUIR FORNECEDOR',
			MB_ICONQUESTION+MB_YESNO)=IDYES) then
		begin
		  Q.SQL.Text:='delete from fornecedor where cod_fornecedor='+QFornecedor.FieldByName('cod_fornecedor').AsString;
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

procedure TFPesFornecedor.BtnPesquisarClick(Sender: TObject);
var filtro: string;
begin
    Screen.Cursor:=crHourGlass;
    filtro:='';

    if (EdtCodigo.Text<>'') then
        filtro:=' where cod_fornecedor='+EdtCodigo.Text;

    if (Trim(EdtNome.Text)<>'') then
    begin
        if (filtro='') then
            filtro:=' where '
        else
            filtro:=filtro+' or ';
        filtro:=filtro+' lower(nome) like '+QuotedStr(AnsiLowerCase(Trim(EdtNome.Text))+'%');
	end;

    if (EdtCNPJ.Text<>'') then
    begin
        if (filtro='') then
            filtro:=' where '
        else
            filtro:=filtro+' or ';
        filtro:=filtro+' cnpj like '+QuotedStr(Trim(EdtCNPJ.Text)+'%');
	end;

    try
	    QFornecedor.Close;
	    QFornecedor.SQL.Clear;
	    QFornecedor.SQL.Text:='select * from fornecedor '+filtro+' order by nome';
	    QFornecedor.Open;
	    EdtCodigo.SetFocus;
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

procedure TFPesFornecedor.BtnAlterarClick(Sender: TObject);
begin
    Screen.Cursor:=crHourGlass;
    try
	    Application.CreateForm(TFCadFornecedor,FCadFornecedor);
	    with FCadFornecedor do
	    begin
			cod:=QFornecedor.FieldByName('cod_fornecedor').AsInteger;
	        cnpj_anterior:=QFornecedor.FieldByName('cnpj').AsString;
		    Caption:='Alterar Fornecedor';
	        EdtNome.Text:=QFornecedor.FieldByName('nome').AsString;
	        EdtCNPJ.Text:=QFornecedor.FieldByName('cnpj').AsString;
	        EdtTelefone.Text:=QFornecedor.FieldByName('telefone').AsString;
	        EdtCodigo.Text:=QFornecedor.FieldByName('cod_fornecedor').AsString;
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

procedure TFPesFornecedor.BtnAdicionarClick(Sender: TObject);
begin
    Application.CreateForm(TFCadFornecedor,FCadFornecedor);
    with FCadFornecedor do
    begin
	    cod:=-1;
	    Caption:='Novo Fornecedor';
        LblCodigo.Visible:=false;
        EdtCodigo.Visible:=false;
	    ShowModal;
	    Destroy;
	end;
	AtualizaBotoes(Sender);
end;

end.

