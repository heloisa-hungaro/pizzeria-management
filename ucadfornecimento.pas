unit ucadfornecimento;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, sqldb, FileUtil, Forms, Controls, Graphics, Dialogs,
	ExtCtrls, Buttons, StdCtrls, MaskEdit, Spin, upesfornecedor, upesingrediente;

type

	{ TFCadFornecimento }

    TFCadFornecimento = class(TForm)
		BtnCancelar: TBitBtn;
		BtnConfirmar: TBitBtn;
		BtnPesqFornecedor: TBitBtn;
		BtnPesqIngrediente: TBitBtn;
		EdtCodFornecedor: TEdit;
		EdtCodIngrediente: TEdit;
		EdtNomeFornecedor: TEdit;
		EdtNomeIngrediente: TEdit;
		EdtMedida: TEdit;
		EdtData: TMaskEdit;
		EdtMarca: TEdit;
		EdtValor: TFloatSpinEdit;
		EdtQtde: TFloatSpinEdit;
		Label1: TLabel;
		Label3: TLabel;
		LblCodigo: TLabel;
		LblCodigo1: TLabel;
		LblCodigo2: TLabel;
		LblCodigo3: TLabel;
		LblCodigo4: TLabel;
		PBottom: TPanel;
		Q: TSQLQuery;
		Transaction: TSQLTransaction;
		procedure BtnCancelarClick(Sender: TObject);
		procedure BtnConfirmarClick(Sender: TObject);
		procedure BtnPesqFornecedorClick(Sender: TObject);
		procedure BtnPesqIngredienteClick(Sender: TObject);
		procedure EdtCodFornecedorExit(Sender: TObject);
		procedure EdtCodIngredienteExit(Sender: TObject);
        procedure FormKeyPress(Sender: TObject; var Key: char);
		procedure FormShow(Sender: TObject);
    private
        { private declarations }
    public
        { public declarations }
        cod_fornecedor, cod_ingrediente: integer;
        data, marca: string;
    end;

var
    FCadFornecimento: TFCadFornecimento;

implementation

{$R *.lfm}

{ TFCadFornecimento }

procedure TFCadFornecimento.FormKeyPress(Sender: TObject; var Key: char);
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

procedure TFCadFornecimento.FormShow(Sender: TObject);
begin
    EdtCodIngredienteExit(Sender);
    EdtCodFornecedorExit(Sender);
end;

procedure TFCadFornecimento.BtnCancelarClick(Sender: TObject);
begin
    Close;
end;

procedure TFCadFornecimento.BtnConfirmarClick(Sender: TObject);
var val,qtde: string;
begin
    Screen.Cursor:=crHourGlass;
    Q.Close;
    if (EdtData.Text='  /  /    ') or (EdtCodFornecedor.Text='') or (EdtCodIngrediente.Text='')
        or (EdtValor.Value=0) or (EdtQtde.Value=0) or (EdtMedida.Text='') then
    begin
        Application.MessageBox('Preencha todos os dados!','Cadastro incompleto',0);
        Screen.Cursor:=crDefault;
        Exit;
	end;
    try
	    val:=StringReplace(FloattoStr(EdtValor.Value), ',', '.', [rfReplaceAll, rfIgnoreCase]);
		qtde:=StringReplace(FloattoStr(EdtQtde.Value), ',', '.', [rfReplaceAll, rfIgnoreCase]);
		if cod_fornecedor=-1 then
	    begin
	        Q.SQL.Text:='select data, cod_ingrediente, cod_fornecedor, marca from fornecedor_fornece_ingrediente where '+
	                    ' data='+QuotedStr(FormatDateTime('yyyy-mm-dd',StrToDate(EdtData.Text)))+' and '+
	                    ' cod_ingrediente='+EdtCodIngrediente.Text+' and cod_fornecedor='+EdtCodFornecedor.Text+
	                    ' and marca like '+QuotedStr(EdtMarca.Text);
		    Q.Open;
		    if Q.RecNo>0 then
	        begin
	            Q.Close;
		        Application.MessageBox('Fornecimento já cadastrado!','Cadastro já existe',0);
	            EdtData.SetFocus;
	            Screen.Cursor:=crDefault;
	            Exit;
			end;
	        Q.Close;
	        Q.SQL.Text:='insert into fornecedor_fornece_ingrediente(data, cod_fornecedor, cod_ingrediente, marca, valor_unitario, '+
	                    ' quantidade, medida) values ('+QuotedStr(FormatDateTime('yyyy-mm-dd',StrToDate(EdtData.Text)))+
	                    ', '+EdtCodFornecedor.Text+', '+EdtCodIngrediente.Text+', '+QuotedStr(EdtMarca.Text)+
	                    ', '+val+', '+qtde+', '+QuotedStr(EdtMedida.Text)+')';
	        Q.ExecSQL;
	        Transaction.Commit;
	        Application.MessageBox('Fornecimento cadastrado com sucesso','Cadastro efetuado',0);
	        Close;
	    end
	    else
	    begin
	        if (EdtData.Text<>data) or (StrToInt(EdtCodFornecedor.Text)<>cod_fornecedor) or
	            (StrToInt(EdtCodIngrediente.Text)<>cod_ingrediente) or (AnsiLowerCase(EdtMarca.Text)<>AnsiLowerCase(marca)) then
		    begin
	            Q.SQL.Text:='select data, cod_ingrediente, cod_fornecedor, marca from fornecedor_fornece_ingrediente where '+
	                    ' data='+QuotedStr(FormatDateTime('yyyy-mm-dd',StrToDate(EdtData.Text)))+' and '+
	                    ' cod_ingrediente='+EdtCodIngrediente.Text+' and cod_fornecedor='+EdtCodFornecedor.Text+
	                    ' and marca like '+QuotedStr(EdtMarca.Text);
			    Q.Open;
			    if Q.RecNo>0 then
		        begin
		            Q.Close;
			        Application.MessageBox('Fornecimento já cadastrado!','Cadastro já existe',0);
		            EdtData.SetFocus;
		            Screen.Cursor:=crDefault;
		            Exit;
				end;
			end;
	        Q.Close;
	        Q.SQL.Text:='update fornecedor_fornece_ingrediente set data='+QuotedStr(FormatDateTime('yyyy-mm-dd',StrToDate(EdtData.Text)))+
	                    ', cod_ingrediente='+EdtCodIngrediente.Text+', cod_fornecedor='+EdtCodFornecedor.Text+
	                    ', marca='+QuotedStr(EdtMarca.Text)+', valor_unitario='+val+', quantidade='+qtde+
	                    ', medida='+QuotedStr(EdtMedida.Text)+
	                    ' where data='+QuotedStr(FormatDateTime('yyyy-mm-dd',StrToDate(data)))+' and '+
	                    ' cod_ingrediente='+IntToStr(cod_ingrediente)+' and cod_fornecedor='+IntToStr(cod_fornecedor)+
	                    ' and marca like '+QuotedStr(marca);
	        Q.ExecSQL;
	        Transaction.Commit;
	        Application.MessageBox('Fornecimento alterado com sucesso','Alteração efetuada',0);
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

procedure TFCadFornecimento.BtnPesqFornecedorClick(Sender: TObject);
begin
    Screen.Cursor:=crHourGlass;
    Application.CreateForm(TFPesFornecedor,FPesFornecedor);
    FPesFornecedor.BtnAdicionar.Visible:=false;
    FPesFornecedor.BtnAlterar.Visible:=false;
    FPesFornecedor.BtnExcluir.Visible:=false;
    FPesFornecedor.LabelInfo.Visible:=true;
    FPesFornecedor.ShowModal;
    if (FPesFornecedor.retorna<>'') then
    begin
	    EdtCodFornecedor.Text:=FPesFornecedor.retorna;
	    EdtCodFornecedorExit(Sender);
	end;
	FPesFornecedor.Destroy;
    Screen.Cursor:=crDefault;
end;

procedure TFCadFornecimento.BtnPesqIngredienteClick(Sender: TObject);
begin
    Screen.Cursor:=crHourGlass;
    Application.CreateForm(TFPesIngrediente,FPesIngrediente);
    FPesIngrediente.BtnAdicionar.Visible:=false;
    FPesIngrediente.BtnAlterar.Visible:=false;
    FPesIngrediente.BtnExcluir.Visible:=false;
    FPesIngrediente.LabelInfo.Visible:=true;
    FPesIngrediente.ShowModal;
    if (FPesIngrediente.retorna<>'') then
    begin
	    EdtCodIngrediente.Text:=FPesIngrediente.retorna;
	    EdtCodIngredienteExit(Sender);
	end;
	FPesIngrediente.Destroy;
    Screen.Cursor:=crDefault;
end;

procedure TFCadFornecimento.EdtCodFornecedorExit(Sender: TObject);
begin
    if (Trim(EdtCodFornecedor.Text)='') then
    begin
        EdtNomeFornecedor.Text:='';
        Exit;
	end;
    Screen.Cursor:=crHourGlass;
    try
		Q.Close;
	    Q.SQL.Text:='select cod_fornecedor, nome from fornecedor where cod_fornecedor='+EdtCodFornecedor.Text;
	    Q.Open;
	    if Q.RecNo=0 then
	    begin
	        EdtNomeFornecedor.Text:='';
	        EdtCodFornecedor.Text:='';
	        Screen.Cursor:=crDefault;
	        Exit;
		end;
	    EdtNomeFornecedor.Text:=Q.FieldByName('nome').AsString;
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

procedure TFCadFornecimento.EdtCodIngredienteExit(Sender: TObject);
begin
    if (Trim(EdtCodIngrediente.Text)='') then
    begin
        EdtNomeIngrediente.Text:='';
        Exit;
	end;
    Screen.Cursor:=crHourGlass;
    try
		Q.Close;
	    Q.SQL.Text:='select cod_ingrediente, nome from ingrediente where cod_ingrediente='+EdtCodIngrediente.Text;
	    Q.Open;
	    if Q.RecNo=0 then
	    begin
	        EdtNomeIngrediente.Text:='';
	        EdtCodIngrediente.Text:='';
	        Screen.Cursor:=crDefault;
	        Exit;
		end;
	    EdtNomeIngrediente.Text:=Q.FieldByName('nome').AsString;
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

