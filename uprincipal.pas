unit UPrincipal;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, db, mysql50conn, FileUtil, Forms, Controls,
  Graphics, LCLType, Dialogs, ExtCtrls, Buttons, Menus, StdCtrls, ComCtrls,
  IniFiles, Translations, RLReport, upescliente, ucadcliente, upesingrediente,
  upesentregador, upesfornecedor, upesfornecimento, upespizza, upesmassa, upesendereco,
  upespedido, ucadpedido, ucancpedido;

type

  { TFPrincipal }

  TFPrincipal = class(TForm)
    AlteraServ: TPanel;
    Botoes: TPanel;
    BtnAlterar: TButton;
    BtnCadastrar: TButton;
    BtnCancelar: TButton;
    BtnEntrar: TButton;
    BtnVoltar: TButton;
    BtnVoltar1: TButton;
    Cadastro: TPanel;
	Database: TMySQL50Connection;
	DRel: TDataSource;
    EdtAltSenha: TEdit;
    EdtAltUser: TEdit;
    EdtNovaSenha: TEdit;
    EdtNovoUser: TEdit;
    EdtPorta: TEdit;
    EdtSenha: TEdit;
    EdtServ: TEdit;
    EdtUser: TEdit;
    ItemSair: TMenuItem;
    ItemTroca: TMenuItem;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Login: TPanel;
    ItemCadastros: TMenuItem;
	ItemNovoPedido: TMenuItem;
	ItemPedidos: TMenuItem;
	ItemIngrediente: TMenuItem;
	ItemClientes: TMenuItem;
	ItemPizza: TMenuItem;
	ItemMassa: TMenuItem;
	ItemFornecedor: TMenuItem;
	ItemEntregador: TMenuItem;
	ItemFornecimento: TMenuItem;
	ItemNovoCliente: TMenuItem;
	ItemCardapio: TMenuItem;
	ItemEnderecos: TMenuItem;
    MenuItens: TMainMenu;
    MostraSenha: TCheckBox;
    MostraSenhaNova: TCheckBox;
    MostraSenhaServ: TCheckBox;
    NovoUser: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
	Q: TSQLQuery;
	QRel: TSQLQuery;
	QRelcod: TLongintField;
	QRelnome: TStringField;
	QReltipo: TStringField;
	RLBand1: TRLBand;
	RelCardapio: TRLReport;
	RLBand2: TRLBand;
	RLBand3: TRLBand;
	RLNome: TRLDBText;
	RLDBText2: TRLDBText;
	RLCod: TRLDBText;
	RLGroup1: TRLGroup;
	RLLabel1: TRLLabel;
	RLLabel3: TRLLabel;
	MemoIngredientes: TRLMemo;
    Servidor: TPanel;
    BtnNovoPedido: TSpeedButton;
    BtnCardapio: TSpeedButton;
    BtnCancelaPedido: TSpeedButton;
    BtnNovoCliente: TSpeedButton;
    BtnSair: TSpeedButton;
    BtnTrocaUser: TSpeedButton;
	BtnQualServ: TSpeedButton;
    StatusBar: TStatusBar;
	Transaction: TSQLTransaction;
	procedure AlteraServClick(Sender: TObject);
    procedure AlteraServMouseEnter(Sender: TObject);
    procedure AlteraServMouseLeave(Sender: TObject);
	procedure BtnAlterarClick(Sender: TObject);
	procedure BtnCadastrarClick(Sender: TObject);
	procedure BtnCancelaPedidoClick(Sender: TObject);
    procedure BtnCancelarClick(Sender: TObject);
	procedure BtnCardapioClick(Sender: TObject);
	procedure BtnEntrarClick(Sender: TObject);
	procedure BtnNovoPedidoClick(Sender: TObject);
	procedure BtnQualServClick(Sender: TObject);
	procedure BtnVoltar1Click(Sender: TObject);
	procedure BtnVoltarClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: char);
	procedure ItemCardapioClick(Sender: TObject);
	procedure ItemClientesClick(Sender: TObject);
	procedure ItemEnderecosClick(Sender: TObject);
	procedure ItemEntregadorClick(Sender: TObject);
	procedure ItemFornecedorClick(Sender: TObject);
	procedure ItemFornecimentoClick(Sender: TObject);
	procedure ItemIngredienteClick(Sender: TObject);
	procedure ItemMassaClick(Sender: TObject);
	procedure ItemNovoClienteClick(Sender: TObject);
	procedure ItemNovoPedidoClick(Sender: TObject);
	procedure ItemPedidosClick(Sender: TObject);
	procedure ItemPizzaClick(Sender: TObject);
    procedure ItemSairClick(Sender: TObject);
	procedure ItemTrocaClick(Sender: TObject);
	procedure LoginEnter(Sender: TObject);
	procedure MostraSenhaChange(Sender: TObject);
    procedure MostraSenhaNovaChange(Sender: TObject);
	procedure MostraSenhaServChange(Sender: TObject);
	procedure NovoUserClick(Sender: TObject);
	procedure NovoUserMouseEnter(Sender: TObject);
	procedure NovoUserMouseLeave(Sender: TObject);
    function Encrypt(const S: String; Key: Word): String;
    function Decrypt(const S: ShortString; Key: Word): String;
	procedure BtnNovoClienteClick(Sender: TObject);
	procedure RLBand3BeforePrint(Sender: TObject; var PrintIt: boolean);
  private
    { private declarations }
  public
    { public declarations }
    user: integer;
    tel_cliente: string;
  end;

var
  FPrincipal: TFPrincipal;

implementation

{$R *.lfm}

const
    C1 = 34522;
    C2 = 76464;

{ TFPrincipal }

function TFPrincipal.Encrypt(const S: String; Key: Word): String;
var
    I: byte;
begin
    Result := '';
    for I := 1 to Length(S) do
    begin
        Result := Result + IntToHex(byte(char(byte(S[I]) xor (Key shr 8))), 2);
        Key := (byte(char(byte(S[I]) xor (Key shr 8))) + Key) * C1 + C2;
    end;
end;

function TFPrincipal.Decrypt(const S: ShortString; Key: Word): String;
var
    I: byte;
    x: char;
begin
    result := '';
    i := 1;
    while (i < Length(S)) do
    begin
        x := char(strToInt('$' + Copy(s, i, 2)));
        Result := result + char(byte(x) xor (Key shr 8));
        Key := (byte(x) + Key) * C1 + C2;
        Inc(i, 2);
    end;
end;

procedure TFPrincipal.BtnNovoClienteClick(Sender: TObject);
begin
    ItemNovoClienteClick(Sender);
end;

procedure TFPrincipal.RLBand3BeforePrint(Sender: TObject; var PrintIt: boolean);
var linha: string;
begin
    linha:='';
    try
	    MemoIngredientes.Lines.Clear;
	    Q.Close;
	    if (QRel.FieldByName('tipo').AsString='MASSAS') then
	    begin
	        Q.SQL.Text:='select MCI.*, I.nome from massa_contem_ingrediente MCI left join ingrediente I on '+
	                ' I.cod_ingrediente=MCI.cod_ingrediente where MCI.cod_massa='+QRel.FieldByName('cod').AsString+
	                ' order by nome';
		end
		else
	    begin
	        Q.SQL.Text:='select PPI.*, I.nome from pizza_possui_ingrediente PPI left join ingrediente I on '+
	                ' I.cod_ingrediente=PPI.cod_ingrediente where PPI.cod_pizza='+QRel.FieldByName('cod').AsString+
	                ' order by nome';
		end;
		Q.Open;
	    Q.First;
	    while not Q.EOF do
	    begin
	        if (linha<>'') then linha:=linha+', ';
	        if (Length(linha)+Length(Q.FieldByName('nome').AsString)+2>96) then
	        begin
	            MemoIngredientes.Lines.Add(linha);
	            linha:='';
			end;
	        linha:=linha+AnsiUpperCase(Q.FieldByName('nome').AsString);
			Q.Next;
		end;
        Q.Close;
    except
        on E : Exception do
	    begin
            Application.MessageBox(PChar('ERRO '+E.Message),'ERRO',0);
			Screen.Cursor:=crDefault;
			Exit;
	    end;
    end;
	if (linha<>'') then
        MemoIngredientes.Lines.Add(linha);
end;

procedure TFPrincipal.FormCreate(Sender: TObject);
var
    ini: TIniFile;
begin
    Screen.Cursor:=crHourGlass;

    TranslateUnitResourceStrings('LclStrConsts', 'C:\lazarus\lcl\languages\lclstrconsts.pt_BR.po', 'pt_BR', '');
    try
	    ini:=TINIFile.Create('PIZZARIA.ini');
		Database.HostName:=ini.ReadString('conexao','host','localhost');
		Database.Port:=ini.ReadInteger('conexao','porta',3306);
		Database.UserName:=ini.ReadString('conexao','usuario','heloisa');
		Database.Password:=Decrypt(ini.ReadString('conexao', 'senha', Encrypt('123', 7834)), 7834);
	    EdtUser.Text:=ini.ReadString('acesso','ultimouser','');
	    ini.Free;
    except
        on E : Exception do
	    begin
            Application.MessageBox(PChar('ERRO '+E.Message),'ERRO',0);
            ini.Free;
			Screen.Cursor:=crDefault;
			Exit;
	    end;
    end;

    DefaultFormatSettings.LongMonthNames[3]:='março';
    DefaultFormatSettings.LongDayNames[1]:='domingo';
    DefaultFormatSettings.LongdayNames[2]:='segunda-feira';
    DefaultFormatSettings.LongDayNames[3]:='terça-feira';
    DefaultFormatSettings.LongDayNames[4]:='quarta-feira';
    DefaultFormatSettings.LongDayNames[5]:='quinta-feira';
    DefaultFormatSettings.LongdayNames[6]:='sexta-feira';
    DefaultFormatSettings.LongDayNames[7]:='sábado';

    MenuItens.Items[0].Visible:=false;
    MenuItens.Items[1].Visible:=false;
    MenuItens.Items[2].Visible:=false;
    MenuItens.Items[3].Visible:=false;
    MenuItens.Items[4].Visible:=false;
    MenuItens.Items[5].Visible:=false;
    StatusBar.Visible:=false;

    Login.Top:=80;
    Login.Left:=136;
    Cadastro.Top:=80;
    Cadastro.Left:=136;
    Servidor.Top:=80;
    Servidor.Left:=136;
    FPrincipal.Height:=455;
    FPrincipal.Width:=735;

    Login.Visible:=true;
    Botoes.Visible:=false;

    Screen.Cursor:=crDefault;
end;

procedure TFPrincipal.FormKeyPress(Sender: TObject; var Key: char);
begin
    try
        if ActiveControl.ClassName='TButton' then
        Exit;
        if key=#13 then
        begin
            key:=#0;
            SelectNext(ActiveControl,True,True);
        end;
    except
    end;
end;

procedure TFPrincipal.ItemCardapioClick(Sender: TObject);
begin
    Screen.Cursor:=crHourGlass;
    try
	    QRel.Close;
	    QRel.SQL.Text:='(select '+QuotedStr('MASSAS')+' as tipo, upper(nome) as nome, cod_massa as cod from massa) UNION'+
	                ' (select '+QuotedStr('PIZZAS')+' as tipo, upper(sabor) as nome, cod_pizza as cod from pizza) '+
	                ' order by tipo, nome';
	    QRel.Open;
	    Screen.Cursor:=crDefault;
	    if (QRel.RecNo=0) then
	        ShowMessage('Não há massas ou pizzas cadastradas para exibir cardápio.'+#10+'Cadastre-as primeiramente.')
	    else
	        RelCardapio.Preview();
    except
        on E : Exception do
	    begin
            Application.MessageBox(PChar('ERRO '+E.Message),'ERRO',0);
			Screen.Cursor:=crDefault;
			Exit;
	    end;
    end;
end;

procedure TFPrincipal.ItemClientesClick(Sender: TObject);
begin
    Screen.Cursor:=crHourGlass;
    Application.CreateForm(TFPesCliente,FPesCliente);
    FPesCliente.ShowModal;
    FPesCliente.Destroy;
    Screen.Cursor:=crDefault;
end;

procedure TFPrincipal.ItemEnderecosClick(Sender: TObject);
begin
  Screen.Cursor:=crHourGlass;
  Application.CreateForm(TFPesEndereco,FPesEndereco);
  FPesEndereco.ShowModal;
  FPesEndereco.Destroy;
  Screen.Cursor:=crDefault;
end;

procedure TFPrincipal.ItemEntregadorClick(Sender: TObject);
begin
    Screen.Cursor:=crHourGlass;
    Application.CreateForm(TFPesEntregador,FPesEntregador);
    FPesEntregador.ShowModal;
    FPesEntregador.Destroy;
    Screen.Cursor:=crDefault;
end;

procedure TFPrincipal.ItemFornecedorClick(Sender: TObject);
begin
    Screen.Cursor:=crHourGlass;
    Application.CreateForm(TFPesFornecedor,FPesFornecedor);
    FPesFornecedor.ShowModal;
    FPesFornecedor.Destroy;
    Screen.Cursor:=crDefault;
end;

procedure TFPrincipal.ItemFornecimentoClick(Sender: TObject);
begin
    Application.CreateForm(TFPesFornecimento,FPesFornecimento);
    FPesFornecimento.ShowModal;
    FPesFornecimento.Destroy;
end;

procedure TFPrincipal.ItemIngredienteClick(Sender: TObject);
begin
    Screen.Cursor:=crHourGlass;
    Application.CreateForm(TFPesIngrediente,FPesIngrediente);
    FPesIngrediente.ShowModal;
    FPesIngrediente.Destroy;
    Screen.Cursor:=crDefault;
end;

procedure TFPrincipal.ItemMassaClick(Sender: TObject);
begin
    Screen.Cursor:=crHourGlass;
    Application.CreateForm(TFPesMassa,FPesMassa);
    FPesMassa.ShowModal;
    FPesMassa.Destroy;
    Screen.Cursor:=crDefault;
end;

procedure TFPrincipal.ItemNovoClienteClick(Sender: TObject);
begin
    Screen.Cursor:=crHourGlass;
    Application.CreateForm(TFCadCliente,FCadCliente);
    with FCadCliente do
    begin
	    cod:=-1;
	    Caption:='Novo Cliente';
        LblCodigo.Visible:=false;
        EdtCodigo.Visible:=false;
	    ShowModal;
	end;
    tel_cliente:=FCadCliente.telefone;
	FCadCliente.Destroy;
    if (Trim(tel_cliente)='') then
    begin
        Screen.Cursor:=crDefault;
        Exit;
	end;
	if (Application.MessageBox(PChar('Deseja cadastrar pedido com o novo cliente?'),
                'NOVO PEDIDO',MB_ICONQUESTION+MB_YESNO)=IDYES) then
	begin
        Application.CreateForm(TFCadPedido,FCadPedido);
	    with FCadPedido do
	    begin
		    cod_pedido:=-1;
	        telefone:=tel_cliente;
		    Caption:='Novo Pedido';
	        LblCodigo.Visible:=false;
	        EdtCodigo.Visible:=false;
		    ShowModal;
		    Destroy;
		end;
	end;
    Screen.Cursor:=crDefault;
end;

procedure TFPrincipal.ItemNovoPedidoClick(Sender: TObject);
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
end;

procedure TFPrincipal.ItemPedidosClick(Sender: TObject);
begin
    Screen.Cursor:=crHourGlass;
    Application.CreateForm(TFPesPedido,FPesPedido);
    FPesPedido.ShowModal;
    FPesPedido.Destroy;
    Screen.Cursor:=crDefault;
end;

procedure TFPrincipal.ItemPizzaClick(Sender: TObject);
begin
    Screen.Cursor:=crHourGlass;
    Application.CreateForm(TFPesPizza,FPesPizza);
    FPesPizza.ShowModal;
    FPesPizza.Destroy;
    Screen.Cursor:=crDefault;
end;

procedure TFPrincipal.FormActivate(Sender: TObject);
begin
    if Login.Visible then
    	EdtUser.SetFocus
    else if Cadastro.Visible then
    	EdtNovoUser.SetFocus
    else if Servidor.Visible then
    	EdtServ.SetFocus;
end;

procedure TFPrincipal.AlteraServMouseEnter(Sender: TObject);
begin
    Screen.Cursor:=crHandPoint;
    AlteraServ.Font.Underline:=True;
end;

procedure TFPrincipal.AlteraServClick(Sender: TObject);
begin
	Servidor.Visible:=true;
	EdtServ.SetFocus;
	Login.Visible:=false;
end;

procedure TFPrincipal.AlteraServMouseLeave(Sender: TObject);
begin
    AlteraServ.Font.Underline:=False;
    Screen.Cursor:=crDefault;
end;

procedure TFPrincipal.BtnAlterarClick(Sender: TObject);
var
    ini: TINIFile;
begin
    Screen.Cursor:=crHourGlass;
    if trim(EdtServ.Text)='' then
    begin
		Application.MessageBox('Digite o servidor!','Campo servidor vazio',0);
		EdtServ.SetFocus;
		Screen.Cursor:=crDefault;
		Exit;
    end else if trim(EdtPorta.Text)='' then
    begin
		Application.MessageBox('Digite a porta!','Campo porta vazio',0);
		EdtPorta.SetFocus;
		Screen.Cursor:=crDefault;
		Exit;
    end else if trim(EdtAltUser.Text)='' then
    begin
		Application.MessageBox('Digite o nome de usuário para conexão!','Campo usuário vazio',0);
		EdtAltUser.SetFocus;
		Screen.Cursor:=crDefault;
		Exit;
    end;
    try
		Database.HostName:=EdtServ.Text;
		Database.Port:=strtoint(EdtPorta.Text);
		Database.UserName:=EdtAltUser.Text;
		Database.Password:=EdtAltSenha.Text;
		Database.Connected:=true;
		Database.Connected:=false;

		ini:=TINIFile.Create('PIZZARIA.ini');
		ini.WriteString('conexao','host',EdtServ.Text);
		ini.WriteInteger('conexao','porta',strtoint(EdtPorta.Text));
		ini.WriteString('conexao','usuario',EdtAltUser.Text);
        ini.WriteString('conexao', 'senha', Encrypt(EdtAltSenha.Text, 7834));
		ini.Free;
		Application.MessageBox('Servidor de conexão alterado!',PChar('Conectado em: '+EdtServ.Text),0);
    except
        on E : Exception do
	    begin
            Application.MessageBox(PChar('Não foi possível conectar no servidor '+EdtServ.Text+' com os dados indicados.'+
                                        #10+'ERRO '+E.Message),'ERRO',0);
            EdtServ.SetFocus;
			Screen.Cursor:=crDefault;
			Exit;
	    end;
    end;

	EdtServ.Text:='';
	EdtPorta.Text:='3306';
	EdtAltUser.Text:='';
	EdtAltSenha.Text:='';
	Servidor.Visible:=false;
	Login.Visible:=true;
	EdtUser.SetFocus;
	Screen.Cursor:=crDefault;
end;

procedure TFPrincipal.BtnCadastrarClick(Sender: TObject);
begin
    Screen.Cursor:=crHourGlass;
    if trim(EdtNovoUser.Text)='' then
    begin
		Application.MessageBox('Digite um nome de usuário!','Campo usuário vazio',0);
		EdtNovoUser.SetFocus;
		Screen.Cursor:=crDefault;
        Exit;
    end
    else if EdtNovaSenha.Text='' then
    begin
		Application.MessageBox('É necessário escolher uma senha!','Campo senha vazio',0);
		EdtNovaSenha.SetFocus;
		Screen.Cursor:=crDefault;
		Exit;
    end;
    try
	    Q.Close;
	    Q.SQL.Clear;
	    Q.SQL.Text:='select * from usuario where lower(login)='+QuotedStr(AnsiLowerCase(trim(EdtNovoUser.Text)));
	    Q.Open;
	    if Q.RecNo>0 then
	    begin
			Application.MessageBox('Usuário já existente! Escolha outro.','Nome de usuário indisponível',0);
			EdtNovoUser.SetFocus;
			Screen.Cursor:=crDefault;
			Exit;
	    end;
	    Q.Close;
	    Q.SQL.Clear;
	    Q.SQL.Text:='insert into usuario (login, senha) values (:LOG,md5(:PSW))';
	    Q.Params.ParamByName('LOG').AsString:=AnsiLowerCase(trim(EdtNovoUser.Text));
	    Q.Params.ParamByName('PSW').AsString:=EdtNovaSenha.Text;
	    Q.ExecSQL;
	    Transaction.Commit;
	    Application.MessageBox('Usuário cadastrado com sucesso.','Cadastro efetuado',0);
	    EdtNovaSenha.Text:='';
	except
        on E : Exception do
	    begin
            Application.MessageBox(PChar('ERRO '+E.Message),'ERRO',0);
			Screen.Cursor:=crDefault;
			Exit;
	    end;
    end;
	EdtNovoUser.Text:='';
    EdtSenha.Text:='';
    EdtUser.Text:='';
    Cadastro.Visible:=false;
    Login.Visible:=true;
    EdtUser.SetFocus;
    Screen.Cursor:=crDefault;
end;

procedure TFPrincipal.BtnCancelaPedidoClick(Sender: TObject);
begin
    Screen.Cursor:=crHourGlass;
    Application.CreateForm(TFCancPedido,FCancPedido);
    Screen.Cursor:=crHourGlass;
    try
	    FCancPedido.QPedido.Close;
	    FCancPedido.QPedido.SQL.Clear;
	    FCancPedido.QPedido.SQL.Text:='select P.cod_pedido, P.data, P.hora, P.valor_total, P.cancelado, C.nome, C.telefone'+
	                        ' from pedido P left join cliente C on C.cod_cliente=P.cod_cliente'+
	                        ' where P.cancelado=0 and P.data='+QuotedStr(FormatDateTime('yyyy-mm-dd',Now))+
	                        ' order by P.data desc, P.hora desc, C.nome';
	    FCancPedido.QPedido.Open;
	    if (FCancPedido.QPedido.RecNo=0) then
	        ShowMessage('Não há nenhum pedido cadastrado no dia de hoje para ser cancelado!')
	    else
	        FCancPedido.ShowModal;
	    FCancPedido.Destroy;
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

procedure TFPrincipal.BtnCancelarClick(Sender: TObject);
begin
    Close;
end;

procedure TFPrincipal.BtnCardapioClick(Sender: TObject);
begin
    ItemCardapioClick(Sender);
end;

procedure TFPrincipal.BtnEntrarClick(Sender: TObject);
var
    ini: TINIFile; serv: string;
begin
    Screen.Cursor:=crHourGlass;
    if not (Database.Connected) then
    begin
        try
            ini:=TINIFile.Create('PIZZARIA.ini');
			serv:=ini.ReadString('conexao','host','localhost');
			Database.HostName:=serv;
			Database.Port:=ini.ReadInteger('conexao','porta',3306);
			Database.UserName:=ini.ReadString('conexao','usuario','heloisa');
			Database.Password:=Decrypt(ini.ReadString('conexao', 'senha', Encrypt('123', 7834)), 7834);
            Database.Connected:=true;
            ini.Free;
        except
            on E : Exception do
		    begin
                Application.MessageBox(PChar('Não foi possível conectar no servidor "'+serv+'"'+#10+
                                        'ERRO '+E.Message),'ERRO',0);
				EdtUser.SetFocus;
				Screen.Cursor:=crDefault;
	            ini.Free;
				Exit;
		    end;
        end;
    end;
	if trim(EdtUser.Text)='' then
    begin
		Application.MessageBox('Digite seu nome de usuário!','Campo usuário vazio',0);
		EdtUser.SetFocus;
		Screen.Cursor:=crDefault;
		Exit;
	end
	else if EdtSenha.Text='' then
	begin
		Application.MessageBox('Digite sua senha!','Campo senha vazio',0);
		EdtSenha.SetFocus;
		Screen.Cursor:=crDefault;
		Exit;
    end;
    try
		Q.Close;
		Q.SQL.Clear;
		Q.SQL.Text:='select * from usuario where lower(login)='+QuotedStr(AnsiLowerCase(trim(EdtUser.Text)));
		Q.Open;
		if Q.RecNo=0 then
		begin
			Application.MessageBox('Usuário inválido.','Nome de usuário inexistente',0);
			EdtUser.SetFocus;
			Screen.Cursor:=crDefault;
			Exit;
	    end;

		Q.Close;
		Q.SQL.Clear;
		Q.SQL.Text:='select * from usuario where lower(login)='+QuotedStr(AnsiLowerCase(trim(EdtUser.Text)))+' and senha=md5('+QuotedStr(EdtSenha.Text)+')';
	    Q.Open;
	    if Q.RecNo=0 then
	    begin
			Application.MessageBox('Senha inválida.','Campo senha incorreto',0);
			EdtSenha.SetFocus;
			Screen.Cursor:=crDefault;
			Exit;
	    end;
	        ini:=TINIFile.Create('PIZZARIA.ini');
	        ini.WriteString('acesso','ultimouser',EdtUser.Text);
	        ini.Free;
			user:=Q.FieldByName('cod_usuario').AsInteger;
            Q.Close;
    except
        on E : Exception do
	    begin
            Application.MessageBox(PChar('ERRO '+E.Message),'ERRO',0);
			Screen.Cursor:=crDefault;
			Exit;
	    end;
    end;
		MenuItens.Items[0].Visible:=true;
		MenuItens.Items[1].Visible:=true;
		MenuItens.Items[2].Visible:=true;
		MenuItens.Items[3].Visible:=true;
        MenuItens.Items[4].Visible:=true;
        MenuItens.Items[5].Visible:=true;
		StatusBar.Visible:=true;
		StatusBar.Panels[0].Text:=' USUÁRIO: '+trim(EdtUser.Text);
		StatusBar.Panels[1].Text:=' '+FormatDateTime ('dddd", "dd" de "mmmm" de "yyyy',Now);
		Login.Visible:=false;
		Botoes.Visible:=true;
		EdtSenha.Text:='';
		Screen.Cursor:=crDefault;
end;

procedure TFPrincipal.BtnNovoPedidoClick(Sender: TObject);
begin
    ItemNovoPedidoClick(Sender);
end;

procedure TFPrincipal.BtnQualServClick(Sender: TObject);
begin
    try
        Screen.Cursor:=crHourGlass;
	    Application.MessageBox(PChar('SERVIDOR: '+Database.HostName+#10+'PORTA: '+InttoStr(Database.Port)+#10+
	                            'USUÁRIO: '+Database.UserName),'SERVIDOR ATUAL',0);
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

procedure TFPrincipal.BtnVoltar1Click(Sender: TObject);
begin
    Screen.Cursor:=crHourGlass;
	EdtAltSenha.Text:='';
	EdtAltUser.Text:='';
	EdtServ.Text:='';
	EdtPorta.Text:='3306';
	EdtSenha.Text:='';
	EdtUser.Text:='';
	Servidor.Visible:=false;
	Login.Visible:=true;
	EdtUser.SetFocus;
    Screen.Cursor:=crDefault;
end;

procedure TFPrincipal.BtnVoltarClick(Sender: TObject);
begin
    Screen.Cursor:=crHourGlass;
	EdtNovaSenha.Text:='';
	EdtNovoUser.Text:='';
	EdtSenha.Text:='';
	EdtUser.Text:='';
	Cadastro.Visible:=false;
	Login.Visible:=true;
	EdtUser.SetFocus;
    Screen.Cursor:=crDefault;
end;

procedure TFPrincipal.ItemSairClick(Sender: TObject);
begin
    Close;
end;

procedure TFPrincipal.ItemTrocaClick(Sender: TObject);
begin
    Screen.Cursor:=crHourGlass;
    MenuItens.Items[0].Visible:=false;
	MenuItens.Items[1].Visible:=false;
	MenuItens.Items[2].Visible:=false;
	MenuItens.Items[3].Visible:=false;
    MenuItens.Items[4].Visible:=false;
    MenuItens.Items[5].Visible:=false;
	StatusBar.Visible:=false;
	Login.Visible:=true;
	Botoes.Visible:=false;
	EdtUser.SetFocus;
    Screen.Cursor:=crDefault;
end;

procedure TFPrincipal.LoginEnter(Sender: TObject);
begin
    if EdtUser.Text='' then EdtUser.SetFocus else EdtSenha.SetFocus;
end;

procedure TFPrincipal.MostraSenhaChange(Sender: TObject);
begin
    if MostraSenha.Checked then
        EdtSenha.PasswordChar:=#0
    else
        EdtSenha.PasswordChar:='*';
end;

procedure TFPrincipal.MostraSenhaNovaChange(Sender: TObject);
begin
    if MostraSenhaNova.Checked then
        EdtNovaSenha.PasswordChar:=#0
    else
        EdtNovaSenha.PasswordChar:='*';
end;

procedure TFPrincipal.MostraSenhaServChange(Sender: TObject);
begin
    if MostraSenhaServ.Checked then
        EdtAltSenha.PasswordChar:=#0
    else
        EdtAltSenha.PasswordChar:='*';
end;

procedure TFPrincipal.NovoUserClick(Sender: TObject);
var mastersenha: string;
begin
    mastersenha:='';
    if not InputQuery('Senha para liberar cadastro', 'DIGITE A SENHA GERAL PARA CADASTRO DE USUÁRIOS', TRUE, mastersenha) then
        Exit;
    if mastersenha <> 'bd2016' then
    begin
        Application.MessageBox('Esta não é a senha geral de cadastro de usuários','Senha incorreta',0);
        Exit;
	end;
	Cadastro.Visible:=true;
	EdtNovoUser.SetFocus;
	Login.Visible:=false;
end;

procedure TFPrincipal.NovoUserMouseEnter(Sender: TObject);
begin
    Screen.Cursor:=crHandPoint;
    NovoUser.Font.Underline:=True;
end;

procedure TFPrincipal.NovoUserMouseLeave(Sender: TObject);
begin
    NovoUser.Font.Underline:=False;
    Screen.Cursor:=crDefault;
end;


end.

