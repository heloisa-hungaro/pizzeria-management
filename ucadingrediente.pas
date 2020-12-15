unit ucadingrediente;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, sqldb, FileUtil, Forms, Controls, Graphics, Dialogs,
	ExtCtrls, Buttons, StdCtrls;

type

	{ TFCadIngrediente }

    TFCadIngrediente = class(TForm)
		BtnCancelar: TBitBtn;
		BtnConfirmar: TBitBtn;
		CbUso: TComboBox;
		EdtCodigo: TEdit;
		EdtNome: TEdit;
		Label2: TLabel;
		Label3: TLabel;
		LblCodigo: TLabel;
		PBottom: TPanel;
		Q: TSQLQuery;
		Transaction: TSQLTransaction;
		procedure BtnCancelarClick(Sender: TObject);
  procedure BtnConfirmarClick(Sender: TObject);
        procedure FormKeyPress(Sender: TObject; var Key: char);
    private
        { private declarations }
    public
        { public declarations }
        cod: integer;
        nome_anterior: string;
    end;

var
    FCadIngrediente: TFCadIngrediente;

implementation

{$R *.lfm}

{ TFCadIngrediente }

procedure TFCadIngrediente.FormKeyPress(Sender: TObject; var Key: char);
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

procedure TFCadIngrediente.BtnConfirmarClick(Sender: TObject);
begin
    Screen.Cursor:=crHourGlass;
    if (EdtNome.Text='') or (CbUso.ItemIndex<0) or (CbUso.ItemIndex>2) then
    begin
        Application.MessageBox('Preencha todos os dados!','Cadastro incompleto',0);
        Screen.Cursor:=crDefault;
        Exit;
	end;
    try
		if cod=-1 then
	    begin
	        Q.SQL.Text:='select nome from ingrediente where lower(nome) like '+QuotedStr(AnsiLowerCase(trim(EdtNome.Text)));
		    Q.Open;
		    if Q.RecNo>0 then
	        begin
	            Q.Close;
		        Application.MessageBox('Ingrediente já cadastrado!','Cadastro já existe',0);
	            EdtNome.SetFocus;
	            Screen.Cursor:=crDefault;
	            Exit;
			end;
	        Q.SQL.Text:='insert into ingrediente(nome,uso) values ('+
	                    QuotedStr(Trim(EdtNome.Text))+', '+IntToStr(CbUso.ItemIndex)+')';
	        Q.ExecSQL;
	        Transaction.Commit;
	        Application.MessageBox('Ingrediente cadastrado com sucesso','Cadastro efetuado',0);
	        Close;
	    end
	    else
	    begin
	        if (AnsiLowerCase(Trim(EdtNome.Text))<>AnsiLowerCase(nome_anterior)) then
	      	begin
		        Q.SQL.Text:='select nome from ingrediente where lower(nome) like '+QuotedStr(AnsiLowerCase(trim(EdtNome.Text)));
			    Q.Open;
			    if Q.RecNo>0 then
		        begin
		            Q.Close;
			        Application.MessageBox('Ingrediente já cadastrado!','Cadastro já existe',0);
		            EdtNome.SetFocus;
		            Screen.Cursor:=crDefault;
		            Exit;
				end;
	        end;
	        Q.SQL.Text:='update ingrediente set nome='+QuotedStr(Trim(EdtNome.Text))+
	                    ', uso='+IntToStr(CbUso.ItemIndex)+' where cod_ingrediente='+IntToStr(cod);
	        Q.ExecSQL;
	        Transaction.Commit;
	        Application.MessageBox('Ingrediente alterado com sucesso','Alteração efetuada',0);
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

procedure TFCadIngrediente.BtnCancelarClick(Sender: TObject);
begin
    Close;
end;

end.

