-- ============================================================================
-- SGF - Sistema de Gestão de Frotas | Dados de demonstração
-- ============================================================================
USE sgf_frotas;

INSERT INTO pacotes (codigo, nome, responsavel) VALUES
('1B2', 'Pacote 1B2 - Rede Coletora Sul', 'Eng. Marcos Lima'),
('1C',  'Pacote 1C - Interceptor Leste', 'Eng. Fernanda Reis'),
('4A',  'Pacote 4A - Estação Elevatória', 'Eng. Paulo Andrade'),
('4B',  'Pacote 4B - Rede Coletora Norte', 'Eng. Camila Souza');

INSERT INTO motoristas (nome, cnh, categoria_cnh, pacote_id) VALUES
('Jefferson Paluzzi', '12345678901', 'D', 4),
('Carlos Eduardo Santos', '23456789012', 'B', 1),
('Renato Alves Costa', '34567890123', 'D', 2),
('Bruno Ferreira Lima', '45678901234', 'B', 3),
('Diego Martins Rocha', '56789012345', 'D', 4);

INSERT INTO veiculos (placa, modelo, marca, ano_fabricacao, tipo, pacote_id, motorista_id, km_atual, status, tag_veloe, tag_sem_parar) VALUES
('FLT1A23', 'Saveiro', 'Volkswagen', 2021, 'utilitario', 1, 2, 58200, 'operando', 'VLE-001', 'SP-001'),
('FLT2B45', 'Strada', 'Fiat', 2022, 'utilitario', 2, 3, 41230, 'operando', 'VLE-002', 'SP-002'),
('FLT3C67', 'Hilux', 'Toyota', 2020, 'utilitario', 3, 4, 89340, 'manutencao', 'VLE-003', 'SP-003'),
('FLT4D89', 'Onix', 'Chevrolet', 2023, 'leve', 4, 1, 15600, 'operando', 'VLE-004', 'SP-004'),
('FLT5E12', 'Master', 'Renault', 2019, 'utilitario', 4, 5, 132400, 'sinistro', 'VLE-005', 'SP-005');

INSERT INTO manutencoes (veiculo_id, tipo, descricao, data_agendada, data_conclusao, km_na_manutencao, oficina, custo, status) VALUES
(1, 'preventiva', 'Troca de óleo e filtros', '2026-08-10', '2026-08-10', 58000, 'Oficina Central', 380.00, 'concluida'),
(3, 'corretiva', 'Reparo sistema de freios', '2026-09-05', NULL, 89300, 'Oficina Toyota Norte', 1250.00, 'em_andamento'),
(2, 'preventiva', 'Revisão 40.000 km', '2026-09-15', NULL, 41200, 'Oficina Fiat Sul', NULL, 'agendada'),
(4, 'preventiva', 'Alinhamento e balanceamento', '2026-09-20', NULL, 15600, 'Oficina Central', NULL, 'agendada');

INSERT INTO abastecimentos (veiculo_id, data_abast, litros, valor_litro, valor_total, km_no_abast, posto) VALUES
(1, '2026-08-20', 45.5, 5.89, 268.05, 58000, 'Posto Ipiranga BR-116'),
(2, '2026-08-21', 38.2, 5.79, 221.16, 41100, 'Posto Shell Marginal'),
(4, '2026-08-25', 32.0, 5.95, 190.40, 15500, 'Posto Ipiranga BR-116'),
(5, '2026-08-18', 60.0, 5.85, 351.00, 132200, 'Posto Petrobras Rodoanel');

INSERT INTO pedagios (veiculo_id, data_passagem, praca, valor) VALUES
(1, '2026-08-20', 'Praça Régis Bittencourt', 14.80),
(2, '2026-08-22', 'Praça Anchieta', 12.30),
(4, '2026-08-26', 'Praça Bandeirantes', 11.50);

INSERT INTO multas (veiculo_id, motorista_id, data_infracao, descricao, valor, pontos, status) VALUES
(3, 4, '2026-07-15', 'Excesso de velocidade até 20%', 130.16, 4, 'paga'),
(5, 5, '2026-08-02', 'Estacionamento irregular', 88.38, 3, 'pendente');

INSERT INTO sinistros (veiculo_id, motorista_id, data_ocorrencia, descricao, oficina, seguradora, custo_reparo, data_retorno_op, status) VALUES
(5, 5, '2026-08-28', 'Colisão traseira em manobra de ré', 'Oficina Renault Autorizada', 'Porto Seguro', 4200.00, NULL, 'em_reparo');
