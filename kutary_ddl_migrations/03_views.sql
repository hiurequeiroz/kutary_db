-- 03_views.sql
SET search_path = kutary, public;

-- Último status da coleta (para facilitar dashboards)
CREATE OR REPLACE VIEW v_coleta_status_atual AS
SELECT hs.coleta_id,
       (ARRAY_AGG(hs.status ORDER BY hs.momento DESC))[1] AS status_atual,
       (ARRAY_AGG(hs.momento ORDER BY hs.momento DESC))[1] AS atualizado_em
FROM historico_status hs
GROUP BY hs.coleta_id;

-- Coletas "públicas" (ajuste regras conforme política LGPD/RLS)
CREATE OR REPLACE VIEW v_coletas_publicas AS
SELECT c.coleta_id, c.tipo, c.categoria_id, cat.nome AS categoria_nome,
       c.territorio_id, t.nome AS territorio_nome,
       c.aldeia_id, a.nome AS aldeia_nome,
       c.etnia_id, e.nome AS etnia_nome,
       c.geom, c.data_evento, c.descricao,
       vs.status_atual
FROM coleta c
JOIN categoria cat ON cat.categoria_id = c.categoria_id
JOIN territorio t   ON t.territorio_id = c.territorio_id
LEFT JOIN aldeia a  ON a.aldeia_id = c.aldeia_id
LEFT JOIN etnia e   ON e.etnia_id = c.etnia_id
LEFT JOIN v_coleta_status_atual vs ON vs.coleta_id = c.coleta_id;

-- GeoJSON pronto para consumo de APIs (cada linha = Feature)
CREATE OR REPLACE VIEW v_coletas_geojson AS
SELECT c.coleta_id,
       jsonb_build_object(
         'type','Feature',
         'geometry', ST_AsGeoJSON(c.geom)::jsonb,
         'properties', jsonb_build_object(
             'tipo', c.tipo,
             'categoria', cat.nome,
             'territorio', t.nome,
             'aldeia', a.nome,
             'etnia', e.nome,
             'data_evento', to_char(c.data_evento, 'YYYY-MM-DD"T"HH24:MI:SSOF'),
             'status', vs.status_atual
         )
       ) AS feature
FROM coleta c
JOIN categoria cat ON cat.categoria_id = c.categoria_id
JOIN territorio t   ON t.territorio_id = c.territorio_id
LEFT JOIN aldeia a  ON a.aldeia_id = c.aldeia_id
LEFT JOIN etnia e   ON e.etnia_id = c.etnia_id
LEFT JOIN v_coleta_status_atual vs ON vs.coleta_id = c.coleta_id;

-- Painel: contagem por organização/território/categoria/status
CREATE OR REPLACE VIEW v_painel_status AS
SELECT o.organizacao_id, o.nome AS organizacao,
       t.territorio_id, t.nome AS territorio,
       cat.categoria_id, cat.nome AS categoria,
       vs.status_atual,
       COUNT(*) AS total
FROM coleta c
JOIN organizacao o ON o.organizacao_id = c.organizacao_id
JOIN territorio t  ON t.territorio_id = c.territorio_id
JOIN categoria cat ON cat.categoria_id = c.categoria_id
LEFT JOIN v_coleta_status_atual vs ON vs.coleta_id = c.coleta_id
GROUP BY o.organizacao_id, o.nome, t.territorio_id, t.nome, cat.categoria_id, cat.nome, vs.status_atual;
