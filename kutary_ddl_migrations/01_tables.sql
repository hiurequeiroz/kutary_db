-- 01_tables.sql
SET search_path = kutary, public;

-- ORGANIZACOES / ESTRUTURA
CREATE TABLE IF NOT EXISTS organizacao (
    organizacao_id      BIGSERIAL PRIMARY KEY,
    nome                TEXT NOT NULL,
    tipo                tipo_org NOT NULL,
    parent_id           BIGINT REFERENCES organizacao(organizacao_id) ON DELETE SET NULL,
    sigla               TEXT,
    uf                  TEXT,
    criado_em           TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS etnia (
    etnia_id            BIGSERIAL PRIMARY KEY,
    nome                TEXT NOT NULL UNIQUE,
    codigo_oficial      TEXT
);

CREATE TABLE IF NOT EXISTS territorio (
    territorio_id       BIGSERIAL PRIMARY KEY,
    nome                TEXT NOT NULL,
    codigo_oficial      TEXT,
    organizacao_id      BIGINT NOT NULL REFERENCES organizacao(organizacao_id) ON DELETE RESTRICT,
    geom                geometry(MultiPolygon, 4326),
    criado_em           TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS aldeia (
    aldeia_id           BIGSERIAL PRIMARY KEY,
    territorio_id       BIGINT NOT NULL REFERENCES territorio(territorio_id) ON DELETE CASCADE,
    nome                TEXT NOT NULL,
    geom                geometry(Geometry, 4326),
    criado_em           TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- USUARIOS E PAPEIS
CREATE TABLE IF NOT EXISTS usuario (
    usuario_id          BIGSERIAL PRIMARY KEY,
    nome                TEXT NOT NULL,
    username            TEXT NOT NULL UNIQUE,
    email               TEXT UNIQUE,
    senha_hash          TEXT NOT NULL,
    telefone            TEXT,
    idioma_pref         TEXT,
    etnia_id            BIGINT REFERENCES etnia(etnia_id) ON DELETE SET NULL,
    organizacao_id      BIGINT REFERENCES organizacao(organizacao_id) ON DELETE SET NULL,
    ativo               BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em           TIMESTAMPTZ NOT NULL DEFAULT now(),
    atualizado_em       TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS papel (
    papel_id            BIGSERIAL PRIMARY KEY,
    nome                TEXT NOT NULL UNIQUE,
    descricao           TEXT
);

CREATE TABLE IF NOT EXISTS usuario_papel (
    usuario_id          BIGINT NOT NULL REFERENCES usuario(usuario_id) ON DELETE CASCADE,
    papel_id            BIGINT NOT NULL REFERENCES papel(papel_id) ON DELETE CASCADE,
    PRIMARY KEY (usuario_id, papel_id)
);

-- LOCAIS / EVENTOS
CREATE TABLE IF NOT EXISTS local_evento (
    local_evento_id     BIGSERIAL PRIMARY KEY,
    territorio_id       BIGINT NOT NULL REFERENCES territorio(territorio_id) ON DELETE RESTRICT,
    aldeia_id           BIGINT REFERENCES aldeia(aldeia_id) ON DELETE SET NULL,
    titulo              TEXT NOT NULL,
    descricao           TEXT,
    geom                geometry(Point, 4326),
    elevacao            NUMERIC,
    referencias         TEXT
);

-- CATEGORIAS / COLETAS
CREATE TABLE IF NOT EXISTS categoria (
    categoria_id        BIGSERIAL PRIMARY KEY,
    dominio             dominio_categoria NOT NULL,
    nome                TEXT NOT NULL,
    descricao           TEXT,
    ativo               BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS coleta (
    coleta_id           BIGSERIAL PRIMARY KEY,
    tipo                tipo_coleta NOT NULL,
    categoria_id        BIGINT NOT NULL REFERENCES categoria(categoria_id) ON DELETE RESTRICT,
    usuario_id          BIGINT NOT NULL REFERENCES usuario(usuario_id) ON DELETE RESTRICT,
    organizacao_id      BIGINT NOT NULL REFERENCES organizacao(organizacao_id) ON DELETE RESTRICT,
    territorio_id       BIGINT NOT NULL REFERENCES territorio(territorio_id) ON DELETE RESTRICT,
    aldeia_id           BIGINT REFERENCES aldeia(aldeia_id) ON DELETE SET NULL,
    etnia_id            BIGINT REFERENCES etnia(etnia_id) ON DELETE SET NULL,
    local_evento_id     BIGINT REFERENCES local_evento(local_evento_id) ON DELETE SET NULL,
    geom                geometry(Geometry, 4326),
    elevacao            NUMERIC,
    descricao           TEXT,
    referencias         TEXT,
    data_evento         TIMESTAMPTZ,
    criado_em           TIMESTAMPTZ NOT NULL DEFAULT now(),
    atualizado_em       TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS coleta_midia (
    coleta_midia_id     BIGSERIAL PRIMARY KEY,
    coleta_id           BIGINT NOT NULL REFERENCES coleta(coleta_id) ON DELETE CASCADE,
    uri_arquivo         TEXT NOT NULL,
    mime_type           TEXT,
    tamanho_bytes       BIGINT,
    hash_conteudo       TEXT
);

CREATE TABLE IF NOT EXISTS historico_status (
    historico_status_id BIGSERIAL PRIMARY KEY,
    coleta_id           BIGINT NOT NULL REFERENCES coleta(coleta_id) ON DELETE CASCADE,
    status              status_coleta NOT NULL,
    responsavel_id      BIGINT REFERENCES usuario(usuario_id) ON DELETE SET NULL,
    observacao          TEXT,
    momento             TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS validacao (
    validacao_id        BIGSERIAL PRIMARY KEY,
    coleta_id           BIGINT NOT NULL REFERENCES coleta(coleta_id) ON DELETE CASCADE,
    validador_id        BIGINT NOT NULL REFERENCES usuario(usuario_id) ON DELETE RESTRICT,
    parecer             TEXT,
    momento             TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS notificacao (
    notificacao_id      BIGSERIAL PRIMARY KEY,
    coleta_id           BIGINT REFERENCES coleta(coleta_id) ON DELETE SET NULL,
    destinatario_id     BIGINT NOT NULL REFERENCES usuario(usuario_id) ON DELETE CASCADE,
    titulo              TEXT NOT NULL,
    mensagem            TEXT NOT NULL,
    lida                BOOLEAN NOT NULL DEFAULT FALSE,
    criado_em           TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS item_paneiro (
    item_paneiro_id     BIGSERIAL PRIMARY KEY,
    dono_id             BIGINT NOT NULL REFERENCES usuario(usuario_id) ON DELETE CASCADE,
    coleta_id           BIGINT NOT NULL REFERENCES coleta(coleta_id) ON DELETE CASCADE,
    tipo                tipo_item_paneiro NOT NULL,
    criado_em           TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS consentimento (
    consentimento_id    BIGSERIAL PRIMARY KEY,
    usuario_id          BIGINT NOT NULL REFERENCES usuario(usuario_id) ON DELETE CASCADE,
    finalidade          TEXT NOT NULL,
    escopo              TEXT NOT NULL CHECK (escopo IN ('CENSO','GERAL')),
    dado_sensivel       BOOLEAN NOT NULL DEFAULT FALSE,
    concedido_em        TIMESTAMPTZ NOT NULL DEFAULT now(),
    expira_em           TIMESTAMPTZ
);

-- Censo (atributos em JSONB; criptografia pode ser feita na aplicação)
CREATE TABLE IF NOT EXISTS censo_agregado (
    agregado_id         BIGSERIAL PRIMARY KEY,
    nome                TEXT
);

CREATE TABLE IF NOT EXISTS censo_registro (
    censo_registro_id   BIGSERIAL PRIMARY KEY,
    coleta_id           BIGINT NOT NULL UNIQUE REFERENCES coleta(coleta_id) ON DELETE CASCADE,
    agregado_id         BIGINT REFERENCES censo_agregado(agregado_id) ON DELETE SET NULL,
    atributos_json      JSONB NOT NULL DEFAULT '{}'::jsonb
);

CREATE TABLE IF NOT EXISTS sincronizacao (
    sincronizacao_id    BIGSERIAL PRIMARY KEY,
    coleta_id           BIGINT NOT NULL REFERENCES coleta(coleta_id) ON DELETE CASCADE,
    estado              estado_sincronizacao NOT NULL,
    tentativas          INT NOT NULL DEFAULT 0,
    ultimo_erro         TEXT,
    atualizado_em       TIMESTAMPTZ NOT NULL DEFAULT now()
);
