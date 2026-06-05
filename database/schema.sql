-- ═══════════════════════════════════════════════════════════
--  CENTRAL DA TURMA — Schema + Seed
--  7º Ano · 2026
--  Execute: psql -U postgres -d central_turma -f database/schema.sql
-- ═══════════════════════════════════════════════════════════

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ── TIPOS ENUM ──────────────────────────────────────────────
DO $$ BEGIN
  CREATE TYPE role_enum AS ENUM (
    'dev',           -- Desenvolvedor (nível 5)
    'ajudante_dev',  -- Ajudante de Desenvolvimento (nível 4)
    'lider',         -- Líder da Sala (nível 3)
    'sub_lider',     -- Vice-líder da Sala (nível 2)
    'aluno'          -- Aluno (nível 1)
  );
  CREATE TYPE aviso_tipo    AS ENUM ('geral', 'urgente', 'lembrete');
  CREATE TYPE material_tipo AS ENUM ('pdf', 'imagem', 'video', 'link', 'outro');
  CREATE TYPE evento_tipo   AS ENUM ('escolar', 'social', 'entrega', 'outro');
EXCEPTION WHEN duplicate_object THEN null; END $$;

-- ── TURMAS ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS turmas (
  id        SERIAL PRIMARY KEY,
  nome      VARCHAR(100) NOT NULL,
  codigo    VARCHAR(20)  UNIQUE NOT NULL,
  criado_em TIMESTAMPTZ  DEFAULT NOW()
);

-- ── USUÁRIOS ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS usuarios (
  id         SERIAL PRIMARY KEY,
  nome       VARCHAR(150) NOT NULL,
  usuario    VARCHAR(50)  UNIQUE NOT NULL,
  senha_hash TEXT         NOT NULL,
  role       role_enum    NOT NULL DEFAULT 'aluno',
  iniciais   VARCHAR(5),
  turma_id   INT REFERENCES turmas(id) ON DELETE SET NULL,
  criado_em  TIMESTAMPTZ  DEFAULT NOW()
);

-- ── AVISOS ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS avisos (
  id        SERIAL PRIMARY KEY,
  titulo    VARCHAR(200) NOT NULL,
  corpo     TEXT         NOT NULL,
  tipo      aviso_tipo   NOT NULL DEFAULT 'geral',
  autor_id  INT REFERENCES usuarios(id) ON DELETE SET NULL,
  turma_id  INT REFERENCES turmas(id)   ON DELETE CASCADE,
  criado_em TIMESTAMPTZ  DEFAULT NOW()
);

-- ── MATERIAIS ───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS materiais (
  id          SERIAL PRIMARY KEY,
  nome        VARCHAR(200)  NOT NULL,
  disciplina  VARCHAR(100)  NOT NULL,
  tipo        material_tipo NOT NULL DEFAULT 'outro',
  tamanho     BIGINT,
  url_arquivo TEXT          NOT NULL,
  enviado_por INT REFERENCES usuarios(id) ON DELETE SET NULL,
  turma_id    INT REFERENCES turmas(id)   ON DELETE CASCADE,
  criado_em   TIMESTAMPTZ   DEFAULT NOW()
);

-- ── RESUMOS ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS resumos (
  id         SERIAL PRIMARY KEY,
  titulo     VARCHAR(200) NOT NULL,
  disciplina VARCHAR(100) NOT NULL,
  corpo      TEXT         NOT NULL,
  autor_id   INT REFERENCES usuarios(id) ON DELETE SET NULL,
  turma_id   INT REFERENCES turmas(id)   ON DELETE CASCADE,
  curtidas   INT          NOT NULL DEFAULT 0,
  criado_em  TIMESTAMPTZ  DEFAULT NOW()
);

-- ── CURTIDAS ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS curtidas_resumo (
  usuario_id INT REFERENCES usuarios(id) ON DELETE CASCADE,
  resumo_id  INT REFERENCES resumos(id)  ON DELETE CASCADE,
  criado_em  TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (usuario_id, resumo_id)
);

-- ── PROVAS ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS provas (
  id         SERIAL PRIMARY KEY,
  disciplina VARCHAR(100) NOT NULL,
  data       DATE         NOT NULL,
  horario    VARCHAR(50),
  conteudo   TEXT,
  turma_id   INT REFERENCES turmas(id) ON DELETE CASCADE,
  criado_em  TIMESTAMPTZ DEFAULT NOW()
);

-- ── EVENTOS ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS eventos (
  id        SERIAL PRIMARY KEY,
  titulo    VARCHAR(200) NOT NULL,
  data      DATE         NOT NULL,
  tipo      evento_tipo  NOT NULL DEFAULT 'outro',
  descricao TEXT,
  turma_id  INT REFERENCES turmas(id) ON DELETE CASCADE,
  criado_em TIMESTAMPTZ DEFAULT NOW()
);

-- ── ÍNDICES ─────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_avisos_turma       ON avisos(turma_id, criado_em DESC);
CREATE INDEX IF NOT EXISTS idx_materiais_turma    ON materiais(turma_id, disciplina);
CREATE INDEX IF NOT EXISTS idx_resumos_turma      ON resumos(turma_id, disciplina);
CREATE INDEX IF NOT EXISTS idx_provas_turma_data  ON provas(turma_id, data);
CREATE INDEX IF NOT EXISTS idx_eventos_turma_data ON eventos(turma_id, data);

-- ═══════════════════════════════════════════════════════════
--  SEED
-- ═══════════════════════════════════════════════════════════

INSERT INTO turmas (nome, codigo) VALUES ('7º Ano', '7ANO-2026')
  ON CONFLICT (codigo) DO NOTHING;

-- Senhas: todos usam "123456"
-- hash bcrypt de "123456"
INSERT INTO usuarios (nome, usuario, senha_hash, role, iniciais, turma_id) VALUES
  ('Desenvolvedor',  'dev',           '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uAnc/IThW', 'dev',          'DV', 1),
  ('João Pedro',     'joao.pedro',    '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uAnc/IThW', 'lider',        'JP', 1),
  ('Maria Clara',    'maria.clara',   '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uAnc/IThW', 'sub_lider',    'MC', 1),
  ('Pedro Henrique', 'pedro.h',       '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uAnc/IThW', 'ajudante_dev', 'PH', 1),
  ('Lucas Oliveira', 'lucas.oliveira','$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uAnc/IThW', 'aluno',        'LO', 1),
  ('Ana Souza',      'ana.souza',     '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uAnc/IThW', 'aluno',        'AS', 1)
ON CONFLICT (usuario) DO NOTHING;

INSERT INTO avisos (titulo, corpo, tipo, autor_id, turma_id) VALUES
  ('📌 Trabalho de Ciências em grupo','Grupos de 3 pessoas. Tema: ecossistemas. Entrega: 25/06.','geral',    1, 1),
  ('📎 Gabarito de Matemática',       'Já disponibilizei o gabarito na seção de Materiais.',      'lembrete', 2, 1)
ON CONFLICT DO NOTHING;

INSERT INTO provas (disciplina, data, horario, conteudo, turma_id) VALUES
  ('Matemática','2026-06-10','1º período','Frações e equações de 1º grau', 1),
  ('Ciências',  '2026-06-17','2º período','Ecossistemas e fotossíntese',   1),
  ('Português', '2026-06-24','',          'Interpretação e gramática',     1),
  ('História',  '2026-07-01','',          'Colonização do Brasil',         1)
ON CONFLICT DO NOTHING;

INSERT INTO eventos (titulo, data, tipo, descricao, turma_id) VALUES
  ('Entrega — Trabalho de Ciências','2026-06-12','entrega','até 23h59',       1),
  ('Reunião de pais e mestres',     '2026-06-14','escolar','18h · Auditório', 1),
  ('Simulado bimestral',            '2026-06-20','escolar','Manhã toda',      1)
ON CONFLICT DO NOTHING;
