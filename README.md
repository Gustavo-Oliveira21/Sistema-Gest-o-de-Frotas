# SGF — Sistema de Gestão de Frotas

Projeto de portfólio inspirado na rotina real de gestão de frotas de um consórcio de saneamento (60 veículos distribuídos em 4 pacotes de obra), aplicando modelagem de banco de dados relacional e um painel de visualização de dados.

## Contexto

O projeto simula os processos que uma área de gestão de frotas administra no dia a dia:
- Controle de veículos, motoristas e pacotes/contratos
- Agendamento e histórico de manutenções (preventivas e corretivas)
- Abastecimento (Veloe) e pedágio (Sem Parar)
- Multas de trânsito
- Sinistros — do registro até o retorno do veículo à operação

## Stack

| Camada | Tecnologia |
|---|---|
| Banco de dados | SQL (MySQL 8 / PostgreSQL) |
| Modelagem | Schema relacional normalizado, 8 tabelas, views analíticas |
| Interface | React |
| Visualização de dados | Recharts |

## Estrutura do repositório

```
├── schema.sql        # DDL completo: tabelas, chaves estrangeiras, índices e views
├── seed_data.sql      # Dados de exemplo para popular o banco e testar as views
├── painel-sgf.jsx      # Dashboard React (KPIs, tabela de veículos, manutenções, custos)
└── README.md
```

## Modelo de dados

8 tabelas principais: `pacotes`, `motoristas`, `veiculos`, `manutencoes`, `abastecimentos`, `pedagios`, `multas`, `sinistros`.

3 views analíticas prontas para consumo por BI ou aplicação:
- `vw_custo_por_pacote` — custo consolidado (combustível + pedágio + manutenção + multas) por pacote
- `vw_manutencoes_proximas` — manutenções vencidas ou a vencer nos próximos 30 dias
- `vw_ranking_custo_veiculo` — ranking de veículos por custo total, para identificar veículos com custo de operação acima da média

## Como rodar o banco

```bash
mysql -u root -p < schema.sql
mysql -u root -p < seed_data.sql
```

Para PostgreSQL, adapte `AUTO_INCREMENT` para `GENERATED ALWAYS AS IDENTITY` e `ENUM` para `CHECK` constraints ou tipos `ENUM` nativos do Postgres.

## Painel (dashboard)

O `painel-sgf.jsx` consome dados no mesmo formato retornado pelas queries do banco (por veículo, por pacote, por status) e exibe:
- Indicadores gerais (veículos ativos, em operação, manutenções pendentes, custo do mês)
- Tabela de veículos filtrável por pacote
- Lista de próximas manutenções e sinistros em aberto
- Gráfico de custo por pacote, segmentado por categoria de gasto

## Sobre este projeto

Construído para consolidar conceitos de modelagem de dados e front-end aplicados a um problema real de gestão operacional, como parte da preparação para atuação em TI.
