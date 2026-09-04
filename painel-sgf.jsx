import React, { useState, useMemo } from "react";
import {
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer,
} from "recharts";
import { Truck, Wrench, AlertTriangle, Fuel, ChevronRight, Gauge } from "lucide-react";

// ---------------------------------------------------------------------------
// Dados de demonstração — estrutura espelha o schema.sql (pacotes, veiculos,
// manutencoes, abastecimentos, multas, sinistros)
// ---------------------------------------------------------------------------
const PACOTES = [
  { codigo: "1B2", nome: "Rede Coletora Sul", cor: "#F2A93B" },
  { codigo: "1C", nome: "Interceptor Leste", cor: "#3E8E93" },
  { codigo: "4A", nome: "Estação Elevatória", cor: "#6FA97C" },
  { codigo: "4B", nome: "Rede Coletora Norte", cor: "#D96B4F" },
];

const VEICULOS = [
  { placa: "FLT1A23", modelo: "Saveiro", pacote: "1B2", motorista: "Carlos E. Santos", km: 58200, status: "operando" },
  { placa: "FLT2B45", modelo: "Strada", pacote: "1C", motorista: "Renato A. Costa", km: 41230, status: "operando" },
  { placa: "FLT3C67", modelo: "Hilux", pacote: "4A", motorista: "Bruno F. Lima", km: 89340, status: "manutencao" },
  { placa: "FLT4D89", modelo: "Onix", pacote: "4B", motorista: "Carlos E. Santos", km: 15600, status: "operando" },
  { placa: "FLT5E12", modelo: "Master", pacote: "4B", motorista: "Diego M. Rocha", km: 132400, status: "sinistro" },
];

const MANUTENCOES = [
  { placa: "FLT3C67", tipo: "Corretiva", descricao: "Reparo sistema de freios", data: "05/09", dias: 2, status: "em_andamento" },
  { placa: "FLT2B45", tipo: "Preventiva", descricao: "Revisão 40.000 km", data: "15/09", dias: 12, status: "agendada" },
  { placa: "FLT4D89", tipo: "Preventiva", descricao: "Alinhamento e balanceamento", data: "20/09", dias: 17, status: "agendada" },
];

const SINISTROS = [
  { placa: "FLT5E12", descricao: "Colisão traseira em manobra de ré", oficina: "Oficina Renault Autorizada", seguradora: "Porto Seguro", custo: 4200, status: "em_reparo" },
];

const CUSTO_POR_PACOTE = [
  { pacote: "1B2", combustivel: 268, pedagio: 15, manutencao: 380, multas: 0 },
  { pacote: "1C", combustivel: 221, pedagio: 12, manutencao: 0, multas: 0 },
  { pacote: "4A", combustivel: 0, pedagio: 0, manutencao: 1250, multas: 130 },
  { pacote: "4B", combustivel: 541, pedagio: 12, manutencao: 0, multas: 88 },
];

const STATUS_META = {
  operando: { label: "Operando", color: "#6FA97C" },
  manutencao: { label: "Em manutenção", color: "#F2A93B" },
  sinistro: { label: "Sinistro", color: "#D96B4F" },
};

function fmtBRL(v) {
  return v.toLocaleString("pt-BR", { style: "currency", currency: "BRL", maximumFractionDigits: 0 });
}

export default function PainelSGF() {
  const [filtroPacote, setFiltroPacote] = useState("todos");

  const veiculosFiltrados = useMemo(
    () => (filtroPacote === "todos" ? VEICULOS : VEICULOS.filter(v => v.pacote === filtroPacote)),
    [filtroPacote]
  );

  const totalVeiculos = VEICULOS.length;
  const emOperacao = VEICULOS.filter(v => v.status === "operando").length;
  const manutencoesPendentes = MANUTENCOES.length;
  const custoTotalMes = CUSTO_POR_PACOTE.reduce(
    (acc, p) => acc + p.combustivel + p.pedagio + p.manutencao + p.multas, 0
  );

  return (
    <div style={{
      fontFamily: "'IBM Plex Sans', sans-serif",
      background: "#14181C",
      color: "#EDEAE3",
      minHeight: "100vh",
      padding: "32px 24px",
    }}>
      <style>{`
        @import url('https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@500;700&family=IBM+Plex+Sans:wght@400;500;600&family=IBM+Plex+Mono:wght@500&display=swap');
        * { box-sizing: border-box; }
        .sgf-tab { transition: background .15s ease, color .15s ease; }
        .sgf-row:hover { background: #232A31 !important; }
      `}</style>

      {/* Header */}
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-end", flexWrap: "wrap", gap: 16, marginBottom: 28 }}>
        <div>
          <div style={{ display: "flex", alignItems: "center", gap: 10, color: "#F2A93B", fontSize: 13, fontWeight: 600, letterSpacing: 0.3, marginBottom: 6 }}>
            <Truck size={16} strokeWidth={2.2} />
            SGF · SISTEMA DE GESTÃO DE FROTAS
          </div>
          <h1 style={{ fontFamily: "'Space Grotesk', sans-serif", fontSize: 28, fontWeight: 700, margin: 0 }}>
            Consórcio Saneamento — visão geral da frota
          </h1>
        </div>
        <div style={{ display: "flex", gap: 6, background: "#1D2329", padding: 4, borderRadius: 8 }}>
          {["todos", ...PACOTES.map(p => p.codigo)].map(cod => (
            <button
              key={cod}
              onClick={() => setFiltroPacote(cod)}
              className="sgf-tab"
              style={{
                border: "none", cursor: "pointer", padding: "7px 14px", borderRadius: 6,
                fontFamily: "'IBM Plex Mono', monospace", fontSize: 13,
                background: filtroPacote === cod ? "#F2A93B" : "transparent",
                color: filtroPacote === cod ? "#14181C" : "#8B93A0",
                fontWeight: 500,
              }}
            >
              {cod === "todos" ? "Todos" : cod}
            </button>
          ))}
        </div>
      </div>

      {/* KPIs */}
      <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(180px, 1fr))", gap: 14, marginBottom: 28 }}>
        {[
          { label: "Veículos na frota", value: totalVeiculos, icon: Truck, color: "#3E8E93" },
          { label: "Em operação", value: emOperacao, icon: Gauge, color: "#6FA97C" },
          { label: "Manutenções pendentes", value: manutencoesPendentes, icon: Wrench, color: "#F2A93B" },
          { label: "Custo do mês", value: fmtBRL(custoTotalMes), icon: Fuel, color: "#D96B4F" },
        ].map(kpi => (
          <div key={kpi.label} style={{ background: "#1D2329", borderRadius: 10, padding: "18px 18px", borderLeft: `3px solid ${kpi.color}` }}>
            <kpi.icon size={18} color={kpi.color} style={{ marginBottom: 10 }} />
            <div style={{ fontFamily: "'Space Grotesk', sans-serif", fontSize: 24, fontWeight: 700 }}>{kpi.value}</div>
            <div style={{ fontSize: 12.5, color: "#8B93A0", marginTop: 2 }}>{kpi.label}</div>
          </div>
        ))}
      </div>

      <div style={{ display: "grid", gridTemplateColumns: "1.5fr 1fr", gap: 20 }}>
        {/* Tabela de veículos */}
        <div style={{ background: "#1D2329", borderRadius: 10, padding: 20 }}>
          <h2 style={{ fontFamily: "'Space Grotesk', sans-serif", fontSize: 15, margin: "0 0 14px" }}>Veículos {filtroPacote !== "todos" && `— Pacote ${filtroPacote}`}</h2>
          <div style={{ fontSize: 13 }}>
            <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr 1fr 1fr 1fr", padding: "6px 10px", color: "#8B93A0", fontSize: 11.5, textTransform: "uppercase", letterSpacing: 0.4 }}>
              <div>Placa</div><div>Modelo</div><div>Pacote</div><div>Motorista</div><div>Status</div>
            </div>
            {veiculosFiltrados.map(v => (
              <div key={v.placa} className="sgf-row" style={{ display: "grid", gridTemplateColumns: "1fr 1fr 1fr 1fr 1fr", padding: "10px 10px", borderTop: "1px solid #262D34", alignItems: "center" }}>
                <div style={{ fontFamily: "'IBM Plex Mono', monospace" }}>{v.placa}</div>
                <div>{v.modelo}</div>
                <div style={{ color: "#8B93A0" }}>{v.pacote}</div>
                <div>{v.motorista}</div>
                <div>
                  <span style={{ background: `${STATUS_META[v.status].color}22`, color: STATUS_META[v.status].color, padding: "3px 9px", borderRadius: 20, fontSize: 11.5, fontWeight: 500 }}>
                    {STATUS_META[v.status].label}
                  </span>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Coluna direita: manutenções + sinistros */}
        <div style={{ display: "flex", flexDirection: "column", gap: 20 }}>
          <div style={{ background: "#1D2329", borderRadius: 10, padding: 20 }}>
            <h2 style={{ fontFamily: "'Space Grotesk', sans-serif", fontSize: 15, margin: "0 0 14px" }}>Próximas manutenções</h2>
            {MANUTENCOES.map(m => (
              <div key={m.placa + m.data} style={{ display: "flex", justifyContent: "space-between", alignItems: "center", padding: "9px 0", borderTop: "1px solid #262D34" }}>
                <div>
                  <div style={{ fontSize: 13.5 }}>{m.descricao}</div>
                  <div style={{ fontSize: 11.5, color: "#8B93A0", fontFamily: "'IBM Plex Mono', monospace" }}>{m.placa} · {m.tipo}</div>
                </div>
                <div style={{ textAlign: "right" }}>
                  <div style={{ fontSize: 12.5, color: m.dias <= 3 ? "#D96B4F" : "#8B93A0" }}>{m.data}</div>
                  <div style={{ fontSize: 11, color: "#8B93A0" }}>{m.dias}d</div>
                </div>
              </div>
            ))}
          </div>

          <div style={{ background: "#1D2329", borderRadius: 10, padding: 20 }}>
            <h2 style={{ fontFamily: "'Space Grotesk', sans-serif", fontSize: 15, margin: "0 0 14px", display: "flex", alignItems: "center", gap: 8 }}>
              <AlertTriangle size={15} color="#D96B4F" /> Sinistros em aberto
            </h2>
            {SINISTROS.map(s => (
              <div key={s.placa} style={{ fontSize: 13 }}>
                <div style={{ fontFamily: "'IBM Plex Mono', monospace", color: "#D96B4F", marginBottom: 4 }}>{s.placa}</div>
                <div style={{ marginBottom: 4 }}>{s.descricao}</div>
                <div style={{ color: "#8B93A0", fontSize: 12 }}>{s.oficina} · {s.seguradora}</div>
                <div style={{ marginTop: 6, fontSize: 12.5 }}>Custo estimado: <b>{fmtBRL(s.custo)}</b></div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Gráfico de custo por pacote */}
      <div style={{ background: "#1D2329", borderRadius: 10, padding: 20, marginTop: 20 }}>
        <h2 style={{ fontFamily: "'Space Grotesk', sans-serif", fontSize: 15, margin: "0 0 14px" }}>Custo por pacote (mês atual)</h2>
        <ResponsiveContainer width="100%" height={220}>
          <BarChart data={CUSTO_POR_PACOTE}>
            <CartesianGrid strokeDasharray="3 3" stroke="#262D34" vertical={false} />
            <XAxis dataKey="pacote" stroke="#8B93A0" fontSize={12} />
            <YAxis stroke="#8B93A0" fontSize={12} tickFormatter={v => `R$${v}`} />
            <Tooltip
              contentStyle={{ background: "#232A31", border: "none", borderRadius: 8, fontSize: 12.5 }}
              formatter={(v, name) => [fmtBRL(v), name]}
            />
            <Bar dataKey="combustivel" stackId="a" fill="#3E8E93" name="Combustível" radius={[0,0,0,0]} />
            <Bar dataKey="pedagio" stackId="a" fill="#6FA97C" name="Pedágio" />
            <Bar dataKey="manutencao" stackId="a" fill="#F2A93B" name="Manutenção" />
            <Bar dataKey="multas" stackId="a" fill="#D96B4F" name="Multas" radius={[4,4,0,0]} />
          </BarChart>
        </ResponsiveContainer>
      </div>

      <div style={{ marginTop: 24, fontSize: 12, color: "#5C636B", display: "flex", alignItems: "center", gap: 6 }}>
        <ChevronRight size={13} /> Dados de demonstração — estrutura alinhada ao schema relacional em schema.sql
      </div>
    </div>
  );
}
