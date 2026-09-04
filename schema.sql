-- ============================================================================
-- SGF - Sistema de Gestão de Frotas
-- Schema relacional | Compatível com PostgreSQL e MySQL 8+
-- Autor: Gustavo | Baseado em processos reais de gestão de frota
--         (Consórcio Saneamento - 4 pacotes de obra, ~60 veículos)
-- ============================================================================

-- Em PostgreSQL, remova "AUTO_INCREMENT" e use "SERIAL"/"GENERATED ALWAYS AS IDENTITY".
-- As instruções abaixo estão no dialeto MySQL; ao final há a versão PostgreSQL equivalente.

CREATE DATABASE IF NOT EXISTS sgf_frotas;
USE sgf_frotas;

-- ----------------------------------------------------------------------------
-- 1. PACOTES (frentes de obra / contratos do consórcio)
-- ----------------------------------------------------------------------------
CREATE TABLE pacotes (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    codigo          VARCHAR(10) NOT NULL UNIQUE,        -- ex: 1B2, 1C, 4A, 4B
    nome            VARCHAR(100) NOT NULL,
    responsavel     VARCHAR(100),
    ativo           BOOLEAN NOT NULL DEFAULT TRUE
);

-- ----------------------------------------------------------------------------
-- 2. MOTORISTAS
-- ----------------------------------------------------------------------------
CREATE TABLE motoristas (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    nome            VARCHAR(120) NOT NULL,
    cnh             VARCHAR(20) UNIQUE,
    categoria_cnh   VARCHAR(5),
    pacote_id       INT,
    ativo           BOOLEAN NOT NULL DEFAULT TRUE,
    FOREIGN KEY (pacote_id) REFERENCES pacotes(id)
);

-- ----------------------------------------------------------------------------
-- 3. VEÍCULOS
-- ----------------------------------------------------------------------------
CREATE TABLE veiculos (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    placa           VARCHAR(8) NOT NULL UNIQUE,
    modelo          VARCHAR(60) NOT NULL,
    marca           VARCHAR(40),
    ano_fabricacao  SMALLINT,
    tipo            ENUM('leve','utilitario','caminhao','maquinario') DEFAULT 'leve',
    pacote_id       INT NOT NULL,
    motorista_id    INT,
    km_atual        INT DEFAULT 0,
    status          ENUM('operando','manutencao','sinistro','baixado') DEFAULT 'operando',
    tag_veloe       VARCHAR(20),      -- identificador do abastecimento
    tag_sem_parar   VARCHAR(20),      -- identificador do pedágio
    FOREIGN KEY (pacote_id) REFERENCES pacotes(id),
    FOREIGN KEY (motorista_id) REFERENCES motoristas(id)
);

-- ----------------------------------------------------------------------------
-- 4. MANUTENÇÕES (preventivas e corretivas)
-- ----------------------------------------------------------------------------
CREATE TABLE manutencoes (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    veiculo_id          INT NOT NULL,
    tipo                ENUM('preventiva','corretiva') NOT NULL,
    descricao           VARCHAR(255),
    data_agendada       DATE NOT NULL,
    data_conclusao      DATE,
    km_na_manutencao    INT,
    oficina             VARCHAR(100),
    custo               DECIMAL(10,2) DEFAULT 0,
    status              ENUM('agendada','em_andamento','concluida','cancelada') DEFAULT 'agendada',
    FOREIGN KEY (veiculo_id) REFERENCES veiculos(id)
);

-- ----------------------------------------------------------------------------
-- 5. ABASTECIMENTOS (Veloe)
-- ----------------------------------------------------------------------------
CREATE TABLE abastecimentos (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    veiculo_id      INT NOT NULL,
    data_abast      DATE NOT NULL,
    litros          DECIMAL(6,2) NOT NULL,
    valor_litro     DECIMAL(6,3),
    valor_total     DECIMAL(10,2) NOT NULL,
    km_no_abast     INT,
    posto           VARCHAR(100),
    FOREIGN KEY (veiculo_id) REFERENCES veiculos(id)
);

-- ----------------------------------------------------------------------------
-- 6. PEDÁGIOS (Sem Parar)
-- ----------------------------------------------------------------------------
CREATE TABLE pedagios (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    veiculo_id      INT NOT NULL,
    data_passagem   DATE NOT NULL,
    praca           VARCHAR(100),
    valor           DECIMAL(8,2) NOT NULL,
    FOREIGN KEY (veiculo_id) REFERENCES veiculos(id)
);

-- ----------------------------------------------------------------------------
-- 7. MULTAS
-- ----------------------------------------------------------------------------
CREATE TABLE multas (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    veiculo_id      INT NOT NULL,
    motorista_id    INT,
    data_infracao   DATE NOT NULL,
    descricao       VARCHAR(255),
    valor           DECIMAL(10,2) NOT NULL,
    pontos          TINYINT,
    status          ENUM('pendente','paga','recorrida') DEFAULT 'pendente',
    FOREIGN KEY (veiculo_id) REFERENCES veiculos(id),
    FOREIGN KEY (motorista_id) REFERENCES motoristas(id)
);

-- ----------------------------------------------------------------------------
-- 8. SINISTROS / INCIDENTES
-- ----------------------------------------------------------------------------
CREATE TABLE sinistros (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    veiculo_id          INT NOT NULL,
    motorista_id        INT,
    data_ocorrencia     DATE NOT NULL,
    descricao           VARCHAR(255),
    oficina             VARCHAR(100),
    seguradora          VARCHAR(100),
    custo_reparo        DECIMAL(10,2),
    data_retorno_op     DATE,
    status              ENUM('em_reparo','concluido','em_analise') DEFAULT 'em_analise',
    FOREIGN KEY (veiculo_id) REFERENCES veiculos(id),
    FOREIGN KEY (motorista_id) REFERENCES motoristas(id)
);

-- ----------------------------------------------------------------------------
-- ÍNDICES para consultas frequentes
-- ----------------------------------------------------------------------------
CREATE INDEX idx_veiculos_pacote ON veiculos(pacote_id);
CREATE INDEX idx_manutencoes_veiculo ON manutencoes(veiculo_id, status);
CREATE INDEX idx_abastecimentos_veiculo_data ON abastecimentos(veiculo_id, data_abast);
CREATE INDEX idx_multas_status ON multas(status);

-- ============================================================================
-- VIEWS analíticas (demonstram uso de SQL para tomada de decisão)
-- ============================================================================

-- Custo total por pacote (combustível + pedágio + manutenção + multas)
CREATE VIEW vw_custo_por_pacote AS
SELECT
    p.codigo AS pacote,
    COALESCE(SUM(a.valor_total), 0)  AS custo_combustivel,
    COALESCE(SUM(pe.valor), 0)       AS custo_pedagio,
    COALESCE(SUM(m.custo), 0)        AS custo_manutencao,
    COALESCE(SUM(mu.valor), 0)       AS custo_multas
FROM pacotes p
LEFT JOIN veiculos v        ON v.pacote_id = p.id
LEFT JOIN abastecimentos a  ON a.veiculo_id = v.id
LEFT JOIN pedagios pe       ON pe.veiculo_id = v.id
LEFT JOIN manutencoes m     ON m.veiculo_id = v.id AND m.status = 'concluida'
LEFT JOIN multas mu         ON mu.veiculo_id = v.id
GROUP BY p.codigo;

-- Veículos com manutenção preventiva vencida ou próxima (30 dias)
CREATE VIEW vw_manutencoes_proximas AS
SELECT
    v.placa, v.modelo, p.codigo AS pacote,
    m.tipo, m.data_agendada, m.status,
    DATEDIFF(m.data_agendada, CURDATE()) AS dias_restantes
FROM manutencoes m
JOIN veiculos v ON v.id = m.veiculo_id
JOIN pacotes p ON p.id = v.pacote_id
WHERE m.status IN ('agendada','em_andamento')
  AND m.data_agendada <= DATE_ADD(CURDATE(), INTERVAL 30 DAY)
ORDER BY m.data_agendada ASC;

-- Ranking de veículos por custo total (identifica veículos "problema")
CREATE VIEW vw_ranking_custo_veiculo AS
SELECT
    v.placa, v.modelo, p.codigo AS pacote,
    COALESCE(SUM(a.valor_total),0) + COALESCE(SUM(m.custo),0) + COALESCE(SUM(mu.valor),0) AS custo_total
FROM veiculos v
JOIN pacotes p ON p.id = v.pacote_id
LEFT JOIN abastecimentos a ON a.veiculo_id = v.id
LEFT JOIN manutencoes m ON m.veiculo_id = v.id AND m.status = 'concluida'
LEFT JOIN multas mu ON mu.veiculo_id = v.id
GROUP BY v.id
ORDER BY custo_total DESC;
