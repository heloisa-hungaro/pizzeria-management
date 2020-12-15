unit ucadpizza;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, sqldb, FileUtil, Forms, Controls, Graphics, Dialogs,
	StdCtrls, ExtCtrls, Buttons, Spin, Grids, upesingrediente;

type

	{ TFCadPizza }

    TFCadPizza = class(TForm)
		BtnAdicionar: TBitBtn;
		BtnCancelar: TBitBtn;
		BtnConfirmar: TBitBtn;
		BtnPesqIngrediente: TBitBtn;
		CbTipo: TComboBox;
		EdtCodigo: TEdit;
		EdtCodIngrediente: TEdit;
		EdtNomeIngrediente: TEdit;
		EdtSabor: TEdit;
		EdtPreco: TFloatSpinEdit;
		Label1: TLabel;
		Label2: TLabel;
		Label3: TLabel;
		Label4: TLabel;
		LblCodigo: TLabel;
		LblCodigo1: TLabel;
		PBottom: TPanel;
		Q: TSQLQuery;
		GridIngredientes: TStringGrid;
		Transaction: TSQLTransaction;
		procedure BtnAdicionarClick(Sender: TObject);
		procedure BtnCancelarClick(Sender: TObject);
		procedure BtnConfirmarClick(Sender: TObject);
  procedure BtnPesqIngredienteClick(Sender: TObject);
		procedure EdtCodIngredienteExit(Sender: TObject);
        procedure FormKeyPress(Sender: TObject; var Key: char);
		procedure GridIngredientesDblClick(Sender: TObject);
    private
        { private declarations }
    public
        { public declarations }
        cod_pizza: integer;
        sabor: string;
    end;

var
    FCadPizza: TFCadPizza;

implementation

{$R *.lfm}

{ TFCadPizza }

procedure TFCadPizza.FormKeyPress(Sender: TObject; var Key: char);
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

procedure TFCadPizza.GridIngredientesDblClick(Sender: TObject);
var r: integer;
begin
    for r:=GridIngredientes.Row to GridIngredientes.RowCount-2 do
        GridIngredientes.Rows[r].Assign(GridIngredientes.Rows[r+1]);
        GridIngredientes.RowCount:=GridIngredientes.RowCount-1;
end;

procedure TFCadPizza.BtnPesqIngredienteClick(Sender: TObject);
begin
    Application.CreateForm(TFPesIngrediente,FPesIngrediente);
    FPesIngrediente.BtnAdicionar.Visible:=false;
    FPesIngrediente.BtnAlterar.Visible:=false;
    FPesIngrediente.BtnExcluir.Visible:=false;
    FPesIngrediente.LabelInfo.Visible:=true;
    FPesIngrediente.LblUso.Visible:=false;
    FPesIngrediente.CbUso.Visible:=false;
    FPesIngrediente.mostra:=0;
    try
	    FPesIngrediente.QIngrediente.Close;
	    FPesIngrediente.QIngrediente.SQL.Text:='select * from ingrediente where (uso=0 or uso=2) order by nome';
	    FPesIngrediente.QIngrediente.Open;
	    FPesIngrediente.ShowModal;
	    if (FPesIngrediente.retorna<>'') then
	    begin
		    EdtCodIngrediente.Text:=FPesIngrediente.retorna;
		    EdtCodIngredienteExit(Sender);
		end;
		FPesIngrediente.Destroy;
    except
        on E : Exception do
	    begin
            Application.MessageBox(PChar('ERRO '+E.Message),'ERRO',0);
			Screen.Cursor:=crDefault;
            FPesIngrediente.Destroy;
			Exit;
	    end;
    end;
end;

procedure TFCadPizza.BtnAdicionarClick(Sender: TObject);
var r: integer;
begin
    if (EdtCodIngrediente.Text='') then
    begin
        Showmessage('Primeiro selecione um ingrediente.');
        Screen.Cursor:=crDefault;
        Exit;
	end;
    Screen.Cursor:=crHourGlass;
    r:=0;
    while (r<GridIngredientes.RowCount) do
    begin
        if (EdtCodIngrediente.Text=GridIngredientes.Cells[0,r]) then
        begin
            Showmessage('Ingrediente já incluso.');
            EdtCodIngrediente.Text:='';
            EdtCodIngredienteExit(Sender);
            EdtCodIngrediente.SetFocus;
            Screen.Cursor:=crDefault;
            Exit;
		end;
        r:=r+1;
	end;
	GridIngredientes.RowCount:=GridIngredientes.RowCount+1;
    if (GridIngredientes.RowCount=1) then
    begin
        GridIngredientes.ColCount:=2;
        GridIngredientes.ColWidths[0]:=100;
        GridIngredientes.ColWidths[1]:=300;
	end;
	GridIngredientes.Cells[0,GridIngredientes.RowCount-1]:=EdtCodIngrediente.Text;
    GridIngredientes.Cells[1,GridIngredientes.RowCount-1]:=EdtNomeIngrediente.Text;
    EdtCodIngrediente.Text:='';
    EdtCodIngredienteExit(Sender);
    EdtCodIngrediente.SetFocus;
    Screen.Cursor:=crDefault;
end;

procedure TFCadPizza.BtnCancelarClick(Sender: TObject);
begin
    Close;
end;

procedure TFCadPizza.BtnConfirmarClick(Sender: TObject);
var preco: string; r, cod: integer;
begin
    Screen.Cursor:=crHourGlass;
    if (Trim(EdtSabor.Text)='') or (CbTipo.ItemIndex=-1)
        or (EdtPreco.Value=0) or (GridIngredientes.RowCount=0) then
    begin
        Application.MessageBox('Preencha todos os dados!','Cadastro incompleto',0);
        Screen.Cursor:=crDefault;
        Exit;
	end;
    try
	    Q.Close;
	    preco:=StringReplace(FloattoStr(EdtPreco.Value), ',', '.', [rfReplaceAll, rfIgnoreCase]);
		if cod_pizza=-1 then
	    begin
	        Q.SQL.Text:='select cod_pizza from pizza where lower(sabor) like '+AnsiLowerCase(QuotedStr(EdtSabor.Text));
		    Q.Open;
		    if Q.RecNo>0 then
	        begin
	            Q.Close;
		        Application.MessageBox('Sabor de pizza já cadastrado!','Cadastro já existe',0);
	            EdtSabor.SetFocus;
	            Screen.Cursor:=crDefault;
	            Exit;
			end;
	        Q.Close;
	        Q.SQL.Text:='insert into pizza(sabor,tipo,preco) values ('+QuotedStr(EdtSabor.Text)+', '
	                    +IntToStr(CbTipo.ItemIndex)+', '+preco+')';
	        Q.ExecSQL;
	        Q.SQL.Text:='select cod_pizza from pizza where sabor like '+QuotedStr(EdtSabor.Text);
		    Q.Open;
	        cod:=Q.FieldByName('cod_pizza').AsInteger;
	        Q.Close;
	        r:=0;
	        for r:=0 to GridIngredientes.RowCount-1 do
	        begin
		        Q.Close;
		        Q.SQL.Text:='insert into pizza_possui_ingrediente(cod_pizza,cod_ingrediente) values '
	                        +'('+IntToStr(cod)+', '+GridIngredientes.Cells[0,r]+')';
		        Q.ExecSQL;
			end;
	        Transaction.Commit;
			Application.MessageBox('Pizza cadastrada com sucesso','Cadastro efetuado',0);
	        Close;
	    end
	    else
	    begin
	        if (AnsiLowerCase(EdtSabor.Text)<>AnsiLowerCase(sabor)) then
		    begin
	            Q.SQL.Text:='select cod_pizza from pizza where lower(sabor) like '+AnsiLowerCase(QuotedStr(EdtSabor.Text));
			    Q.Open;
			    if Q.RecNo>0 then
		        begin
		            Q.Close;
			        Application.MessageBox('Sabor de pizza já cadastrado!','Cadastro já existe',0);
		            EdtSabor.SetFocus;
		            Screen.Cursor:=crDefault;
		            Exit;
				end;
			end;
	        Q.Close;
	        Q.SQL.Text:='update pizza set sabor='+QuotedStr(EdtSabor.Text)+
	                    ', tipo='+IntToStr(CbTipo.ItemIndex)+', preco='+preco+
	                    ' where cod_pizza='+IntToStr(cod_pizza);
	        Q.ExecSQL;
	        Q.SQL.Text:='delete from pizza_possui_ingrediente where cod_pizza='+IntToStr(cod_pizza);
	        Q.ExecSQL;
	        r:=0;
	        for r:=0 to GridIngredientes.RowCount-1 do
	        begin
		        Q.Close;
		        Q.SQL.Text:='insert into pizza_possui_ingrediente(cod_pizza,cod_ingrediente) values '
	                        +'('+IntToStr(cod_pizza)+', '+GridIngredientes.Cells[0,r]+')';
		        Q.ExecSQL;
			end;
	        Transaction.Commit;
	        Application.MessageBox('Pizza alterada com sucesso','Alteração efetuada',0);
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

procedure TFCadPizza.EdtCodIngredienteExit(Sender: TObject);
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

