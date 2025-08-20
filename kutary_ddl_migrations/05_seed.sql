-- 05_seed.sql - dados básicos
SET search_path = kutary, public;

INSERT INTO papel (nome, descricao) VALUES
    ('Agente', 'Agente de monitoramento local'),
    ('Lideranca', 'Liderança comunitária'),
    ('Analista', 'Analista COIAB'),
    ('Coordenador', 'Coordenação COIAB')
ON CONFLICT (nome) DO NOTHING;

-- Categorias exemplo (preencher de acordo com a taxonomia final)
INSERT INTO categoria (dominio, nome, descricao) VALUES
    ('MONITORAMENTO', 'Aldeia atual', 'Localização atual da aldeia'),
    ('MONITORAMENTO', 'Área sagrada', 'Locais sagrados'),
    ('CADEIA', 'Roça ou Plantação', 'Atividade agrícola'),
    ('CENSO', 'Grupo ou Etnia', 'Informações demográficas'),
    ('ALERTA', 'Desmatamento', 'Detecção de desmatamento')
ON CONFLICT DO NOTHING;
