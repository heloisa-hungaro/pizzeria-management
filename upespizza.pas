unit upespizza;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, sqldb, db, FileUtil, Forms, Controls, Graphics, Dialogs,
	ExtCtrls, StdCtrls, Buttons, DBGrids, LCLType, ucadpizza;

type

	{ TFPesPizza }

    TFPesPizza = class(TForm)
		BtnAdicionar: TBitBtn;
		BtnAlterar: TBitBtn;
		BtnExcluir: TBitBtn;
		BtnPesquisar: TBitBtn;
		BtnSelecionar: TBitBtn;
		BtnVoltar: TBitBtn;
		CbTipo: TComboBox;
		DBGrid1: TDBGrid;
		DPizza: TDataSource;
		EdtCodigo: TEdit;
		EdtSabor: TEdit;
		Label1: TLabel;
		Label2: TLabel;
		Label3: TLabel;
		Label4: TLabel;
		Label5: TLabel;
		PBottom: TPanel;
		PTop: TPanel;
		Q: TSQLQuery;
		QPizza: TSQLQuery;
		QPizzacod_pizza: TAutoIncField;
		QPizzapreco: TFloatField;
		QPizzasabor: TStringField;
		QPizzatipo: TLargeintField;
		QPizzatipo_escrito1: TStringField;
		Transaction: TSQLTransaction;
		procedure BtnAdicionarClick(Sender: TObject);
		procedure BtnAlterarClick(Sender: TObject);
  procedure BtnExcluirClick(Sender: TObject);
  procedure BtnPesquisarClick(Sender: TObject);
  procedure BtnSelecionarClick(Sender: TObject);
        procedure BtnVoltarClick(Sender: TObject);
		procedure DBGrid1DblClick(Sender: TObject);
		procedure FormCreate(Sender: TObject);
        procedure FormKeyPress(Sender: TObject; var Key: char);
		procedure QPizzaCalcFields(DataSet: TDataSet);
        procedure AtualizaBotoes(Sender: TObject);
    private
        { private declarations }
    public
        { public declarations }
        retorna: string;
    end;

var
    FPesPizza: TFPesPizza;

implementation

{$R *.lfm}

{ TFPesPizza }

procedure TFPesPizza.AtualizaBotoes(Sender: TObject);
begin
    try
	    QPizza.Close;
	    QPizza.Open;
	    if QPizza.RecNo=0 then
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

procedure TFPesPizza.FormKeyPress(Sender: TObject; var Key: char);
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

procedure TFPesPizza.BtnVoltarClick(Sender: TObject);
begin
    Close;
end;

procedure TFPesPizza.DBGrid1DblClick(Sender: TObject);
var stringredientes: string;
begin
    stringredientes:='';
    try
	    if QPizza.RecNo=0 then
	        Exit;
	    Screen.Cursor:=crHourGlass;
	    Q.Close;
	    Q.SQL.Text:='select * from ingrediente I inner join pizza_possui_ingrediente PPI on '+
	                'PPI.cod_ingrediente=I.cod_ingrediente and '+
	                'PPI.cod_pizza='+QPizza.FieldByName('cod_pizza').AsString+' order by I.nome';
	    Q.Open;
	    Q.First;
	    stringredientes:=stringredientes+AnsiUpperCase(Q.FieldByName('nome').AsString);
	    Q.Next;
	    while not Q.EOF do
	    begin
	        stringredientes:=stringredientes+', '+AnsiUpperCase(Q.FieldByName('nome').AsString);
	        Q.Next;
		end;
	    Q.Close;
	    Screen.Cursor:=crDefault;
	    Application.MessageBox(PChar(stringredientes),PChar('INGREDIENTES DA PIZZA '+AnsiUpperCase(QPizza.FieldByName('sabor').AsString)),0);
    except
        on E : Exception do
	    begin
            Application.MessageBox(PChar('ERRO '+E.Message),'ERRO',0);
			Screen.Cursor:=crDefault;
			Exit;
	    end;
    end;
end;

procedure TFPesPizza.FormCreate(Sender: TObject);
begin
    AtualizaBotoes(Sender);
end;

procedure TFPesPizza.BtnPesquisarClick(Sender: TObject);
var filtro: string;
begin
    Screen.Cursor:=crHourGlass;
    filtro:='';
    if (EdtCodigo.Text<>'') then
	    filtro:=' where cod_pizza='+EdtCodigo.Text;

    if (Trim(EdtSabor.Text)<>'') then
    begin
        if (filtro='') then
            filtro:=' where '
        else
            filtro:=filtro+' or ';
        filtro:=filtro+' lower(sabor) like '+QuotedStr(AnsiLowerCase(Trim(EdtSabor.Text))+'%');
	end;

    if (CbTipo.ItemIndex<>0) then
    begin
        if (filtro='') then
            filtro:=' where '
        else
            filtro:=filtro+' or ';
        filtro:=filtro+' tipo='+IntToStr(CbTipo.ItemIndex-1);
	end;

    try
	    QPizza.Close;
	    QPizza.SQL.Clear;
	    QPizza.SQL.Text:='select * from pizza '+filtro+' order by tipo, sabor';
	    QPizza.Open;
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

procedure TFPesPizza.BtnSelecionarClick(Sender: TObject);
begin
    if (BtnAdicionar.Visible) or (QPizza.RecNo=0) then
        Exit;
    try
	    retorna:=QPizza.FieldByName('cod_pizza').AsString;
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

procedure TFPesPizza.BtnExcluirClick(Sender: TObject);
begin
    Screen.Cursor:=crHourGlass;
    try
	    Q.Close;
	    Q.SQL.Text:='select * from pedido_tem_massa_pizza where cod_pizza='+QPizza.FieldByName('cod_pizza').AsString;
	    Q.Open;
	    if (Q.RecNo>0) then
	    begin
		    if (Application.MessageBox(PChar('A pizza que deseja excluir ('+
	            AnsiUpperCase(QPizza.FieldByName('sabor').AsString)+') consta em pedidos já realizados.'+#10+
	            ' Excluí-la irá deletar informações importantes desses pedidos.'+#10+'Deseja REALMENTE continuar?'),
	            'AVISO IMPORTANTE',MB_ICONQUESTION+MB_YESNO)=IDNO) then
		    begin
		        Screen.Cursor:=crDefault;
		        Exit;
		    end;
		end;

		if (Application.MessageBox(PChar('Deseja realmente excluir a pizza '+
	        AnsiUpperCase(QPizza.FieldByName('sabor').AsString)+'?'),'EXCLUIR PIZZA',
			MB_ICONQUESTION+MB_YESNO)=IDYES) then
		begin
		  Q.SQL.Text:='delete from pizza where cod_pizza='+QPizza.FieldByName('cod_pizza').AsString;
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

procedure TFPesPizza.BtnAdicionarClick(Sender: TObject);
begin
    Application.CreateForm(TFCadPizza,FCadPizza);
    with FCadPizza do
    begin
        cod_pizza:=-1;
        Caption:='Nova Pizza';
        LblCodigo.Visible:=false;
        EdtCodigo.Visible:=false;
        ShowModal;
        Destroy;
    end;
    AtualizaBotoes(Sender);
end;

procedure TFPesPizza.BtnAlterarClick(Sender: TObject);
begin
    Screen.Cursor:=crHourGlass;
    try
	    Application.CreateForm(TFCadPizza,FCadPizza);
	    with FCadPizza do
	    begin
			cod_pizza:=QPizza.FieldByName('cod_pizza').AsInteger;
	        sabor:=QPizza.FieldByName('sabor').AsString;
		    Caption:='Alterar Pizza';
	        EdtPreco.Value:=QPizza.FieldByName('preco').AsFloat;
	        EdtSabor.Text:=QPizza.FieldByName('sabor').AsString;
	        CbTipo.ItemIndex:=QPizza.FieldByName('tipo').AsInteger;
	        EdtCodigo.Text:=QPizza.FieldByName('cod_pizza').AsString;
	        Q.Close;
	        Q.SQL.Text:='select PPI.cod_ingrediente, I.nome from pizza_possui_ingrediente PPI '+
	                    ' left join ingrediente I on I.cod_ingrediente=PPI.cod_ingrediente where '+
	                    ' PPI.cod_pizza='+IntToStr(cod_pizza)+' order by I.nome';
	        Q.Open;
	        Q.First;
	        while not Q.EOF do
		    begin
		        GridIngredientes.RowCount:=GridIngredientes.RowCount+1;
			    if (GridIngredientes.RowCount=1) then
			    begin
			        GridIngredientes.ColCount:=2;
			        GridIngredientes.ColWidths[0]:=100;
			        GridIngredientes.ColWidths[1]:=300;
				end;
				GridIngredientes.Cells[0,GridIngredientes.RowCount-1]:=Q.FieldByName('cod_ingrediente').AsString;
			    GridIngredientes.Cells[1,GridIngredientes.RowCount-1]:=Q.FieldByName('nome').AsString;
	            Q.Next;
			end;
			Q.Close;

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

procedure TFPesPizza.QPizzaCalcFields(DataSet: TDataSet);
begin
    try
	    if QPizza.FieldByName('tipo').AsInteger=0 then
	        QPizza.FieldByName('tipo_escrito').AsString:='SALGADA'
	    else
	        QPizza.FieldByName('tipo_escrito').AsString:='DOCE';
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

