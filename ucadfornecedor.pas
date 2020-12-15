unit ucadfornecedor;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, sqldb, FileUtil, Forms, Controls, Graphics, Dialogs,
	StdCtrls, MaskEdit, ExtCtrls, Buttons;

type

	{ TFCadFornecedor }

    TFCadFornecedor = class(TForm)
		BtnCancelar: TBitBtn;
		BtnConfirmar: TBitBtn;
		EdtCodigo: TEdit;
		EdtCNPJ: TMaskEdit;
		EdtNome: TEdit;
		EdtTelefone: TMaskEdit;
		Label1: TLabel;
		Label2: TLabel;
		Label7: TLabel;
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
        cnpj_anterior: string;
    end;

var
    FCadFornecedor: TFCadFornecedor;

implementation

{$R *.lfm}

{ TFCadFornecedor }

procedure TFCadFornecedor.FormKeyPress(Sender: TObject; var Key: char);
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

procedure TFCadFornecedor.BtnCancelarClick(Sender: TObject);
begin
    Close;
end;

procedure TFCadFornecedor.BtnConfirmarClick(Sender: TObject);
begin
    Screen.Cursor:=crHourGlass;
    if (EdtNome.Text='') or (EdtCNPJ.Text='') or (EdtTelefone.Text='') then
    begin
        Application.MessageBox('Preencha todos os dados!','Cadastro incompleto',0);
        Screen.Cursor:=crDefault;
        Exit;
	end;
    try
		if cod=-1 then
	    begin
	        Q.SQL.Text:='select nome from fornecedor where cnpj like '+QuotedStr(EdtCNPJ.Text);
		    Q.Open;
		    if Q.RecNo>0 then
	        begin
	            Q.Close;
		        Application.MessageBox('Fornecedor já cadastrado!','Cadastro já existe',0);
	            EdtNome.SetFocus;
	            Screen.Cursor:=crDefault;
	            Exit;
			end;
	        Q.SQL.Text:='insert into fornecedor(nome,cnpj,telefone) values ('+
	                    QuotedStr(EdtNome.Text)+', '+QuotedStr(EdtCNPJ.Text)+', '+QuotedStr(EdtTelefone.Text)+')';
	        Q.ExecSQL;
	        Transaction.Commit;
	        Application.MessageBox('Fornecedor cadastrado com sucesso','Cadastro efetuado',0);
	        Close;
	    end
	    else
	    begin
	        if (EdtCNPJ.Text<>cnpj_anterior) then
		    begin
	            Q.SQL.Text:='select nome from fornecedor where cnpj like '+QuotedStr(EdtCNPJ.Text);
			    Q.Open;
			    if Q.RecNo>0 then
		        begin
		            Q.Close;
			        Application.MessageBox('Fornecedor já cadastrado!','Cadastro já existe',0);
		            EdtNome.SetFocus;
		            Screen.Cursor:=crDefault;
		            Exit;
				end;
			end;
	        Q.SQL.Text:='update fornecedor set nome='+QuotedStr(EdtNome.Text)+
	                    ', cnpj='+QuotedStr(EdtCNPJ.Text)+', telefone='+QuotedStr(EdtTelefone.Text)+
	                    ' where cod_fornecedor='+IntToStr(cod);
	        Q.ExecSQL;
	        Transaction.Commit;
	        Application.MessageBox('Fornecedor alterado com sucesso','Alteração efetuada',0);
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

end.

