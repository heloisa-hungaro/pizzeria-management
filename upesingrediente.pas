unit upesingrediente;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, sqldb, db, FileUtil, Forms, Controls, Graphics, Dialogs,
	ExtCtrls, StdCtrls, Buttons, DBGrids, LCLType, ucadingrediente;

type

	{ TFPesIngrediente }

    TFPesIngrediente = class(TForm)
		BtnAdicionar: TBitBtn;
		BtnAlterar: TBitBtn;
		BtnExcluir: TBitBtn;
		BtnPesquisar: TBitBtn;
		BtnVoltar: TBitBtn;
		CbUso: TComboBox;
		DBGrid1: TDBGrid;
		DIngrediente: TDataSource;
		EdtCodigo: TEdit;
		EdtNome: TEdit;
		Label1: TLabel;
		LblUso: TLabel;
		Label3: TLabel;
		Label4: TLabel;
		LabelInfo: TLabel;
		PBottom: TPanel;
		PTop: TPanel;
		Q: TSQLQuery;
		QIngrediente: TSQLQuery;
		QIngredientecod_ingrediente: TAutoIncField;
		QIngredientenome: TStringField;
		QIngredienteuso: TWordField;
		QIngredienteuso_escrito1: TStringField;
		Transaction: TSQLTransaction;
		procedure BtnAdicionarClick(Sender: TObject);
		procedure BtnAlterarClick(Sender: TObject);
        procedure BtnExcluirClick(Sender: TObject);
        procedure BtnPesquisarClick(Sender: TObject);
	    procedure BtnVoltarClick(Sender: TObject);
		procedure DBGrid1DblClick(Sender: TObject);
		procedure FormCreate(Sender: TObject);
	    procedure FormKeyPress(Sender: TObject; var Key: char);
        procedure QIngredienteCalcFields(DataSet: TDataSet);
        procedure AtualizaBotoes(Sender: TObject);
    private
        { private declarations }
    public
        { public declarations }
        retorna: string;
        mostra: integer;
    end;

var
    FPesIngrediente: TFPesIngrediente;

implementation

{$R *.lfm}

{ TFPesIngrediente }

procedure TFPesIngrediente.AtualizaBotoes(Sender: TObject);
begin
    try
	    QIngrediente.Close;
	    QIngrediente.Open;
	    if QIngrediente.RecNo=0 then
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

procedure TFPesIngrediente.QIngredienteCalcFields(DataSet: TDataSet);
begin
    try
	    case QIngrediente.FieldByName('uso').AsInteger of
	        0: QIngrediente.FieldByName('uso_escrito').AsString:='PIZZA';
	        1: QIngrediente.FieldByName('uso_escrito').AsString:='MASSA';
	        2: QIngrediente.FieldByName('uso_escrito').AsString:='MASSA E PIZZA';
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

procedure TFPesIngrediente.BtnVoltarClick(Sender: TObject);
begin
    Close;
end;

procedure TFPesIngrediente.DBGrid1DblClick(Sender: TObject);
begin
    if (BtnAdicionar.Visible) or (QIngrediente.RecNo=0) then
        Exit;
    try
	    retorna:=QIngrediente.FieldByName('cod_ingrediente').AsString;
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

procedure TFPesIngrediente.FormCreate(Sender: TObject);
begin
    AtualizaBotoes(Sender);
    mostra:=-1;
end;

procedure TFPesIngrediente.FormKeyPress(Sender: TObject; var Key: char);
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


procedure TFPesIngrediente.BtnExcluirClick(Sender: TObject);
var strpizza,strmassa, straviso: string;
begin
    strpizza:='';
    strmassa:='';
    straviso:='';
    try
	    if QIngrediente.RecNo=0 then
	        Exit;
	    Screen.Cursor:=crHourGlass;
	    Q.Close;
		    Q.SQL.Text:='select * from pizza P inner join pizza_possui_ingrediente PPI on '+
	                'P.cod_pizza=PPI.cod_pizza and '+
	                'PPI.cod_ingrediente='+QIngrediente.FieldByName('cod_ingrediente').AsString+' order by P.sabor';
	    Q.Open;
	    if (Q.RecNo>0) then
	    begin
		    Q.First;
		    strpizza:=strpizza+AnsiUpperCase(Q.FieldByName('sabor').AsString);
		    Q.Next;
		    while not Q.EOF do
		    begin
		        strpizza:=strpizza+', '+AnsiUpperCase(Q.FieldByName('sabor').AsString);
		        Q.Next;
			end;
		end;
	    if (strpizza<>'') then
	        strpizza:=#10+#10+'PIZZAS: '+strpizza;

	    Q.Close;
	    Q.SQL.Text:='select * from massa M inner join massa_contem_ingrediente MCI on '+
	                'M.cod_massa=MCI.cod_massa and '+
	                'MCI.cod_ingrediente='+QIngrediente.FieldByName('cod_ingrediente').AsString+' order by M.nome';
	    Q.Open;
	    if (Q.RecNo>0) then
	    begin
		    Q.First;
		    strmassa:=strmassa+AnsiUpperCase(Q.FieldByName('nome').AsString);
		    Q.Next;
		    while not Q.EOF do
		    begin
		        strmassa:=strmassa+', '+AnsiUpperCase(Q.FieldByName('nome').AsString);
		        Q.Next;
			end;
		end;
	    if (strmassa<>'') then
	        strmassa:=#10+#10+'MASSAS: '+strmassa;
		Q.Close;
	    Q.SQL.Text:='select * from fornecedor_fornece_ingrediente where '+
	                'cod_ingrediente='+QIngrediente.FieldByName('cod_ingrediente').AsString;
	    Q.Open;

	    if (strmassa<>'') or (strpizza<>'') then
	    begin
	        straviso:='Ao deletar este ingrediente, ele será removido da composição das seguintes massas/pizzas:'+
		        strmassa+strpizza+#10+#10;
	        if (Q.RecNo>0) then
	            straviso:=straviso+'Além disso, seus fornecimentos também serão apagados.'+#10+#10;
	        straviso:=straviso+'Deseja REALMENTE continuar?';
		end
		else if (Q.RecNo>0) then
	        straviso:='Os fornecimentos deste ingrediente serão apagados.'+#10+#10+
	            'Deseja REALMENTE continuar?';
	    Q.Close;

	    if (straviso<>'') then
	    begin
		    if (Application.MessageBox(PChar(straviso),'AVISO IMPORTANTE',MB_ICONQUESTION+MB_YESNO)=IDNO) then
		    begin
	            Screen.Cursor:=crDefault;
	            Exit;
	        end;
		end;
		if (Application.MessageBox(PChar('Deseja realmente excluir o ingrediente '+
	        AnsiUpperCase(QIngrediente.FieldByName('nome').AsString)+'?'),'EXCLUIR INGREDIENTE',
			MB_ICONQUESTION+MB_YESNO)=IDYES) then
		begin
		  Q.SQL.Text:='delete from ingrediente where cod_ingrediente='+QIngrediente.FieldByName('cod_ingrediente').AsString;
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

procedure TFPesIngrediente.BtnPesquisarClick(Sender: TObject);
var filtro: string;
begin
    Screen.Cursor:=crHourGlass;
    filtro:='';
    if (EdtCodigo.Text<>'') then
	    filtro:=' where cod_ingrediente='+EdtCodigo.Text;

    if (Trim(EdtNome.Text)<>'') then
    begin
        if (filtro='') then
            filtro:=' where '
        else
            filtro:=filtro+' or ';
        filtro:=filtro+' lower(nome) like '+QuotedStr(AnsiLowerCase(Trim(EdtNome.Text))+'%');
	end;

    if (CbUso.ItemIndex<>0) then
    begin
        if (filtro='') then
            filtro:=' where '
        else
            filtro:=filtro+' or ';
        filtro:=filtro+' uso='+IntToStr(CbUso.ItemIndex-1);
	end;

    if (mostra<>-1) then
    begin
        if (filtro='') then
            filtro:=' where '
        else
            filtro:=filtro+' and ';
        filtro:=filtro+' (uso='+IntToStr(mostra)+' or uso=2) ';
	end;

    try
	    QIngrediente.Close;
	    QIngrediente.SQL.Clear;
	    QIngrediente.SQL.Text:='select * from ingrediente '+filtro+' order by nome';
	    QIngrediente.Open;
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

procedure TFPesIngrediente.BtnAdicionarClick(Sender: TObject);
begin
    Application.CreateForm(TFCadIngrediente,FCadIngrediente);
    with FCadIngrediente do
    begin
	    cod:=-1;
	    Caption:='Novo Ingrediente';
        LblCodigo.Visible:=false;
        EdtCodigo.Visible:=false;
	    ShowModal;
	    Destroy;
	end;
	AtualizaBotoes(Sender);
end;

procedure TFPesIngrediente.BtnAlterarClick(Sender: TObject);
begin
    Screen.Cursor:=crHourGlass;
    try
	    Application.CreateForm(TFCadIngrediente,FCadIngrediente);
	    with FCadIngrediente do
	    begin
			cod:=QIngrediente.FieldByName('cod_ingrediente').AsInteger;
	        nome_anterior:=QIngrediente.FieldByName('nome').AsString;
		    Caption:='Alterar Ingrediente';
	        EdtNome.Text:=QIngrediente.FieldByName('nome').AsString;
	        FCadIngrediente.CbUso.ItemIndex:=QIngrediente.FieldByName('uso').AsInteger;
	        EdtCodigo.Text:=QIngrediente.FieldByName('cod_ingrediente').AsString;
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

end.

