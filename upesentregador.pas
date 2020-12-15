unit upesentregador;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, sqldb, db, FileUtil, Forms, Controls, Graphics, Dialogs,
	ExtCtrls, StdCtrls, Buttons, DBGrids, LCLType, ucadentregador;

type

	{ TFPesEntregador }

    TFPesEntregador = class(TForm)
		BtnAdicionar: TBitBtn;
		BtnAlterar: TBitBtn;
		BtnExcluir: TBitBtn;
		BtnPesquisar: TBitBtn;
		BtnVoltar: TBitBtn;
		GridEntregador: TDBGrid;
		DEntregador: TDataSource;
		EdtCodigo: TEdit;
		EdtNome: TEdit;
		EdtCPF: TEdit;
		Label1: TLabel;
		Label2: TLabel;
		Label3: TLabel;
		Label4: TLabel;
		LabelInfo: TLabel;
		PBottom: TPanel;
		PTop: TPanel;
		Q: TSQLQuery;
		QEntregador: TSQLQuery;
		Transaction: TSQLTransaction;
		procedure BtnAdicionarClick(Sender: TObject);
        procedure BtnAlterarClick(Sender: TObject);
        procedure BtnExcluirClick(Sender: TObject);
        procedure BtnPesquisarClick(Sender: TObject);
        procedure BtnVoltarClick(Sender: TObject);
        procedure FormCreate(Sender: TObject);
        procedure AtualizaBotoes(Sender: TObject);
        procedure FormKeyPress(Sender: TObject; var Key: char);
		procedure GridEntregadorDblClick(Sender: TObject);
    private
        { private declarations }
    public
        { public declarations }
        retorna: string;
    end;

var
    FPesEntregador: TFPesEntregador;

implementation

{$R *.lfm}

{ TFPesEntregador }

procedure TFPesEntregador.AtualizaBotoes(Sender: TObject);
begin
    try
	    QEntregador.Close;
	    QEntregador.Open;
	    if QEntregador.RecNo=0 then
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

procedure TFPesEntregador.FormKeyPress(Sender: TObject; var Key: char);
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

procedure TFPesEntregador.GridEntregadorDblClick(Sender: TObject);
begin
    if (BtnAdicionar.Visible) or (QEntregador.RecNo=0) then
        Exit;
    try
	    retorna:=QEntregador.FieldByName('cod_entregador').AsString;
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

procedure TFPesEntregador.BtnVoltarClick(Sender: TObject);
begin
    Close;
end;

procedure TFPesEntregador.FormCreate(Sender: TObject);
begin
    AtualizaBotoes(Sender);
end;

procedure TFPesEntregador.BtnExcluirClick(Sender: TObject);
begin
    Screen.Cursor:=crHourGlass;
    try
		if (Application.MessageBox(PChar('Deseja realmente excluir o entregador '+
	        AnsiUpperCase(QEntregador.FieldByName('nome').AsString)+'?'),'EXCLUIR ENTREGADOR',
			MB_ICONQUESTION+MB_YESNO)=IDYES) then
		begin
		  Q.SQL.Text:='delete from entregador where cod_entregador='+QEntregador.FieldByName('cod_entregador').AsString;
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

procedure TFPesEntregador.BtnPesquisarClick(Sender: TObject);
var filtro: string;
begin
    Screen.Cursor:=crHourGlass;
    filtro:='';

    if (EdtCodigo.Text<>'') then
        filtro:=' where cod_entregador='+EdtCodigo.Text;

    if (Trim(EdtNome.Text)<>'') then
    begin
        if (filtro='') then
            filtro:=' where '
        else
            filtro:=filtro+' or ';
        filtro:=filtro+' lower(nome) like '+QuotedStr(AnsiLowerCase(Trim(EdtNome.Text))+'%');
	end;

    if (EdtCPF.Text<>'') then
    begin
        if (filtro='') then
            filtro:=' where '
        else
            filtro:=filtro+' or ';
        filtro:=filtro+' cpf like '+QuotedStr(Trim(EdtCPF.Text)+'%');
	end;

    try
	    QEntregador.Close;
	    QEntregador.SQL.Clear;
	    QEntregador.SQL.Text:='select * from entregador '+filtro+' order by nome';
	    QEntregador.Open;
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

procedure TFPesEntregador.BtnAlterarClick(Sender: TObject);
begin
    Screen.Cursor:=crHourGlass;
    try
	    Application.CreateForm(TFCadEntregador,FCadEntregador);
	    with FCadEntregador do
	    begin
			cod:=QEntregador.FieldByName('cod_entregador').AsInteger;
	        cpf_anterior:=QEntregador.FieldByName('cpf').AsString;
		    Caption:='Alterar Entregador';
	        EdtNome.Text:=QEntregador.FieldByName('nome').AsString;
	        EdtCPF.Text:=QEntregador.FieldByName('cpf').AsString;
	        EdtTelefone.Text:=QEntregador.FieldByName('telefone').AsString;
	        EdtCodigo.Text:=QEntregador.FieldByName('cod_entregador').AsString;
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

procedure TFPesEntregador.BtnAdicionarClick(Sender: TObject);
begin
    Application.CreateForm(TFCadEntregador,FCadEntregador);
    with FCadEntregador do
    begin
	    cod:=-1;
	    Caption:='Novo Entregador';
        LblCodigo.Visible:=false;
        EdtCodigo.Visible:=false;
	    ShowModal;
	    Destroy;
	end;
	AtualizaBotoes(Sender);
end;

end.

