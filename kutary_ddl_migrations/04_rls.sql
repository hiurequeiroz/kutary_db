-- 04_rls.sql (Row Level Security) - exemplo inicial
SET search_path = kutary, public;

-- Habilitar RLS nas tabelas sensíveis
ALTER TABLE coleta ENABLE ROW LEVEL SECURITY;
ALTER TABLE censo_registro ENABLE ROW LEVEL SECURITY;

-- Exemplo de políticas (AJUSTE para seu provedor de autenticação)
-- Supondo uma função current_setting('app.organizacao_id') para injetar o id do usuário logado
-- no início da sessão/tx. Altere conforme o seu stack (Django/Hasura/PostgREST/etc.).

-- Usuários podem ver coletas da sua organização (e subordinadas). Requer uma função recursiva
-- ou view que retorne organizacoes visíveis. Aqui um esqueleto simples de política por igualdade.
CREATE POLICY coleta_select_mesma_org
    ON coleta FOR SELECT
    USING (organizacao_id = current_setting('app.organizacao_id', true)::BIGINT);

-- Para Censo, restringir ainda mais (ex.: apenas analistas/validadores):
-- ALTER TABLE censo_registro FORCE ROW LEVEL SECURITY;
-- CREATE POLICY censo_apenas_analistas ON censo_registro FOR SELECT
-- USING ( current_setting('app.papel', true) = 'Analista' );
