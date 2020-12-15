unit upesmassa;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, sqldb, db, FileUtil, Forms, Controls, Graphics, Dialogs,
	ExtCtrls, StdCtrls, Buttons, DBGrids, LCLType, ucadmassa;

type

	{ TFPesMassa }

    TFPesMassa = class(TForm)
		BtnAdicionar: TBitBtn;
		BtnAlterar: TBitBtn;
		BtnSelecionar: TBitBtn;
		BtnExcluir: TBitBtn;
		BtnPesquisar: TBitBtn;
		BtnVoltar: TBitBtn;
		DBGrid1: TDBGrid;
		DMassa: TDataSource;
		EdtCodigo: TEdit;
		EdtNome: TEdit;
		Label1: TLabel;
		Label3: TLabel;
		Label4: TLabel;
		Label5: TLabel;
		PBottom: TPanel;
		PTop: TPanel;
		Q: TSQLQuery;
		QMassa: TSQLQuery;
		QMassacod_massa: TAutoIncField;
		QMassanome: TStringField;
		QMassavalor_adicional: TFloatField;
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
        procedure AtualizaBotoes(Sender: TObject);
    private
        { private declarations }
    public
        { public declarations }
        retorna: string;
    end;

var
    FPesMassa: TFPesMassa;

implementation

{$R *.lfm}

{ TFPesMassa }

procedure TFPesMassa.AtualizaBotoes(Sender: TObject);
begin
    try
	    QMassa.Close;
	    QMassa.Open;
	    if QMassa.RecNo=0 then
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

procedure TFPesMassa.FormCreate(Sender: TObject);
begin
    AtualizaBotoes(Sender);
end;

procedure TFPesMassa.BtnPesquisarClick(Sender: TObject);
var filtro: string;
begin
    Screen.Cursor:=crHourGlass;
    filtro:='';
    if (EdtCodigo.Text<>'') then
	    filtro:=' where cod_massa='+EdtCodigo.Text;

    if (Trim(EdtNome.Text)<>'') then
    begin
        if (filtro='') then
            filtro:=' where '
        else
            filtro:=filtro+' or ';
        filtro:=filtro+' lower(nome) like '+QuotedStr(AnsiLowerCase(Trim(EdtNome.Text))+'%');
	end;

    try
	    QMassa.Close;
	    QMassa.SQL.Clear;
	    QMassa.SQL.Text:='select * from massa '+filtro+' order by nome';
	    QMassa.Open;
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

procedure TFPesMassa.BtnSelecionarClick(Sender: TObject);
begin
    if (BtnAdicionar.Visible) or (QMassa.RecNo=0) then
        Exit;
    try
	    retorna:=QMassa.FieldByName('cod_massa').AsString;
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

procedure TFPesMassa.BtnVoltarClick(Sender: TObject);
begin
    Close;
end;



procedure TFPesMassa.DBGrid1DblClick(Sender: TObject);
var stringredientes: string;
begin
    stringredientes:='';
    try
	    if QMassa.RecNo=0 then
	        Exit;
	    Screen.Cursor:=crHourGlass;
	    Q.Close;
	    Q.SQL.Text:='select * from ingrediente I inner join massa_contem_ingrediente MCI on '+
	                'MCI.cod_ingrediente=I.cod_ingrediente and '+
	                'MCI.cod_massa='+QMassa.FieldByName('cod_massa').AsString+' order by I.nome';
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
	    Application.MessageBox(PChar(stringredientes),PChar('INGREDIENTES DA MASSA '+AnsiUpperCase(QMassa.FieldByName('nome').AsString)),0);
    except
        on E : Exception do
	    begin
            Application.MessageBox(PChar('ERRO '+E.Message),'ERRO',0);
			Screen.Cursor:=crDefault;
			Exit;
	    end;
    end;
end;

procedure TFPesMassa.BtnExcluirClick(Sender: TObject);
begin
    Screen.Cursor:=crHourGlass;
    try
	    Q.Close;
	    Q.SQL.Text:='select * from pedido_tem_massa_pizza where cod_massa='+QMassa.FieldByName('cod_massa').AsString;
	    Q.Open;
	    if (Q.RecNo>0) then
	    begin
		    if (Application.MessageBox(PChar('A massa que deseja excluir ('+
	            AnsiUpperCase(QMassa.FieldByName('nome').AsString)+') consta em pedidos já realizados.'+#10+
	            ' Excluí-la irá deletar informações importantes desses pedidos.'+#10+'Deseja REALMENTE continuar?'),
	            'AVISO IMPORTANTE',MB_ICONQUESTION+MB_YESNO)=IDNO) then
	        begin
		        Screen.Cursor:=crDefault;
		        Exit;
		    end;
		end;

		if (Application.MessageBox(PChar('Deseja realmente excluir a massa '+
	        AnsiUpperCase(QMassa.FieldByName('nome').AsString)+'?'),'EXCLUIR MASSA',
			MB_ICONQUESTION+MB_YESNO)=IDYES) then
		begin
		  Q.SQL.Text:='delete from massa where cod_massa='+QMassa.FieldByName('cod_massa').AsString;
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

procedure TFPesMassa.BtnAdicionarClick(Sender: TObject);
begin
    Application.CreateForm(TFCadMassa,FCadMassa);
    with FCadMassa do
    begin
        cod_massa:=-1;
        Caption:='Nova Massa';
        LblCodigo.Visible:=false;
        EdtCodigo.Visible:=false;
        ShowModal;
        Destroy;
    end;
    AtualizaBotoes(Sender);
end;

procedure TFPesMassa.BtnAlterarClick(Sender: TObject);
begin
    Screen.Cursor:=crHourGlass;
    try
	    Application.CreateForm(TFCadMassa,FCadMassa);
	    with FCadMassa do
	    begin
			cod_massa:=QMassa.FieldByName('cod_massa').AsInteger;
	        nome:=QMassa.FieldByName('nome').AsString;
		    Caption:='Alterar Massa';
	        EdtVal.Value:=QMassa.FieldByName('valor_adicional').AsFloat;
	        EdtNome.Text:=QMassa.FieldByName('nome').AsString;
	        EdtCodigo.Text:=QMassa.FieldByName('cod_massa').AsString;
	        Q.Close;
	        Q.SQL.Text:='select MCI.cod_ingrediente, I.nome from massa_contem_ingrediente MCI '+
	                    ' left join ingrediente I on I.cod_ingrediente=MCI.cod_ingrediente where '+
	                    ' MCI.cod_massa='+IntToStr(cod_massa)+' order by I.nome';
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

procedure TFPesMassa.FormKeyPress(Sender: TObject; var Key: char);
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

