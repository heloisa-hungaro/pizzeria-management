unit ucadpedido;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, sqldb, FileUtil, Forms, Controls, Graphics, Dialogs,
	ExtCtrls, Buttons, StdCtrls, Grids, Spin, upescliente, upesentregador, ucadcliente,
    upespizza, upesmassa, LCLType, MaskEdit;

type

	{ TFCadPedido }

    TFCadPedido = class(TForm)
		BtnAdicionar: TBitBtn;
		BtnAlterar: TBitBtn;
		BtnCancelar: TBitBtn;
		BtnConfirmar: TBitBtn;
		BtnPesqCliente: TBitBtn;
		BtnPesqEntregador: TBitBtn;
		BtnPesqMassa: TBitBtn;
		BtnPesqPizza: TBitBtn;
		CmbEntrega: TComboBox;
		CmbFormaPagto: TComboBox;
		EdtCodMassa: TEdit;
		EdtCodPizza: TEdit;
		EdtNomeMassa: TEdit;
		EdtNomePizza: TEdit;
		EdtObs: TEdit;
		EdtQtde: TSpinEdit;
		EdtTelCliente: TMaskEdit;
		EdtValMassa: TEdit;
		EdtCodCliente: TEdit;
		EdtCodEntregador: TEdit;
		EdtData: TEdit;
		EdtValPizza: TEdit;
		EdtValorTotal: TEdit;
		EdtTroco: TEdit;
		EdtHora: TEdit;
		EdtCodigo: TEdit;
		EdtNomeEntregador: TEdit;
		EdtEndereco: TEdit;
		EdtNomeCliente: TEdit;
		EdtValorEntrega: TFloatSpinEdit;
		EdtTrocoPara: TFloatSpinEdit;
		GridPizzas: TStringGrid;
		GbCliente: TGroupBox;
		GbData: TGroupBox;
		GbEntrega: TGroupBox;
		GbPagamento: TGroupBox;
		GbPizzas: TGroupBox;
		Label10: TLabel;
		Label5: TLabel;
		LblCodigo2: TLabel;
		LblCodigo3: TLabel;
		LblCodigo4: TLabel;
		LblTroco: TLabel;
		LblCodigo: TLabel;
		Label2: TLabel;
		Label3: TLabel;
		Label4: TLabel;
		Label6: TLabel;
		Label7: TLabel;
		Label8: TLabel;
		Label9: TLabel;
		LblEntregador: TLabel;
		LblEndereco: TLabel;
		LblValorEntrega: TLabel;
		LblTrocoPara: TLabel;
		PBottom: TPanel;
		Q: TSQLQuery;
		Transaction: TSQLTransaction;
		procedure BtnAdicionarClick(Sender: TObject);
        procedure BtnAlterarClick(Sender: TObject);
        procedure BtnCancelarClick(Sender: TObject);
		procedure BtnConfirmarClick(Sender: TObject);
		procedure BtnPesqClienteClick(Sender: TObject);
		procedure BtnPesqEntregadorClick(Sender: TObject);
		procedure BtnPesqMassaClick(Sender: TObject);
		procedure BtnPesqPizzaClick(Sender: TObject);
		procedure CmbEntregaChange(Sender: TObject);
		procedure CmbFormaPagtoChange(Sender: TObject);
		procedure EdtCodEntregadorExit(Sender: TObject);
		procedure EdtCodMassaExit(Sender: TObject);
		procedure EdtCodPizzaExit(Sender: TObject);
		procedure EdtTelClienteExit(Sender: TObject);
		procedure EdtTrocoParaEditingDone(Sender: TObject);
		procedure EdtValorEntregaEditingDone(Sender: TObject);
		procedure EdtValorTotalChange(Sender: TObject);
		procedure FormCreate(Sender: TObject);
        procedure FormKeyPress(Sender: TObject; var Key: char);
        procedure FormShow(Sender: TObject);
        procedure AtualizaTotal(Sender: TObject);
		procedure GridPizzasDblClick(Sender: TObject);
    private
        { private declarations }
    public
        { public declarations }
        cod_pedido: integer;
        telefone: string;
    end;

var
    FCadPedido: TFCadPedido;

implementation

{$R *.lfm}


{ TFCadPedido }

procedure TFCadPedido.AtualizaTotal(Sender: TObject);
var tot: double; r: integer;
begin
    Screen.Cursor:=crHourGlass;
    try
	    tot:=0;
	    if (CmbEntrega.ItemIndex=1) then
	        tot:=EdtValorEntrega.Value;
	    if (GridPizzas.RowCount>1) then
	    begin
	        for r:=1 to GridPizzas.RowCount-1 do
	        begin
	            tot:=tot+StrToFloat(GridPizzas.Cells[5,r]);
			end;
		end;
	    EdtValorTotal.Text:=FormatFloat('#0.00',tot);
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

procedure TFCadPedido.GridPizzasDblClick(Sender: TObject);
var r: integer;
begin
    if (GridPizzas.Row=0) then Exit;
    Screen.Cursor:=crHourGlass;
    for r:=GridPizzas.Row to GridPizzas.RowCount-2 do
        GridPizzas.Rows[r].Assign(GridPizzas.Rows[r+1]);
        GridPizzas.RowCount:=GridPizzas.RowCount-1;
    AtualizaTotal(Sender);
    Screen.Cursor:=crDefault;
end;

procedure TFCadPedido.FormKeyPress(Sender: TObject; var Key: char);
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

procedure TFCadPedido.FormShow(Sender: TObject);
begin
    CmbEntregaChange(Sender);
    CmbFormaPagtoChange(Sender);
    if (cod_pedido=-1) then
    begin
	    EdtData.Text:=DateToStr(Date);
	    EdtHora.Text:=TimeToStr(Time);
        if (telefone<>'') then
        begin
            EdtTelCliente.Text:=telefone;
            EdtTelClienteExit(Sender);
            CmbEntrega.SetFocus;
		end;
	end
    else
    begin
        if (CmbEntrega.ItemIndex=1) then
            EdtCodEntregadorExit(Sender);
        EdtTelClienteExit(Sender);
        EdtTrocoParaEditingDone(Sender);
	end;
end;

procedure TFCadPedido.BtnCancelarClick(Sender: TObject);
begin
    Close;
end;

procedure TFCadPedido.BtnConfirmarClick(Sender: TObject);
var total, entrega, preco, trocopara: string; r, cod: integer;
begin
    if (EdtTelCliente.Text='') then
    begin
        Application.MessageBox('Preencha os dados do cliente!','Pedido incompleto',0);
        EdtTelCliente.SetFocus;
        Exit;
	end;
    if (CmbEntrega.ItemIndex=-1) then
    begin
        Application.MessageBox('Preencha se é para entrega ou não!','Pedido incompleto',0);
        CmbEntrega.SetFocus;
        Exit;
	end;
	if (CmbEntrega.ItemIndex=1) and (EdtCodEntregador.Text='') then
    begin
        Application.MessageBox('Preencha os dados do entregador!','Pedido incompleto',0);
        EdtCodEntregador.SetFocus;
        Exit;
	end;
    if (GridPizzas.RowCount=1) then
    begin
        Application.MessageBox('Não há nenhuma pizza no pedido!','Pedido incompleto',0);
        EdtCodMassa.SetFocus;
        Exit;
	end;
    if (CmbFormaPagto.ItemIndex=-1) then
    begin
        Application.MessageBox('Preencha a forma de pagamento!','Pedido incompleto',0);
        CmbFormaPagto.SetFocus;
        Exit;
	end;
    if (CmbEntrega.ItemIndex=1) and (EdtValorEntrega.Value=0) then
    begin
        if (Application.MessageBox('Confirma que a entrega é GRÁTIS?','ENTREGA GRÁTIS?',MB_ICONQUESTION+MB_YESNO)=IDNO) then
		begin
            EdtValorEntrega.SetFocus;
	        Exit;
	    end;
    end;
    if (CmbFormaPagto.ItemIndex=0) and (EdtTrocoPara.Value=0) then
    begin
	    if (Application.MessageBox('Confirma que não precisa de troco?','NÃO PRECISA DE TROCO?',MB_ICONQUESTION+MB_YESNO)=IDNO) then
		begin
            EdtTrocoPara.SetFocus;
	        Exit;
	    end;
    end;
    Screen.Cursor:=crHourGlass;
    try
	    total:=StringReplace(EdtValorTotal.Text, ',', '.', [rfReplaceAll, rfIgnoreCase]);
	    entrega:=StringReplace(FloattoStr(EdtValorEntrega.Value), ',', '.', [rfReplaceAll, rfIgnoreCase]);
	    trocopara:=StringReplace(FloattoStr(EdtTrocoPara.Value), ',', '.', [rfReplaceAll, rfIgnoreCase]);
	    if cod_pedido=-1 then
	    begin
	        Q.Close;
	        Q.SQL.Text:='insert into pedido(data,hora,valor_total,forma_pagamento,cancelado,cod_cliente,troco_para) values ('+
	                    QuotedStr(FormatDateTime('yyyy-mm-dd',StrToDate(EdtData.Text)))+', '+
	                    QuotedStr(EdtHora.Text)+', '+total+', '+IntToStr(CmbFormaPagto.ItemIndex)+', 0, '+
	                    EdtCodCliente.Text+', '+trocopara+')';
	        Q.ExecSQL;
	        Q.SQL.Text:='select cod_pedido from pedido where data='+QuotedStr(FormatDateTime('yyyy-mm-dd',StrToDate(EdtData.Text)))+
	                    ' and hora='+QuotedStr(EdtHora.Text);
		    Q.Open;
	        cod:=Q.FieldByName('cod_pedido').AsInteger;
	        Q.Close;
	        if (CmbEntrega.ItemIndex=1) then
	        begin
	            Q.SQL.Text:='insert into entregador_entrega_pedido(cod_pedido,cod_entregador,valor_entrega) values '
	                        +'('+IntToStr(cod)+', '+EdtCodEntregador.Text+', '+entrega+')';
	            Q.ExecSQL;
	        end;
	        r:=0;
	        for r:=1 to GridPizzas.RowCount-1 do
	        begin
	            preco:=StringReplace(GridPizzas.Cells[5,r], ',', '.', [rfReplaceAll, rfIgnoreCase]);
		        Q.Close;
		        Q.SQL.Text:='insert into pedido_tem_massa_pizza(cod_pedido,cod_massa,cod_pizza,quantidade,observacoes,valor) values '
	                        +'('+IntToStr(cod)+', '+GridPizzas.Cells[1,r]+', '+GridPizzas.Cells[3,r]+', '
	                        +GridPizzas.Cells[0,r]+', '+QuotedStr(GridPizzas.Cells[6,r])+', '+preco+')';
		        Q.ExecSQL;
			end;
	        Transaction.Commit;
			Application.MessageBox('Pedido cadastrado com sucesso','Cadastro efetuado',0);
	        Close;
	    end
	    else
	    begin
	        Q.Close;
	        Q.SQL.Text:='update pedido set valor_total='+total+' and forma_pagamento='+IntToStr(CmbFormaPagto.ItemIndex)+
                        ' and cod_cliente='+EdtCodCliente.Text+' and troco_para='+trocopara+' where cod_pedido='+IntToStr(cod_pedido);
	        Q.ExecSQL;
	        if (CmbEntrega.ItemIndex=1) then
	        begin
	            Q.SQL.Text:='insert into entregador_entrega_pedido(cod_pedido,cod_entregador,valor_entrega) values '
	                        +'('+IntToStr(cod_pedido)+', '+EdtCodEntregador.Text+', '+entrega+')';
	            Q.ExecSQL;
	        end;
	        r:=0;
	        for r:=1 to GridPizzas.RowCount-1 do
	        begin
	            preco:=StringReplace(GridPizzas.Cells[5,r], ',', '.', [rfReplaceAll, rfIgnoreCase]);
		        Q.Close;
		        Q.SQL.Text:='insert into pedido_tem_massa_pizza(cod_pedido,cod_massa,cod_pizza,quantidade,observacoes,valor) values '
	                        +'('+IntToStr(cod_pedido)+', '+GridPizzas.Cells[1,r]+', '+GridPizzas.Cells[3,r]+', '
	                        +GridPizzas.Cells[0,r]+', '+QuotedStr(GridPizzas.Cells[6,r])+', '+preco+')';
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

procedure TFCadPedido.BtnAlterarClick(Sender: TObject);
begin
    Screen.Cursor:=crHourGlass;
    Application.CreateForm(TFCadCliente,FCadCliente);
    try
	    Q.Close;
	    Q.SQL.Text:='select * from cliente where cod_cliente='+EdtCodCliente.Text;
	    Q.Open;
		FCadCliente.cod:=Q.FieldByName('cod_cliente').AsInteger;
	    FCadCliente.telefone_anterior:=Q.FieldByName('telefone').AsString;
	    FCadCliente.Caption:='Alterar Cliente';
	    FCadCliente.EdtTelefone.Text:=Q.FieldByName('telefone').AsString;
	    FCadCliente.EdtNome.Text:=Q.FieldByName('nome').AsString;
	    FCadCliente.EdtCEP.Text:=Q.FieldByName('cep').AsString;
	    FCadCliente.EdtRua.Text:=Q.FieldByName('rua').AsString;
	    FCadCliente.EdtNumero.Text:=Q.FieldByName('numero').AsString;
	    FCadCliente.EdtComplemento.Text:=Q.FieldByName('complemento').AsString;
	    FCadCliente.EdtCodigo.Text:=Q.FieldByName('cod_cliente').AsString;
	    Screen.Cursor:=crDefault;
	    FCadCliente.ShowModal;
	    FCadCliente.Destroy;
	    EdtTelClienteExit(Sender);
    except
        on E : Exception do
	    begin
            Application.MessageBox(PChar('ERRO '+E.Message),'ERRO',0);
			Screen.Cursor:=crDefault;
            FCadCliente.Destroy;
			Exit;
	    end;
    end;
end;

procedure TFCadPedido.BtnAdicionarClick(Sender: TObject);
var r: integer;
begin
    if (EdtCodMassa.Text='') then
    begin
        Showmessage('Primeiro selecione uma massa.');
        Exit;
	end;
    if (EdtCodPizza.Text='') then
    begin
        Showmessage('Primeiro selecione um sabor de pizza.');
        Exit;
	end;
    Screen.Cursor:=crHourGlass;
    r:=0;
    while (r<GridPizzas.RowCount) do
    begin
        if (EdtCodMassa.Text=GridPizzas.Cells[1,r]) and (EdtCodPizza.Text=GridPizzas.Cells[3,r]) then
        begin
            Showmessage('Pizza já inclusa.');
            EdtCodMassa.Text:='';
            EdtCodMassaExit(Sender);
            EdtCodPizza.Text:='';
            EdtCodPizzaExit(Sender);
            EdtCodMassa.SetFocus;
            Screen.Cursor:=crDefault;
            Exit;
		end;
        r:=r+1;
	end;
	GridPizzas.RowCount:=GridPizzas.RowCount+1;

	GridPizzas.Cells[0,GridPizzas.RowCount-1]:=EdtQtde.Text;
    GridPizzas.Cells[1,GridPizzas.RowCount-1]:=EdtCodMassa.Text;
    GridPizzas.Cells[2,GridPizzas.RowCount-1]:=EdtNomeMassa.Text;
    GridPizzas.Cells[3,GridPizzas.RowCount-1]:=EdtCodPizza.Text;
    GridPizzas.Cells[4,GridPizzas.RowCount-1]:=EdtNomePizza.Text;
    try
	    GridPizzas.Cells[5,GridPizzas.RowCount-1]:=FormatFloat('#0.00',(EdtQtde.Value*
	                                                (StrToFloat(EdtValMassa.Text)+StrToFloat(EdtValPizza.Text))));
    except
        on E : Exception do
	    begin
            Application.MessageBox(PChar('ERRO '+E.Message),'ERRO',0);
			Screen.Cursor:=crDefault;
			Exit;
	    end;
    end;
	GridPizzas.Cells[6,GridPizzas.RowCount-1]:=EdtObs.Text;
    EdtCodMassa.Text:='';
    EdtCodMassaExit(Sender);
    EdtCodPizza.Text:='';
    EdtCodPizzaExit(Sender);
    EdtObs.Text:='';
    EdtQtde.Value:=1;
    EdtCodMassa.SetFocus;
    AtualizaTotal(Sender);
    Screen.Cursor:=crDefault;
end;

procedure TFCadPedido.BtnPesqClienteClick(Sender: TObject);
begin
    Application.CreateForm(TFPesCliente,FPesCliente);
    FPesCliente.BtnAdicionar.Visible:=false;
    FPesCliente.BtnAlterar.Visible:=false;
    FPesCliente.BtnExcluir.Visible:=false;
    FPesCliente.LabelInfo.Visible:=true;
    FPesCliente.ShowModal;
    if (FPesCliente.retorna<>'') then
    begin
	    EdtTelCliente.Text:=FPesCliente.retorna;
	    EdtTelClienteExit(Sender);
	end;
	FPesCliente.Destroy;
end;

procedure TFCadPedido.BtnPesqEntregadorClick(Sender: TObject);
begin
    Application.CreateForm(TFPesEntregador,FPesEntregador);
    FPesEntregador.BtnAdicionar.Visible:=false;
    FPesEntregador.BtnAlterar.Visible:=false;
    FPesEntregador.BtnExcluir.Visible:=false;
    FPesEntregador.LabelInfo.Visible:=true;
    FPesEntregador.ShowModal;
    if (FPesEntregador.retorna<>'') then
    begin
	    EdtCodEntregador.Text:=FPesEntregador.retorna;
	    EdtCodEntregadorExit(Sender);
	end;
	FPesEntregador.Destroy;
end;

procedure TFCadPedido.BtnPesqMassaClick(Sender: TObject);
begin
    Application.CreateForm(TFPesMassa,FPesMassa);
    FPesMassa.BtnAdicionar.Visible:=false;
    FPesMassa.BtnAlterar.Visible:=false;
    FPesMassa.BtnExcluir.Visible:=false;
    FPesMassa.ShowModal;
    if (FPesMassa.retorna<>'') then
    begin
	    EdtCodMassa.Text:=FPesMassa.retorna;
	    EdtCodMassaExit(Sender);
	end;
	FPesMassa.Destroy;
end;

procedure TFCadPedido.BtnPesqPizzaClick(Sender: TObject);
begin
    Application.CreateForm(TFPesPizza,FPesPizza);
    FPesPizza.BtnAdicionar.Visible:=false;
    FPesPizza.BtnAlterar.Visible:=false;
    FPesPizza.BtnExcluir.Visible:=false;
    FPesPizza.ShowModal;
    if (FPesPizza.retorna<>'') then
    begin
	    EdtCodPizza.Text:=FPesPizza.retorna;
	    EdtCodPizzaExit(Sender);
	end;
	FPesPizza.Destroy;
end;

procedure TFCadPedido.CmbEntregaChange(Sender: TObject);
begin
    if (CmbEntrega.ItemIndex=0) then
    begin
        LblValorEntrega.Visible:=false;
        EdtValorEntrega.Visible:=false;
        LblEntregador.Visible:=false;
        EdtCodEntregador.Visible:=false;
        EdtNomeEntregador.Visible:=false;
        LblEndereco.Visible:=false;
        EdtEndereco.Visible:=false;
        BtnPesqEntregador.Visible:=false;
	end
    else
    begin
        LblValorEntrega.Visible:=true;
        EdtValorEntrega.Visible:=true;
        LblEntregador.Visible:=true;
        EdtCodEntregador.Visible:=true;
        EdtNomeEntregador.Visible:=true;
        LblEndereco.Visible:=true;
        EdtEndereco.Visible:=true;
        BtnPesqEntregador.Visible:=true;
	end;
end;

procedure TFCadPedido.CmbFormaPagtoChange(Sender: TObject);
begin
    if (CmbFormaPagto.ItemIndex<>0) then
    begin
        LblTrocoPara.Visible:=false;
        EdtTrocoPara.Visible:=false;
        LblTroco.Visible:=false;
        EdtTroco.Visible:=false;
	end
    else
    begin
        LblTrocoPara.Visible:=true;
        EdtTrocoPara.Visible:=true;
        LblTroco.Visible:=true;
        EdtTroco.Visible:=true;
	end;
end;

procedure TFCadPedido.EdtCodEntregadorExit(Sender: TObject);
begin
    if (Trim(EdtCodEntregador.Text)='') then
    begin
        EdtNomeEntregador.Text:='';
        Exit;
	end;
    Screen.Cursor:=crHourGlass;
	try
		Q.Close;
	    Q.SQL.Text:='select cod_entregador, nome from entregador where cod_entregador='+EdtCodEntregador.Text;
	    Q.Open;
	    if Q.RecNo=0 then
	    begin
	        EdtNomeEntregador.Text:='';
	        EdtCodEntregador.Text:='';
	        Screen.Cursor:=crDefault;
	        Exit;
		end;
	    EdtNomeEntregador.Text:=Q.FieldByName('nome').AsString;
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



procedure TFCadPedido.EdtCodMassaExit(Sender: TObject);
begin
    if (Trim(EdtCodMassa.Text)='') then
    begin
        EdtNomeMassa.Text:='';
        Exit;
	end;
    Screen.Cursor:=crHourGlass;
    try
		Q.Close;
	    Q.SQL.Text:='select cod_massa, nome, valor_adicional from massa where cod_massa='+EdtCodMassa.Text;
	    Q.Open;
	    if Q.RecNo=0 then
	    begin
	        EdtNomeMassa.Text:='';
	        EdtCodMassa.Text:='';
	        Screen.Cursor:=crDefault;
	        Exit;
		end;
	    EdtNomeMassa.Text:=Q.FieldByName('nome').AsString;
	    EdtValMassa.Text:=StringReplace(Q.FieldByName('valor_adicional').AsString, '.', ',', [rfReplaceAll, rfIgnoreCase]);
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

procedure TFCadPedido.EdtCodPizzaExit(Sender: TObject);
begin
    if (Trim(EdtCodPizza.Text)='') then
    begin
        EdtNomePizza.Text:='';
        Exit;
	end;
    Screen.Cursor:=crHourGlass;
    try
		Q.Close;
	    Q.SQL.Text:='select cod_pizza, sabor, preco from pizza where cod_pizza='+EdtCodPizza.Text;
	    Q.Open;
	    if Q.RecNo=0 then
	    begin
	        EdtNomePizza.Text:='';
	        EdtCodPizza.Text:='';
	        Screen.Cursor:=crDefault;
	        Exit;
		end;
	    EdtNomePizza.Text:=Q.FieldByName('sabor').AsString;
	    EdtValPizza.Text:=StringReplace(Q.FieldByName('preco').AsString, '.', ',', [rfReplaceAll, rfIgnoreCase]);
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

procedure TFCadPedido.EdtTelClienteExit(Sender: TObject);
begin
    if (Trim(EdtTelCliente.Text)='') then
    begin
        EdtNomeCliente.Text:='';
        EdtCodCliente.Text:='';
        EdtEndereco.Text:='';
        BtnAlterar.Enabled:=false;
        Exit;
	end;
    Screen.Cursor:=crHourGlass;
    try
		Q.Close;
	    Q.SQL.Text:='select c.*, e.rua from cliente c left join endereco e on e.cep=c.cep where c.telefone='+EdtTelCliente.Text;
	    Q.Open;
	    if Q.RecNo=0 then
	    begin
	        EdtNomeCliente.Text:='';
	        EdtCodCliente.Text:='';
	        EdtTelCliente.Text:='';
	        EdtEndereco.Text:='';
	        BtnAlterar.Enabled:=false;
	        Screen.Cursor:=crDefault;
	        Exit;
		end;
	    EdtNomeCliente.Text:=Q.FieldByName('nome').AsString;
	    EdtCodCliente.Text:=Q.FieldByName('cod_cliente').AsString;
	    EdtEndereco.Text:=Q.FieldByName('rua').AsString+', nº '+Q.FieldByName('numero').AsString;
	    BtnAlterar.Enabled:=true;
	    if (Q.FieldByName('complemento').AsString<>'') then
	        EdtEndereco.Text:=EdtEndereco.Text+', '+Q.FieldByName('complemento').AsString;
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


procedure TFCadPedido.EdtTrocoParaEditingDone(Sender: TObject);
begin
    if (EdtTrocoPara.Value=0) then Exit;
    Screen.Cursor:=crHourGlass;
    try
	    if (EdtTrocoPara.Value<StrToFloat(EdtValorTotal.Text)) then
	    begin
	        ShowMessage('Valor para troco menor que valor total!');
	        EdtTrocoPara.Value:=0;
	        EdtTroco.Text:='0,00';
		end
	    else
	    begin
	        EdtTroco.Text:=FormatFloat('#0.00',(EdtTrocoPara.Value-StrToFloat(EdtValorTotal.Text)));
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


procedure TFCadPedido.EdtValorEntregaEditingDone(Sender: TObject);
begin
    AtualizaTotal(Sender);
end;

procedure TFCadPedido.EdtValorTotalChange(Sender: TObject);
begin
    if (EdtTrocoPara.Value=0) then Exit;
    Screen.Cursor:=crHourGlass;
    try
	    if (EdtTrocoPara.Value<StrToFloat(EdtValorTotal.Text)) then
	    begin
	        ShowMessage('Valor para troco menor que valor total!');
	        EdtTrocoPara.Value:=0;
	        EdtTroco.Text:='0,00';
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



procedure TFCadPedido.FormCreate(Sender: TObject);
begin
    if (telefone='') then Exit;
    EdtTelCliente.Text:=telefone;
    EdtTelClienteExit(Sender);
end;

end.

