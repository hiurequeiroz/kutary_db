-- 00_init.sql
-- Base inicial para PostgreSQL + PostGIS (recomendado PG >= 14, PostGIS >= 3)
-- Executar como superuser/owner do banco.

CREATE SCHEMA IF NOT EXISTS kutary;

-- Extensões necessárias
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Tipos ENUM usados no modelo
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'tipo_org') THEN
        CREATE TYPE kutary.tipo_org AS ENUM ('NACIONAL','REGIONAL','LOCAL');
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'dominio_categoria') THEN
        CREATE TYPE kutary.dominio_categoria AS ENUM ('MONITORAMENTO','CADEIA','CENSO','ALERTA');
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'tipo_coleta') THEN
        CREATE TYPE kutary.tipo_coleta AS ENUM ('MONITORAMENTO','CADEIA','CENSO','ALERTA');
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'status_coleta') THEN
        CREATE TYPE kutary.status_coleta AS ENUM ('RASCUNHO','ENVIADO','EM_ANALISE','VALIDADO','PUBLICADO');
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'estado_sincronizacao') THEN
        CREATE TYPE kutary.estado_sincronizacao AS ENUM ('PENDENTE','ERRO','SINCRONIZADO');
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'tipo_item_paneiro') THEN
        CREATE TYPE kutary.tipo_item_paneiro AS ENUM ('RASCUNHO','ENVIADO','SALVO');
    END IF;
END $$;
