unit upescliente;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, sqldb, db, FileUtil, Forms, Controls, Graphics, Dialogs,
	StdCtrls, ExtCtrls, Buttons, DBGrids, LCLType, ucadcliente;

type

	{ TFPesCliente }

    TFPesCliente = class(TForm)
		BtnPesquisar: TBitBtn;
		BtnAdicionar: TBitBtn;
		BtnAlterar: TBitBtn;
		BtnExcluir: TBitBtn;
		BtnVoltar: TBitBtn;
		GridCliente: TDBGrid;
		DCliente: TDataSource;
		EdtTelefone: TEdit;
		EdtNome: TEdit;
		EdtCodigo: TEdit;
		Label1: TLabel;
		Label2: TLabel;
		Label3: TLabel;
		Label4: TLabel;
		LabelInfo: TLabel;
		PTop: TPanel;
		PBottom: TPanel;
		QCliente: TSQLQuery;
		Q: TSQLQuery;
		Transaction: TSQLTransaction;
		procedure BtnAdicionarClick(Sender: TObject);
		procedure BtnAlterarClick(Sender: TObject);
        procedure BtnExcluirClick(Sender: TObject);
        procedure BtnPesquisarClick(Sender: TObject);
        procedure BtnVoltarClick(Sender: TObject);
        procedure FormCreate(Sender: TObject);
		procedure FormKeyPress(Sender: TObject; var Key: char);
        procedure AtualizaBotoes(Sender: TObject);
		procedure GridClienteDblClick(Sender: TObject);
    private
        { private declarations }
    public
        { public declarations }
        retorna: string;
    end;

var
    FPesCliente: TFPesCliente;

implementation

{$R *.lfm}

{ TFPesCliente }

procedure TFPesCliente.AtualizaBotoes(Sender: TObject);
begin
    try
	    QCliente.Close;
	    QCliente.Open;
	    if QCliente.RecNo=0 then
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

procedure TFPesCliente.GridClienteDblClick(Sender: TObject);
begin
    if (BtnAdicionar.Visible) or (QCliente.RecNo=0) then
        Exit;
    try
	    retorna:=QCliente.FieldByName('telefone').AsString;
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

procedure TFPesCliente.BtnVoltarClick(Sender: TObject);
begin
    Close;
end;

procedure TFPesCliente.FormCreate(Sender: TObject);
begin
    AtualizaBotoes(Sender);
end;

procedure TFPesCliente.BtnPesquisarClick(Sender: TObject);
var filtro: string;
begin
    Screen.Cursor:=crHourGlass;
    filtro:='';

    if (EdtCodigo.Text<>'') then
        filtro:=' where cod_cliente='+EdtCodigo.Text;

    if (EdtTelefone.Text<>'') then
    begin
        if (filtro='') then
            filtro:=' where '
        else
            filtro:=filtro+' or ';
        filtro:=filtro+' telefone='+EdtTelefone.Text;
	end;


    if (Trim(EdtNome.Text)<>'') then
    begin
        if (filtro='') then
            filtro:=' where '
        else
            filtro:=filtro+' or ';
        filtro:=filtro+' lower(nome) like '+QuotedStr(AnsiLowerCase(Trim(EdtNome.Text))+'%');
	end;

    try
	    QCliente.Close;
	    QCliente.SQL.Clear;
	    QCliente.SQL.Text:='select c.*, e.rua from cliente c left join endereco e on e.cep=c.cep '+
                            filtro+' order by c.cod_cliente desc';
	    QCliente.Open;
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

procedure TFPesCliente.BtnExcluirClick(Sender: TObject);
begin
    Screen.Cursor:=crHourGlass;
    try
	    Q.Close;
	    Q.SQL.Text:='select * from pedido where '+
	                'cod_cliente='+QCliente.FieldByName('cod_cliente').AsString;
	    Q.Open;

	    if (Q.RecNo>0) then
	    begin
	        Q.Close;
		    if (Application.MessageBox(PChar('O cliente que deseja excluir possui pedidos cadastrados!'+
	                #10+'Deseja REALMENTE continuar?'),'AVISO IMPORTANTE',MB_ICONQUESTION+MB_YESNO)=IDNO) then
		    begin
	            Screen.Cursor:=crDefault;
	            Exit;
	        end;
		end;

	    if (Application.MessageBox(PChar('Deseja realmente excluir o cliente '+AnsiUpperCase(QCliente.FieldByName('nome').AsString)+
	        ', telefone '+QCliente.FieldByName('telefone').AsString+' ?'),'EXCLUIR CLIENTE',
	        MB_ICONQUESTION+MB_YESNO)=IDYES) then
	    begin
	        Q.SQL.Text:='delete from cliente where cod_cliente='+QCliente.FieldByName('cod_cliente').AsString;
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

procedure TFPesCliente.BtnAdicionarClick(Sender: TObject);
begin
    Application.CreateForm(TFCadCliente,FCadCliente);
    with FCadCliente do
    begin
	    cod:=-1;
	    Caption:='Novo Cliente';
        LblCodigo.Visible:=false;
        EdtCodigo.Visible:=false;
	    ShowModal;
	    Destroy;
	end;
	AtualizaBotoes(Sender);
end;

procedure TFPesCliente.BtnAlterarClick(Sender: TObject);
begin
    Screen.Cursor:=crHourGlass;
    try
	    Application.CreateForm(TFCadCliente,FCadCliente);
	    with FCadCliente do
	    begin
			cod:=QCliente.FieldByName('cod_cliente').AsInteger;
	        telefone_anterior:=QCliente.FieldByName('telefone').AsString;
		    Caption:='Alterar Cliente';
	        EdtTelefone.Text:=QCliente.FieldByName('telefone').AsString;
	        EdtNome.Text:=QCliente.FieldByName('nome').AsString;
	        EdtCEP.Text:=QCliente.FieldByName('cep').AsString;
	        EdtRua.Text:=QCliente.FieldByName('rua').AsString;
	        EdtNumero.Text:=QCliente.FieldByName('numero').AsString;
	        EdtComplemento.Text:=QCliente.FieldByName('complemento').AsString;
	        EdtCodigo.Text:=QCliente.FieldByName('cod_cliente').AsString;
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

procedure TFPesCliente.FormKeyPress(Sender: TObject; var Key: char);
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



end.

