# Kutary — Pacote DDL + Migrações (PostgreSQL + PostGIS)

**Gerado em:** 2025-08-12T11:44:55.114642

## Estrutura
- `00_init.sql` — cria schema, extensões e tipos ENUM.
- `01_tables.sql` — cria todas as tabelas e chaves estrangeiras.
- `02_indexes.sql` — índices GIST (espaciais) e BTREE.
- `03_views.sql` — views para status atual, público, GeoJSON e painel.
- `04_rls.sql` — esqueleto de RLS (políticas de exemplo; ajustar ao seu IAM).
- `05_seed.sql` — papéis e categorias iniciais (exemplos).

## Como aplicar
```bash
# 1) criar banco (se ainda não existir)
createdb kutary_db

# 2) aplicar migrações na ordem:
psql -d kutary_db -f 00_init.sql
psql -d kutary_db -f 01_tables.sql
psql -d kutary_db -f 02_indexes.sql
psql -d kutary_db -f 03_views.sql
psql -d kutary_db -f 04_rls.sql   # opcional, revise políticas
psql -d kutary_db -f 05_seed.sql
```

> **SRID**: 4326 (WGS84). Ajuste se necessário para outro referencial.
> **LGPD**: Dados de Censo e atributos sensíveis devem ser controlados via RLS e minimização de campos. Considere criptografia na aplicação.

## Integração com frameworks
- **Django**: use `django.contrib.gis` com `PostGIS`. Converta os ENUMs para `models.TextChoices` ou instale pacote de ENUM PostgreSQL.
- **Alembic (SQLAlchemy)**: gere migrações a partir de modelos; ainda assim mantenha estes SQLs como baseline.
- **Hasura/PostgREST**: proveja `current_setting('app.organizacao_id')` na sessão para ativar políticas RLS por organização.

## Próximos passos sugeridos
1. Completar **taxonomias** (categorias, etnias, organizações) com listas oficiais.
2. Implementar **workflow de validação** do status (inserindo em `historico_status`).
3. Expor `v_coletas_geojson` numa API para mapas (ou servir via GeoServer).
