unit ucadendereco;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, sqldb, FileUtil, Forms, Controls, Graphics, Dialogs,
	StdCtrls, MaskEdit, ExtCtrls, Buttons;

type

	{ TFCadEndereco }

    TFCadEndereco = class(TForm)
		BtnCancelar: TBitBtn;
		BtnConfirmar: TBitBtn;
		EdtCEP: TMaskEdit;
		EdtRua: TEdit;
		Label2: TLabel;
		Label7: TLabel;
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
        cep: string;
    end;

var
    FCadEndereco: TFCadEndereco;

implementation

{$R *.lfm}

{ TFCadEndereco }

procedure TFCadEndereco.FormKeyPress(Sender: TObject; var Key: char);
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

procedure TFCadEndereco.EdtCEPExit(Sender: TObject);
begin
    Screen.Cursor:=crHourGlass;
    if (Length(Trim(EdtCEP.Text))<8) then
    begin
        Application.MessageBox('Digite um CEP válido!','CEP inválido',0);
		Screen.Cursor:=crDefault;
        EdtCEP.SetFocus;
		Exit;
	end;
    try
            StrToInt(EdtCEP.Text);
	except
        Application.MessageBox('Digite um CEP válido!','CEP inválido',0);
		Screen.Cursor:=crDefault;
        EdtCEP.SetFocus;
		Exit;
	end;
    Screen.Cursor:=crDefault;
end;

procedure TFCadEndereco.BtnConfirmarClick(Sender: TObject);
begin
    Screen.Cursor:=crHourGlass;
    if (Trim(EdtCEP.Text)='') or (EdtRua.Text='') then
    begin
          Application.MessageBox('Preencha todos os dados!','Cadastro incompleto',0);
          Screen.Cursor:=crDefault;
          Exit;
  	end;
    if (Length(Trim(EdtCEP.Text))<8) then
    begin
        Application.MessageBox('Digite um CEP válido!','CEP inválido',0);
		Screen.Cursor:=crDefault;
        EdtCEP.SetFocus;
		Exit;
	end;
    try
            StrToInt(EdtCEP.Text);
	except
        Application.MessageBox('Digite um CEP válido!','CEP inválido',0);
		Screen.Cursor:=crDefault;
        EdtCEP.SetFocus;
		Exit;
	end;

    try
  		if cep='' then
  	    begin
  	        Q.SQL.Text:='select cep from endereco where cep like '+QuotedStr(EdtCEP.Text);
  		    Q.Open;
  		    if Q.RecNo>0 then
  	        begin
  	            Q.Close;
  		        Application.MessageBox('Endereço já cadastrado!','Cadastro já existe',0);
  	            EdtCEP.SetFocus;
  	            Screen.Cursor:=crDefault;
  	            Exit;
  			end;
  	        Q.SQL.Text:='insert into endereco(cep,rua) values ('+
  	                    QuotedStr(EdtCEP.Text)+', '+QuotedStr(EdtRua.Text)+')';
  	        Q.ExecSQL;
  	        Transaction.Commit;
  	        Application.MessageBox('Endereço cadastrado com sucesso','Cadastro efetuado',0);
  	        Close;
  	    end
  	    else
  	    begin
  	        Q.SQL.Text:='update endereco set rua='+QuotedStr(EdtRua.Text)+
                        ' where cep='+QuotedStr(cep);
  	        Q.ExecSQL;
  	        Transaction.Commit;
  	        Application.MessageBox('Endereço alterado com sucesso','Alteração efetuada',0);
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

procedure TFCadEndereco.BtnCancelarClick(Sender: TObject);
begin
    Close;
end;

end.

