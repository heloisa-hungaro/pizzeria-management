unit ucadcliente;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, sqldb, FileUtil, Forms, Controls, Graphics, Dialogs,
	ExtCtrls, Buttons, StdCtrls, MaskEdit, LCLType, ucadendereco;

type

	{ TFCadCliente }

    TFCadCliente = class(TForm)
		BtnConfirmar: TBitBtn;
		BtnCancelar: TBitBtn;
		EdtTelefone: TMaskEdit;
		EdtNome: TEdit;
		EdtRua: TEdit;
		EdtNumero: TEdit;
		EdtComplemento: TEdit;
		EdtCodigo: TEdit;
		Label1: TLabel;
		Label2: TLabel;
		Label3: TLabel;
		Label4: TLabel;
		Label5: TLabel;
		Label7: TLabel;
		LblCodigo: TLabel;
		EdtCEP: TMaskEdit;
		PBottom: TPanel;
		Q: TSQLQuery;
		Transaction: TSQLTransaction;
		procedure BtnCancelarClick(Sender: TObject);
		procedure BtnConfirmarClick(Sender: TObject);
		procedure EdtCEPExit(Sender: TObject);
		procedure FormKeyPress(Sender: TObject; var Key: char);
    private
        { private declarations }
    public
        { public declarations }
        cod: integer;
        telefone_anterior: string;
        telefone: string;
    end;

var
    FCadCliente: TFCadCliente;

implementation

{$R *.lfm}

{ TFCadCliente }

procedure TFCadCliente.BtnCancelarClick(Sender: TObject);
begin
    telefone:='';
    Close;
end;

procedure TFCadCliente.BtnConfirmarClick(Sender: TObject);
begin
    Screen.Cursor:=crHourGlass;
	if (EdtTelefone.Text='') or (EdtNome.Text='') or (EdtCEP.Text='') or (EdtRua.Text='') or (EdtNumero.Text='') then
    begin
        Application.MessageBox('Preencha todos os dados!','Cadastro incompleto',0);
        Screen.Cursor:=crDefault;
        Exit;
	end;
    try
  		Q.Close;
  	    Q.SQL.Text:='select * from endereco where cep='+Trim(EdtCEP.Text);
  	    Q.Open;
  	    if Q.RecNo=0 then
  	    begin
  	        Application.MessageBox('Cadastre anteriormente o CEP para efetivar o cadastro!','CEP não cadastrado',0);
	        Screen.Cursor:=crDefault;
	        Exit;
  		end;
		if cod=-1 then
	    begin
            Q.Close;
	        Q.SQL.Text:='select telefone from cliente where telefone='+EdtTelefone.Text;
		    Q.Open;
		    if Q.RecNo>0 then
	        begin
	            Q.Close;
		        Application.MessageBox('Número de telefone já cadastrado!','Cadastro já existe',0);
	            EdtTelefone.SetFocus;
	            Screen.Cursor:=crDefault;
	            Exit;
			end;
			Q.SQL.Text:='insert into cliente(telefone,nome,cep,numero,complemento) values ('+
	                    EdtTelefone.Text+','+QuotedStr(EdtNome.Text)+','+QuotedStr(EdtCEP.Text)+','+
                        QuotedStr(EdtNumero.Text)+','+QuotedStr(EdtComplemento.Text)+')';
	        Q.ExecSQL;
	        Transaction.Commit;
	        Application.MessageBox('Cliente cadastrado com sucesso','Cadastro efetuado',0);
	        telefone:=EdtTelefone.Text;
	        Close;
	    end
	    else
	    begin
	        if (EdtTelefone.Text<>telefone_anterior) then
		    begin
                Q.Close;
	            Q.SQL.Text:='select telefone from cliente where telefone='+EdtTelefone.Text;
			    Q.Open;
			    if Q.RecNo>0 then
		        begin
		            Q.Close;
			        Application.MessageBox('Número de telefone já cadastrado!','Cadastro já existe',0);
		            EdtTelefone.SetFocus;
		            Screen.Cursor:=crDefault;
		            Exit;
				end;
			end;
			Q.SQL.Text:='update cliente set telefone='+EdtTelefone.Text+', nome='+QuotedStr(EdtNome.Text)+
	                    ', cep='+QuotedStr(EdtCEP.Text)+', numero='+QuotedStr(EdtNumero.Text)+
                        ', complemento='+QuotedStr(EdtComplemento.Text)+
                        ' where cod_cliente='+IntToStr(cod);
	        Q.ExecSQL;
	        Transaction.Commit;
	        Application.MessageBox('Cliente alterado com sucesso','Alteração efetuada',0);
	        Close;
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

procedure TFCadCliente.EdtCEPExit(Sender: TObject);
begin
    if (Trim(EdtCEP.Text)='') then
    begin
        EdtRua.Text:='';
        EdtRua.Enabled:=false;
        Exit;
	end;
    Screen.Cursor:=crHourGlass;
    if (Length(Trim(EdtCEP.Text))<8) then
    begin
        Application.MessageBox('Digite um CEP válido!','CEP inválido',0);
		Screen.Cursor:=crDefault;
		Exit;
	end;
    try
            StrToInt(EdtCEP.Text);
	except
        Application.MessageBox('Digite um CEP válido!','CEP inválido',0);
		Screen.Cursor:=crDefault;
		Exit;
	end;
	try
		Q.Close;
	    Q.SQL.Text:='select * from endereco where cep='+Trim(EdtCEP.Text);
	    Q.Open;
	    if Q.RecNo=0 then
	    begin
            if (Application.MessageBox('O endereço correspondente ao CEP digitado não foi encontrado. Deseja cadastrar endereço com este CEP?','ENDEREÇO NÃO CADASTRADO',
			MB_ICONQUESTION+MB_YESNO)=IDYES) then
			begin
			    Application.CreateForm(TFCadEndereco,FCadEndereco);
			    FCadEndereco.Caption:='Novo Endereço: CEP '+EdtCEP.Text;
				FCadEndereco.EdtCEP.Text:=EdtCEP.Text;
	            FCadEndereco.EdtCEP.Enabled:=false;
		        Screen.Cursor:=crDefault;
			    FCadEndereco.ShowModal;
			    FCadEndereco.Destroy;
                Q.Close;
			    Q.SQL.Text:='select * from endereco where cep='+Trim(EdtCEP.Text);
			    Q.Open;
			    if Q.RecNo=0 then
			    begin
		            EdtCEP.Text:='';
                    EdtRua.Text:='';
		            EdtCEP.SetFocus;
		            Screen.Cursor:=crDefault;
		            Exit;
				end;
			end
            else
            begin
                EdtCEP.Text:='';
                EdtRua.Text:='';
	            EdtCEP.SetFocus;
	            Screen.Cursor:=crDefault;
	            Exit;
			end;
		end;
		EdtRua.Text:=Q.FieldByName('rua').AsString;
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

procedure TFCadCliente.FormKeyPress(Sender: TObject; var Key: char);
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

