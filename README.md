# Central da Turma — 7º Ano

Backend **Node.js + Express + PostgreSQL** para a Central da Turma do 7º Ano.

---

## Hierarquia de cargos

| Cargo              | Nível | Permissões                                  |
|--------------------|-------|---------------------------------------------|
| Desenvolvedor      | 5     | Tudo + criar contas                         |
| Ajudante de Dev    | 4     | Editar conteúdo (avisos, provas, materiais) |
| Líder da Sala      | 3     | Editar conteúdo + gerenciar membros         |
| Vice-líder da Sala | 2     | Editar conteúdo (avisos, provas, materiais) |
| Aluno              | 1     | Somente leitura + curtir resumos            |

---

## Passo a passo

### 1. Criar banco e rodar schema
```bash
psql -U postgres -c "CREATE DATABASE central_turma;"
psql -U postgres -d central_turma -f database/schema.sql
```

### 2. Configurar .env
```bash
cp .env.example .env
# edite DATABASE_URL e JWT_SECRET
```

### 3. Instalar e iniciar
```bash
npm install
npm start          # produção
npm run dev        # desenvolvimento (auto-reload)
```

### 4. Abrir o frontend
Abra `frontend/central-estudos.html` no navegador.
O `BASE_URL` já aponta para `http://localhost:3000`.

---

## Usuários de exemplo (senha: `123456`)

| Usuário          | Cargo              |
|------------------|--------------------|
| `dev`            | Desenvolvedor      |
| `joao.pedro`     | Líder da Sala      |
| `maria.clara`    | Vice-líder da Sala |
| `pedro.h`        | Ajudante de Dev    |
| `lucas.oliveira` | Aluno              |
| `ana.souza`      | Aluno              |

---

## Rotas da API

| Método | Rota                    | Acesso mínimo | Descrição                     |
|--------|-------------------------|---------------|-------------------------------|
| POST   | `/auth/login`           | público       | Login                         |
| GET    | `/auth/me`              | logado        | Usuário atual                 |
| POST   | `/auth/criar-conta`     | dev           | Criar nova conta              |
| GET    | `/avisos`               | logado        | Listar avisos                 |
| POST   | `/avisos`               | vice-líder+   | Criar aviso                   |
| DELETE | `/avisos/:id`           | vice-líder+   | Remover aviso                 |
| GET    | `/materiais`            | logado        | Listar materiais              |
| POST   | `/materiais`            | vice-líder+   | Upload de arquivo             |
| DELETE | `/materiais/:id`        | vice-líder+   | Remover material              |
| GET    | `/resumos`              | logado        | Listar resumos                |
| POST   | `/resumos`              | vice-líder+   | Criar resumo                  |
| POST   | `/resumos/:id/curtir`   | logado        | Toggle curtida                |
| DELETE | `/resumos/:id`          | vice-líder+   | Remover resumo                |
| GET    | `/provas`               | logado        | Listar provas                 |
| POST   | `/provas`               | vice-líder+   | Criar prova                   |
| DELETE | `/provas/:id`           | vice-líder+   | Remover prova                 |
| GET    | `/eventos`              | logado        | Listar eventos                |
| POST   | `/eventos`              | vice-líder+   | Criar evento                  |
| DELETE | `/eventos/:id`          | vice-líder+   | Remover evento                |
| GET    | `/membros`              | logado        | Listar membros                |
| PUT    | `/membros/:id`          | líder+        | Alterar cargo                 |
| DELETE | `/membros/:id`          | líder+        | Remover da turma              |

---

## Estrutura

```
central-turma/
├── .env                    ← suas variáveis
├── .env.example
├── package.json
├── database/
│   └── schema.sql          ← schema + seed
├── frontend/
│   └── central-estudos.html
└── backend/
    ├── server.js
    ├── db.js
    ├── config/database.js
    ├── middleware/
    │   ├── auth.js         ← auth + podeEditar + podeLiderar + soDev
    │   └── soAdmin.js      ← alias de compatibilidade
    └── routes/
        ├── auth.js         ← login + /me + criar-conta
        ├── avisos.js
        ├── materiais.js
        ├── resumos.js
        ├── provas.js
        ├── eventos.js
        └── membros.js
```
