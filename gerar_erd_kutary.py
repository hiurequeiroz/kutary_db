# Fix graphviz rendering by using a base filename without extension and rendering twice (PNG and PDF).
from graphviz import Digraph

base = "kutary_erd_v1"

g = Digraph("kutary_erd", format="png")
g.attr(rankdir="LR", fontsize="12")

def entity(name, fields):
    # Create a simple text label instead of HTML
    label_lines = [name]
    label_lines.extend(fields)
    label = "\\n".join(label_lines)
    g.node(name, label=label, shape="box")

# Entities
entity("Usuario", [
    "usuario_id (PK)",
    "nome",
    "username",
    "email",
    "senha_hash",
    "telefone",
    "idioma_pref",
    "etnia_id (FK)",
    "organizacao_id (FK)",
    "ativo",
    "criado_em, atualizado_em",
])

entity("Papel", [
    "papel_id (PK)",
    "nome (Agente, Lideranca, Analista, Coord.)",
    "descricao"
])

entity("UsuarioPapel", [
    "usuario_id (FK)",
    "papel_id (FK)",
    "PRIMARY KEY (usuario_id, papel_id)"
])

entity("Organizacao", [
    "organizacao_id (PK)",
    "nome",
    "tipo (NACIONAL/REGIONAL/LOCAL)",
    "parent_id (FK -> Organizacao)",
    "sigla, uf",
    "criado_em"
])

entity("Territorio", [
    "territorio_id (PK)",
    "nome",
    "codigo_oficial",
    "organizacao_id (FK)",
    "geom (POLYGON/MULTI)",
    "criado_em"
])

entity("Aldeia", [
    "aldeia_id (PK)",
    "territorio_id (FK)",
    "nome",
    "geom (POINT/POLYGON)",
    "criado_em"
])

entity("Etnia", [
    "etnia_id (PK)",
    "nome",
    "codigo_oficial"
])

entity("LocalEvento", [
    "local_evento_id (PK)",
    "territorio_id (FK)",
    "aldeia_id (FK, NULL)",
    "titulo",
    "descricao",
    "geom (POINT)",
    "elevacao",
    "referencias"
])

entity("Categoria", [
    "categoria_id (PK)",
    "dominio (MONITORAMENTO/CADEIA/CENSO/ALERTA)",
    "nome",
    "descricao",
    "ativo"
])

entity("Coleta", [
    "coleta_id (PK)",
    "tipo (MONITORAMENTO/CADEIA/CENSO/ALERTA)",
    "categoria_id (FK)",
    "usuario_id (FK)",
    "organizacao_id (FK)",
    "territorio_id (FK)",
    "aldeia_id (FK, NULL)",
    "etnia_id (FK, NULL)",
    "local_evento_id (FK, NULL)",
    "geom (POINT/POLYGON)",
    "elevacao",
    "descricao",
    "referencias",
    "data_evento",
    "criado_em, atualizado_em"
])

entity("ColetaMidia", [
    "coleta_midia_id (PK)",
    "coleta_id (FK)",
    "uri_arquivo",
    "mime_type",
    "tamanho_bytes",
    "hash_conteudo"
])

entity("StatusColeta", [
    "status_coleta_id (PK)",
    "nome (RASCUNHO, ENVIADO, EM_ANALISE, VALIDADO, PUBLICADO)"
])

entity("HistoricoStatus", [
    "historico_status_id (PK)",
    "coleta_id (FK)",
    "status_coleta_id (FK)",
    "responsavel_id (FK Usuario, NULL)",
    "observacao",
    "momento"
])

entity("Validacao", [
    "validacao_id (PK)",
    "coleta_id (FK)",
    "validador_id (FK Usuario)",
    "parecer",
    "momento"
])

entity("Notificacao", [
    "notificacao_id (PK)",
    "coleta_id (FK, NULL)",
    "destinatario_id (FK Usuario)",
    "titulo",
    "mensagem",
    "lida (bool)",
    "criado_em"
])

entity("ItemPaneiro", [
    "item_paneiro_id (PK)",
    "dono_id (FK Usuario)",
    "coleta_id (FK)",
    "tipo (RASCUNHO/ENVIADO/SALVO)",
    "criado_em"
])

entity("Consentimento", [
    "consentimento_id (PK)",
    "usuario_id (FK)",
    "finalidade",
    "escopo (CENSO/GERAL)",
    "dado_sensivel (bool)",
    "concedido_em",
    "expira_em (NULL)"
])

entity("CensoRegistro", [
    "censo_registro_id (PK)",
    "coleta_id (FK)",
    "agregado_id (FK, NULL)",
    "atributos_json (criptografado)"
])

entity("Sincronizacao", [
    "sincronizacao_id (PK)",
    "coleta_id (FK)",
    "estado (PENDENTE/ERRO/SINCRONIZADO)",
    "tentativas",
    "ultimo_erro",
    "atualizado_em"
])

# Relationships
edges = [
    ("UsuarioPapel","Usuario"),
    ("UsuarioPapel","Papel"),
    ("Usuario","Organizacao"),
    ("Organizacao","Organizacao"),  # parent
    ("Territorio","Organizacao"),
    ("Aldeia","Territorio"),
    ("Usuario","Etnia"),
    ("LocalEvento","Territorio"),
    ("LocalEvento","Aldeia"),
    ("Coleta","Categoria"),
    ("Coleta","Usuario"),
    ("Coleta","Organizacao"),
    ("Coleta","Territorio"),
    ("Coleta","Aldeia"),
    ("Coleta","Etnia"),
    ("Coleta","LocalEvento"),
    ("ColetaMidia","Coleta"),
    ("HistoricoStatus","Coleta"),
    ("HistoricoStatus","StatusColeta"),
    ("HistoricoStatus","Usuario"),
    ("Validacao","Coleta"),
    ("Validacao","Usuario"),
    ("Notificacao","Coleta"),
    ("Notificacao","Usuario"),
    ("ItemPaneiro","Usuario"),
    ("ItemPaneiro","Coleta"),
    ("Consentimento","Usuario"),
    ("CensoRegistro","Coleta"),
    ("Sincronizacao","Coleta"),
]

for a,b in edges:
    g.edge(a, b, arrowhead="normal")

png_path = g.render(filename=base, format="png", cleanup=True)
pdf_path = g.render(filename=base, format="pdf", cleanup=True)

png_path, pdf_path
