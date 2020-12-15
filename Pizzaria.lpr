program Pizzaria;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, fortes324forlaz, UPrincipal, upescliente, ucadcliente, ucadingrediente,
  upesingrediente, ucadentregador, upesentregador, ucadfornecedor,
  upesfornecedor, upesfornecimento, ucadfornecimento, upespizza, upesmassa,
  ucadpizza, ucadmassa, ucadpedido, upespedido, ucancpedido, upesendereco, 
  ucadendereco
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TFPrincipal, FPrincipal);
  Application.Run;
end.

