-- 02_indexes.sql
SET search_path = kutary, public;

-- Índices espaciais
CREATE INDEX IF NOT EXISTS territorio_gix ON territorio USING GIST (geom);
CREATE INDEX IF NOT EXISTS aldeia_gix ON aldeia USING GIST (geom);
CREATE INDEX IF NOT EXISTS local_evento_gix ON local_evento USING GIST (geom);
CREATE INDEX IF NOT EXISTS coleta_gix ON coleta USING GIST (geom);

-- Índices por chaves estrangeiras e campos de filtro comuns
CREATE INDEX IF NOT EXISTS idx_usuario_org ON usuario (organizacao_id);
CREATE INDEX IF NOT EXISTS idx_territorio_org ON territorio (organizacao_id);
CREATE INDEX IF NOT EXISTS idx_aldeia_territorio ON aldeia (territorio_id);

CREATE INDEX IF NOT EXISTS idx_coleta_categoria ON coleta (categoria_id);
CREATE INDEX IF NOT EXISTS idx_coleta_usuario ON coleta (usuario_id);
CREATE INDEX IF NOT EXISTS idx_coleta_org ON coleta (organizacao_id);
CREATE INDEX IF NOT EXISTS idx_coleta_territorio ON coleta (territorio_id);
CREATE INDEX IF NOT EXISTS idx_coleta_data_evento ON coleta (data_evento);
CREATE INDEX IF NOT EXISTS idx_hist_status_coleta ON historico_status (coleta_id, momento DESC);
CREATE INDEX IF NOT EXISTS idx_notif_destinatario ON notificacao (destinatario_id, lida);

-- Consultas por tipo/status
CREATE INDEX IF NOT EXISTS idx_coleta_tipo ON coleta (tipo);
CREATE INDEX IF NOT EXISTS idx_cat_dominio ON categoria (dominio);
