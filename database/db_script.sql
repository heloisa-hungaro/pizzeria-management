# Host: localhost  (Version: 5.5.27-log)
# Date: 2016-08-27 15:25:59
# Generator: MySQL-Front 5.3  (Build 4.234)

/*!40101 SET NAMES latin1 */;

#
# Structure for table "endereco"
#

CREATE TABLE `endereco` (
  `cep` varchar(10) NOT NULL DEFAULT '',
  `rua` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`cep`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

#
# Structure for table "cliente"
#

CREATE TABLE `cliente` (
  `cod_cliente` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `telefone` varchar(15) NOT NULL DEFAULT '',
  `nome` varchar(50) NOT NULL DEFAULT '',
  `cep` varchar(10) DEFAULT NULL,
  `numero` varchar(10) DEFAULT NULL,
  `complemento` varchar(30) DEFAULT NULL,
  PRIMARY KEY (`cod_cliente`),
  UNIQUE KEY `telefone` (`telefone`),
  KEY `cep` (`cep`),
  CONSTRAINT `cliente_ibfk_1` FOREIGN KEY (`cep`) REFERENCES `endereco` (`cep`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

#
# Structure for table "entregador"
#

CREATE TABLE `entregador` (
  `cod_entregador` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `nome` varchar(50) NOT NULL DEFAULT '',
  `cpf` varchar(15) NOT NULL DEFAULT '',
  `telefone` varchar(15) NOT NULL DEFAULT '',
  PRIMARY KEY (`cod_entregador`),
  UNIQUE KEY `cpf` (`cpf`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

#
# Structure for table "fornecedor"
#

CREATE TABLE `fornecedor` (
  `cod_fornecedor` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `cnpj` varchar(20) NOT NULL DEFAULT '',
  `nome` varchar(50) NOT NULL DEFAULT '',
  `telefone` varchar(15) NOT NULL DEFAULT '',
  PRIMARY KEY (`cod_fornecedor`),
  UNIQUE KEY `cnpj` (`cnpj`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

#
# Structure for table "ingrediente"
#

CREATE TABLE `ingrediente` (
  `cod_ingrediente` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `nome` varchar(50) NOT NULL DEFAULT '' COMMENT 'ex: QUEIJO PARMESÃO',
  `uso` tinyint(1) unsigned NOT NULL DEFAULT '2' COMMENT 'em pizza (0). em massa (1), em ambos (2)',
  PRIMARY KEY (`cod_ingrediente`),
  UNIQUE KEY `nome` (`nome`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

#
# Structure for table "fornecedor_fornece_ingrediente"
#

CREATE TABLE `fornecedor_fornece_ingrediente` (
  `cod_fornecedor` int(11) unsigned NOT NULL DEFAULT '0',
  `cod_ingrediente` int(11) unsigned NOT NULL DEFAULT '0',
  `valor_unitario` float(6,2) NOT NULL DEFAULT '0.00',
  `medida` varchar(80) NOT NULL DEFAULT '' COMMENT 'ex: QUILO / UNIDADES',
  `quantidade` float(5,3) NOT NULL DEFAULT '0.000',
  `data` date NOT NULL DEFAULT '0000-00-00',
  `marca` varchar(50) NOT NULL DEFAULT '',
  PRIMARY KEY (`cod_fornecedor`,`cod_ingrediente`,`data`,`marca`),
  KEY `cod_ingrediente` (`cod_ingrediente`),
  CONSTRAINT `fornecedor_fornece_ingrediente_ibfk_1` FOREIGN KEY (`cod_fornecedor`) REFERENCES `fornecedor` (`cod_fornecedor`),
  CONSTRAINT `fornecedor_fornece_ingrediente_ibfk_2` FOREIGN KEY (`cod_ingrediente`) REFERENCES `ingrediente` (`cod_ingrediente`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

#
# Structure for table "massa"
#

CREATE TABLE `massa` (
  `cod_massa` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `nome` varchar(50) NOT NULL DEFAULT '' COMMENT 'ex: TRADICIONAL',
  `valor_adicional` float(4,2) unsigned NOT NULL DEFAULT '0.00',
  PRIMARY KEY (`cod_massa`),
  UNIQUE KEY `nome` (`nome`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

#
# Structure for table "massa_contem_ingrediente"
#

CREATE TABLE `massa_contem_ingrediente` (
  `cod_massa` int(11) unsigned NOT NULL DEFAULT '0',
  `cod_ingrediente` int(11) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`cod_massa`,`cod_ingrediente`),
  KEY `cod_ingrediente` (`cod_ingrediente`),
  CONSTRAINT `massa_contem_ingrediente_ibfk_1` FOREIGN KEY (`cod_massa`) REFERENCES `massa` (`cod_massa`),
  CONSTRAINT `massa_contem_ingrediente_ibfk_2` FOREIGN KEY (`cod_ingrediente`) REFERENCES `ingrediente` (`cod_ingrediente`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

#
# Structure for table "pedido"
#

CREATE TABLE `pedido` (
  `cod_pedido` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `data` date NOT NULL DEFAULT '0000-00-00',
  `hora` time NOT NULL DEFAULT '00:00:00',
  `valor_total` float(6,2) NOT NULL DEFAULT '0.00',
  `forma_pagamento` int(3) NOT NULL DEFAULT '0' COMMENT '0 = dinheiro / 1 = cartão débito / 2 = cartão crédito',
  `cancelado` int(1) NOT NULL DEFAULT '0' COMMENT 'NÃO (0) ; SIM (1)',
  `cod_cliente` int(11) unsigned NOT NULL DEFAULT '0',
  `troco_para` decimal(6,2) DEFAULT NULL COMMENT 'valor a pagar p/ calculo do troco (somente para pagamentos em dinheiro)',
  PRIMARY KEY (`cod_pedido`),
  KEY `cod_cliente` (`cod_cliente`),
  CONSTRAINT `pedido_ibfk_1` FOREIGN KEY (`cod_cliente`) REFERENCES `cliente` (`cod_cliente`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

#
# Structure for table "entregador_entrega_pedido"
#

CREATE TABLE `entregador_entrega_pedido` (
  `cod_entregador` int(11) unsigned NOT NULL DEFAULT '0',
  `cod_pedido` int(11) unsigned NOT NULL DEFAULT '0',
  `valor_entrega` float(4,2) DEFAULT NULL,
  PRIMARY KEY (`cod_entregador`,`cod_pedido`),
  KEY `cod_pedido` (`cod_pedido`),
  CONSTRAINT `entregador_entrega_pedido_ibfk_1` FOREIGN KEY (`cod_entregador`) REFERENCES `entregador` (`cod_entregador`),
  CONSTRAINT `entregador_entrega_pedido_ibfk_2` FOREIGN KEY (`cod_pedido`) REFERENCES `pedido` (`cod_pedido`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

#
# Structure for table "pizza"
#

CREATE TABLE `pizza` (
  `cod_pizza` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `sabor` varchar(50) NOT NULL DEFAULT '' COMMENT 'ex: CALABRESA',
  `preco` float(4,2) NOT NULL DEFAULT '0.00',
  `tipo` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'SALGADA (0) OU DOCE (1)',
  PRIMARY KEY (`cod_pizza`),
  UNIQUE KEY `sabor` (`sabor`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

#
# Structure for table "pedido_tem_massa_pizza"
#

CREATE TABLE `pedido_tem_massa_pizza` (
  `cod_pedido` int(11) unsigned NOT NULL DEFAULT '0',
  `cod_massa` int(11) unsigned NOT NULL DEFAULT '0',
  `cod_pizza` int(11) unsigned NOT NULL DEFAULT '0',
  `observacoes` varchar(200) DEFAULT NULL,
  `quantidade` int(11) NOT NULL DEFAULT '1',
  `valor` decimal(6,2) DEFAULT NULL,
  PRIMARY KEY (`cod_pedido`,`cod_massa`,`cod_pizza`),
  KEY `cod_massa` (`cod_massa`),
  KEY `cod_pizza` (`cod_pizza`),
  CONSTRAINT `pedido_tem_massa_pizza_ibfk_1` FOREIGN KEY (`cod_pedido`) REFERENCES `pedido` (`cod_pedido`),
  CONSTRAINT `pedido_tem_massa_pizza_ibfk_2` FOREIGN KEY (`cod_massa`) REFERENCES `massa` (`cod_massa`),
  CONSTRAINT `pedido_tem_massa_pizza_ibfk_3` FOREIGN KEY (`cod_pizza`) REFERENCES `pizza` (`cod_pizza`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

#
# Structure for table "pizza_possui_ingrediente"
#

CREATE TABLE `pizza_possui_ingrediente` (
  `cod_pizza` int(11) unsigned NOT NULL DEFAULT '0',
  `cod_ingrediente` int(11) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`cod_pizza`,`cod_ingrediente`),
  KEY `cod_ingrediente` (`cod_ingrediente`),
  CONSTRAINT `pizza_possui_ingrediente_ibfk_1` FOREIGN KEY (`cod_pizza`) REFERENCES `pizza` (`cod_pizza`),
  CONSTRAINT `pizza_possui_ingrediente_ibfk_2` FOREIGN KEY (`cod_ingrediente`) REFERENCES `ingrediente` (`cod_ingrediente`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

#
# Structure for table "usuario"
#

CREATE TABLE `usuario` (
  `cod_usuario` int(11) NOT NULL AUTO_INCREMENT,
  `login` varchar(25) NOT NULL DEFAULT '',
  `senha` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`cod_usuario`),
  UNIQUE KEY `login` (`login`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

#
# Trigger "aft_upd_pedido"
#

CREATE DEFINER='root'@'localhost' TRIGGER `pizzaria`.`aft_upd_pedido` AFTER UPDATE ON `pizzaria`.`pedido`
  FOR EACH ROW BEGIN
     delete from entregador_entrega_pedido where cod_pedido=old.cod_pedido;
     delete from pedido_tem_massa_pizza where cod_pedido=old.cod_pedido;
END;

#
# Trigger "bef_del_cliente"
#

CREATE DEFINER='root'@'localhost' TRIGGER `pizzaria`.`bef_del_cliente` BEFORE DELETE ON `pizzaria`.`cliente`
  FOR EACH ROW BEGIN
     delete from pedido where cod_cliente=old.cod_cliente;
END;

#
# Trigger "bef_del_endereco"
#

CREATE DEFINER='root'@'localhost' TRIGGER `pizzaria`.`bef_del_endereco` BEFORE DELETE ON `pizzaria`.`endereco`
  FOR EACH ROW BEGIN
     delete from cliente where cep=old.cep;
END;

#
# Trigger "bef_del_fornecedor"
#

CREATE DEFINER='root'@'localhost' TRIGGER `pizzaria`.`bef_del_fornecedor` BEFORE DELETE ON `pizzaria`.`fornecedor`
  FOR EACH ROW BEGIN
     delete from fornecedor_fornece_ingrediente where cod_fornecedor=old.cod_fornecedor;
END;

#
# Trigger "bef_del_ingrediente"
#

CREATE DEFINER='root'@'localhost' TRIGGER `pizzaria`.`bef_del_ingrediente` BEFORE DELETE ON `pizzaria`.`ingrediente`
  FOR EACH ROW BEGIN
     delete from massa_contem_ingrediente where cod_ingrediente=old.cod_ingrediente;
     delete from pizza_possui_ingrediente where cod_ingrediente=old.cod_ingrediente;
     delete from fornecedor_fornece_ingrediente where cod_ingrediente=old.cod_ingrediente;
END;

#
# Trigger "bef_del_massa"
#

CREATE DEFINER='root'@'localhost' TRIGGER `pizzaria`.`bef_del_massa` BEFORE DELETE ON `pizzaria`.`massa`
  FOR EACH ROW BEGIN
     delete from massa_contem_ingrediente where cod_massa=old.cod_massa;
     delete from pedido_tem_massa_pizza where cod_massa=old.cod_massa;
END;

#
# Trigger "bef_del_pedido"
#

CREATE DEFINER='root'@'localhost' TRIGGER `pizzaria`.`bef_del_pedido` BEFORE DELETE ON `pizzaria`.`pedido`
  FOR EACH ROW BEGIN
     delete from entregador_entrega_pedido where cod_pedido=old.cod_pedido;
     delete from pedido_tem_massa_pizza where cod_pedido=old.cod_pedido;
END;

#
# Trigger "bef_del_pizza"
#

CREATE DEFINER='root'@'localhost' TRIGGER `pizzaria`.`bef_del_pizza` BEFORE DELETE ON `pizzaria`.`pizza`
  FOR EACH ROW BEGIN
     delete from pizza_possui_ingrediente where cod_pizza=old.cod_pizza;
     delete from pedido_tem_massa_pizza where cod_pizza=old.cod_pizza;
END;
