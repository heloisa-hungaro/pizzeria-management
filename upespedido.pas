unit upespedido;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, sqldb, db, FileUtil, Forms, Controls, Graphics, Dialogs,
	ExtCtrls, Buttons, DBGrids, StdCtrls, MaskEdit, Spin, ucadpedido, LCLType;

type

	{ TFPesPedido }

    TFPesPedido = class(TForm)
		BtnAdicionar: TBitBtn;
		BtnAlterar: TBitBtn;
		BtnCancelar: TBitBtn;
		BtnExcluir: TBitBtn;
		BtnPesquisar: TBitBtn;
		BtnVoltar: TBitBtn;
		CmbEntrega: TComboBox;
		DBGrid1: TDBGrid;
		DPedido: TDataSource;
		EdtCodigo: TEdit;
		CmbFormaPagto: TComboBox;
		EdtTelefone: TEdit;
		EdtData: TMaskEdit;
		EdtCliente: TEdit;
		EdtValor: TFloatSpinEdit;
		Label2: TLabel;
		Label3: TLabel;
		Label4: TLabel;
		Label5: TLabel;
		Label6: TLabel;
		Label7: TLabel;
		Label8: TLabel;
		PBottom: TPanel;
		PTop: TPanel;
		Q: TSQLQuery;
		QPedido: TSQLQuery;
		QPedidocanc: TStringField;
		QPedidocancelado: TLongintField;
		QPedidocod_cliente: TLongintField;
		QPedidocod_entregador: TLongintField;
		QPedidocod_pedido: TLongintField;
		QPedidocod_pedido_1: TLongintField;
		QPedidodata: TDateField;
		QPedidoentregue: TStringField;
		QPedidoforma_pagamento: TLongintField;
		QPedidohora: TTimeField;
		QPedidonome: TStringField;
		QPedidopagto: TStringField;
		QPedidotelefone: TStringField;
		QPedidotroco_para: TBCDField;
		QPedidovalor_entrega: TFloatField;
		QPedidovalor_total: TFloatField;
		RdoTipo: TRadioGroup;
		Transaction: TSQLTransaction;
		procedure BtnAdicionarClick(Sender: TObject);
		procedure BtnAlterarClick(Sender: TObject);
  procedure BtnCancelarClick(Sender: TObject);
  procedure BtnExcluirClick(Sender: TObject);
  procedure BtnPesquisarClick(Sender: TObject);
  procedure BtnVoltarClick(Sender: TObject);
  procedure FormCreate(Sender: TObject);
  procedure FormKeyPress(Sender: TObject; var Key: char);
        procedure AtualizaBotoes(Sender: TObject);
    private
        { private declarations }
    public
        { public declarations }
    end;

var
    FPesPedido: TFPesPedido;

implementation

{$R *.lfm}

{ TFPesPedido }

procedure TFPesPedido.AtualizaBotoes(Sender: TObject);
begin
    try
	    QPedido.Close;
	    QPedido.Open;
	    if QPedido.RecNo=0 then
	    begin
	        BtnAlterar.Enabled:=false;
	        BtnCancelar.Enabled:=false;
	        BtnExcluir.Enabled:=false;
		end
	    else
	    begin
	        BtnAlterar.Enabled:=true;
	        BtnCancelar.Enabled:=true;
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

procedure TFPesPedido.FormKeyPress(Sender: TObject; var Key: char);
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

procedure TFPesPedido.FormCreate(Sender: TObject);
begin
    AtualizaBotoes(Sender);
end;

procedure TFPesPedido.BtnVoltarClick(Sender: TObject);
begin
    Close;
end;

procedure TFPesPedido.BtnPesquisarClick(Sender: TObject);
var filtro: string;
begin
    Screen.Cursor:=crHourGlass;
    filtro:='';

    if (EdtCodigo.Text<>'') then
        filtro:=' where P.cod_pedido='+EdtCodigo.Text;

    if (EdtData.Text<>'  /  /    ') then
    begin
        if (filtro='') then
            filtro:=' where '
        else
            filtro:=filtro+' and ';
        filtro:=filtro+' P.data='+QuotedStr(FormatDateTime('yyyy-mm-dd',StrToDate(EdtData.Text)));
    end;

    if (Trim(EdtCliente.Text)<>'') then
    begin
        if (filtro='') then
            filtro:=' where '
        else
            filtro:=filtro+' and ';
        filtro:=filtro+' lower(C.nome) like '+QuotedStr(AnsiLowerCase(Trim(EdtCliente.Text))+'%');
	end;

    if (EdtTelefone.Text<>'') then
    begin
        if (filtro='') then
            filtro:=' where '
        else
            filtro:=filtro+' and ';
        filtro:=filtro+' C.telefone='+EdtTelefone.Text;
	end;

    if (CmbEntrega.ItemIndex<>0) then
    begin
        if (filtro='') then
            filtro:=' where '
        else
            filtro:=filtro+' and ';
        if (CmbEntrega.ItemIndex=1) then
            filtro:=filtro+' EEP.valor_entrega IS NULL '
        else
            filtro:=filtro+' EEP.valor_entrega IS NOT NULL ';
	end;

    if (CmbFormaPagto.ItemIndex<>0) then
    begin
        if (filtro='') then
            filtro:=' where '
        else
            filtro:=filtro+' and ';
        filtro:=filtro+' forma_pagamento='+IntToStr(CmbFormaPagto.ItemIndex-1);
	end;

    if (RdoTipo.ItemIndex<>0) then
    begin
        if (filtro='') then
            filtro:=' where '
        else
            filtro:=filtro+' and ';
        filtro:=filtro+' cancelado='+IntToStr(RdoTipo.ItemIndex-1);
	end;

    try
	    if (EdtValor.Value<>0) then
	    begin
	        if (filtro='') then
	            filtro:=' where '
	        else
	            filtro:=filtro+' and ';
	        filtro:=filtro+' valor_total='+StringReplace(FloatToStr(EdtValor.Value), ',', '.', [rfReplaceAll, rfIgnoreCase]);
		end;

	    QPedido.Close;
	    QPedido.SQL.Clear;
	    QPedido.SQL.Text:='select P.*, EEP.*, case forma_pagamento when 0 then '+QuotedStr('DINHEIRO')+
	                                ' when 1 then '+QuotedStr('DÉBITO')+' when 2 then '+QuotedStr('CRÉDITO')+
	                                ' end as pagto, case cancelado when 0 then '+QuotedStr('NÃO')+
	                                ' when 1 then '+QuotedStr('SIM')+' end as canc, C.nome, C.telefone,'+
									' case when  EEP.valor_entrega IS NULL then '+QuotedStr('NÃO')+
	                                ' else '+QuotedStr('SIM')+' end as entregue from pedido P'+
									' left join cliente C on C.cod_cliente=P.cod_cliente'+
									' left join entregador_entrega_pedido EEP on'+
									' EEP.cod_pedido=P.cod_pedido '+filtro+
									' order by P.data desc, P.hora desc, C.nome';
	    QPedido.Open;
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

procedure TFPesPedido.BtnExcluirClick(Sender: TObject);
begin
    Screen.Cursor:=crHourGlass;
    try
		if (Application.MessageBox(PChar('Deseja realmente EXCLUIR o pedido de '+
	        AnsiUpperCase(QPedido.FieldByName('nome').AsString)+', telefone '+
	        QPedido.FieldByName('telefone').AsString+', do dia '+
	        QPedido.FieldByName('data').AsString+' feito às  '+
	        FormatDateTime('t',QPedido.FieldByName('hora').AsDateTime)+'?'),'EXCLUIR PEDIDO',
			MB_ICONQUESTION+MB_YESNO)=IDYES) then
		begin
		  Q.SQL.Text:='delete from pedido where '+
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

procedure TFPesPedido.BtnCancelarClick(Sender: TObject);
begin
    Screen.Cursor:=crHourGlass;
    try
	    if (QPedido.FieldByName('cancelado').AsInteger=1) then
	    begin
	        ShowMessage('O pedido já está cancelado!');
	        Screen.Cursor:=crDefault;
	        Exit;
		end;
		if (QPedido.FieldByName('data').AsDateTime<>Date) then
	    begin
		    if (Application.MessageBox(PChar('O pedido que deseja CANCELAR não é de hoje ('+
		                FormatDateTime('dd/mm/yyyy',Now)+'). É de '+
	                    FormatDateTime('dd/mm/yyyy',QPedido.FieldByName('data').AsDateTime)+'.'+
		                #10+'Deseja REALMENTE continuar?'),'AVISO IMPORTANTE',MB_ICONQUESTION+MB_YESNO)=IDNO) then
			begin
		        Screen.Cursor:=crDefault;
		        Exit;
		    end;
	    end;
		if (Application.MessageBox(PChar('Deseja realmente CANCELAR o pedido de '+
	        AnsiUpperCase(QPedido.FieldByName('nome').AsString)+', telefone '+
	        QPedido.FieldByName('telefone').AsString+', do dia '+
	        QPedido.FieldByName('data').AsString+' feito às  '+
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

procedure TFPesPedido.BtnAdicionarClick(Sender: TObject);
begin
    Application.CreateForm(TFCadPedido,FCadPedido);
    with FCadPedido do
    begin
	    cod_pedido:=-1;
        telefone:='';
	    Caption:='Novo Pedido';
        LblCodigo.Visible:=false;
        EdtCodigo.Visible:=false;
	    ShowModal;
	    Destroy;
	end;
	AtualizaBotoes(Sender);
end;

procedure TFPesPedido.BtnAlterarClick(Sender: TObject);
begin
    Screen.Cursor:=crHourGlass;
    try
	    if (QPedido.FieldByName('data').AsDateTime<>Date) and (QPedido.FieldByName('cancelado').AsInteger=0) then
	    begin
		    if (Application.MessageBox(PChar('O pedido que deseja ALTERAR não é de hoje ('+
		                FormatDateTime('dd/mm/yyyy',Now)+'). É de '+
	                    FormatDateTime('dd/mm/yyyy',QPedido.FieldByName('data').AsDateTime)+'.'+
		                #10+'Deseja REALMENTE continuar?'),'AVISO IMPORTANTE',MB_ICONQUESTION+MB_YESNO)=IDNO) then
			begin
		        Screen.Cursor:=crDefault;
		        Exit;
		    end;
	    end;
	    Application.CreateForm(TFCadPedido,FCadPedido);
	    with FCadPedido do
	    begin
			cod_pedido:=QPedido.FieldByName('cod_pedido').AsInteger;
		    Caption:='Alterar Pedido';
	        Q.Close;
		    Q.SQL.Text:='select telefone, cod_cliente from cliente where cod_cliente='+QPedido.FieldByName('cod_cliente').AsString;
		    Q.Open;
	        EdtTelCliente.Text:=Q.FieldByName('telefone').AsString;
	        Q.Close;
	        EdtData.Text:=FormatDateTime('dd/mm/yyyy',QPedido.FieldByName('data').AsDateTime);
	        EdtHora.Text:=QPedido.FieldByName('hora').AsString;
	        EdtCodigo.Text:=QPedido.FieldByName('cod_pedido').AsString;
	        if (QPedido.FieldByName('entregue').AsString='NÃO') then
	        begin
	            CmbEntrega.ItemIndex:=0;
			end
	        else
	        begin
	            CmbEntrega.ItemIndex:=1;
	            EdtCodEntregador.Text:=QPedido.FieldByName('cod_entregador').AsString;
	            EdtValorEntrega.Value:=QPedido.FieldByName('valor_entrega').AsFloat;
			end;
	        EdtValorTotal.Text:=StringReplace(FormatFloat('#0.00',
	                            QPedido.FieldByName('valor_total').AsFloat), '.', ',', [rfReplaceAll, rfIgnoreCase]);
	        CmbFormaPagto.ItemIndex:=QPedido.FieldByName('forma_pagamento').AsInteger;
	        if (QPedido.FieldByName('troco_para').AsString<>'') then
	            EdtTrocoPara.Value:=StrToFloat(StringReplace(QPedido.FieldByName('troco_para').AsString, '.', ',', [rfReplaceAll, rfIgnoreCase]));
	        Q.Close;
	        Q.SQL.Text:='select PTMP.*, P.sabor, M.nome from pedido_tem_massa_pizza PTMP '+
	                    ' left join massa M on M.cod_massa=PTMP.cod_massa '+
	                    ' left join pizza P on P.cod_pizza=PTMP.cod_pizza where '+
	                    ' PTMP.cod_pedido='+IntToStr(cod_pedido)+' order by P.sabor, M.nome';
	        Q.Open;
	        Q.First;
	        while not Q.EOF do
		    begin
		        GridPizzas.RowCount:=GridPizzas.RowCount+1;
				GridPizzas.Cells[0,GridPizzas.RowCount-1]:=Q.FieldByName('quantidade').AsString;
			    GridPizzas.Cells[1,GridPizzas.RowCount-1]:=Q.FieldByName('cod_massa').AsString;
				GridPizzas.Cells[2,GridPizzas.RowCount-1]:=Q.FieldByName('nome').AsString;
			    GridPizzas.Cells[3,GridPizzas.RowCount-1]:=Q.FieldByName('cod_pizza').AsString;
				GridPizzas.Cells[4,GridPizzas.RowCount-1]:=Q.FieldByName('sabor').AsString;
			    GridPizzas.Cells[5,GridPizzas.RowCount-1]:=StringReplace(FormatFloat('#0.00',
	                                        Q.FieldByName('valor').AsFloat), '.', ',', [rfReplaceAll, rfIgnoreCase]);
			    GridPizzas.Cells[6,GridPizzas.RowCount-1]:=Q.FieldByName('observacoes').AsString;
	            Q.Next;
			end;
			Q.Close;
	        if (QPedido.FieldByName('cancelado').AsInteger=1) then
	        begin
	            ShowMessage('Não é possível alterar pedidos cancelados, apenas visualizar.');
	            GbCliente.Enabled:=false;
	            GbData.Enabled:=false;
	            GbPagamento.Enabled:=false;
	            GbEntrega.Enabled:=false;
	            GbPizzas.Enabled:=false;
	            BtnConfirmar.Enabled:=false;
			end;
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

