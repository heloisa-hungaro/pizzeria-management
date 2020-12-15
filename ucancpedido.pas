unit ucancpedido;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, sqldb, db, FileUtil, Forms, Controls, Graphics, Dialogs,
	StdCtrls, DBGrids, ExtCtrls, Buttons, MaskEdit, LCLType;

type

	{ TFCancPedido }

    TFCancPedido = class(TForm)
		BtnCancelar: TBitBtn;
		BtnPesquisar: TBitBtn;
		BtnVoltar: TBitBtn;
		EdtCliente: TEdit;
		EdtTelefone: TEdit;
		GridPedidos: TDBGrid;
		DPedido: TDataSource;
		GbPedidos: TGroupBox;
		Label2: TLabel;
		Label6: TLabel;
		PBottom: TPanel;
		PTop: TPanel;
		Q: TSQLQuery;
		QPedido: TSQLQuery;
		QPedidocancelado: TLongintField;
		QPedidocod_pedido: TLongintField;
		QPedidodata: TDateField;
		QPedidohora: TTimeField;
		QPedidonome: TStringField;
		QPedidotelefone: TStringField;
		QPedidovalor_total: TFloatField;
		Transaction: TSQLTransaction;
		procedure BtnCancelarClick(Sender: TObject);
		procedure BtnPesquisarClick(Sender: TObject);
        procedure BtnVoltarClick(Sender: TObject);
		procedure FormCreate(Sender: TObject);
	    procedure FormKeyPress(Sender: TObject; var Key: char);
	    procedure GridPedidosDblClick(Sender: TObject);
        procedure AtualizaBotoes(Sender: TObject);
    private
        { private declarations }
    public
        { public declarations }
    end;

var
    FCancPedido: TFCancPedido;

implementation

{$R *.lfm}

{ TFCancPedido }

procedure TFCancPedido.AtualizaBotoes(Sender: TObject);
begin
    try
	    QPedido.Close;
	    QPedido.Open;
	    if QPedido.RecNo=0 then
	    begin
	        BtnCancelar.Enabled:=false;
		end
	    else
	    begin
	        BtnCancelar.Enabled:=true;
		end;
    except
        on E : Exception do
	    begin
            Application.MessageBox(PChar('ERRO '+E.Message),'ERRO',0);
			Exit;
	    end;
    end;
end;

procedure TFCancPedido.FormKeyPress(Sender: TObject; var Key: char);
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

procedure TFCancPedido.GridPedidosDblClick(Sender: TObject);
begin
    BtnCancelarClick(Sender);
end;

procedure TFCancPedido.BtnVoltarClick(Sender: TObject);
begin
    Close;
end;

procedure TFCancPedido.FormCreate(Sender: TObject);
begin
    GbPedidos.Caption:='PEDIDOS DE HOJE - DIA '+FormatDateTime('dd/mm/yyyy',Now);
end;

procedure TFCancPedido.BtnCancelarClick(Sender: TObject);
begin
   Screen.Cursor:=crHourGlass;
    try
		if (Application.MessageBox(PChar('Deseja realmente CANCELAR o pedido de '+
	        AnsiUpperCase(QPedido.FieldByName('nome').AsString)+', telefone '+
	        QPedido.FieldByName('telefone').AsString+' feito às  '+
	        FormatDateTime('t',QPedido.FieldByName('hora').AsDateTime)+'?'),'CANCELAR PEDIDO',
			MB_ICONQUESTION+MB_YESNO)=IDYES) then
		begin
		  Q.SQL.Text:='update pedido set cancelado=1 where '+
	                    ' cod_pedido='+QPedido.FieldByName('cod_pedido').AsString;
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

procedure TFCancPedido.BtnPesquisarClick(Sender: TObject);
var filtro: string;
begin
    Screen.Cursor:=crHourGlass;
    filtro:='';

    if (Trim(EdtCliente.Text)<>'') then
        filtro:=' and lower(C.nome) like '+QuotedStr(AnsiLowerCase(Trim(EdtCliente.Text))+'%');

    if (EdtTelefone.Text<>'') then
        filtro:=filtro+' and C.telefone='+EdtTelefone.Text;

    try
	    QPedido.Close;
	    QPedido.SQL.Clear;
	    QPedido.SQL.Text:='select P.cod_pedido, P.data, P.hora, P.valor_total, P.cancelado, C.nome, C.telefone'+
	                        ' from pedido P left join cliente C on C.cod_cliente=P.cod_cliente'+
	                        ' where P.cancelado=0 and P.data='+QuotedStr(FormatDateTime('yyyy-mm-dd',Now))+
	                        filtro+' order by P.data desc, P.hora desc, C.nome';
	    QPedido.Open;
    except
        on E : Exception do
	    begin
            Application.MessageBox(PChar('ERRO '+E.Message),'ERRO',0);
			Screen.Cursor:=crDefault;
			Exit;
	    end;
    end;
	EdtTelefone.SetFocus;
    AtualizaBotoes(Sender);
    Screen.Cursor:=crDefault;
end;

end.

