unit ucadentregador;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, sqldb, FileUtil, Forms, Controls, Graphics, Dialogs,
	StdCtrls, MaskEdit, ExtCtrls, Buttons;

type

	{ TFCadEntregador }

    TFCadEntregador = class(TForm)
		BtnCancelar: TBitBtn;
		BtnConfirmar: TBitBtn;
		EdtCPF: TMaskEdit;
		EdtCodigo: TEdit;
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
        cpf_anterior: string;
    end;

var
    FCadEntregador: TFCadEntregador;

implementation

{$R *.lfm}

{ TFCadEntregador }

procedure TFCadEntregador.FormKeyPress(Sender: TObject; var Key: char);
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

procedure TFCadEntregador.BtnCancelarClick(Sender: TObject);
begin
    Close;
end;

procedure TFCadEntregador.BtnConfirmarClick(Sender: TObject);
begin
    Screen.Cursor:=crHourGlass;
    if (EdtNome.Text='') or (EdtCPF.Text='') or (EdtTelefone.Text='') then
    begin
        Application.MessageBox('Preencha todos os dados!','Cadastro incompleto',0);
        Screen.Cursor:=crDefault;
        Exit;
	end;
    try
		if cod=-1 then
	    begin
	        Q.SQL.Text:='select nome from entregador where cpf like '+QuotedStr(EdtCPF.Text);
		    Q.Open;
		    if Q.RecNo>0 then
	        begin
	            Q.Close;
		        Application.MessageBox('Entregador já cadastrado!','Cadastro já existe',0);
	            EdtNome.SetFocus;
	            Screen.Cursor:=crDefault;
	            Exit;
			end;
	        Q.SQL.Text:='insert into entregador(nome,cpf,telefone) values ('+
	                    QuotedStr(EdtNome.Text)+', '+QuotedStr(EdtCPF.Text)+', '+QuotedStr(EdtTelefone.Text)+')';
	        Q.ExecSQL;
	        Transaction.Commit;
	        Application.MessageBox('Entregador cadastrado com sucesso','Cadastro efetuado',0);
	        Close;
	    end
	    else
	    begin
	        if (EdtCPF.Text<>cpf_anterior) then
		    begin
	            Q.SQL.Text:='select nome from entregador where cpf like '+QuotedStr(EdtCPF.Text);
			    Q.Open;
			    if Q.RecNo>0 then
		        begin
		            Q.Close;
			        Application.MessageBox('Entregador já cadastrado!','Cadastro já existe',0);
		            EdtNome.SetFocus;
		            Screen.Cursor:=crDefault;
		            Exit;
				end;
			end;
	        Q.SQL.Text:='update entregador set nome='+QuotedStr(EdtNome.Text)+
	                    ', cpf='+QuotedStr(EdtCPF.Text)+', telefone='+QuotedStr(EdtTelefone.Text)+
	                    ' where cod_entregador='+IntToStr(cod);
	        Q.ExecSQL;
	        Transaction.Commit;
	        Application.MessageBox('Entregador alterado com sucesso','Alteração efetuada',0);
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

