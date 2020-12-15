unit upesendereco;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, db, sqldb, FileUtil, Forms, Controls, Graphics, Dialogs,
	ExtCtrls, StdCtrls, Buttons, MaskEdit, DBGrids, LCLType, ucadendereco;

type

	{ TFPesEndereco }

    TFPesEndereco = class(TForm)
		BtnAdicionar: TBitBtn;
		BtnAlterar: TBitBtn;
		BtnExcluir: TBitBtn;
		BtnPesquisar: TBitBtn;
		BtnVoltar: TBitBtn;
		DEndereco: TDataSource;
		EdtCEP: TMaskEdit;
		EdtRua: TEdit;
		GridEntregador: TDBGrid;
		Label2: TLabel;
		Label4: TLabel;
		PBottom: TPanel;
		PTop: TPanel;
		Q: TSQLQuery;
		QEndereco: TSQLQuery;
		QEnderecocep: TStringField;
		QEnderecorua: TStringField;
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
    FPesEndereco: TFPesEndereco;

implementation

{$R *.lfm}

{ TFPesEndereco }

procedure TFPesEndereco.AtualizaBotoes(Sender: TObject);
begin
    try
	    QEndereco.Close;
	    QEndereco.Open;
	    if QEndereco.RecNo=0 then
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

procedure TFPesEndereco.FormCreate(Sender: TObject);
begin
    AtualizaBotoes(Sender);
end;

procedure TFPesEndereco.BtnVoltarClick(Sender: TObject);
begin
    Close;
end;

procedure TFPesEndereco.BtnPesquisarClick(Sender: TObject);
var filtro: string;
begin
    Screen.Cursor:=crHourGlass;


    filtro:='';

    if (Trim(EdtCEP.Text)<>'') then
    begin
        if (Length(Trim(EdtCEP.Text))<8) then
	    begin
	        Application.MessageBox('Digite um CEP válido para pesquisa','CEP inválido',0);
			Screen.Cursor:=crDefault;
	        EdtCEP.SetFocus;
			Exit;
		end;
	    try
	            StrToInt(EdtCEP.Text);
		except
	        Application.MessageBox('Digite um CEP válido para pesquisa','CEP inválido',0);
			Screen.Cursor:=crDefault;
	        EdtCEP.SetFocus;
			Exit;
		end;
        filtro:=' where cep='+EdtCEP.Text;
	end;

    if (Trim(EdtRua.Text)<>'') then
    begin
        if (filtro='') then
            filtro:=' where '
        else
            filtro:=filtro+' or ';
        filtro:=filtro+' lower(rua) like '+QuotedStr('%'+AnsiLowerCase(Trim(EdtRua.Text))+'%');
	end;
    try
	    QEndereco.Close;
	    QEndereco.SQL.Clear;
	    QEndereco.SQL.Text:='select * from endereco '+filtro+' order by rua';
	    QEndereco.Open;
	    EdtCEP.SetFocus;
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

procedure TFPesEndereco.BtnExcluirClick(Sender: TObject);
begin
    Screen.Cursor:=crHourGlass;
    try
        Q.Close;
	    Q.SQL.Text:='select cep from cliente where cep='+QEndereco.FieldByName('cep').AsString;
	    Q.Open;
	    if (Q.RecNo>0) then
	    begin
		    Application.MessageBox(PChar('O endereço que deseja excluir ('+
			            AnsiUpperCase(QEndereco.FieldByName('rua').AsString)+') consta em cadastros de clientes.'+#10+
			            'Por questões de segurança, não é possível excluir este endereço.'),
			            'ENDEREÇO EM USO',0);
	        Screen.Cursor:=crDefault;
	        Exit;
		end;

		if (Application.MessageBox(PChar('Deseja realmente excluir o endereco da rua '+
	        AnsiUpperCase(QEndereco.FieldByName('rua').AsString)+'?'),'EXCLUIR ENDEREÇO',
			MB_ICONQUESTION+MB_YESNO)=IDYES) then
		begin
		  Q.SQL.Text:='delete from endereco where cep='+QEndereco.FieldByName('cep').AsString;
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

procedure TFPesEndereco.BtnAdicionarClick(Sender: TObject);
begin
    Application.CreateForm(TFCadEndereco,FCadEndereco);
    with FCadEndereco do
    begin
	    cep:='';
	    Caption:='Novo Endereço';
	    ShowModal;
	    Destroy;
	end;
	AtualizaBotoes(Sender);
end;

procedure TFPesEndereco.BtnAlterarClick(Sender: TObject);
begin
    Screen.Cursor:=crHourGlass;
    try
	    Application.CreateForm(TFCadEndereco,FCadEndereco);
	    with FCadEndereco do
	    begin
			cep:=QEndereco.FieldByName('cep').AsString;
		    Caption:='Alterar Endereço';
	        EdtRua.Text:=QEndereco.FieldByName('rua').AsString;
			EdtCEP.Text:=QEndereco.FieldByName('cep').AsString;
            EdtCEP.Enabled:=false;
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

procedure TFPesEndereco.FormKeyPress(Sender: TObject; var Key: char);
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

