#  Sistema de Biblioteca em PL/SQL

Sistema educacional completo de gerenciamento de empréstimos de livros implementado em PL/SQL/Oracle, demonstrando conceitos avançados de banco de dados.

---

##  Estrutura do Projeto

```
biblioteca/
├── 01_DDL/              # Definição de estrutura de dados
│   ├── 01_tabelas.sql   # Criação das 3 tabelas principais
│   └── 02_sequences.sql # Sequences para geração de IDs
├── 02_DML/              # Inserção de dados
│   └── 01_seeds.sql     # Dados iniciais + bloco PL/SQL de demonstração
├── 03_BLOCOS/           # Blocos anônimos PL/SQL
│   ├── excecoes.sql     # Tratamento de exceções customizadas
│   └── Loops_Cursores.sql # Loops com cursores explícitos e FOR cursores
├── 04_SUBPROGRAMAS/     # Procedures e Functions
│   ├── procedures.sql   # Procedure: registrar_emprestimo
│   └── funcoes.sql      # Function: calcular_multa
└── Packages/            # Packages (Spec + Body)
    └── pkg_biblioteca_spec.sql # Package encapsulando toda lógica
```

---

##  Modelo de Dados

### Tabelas

#### **LIVROS**
- `id_livro`: Identificador único (PK)
- `titulo`: Nome do livro (obrigatório, até 200 caracteres)
- `autor`: Nome do autor
- `ano`: Ano de publicação (até 4 dígitos)
- `disponivel`: Status do livro ('S'=disponível, 'N'=emprestado)

#### **MEMBROS**
- `id_membro`: Identificador único (PK)
- `nome`: Nome completo do membro
- `email`: Endereço de email
- `data_cadastro`: Quando foi cadastrado (padrão: data atual)

#### **EMPRESTIMOS**
- `id_emprestimo`: Identificador único (PK)
- `id_livro`: Referência ao livro (FK)
- `id_membro`: Referência ao membro (FK)
- `data_saida`: Data do empréstimo (padrão: data atual)
- `data_prevista`: Data de devolução prevista
- `data_retorno`: Data real de devolução (NULL enquanto não devolver)

### Relacionamentos
- Um **membro** pode ter vários **empréstimos**
- Um **livro** pode estar em vários **empréstimos** (ao longo do tempo)
- Cada **empréstimo** conecta exatamente um membro a um livro

---

##  Conceitos PL/SQL Demonstrados

### 01_DDL - Definição de Dados
- ✅ Criação de tabelas com constraints (PRIMARY KEY, FOREIGN KEY)
- ✅ Tipos de dados: NUMBER, VARCHAR2, CHAR, DATE
- ✅ Valores padrão (DEFAULT)
- ✅ Criação de SEQUENCES para IDs auto-incrementados

### 02_DML - Manipulação de Dados
- ✅ INSERT de registros
- ✅ COMMIT (persistência de dados)
- ✅ **%TYPE** - Herança de tipos das colunas
- ✅ SELECT INTO - Recuperação de dados em variáveis
- ✅ IF/ELSIF/ELSE - Estruturas condicionais
- ✅ CASE - Expressão condicional compacta

### 03_BLOCOS - Blocos Anônimos

#### **excecoes.sql**
- ✅ DECLARE de variáveis e exceções customizadas
- ✅ PRAGMA EXCEPTION_INIT - Mapear códigos de erro
- ✅ SELECT INTO com tratamento de NO_DATA_FOUND
- ✅ RAISE_APPLICATION_ERROR - Lançar erros controlados
- ✅ EXCEPTION - Captura com WHEN específicos e WHEN OTHERS
- ✅ SQLERRM - Recuperar mensagem de erro

#### **Loops_Cursores.sql**
- ✅ CURSOR explícito com SELECT
- ✅ **%ROWTYPE** - Tipo de registro herdado do cursor
- ✅ OPEN, FETCH, CLOSE manual
- ✅ EXIT WHEN com %NOTFOUND
- ✅ FOR cursor - Loop implícito automático

### 04_SUBPROGRAMAS - Procedures e Functions

#### **procedures.sql**
- ✅ Parâmetros IN, OUT
- ✅ Parâmetros com valor DEFAULT
- ✅ FOR UPDATE - Bloqueio de linhas
- ✅ MAX + NVL - Lógica de ID sequencial
- ✅ Múltiplas operações em transação
- ✅ COMMIT e ROLLBACK

#### **funcoes.sql**
- ✅ Function com RETURN
- ✅ GREATEST - Função de maior valor
- ✅ ROUND - Arredondamento de casas decimais
- ✅ Cálculo de multa por atraso (R$ 2,50 por dia)

### Packages - Encapsulamento
- ✅ PACKAGE SPEC - Interface pública
- ✅ PACKAGE BODY - Implementação privada
- ✅ Variáveis privadas (g_total_operacoes)
- ✅ Constantes (c_multa_dia)
- ✅ Múltiplas procedures e functions
- ✅ JOINs com 3 tabelas (Membros + Livros + Empréstimos)
- ✅ Loops com SELECT dinâmicos (FOR rec IN SELECT)

---

##  Como Usar

### 1. Criar a Estrutura
Execute na sequência:
```sql
-- Criar tabelas
@01_DDL/01_tabelas.sql

-- Criar sequences
@01_DDL/02_sequences.sql

-- Inserir dados iniciais
@02_DML/01_seeds.sql
```

### 2. Testar Blocos Isolados
```sql
-- Testar tratamento de exceções
@03_BLOCOS/excecoes.sql

-- Testar cursores
@03_BLOCOS/Loops_Cursores.sql
```

### 3. Usar o Package
```sql
-- Criar package
@Packages/pkg_biblioteca_spec.sql

-- Registrar um empréstimo
BEGIN
  pkg_biblioteca.registrar_emprestimo(
    p_id_livro  => 1,
    p_id_membro => 1,
    p_dias      => 14
  );
END;
/

-- Listar empréstimos em aberto
BEGIN
  pkg_biblioteca.listar_em_aberto;
END;
/

-- Devolver um livro
BEGIN
  pkg_biblioteca.devolver_livro(p_id_emp => 1);
END;
/
```

---

## Dados Iniciais

### Livros
| ID | Título | Autor | Ano | Status |
|----|--------|-------|-----|--------|
| 1 | Clean Code | Robert Martin | 2008 | Disponível |
| 2 | O Hobbit | Tolkien | 1937 | Disponível |
| 3 | 1984 | George Orwell | 1949 | Emprestado |

### Membros
| ID | Nome | Email |
|----|------|-------|
| 1 | Igor | igor@email.com |
| 2 | Ana | ana@email.com |

---

##  Conceitos Estudados



- **Modelagem Relacional**: Tabelas, chaves primárias, chaves estrangeiras
- **Integridade de Dados**: Constraints e validações
- **Transações**: COMMIT, ROLLBACK, consistência ACID
- **Controle de Concorrência**: FOR UPDATE, bloqueios pessimistas
- **Tratamento de Erros**: Exceções predefinidas e customizadas
- **Cursores**: Manipulação de conjuntos de dados
- **Modularização**: Procedures, Functions, Packages
- **Encapsulamento**: Separação entre interface (SPEC) e implementação (BODY)
- **Queries Avançadas**: JOINs, subqueries, funções de agregação
- **Lógica de Negócio**: Cálculo de multas, controle de disponibilidade

---

##  Notas Importantes

1. **Sequences**: As sequences começam em números altos (4, 3, 1) para evitar conflito com dados iniciais inseridos manualmente
2. **Multa**: Calculada como R$ 2,50 por dia de atraso (função `calcular_multa`)
3. **Lock**: `FOR UPDATE` é usado para evitar race conditions (dois usuários pegando o mesmo livro)
4. **NVL em Multa**: Se o livro ainda não foi devolvido, usa a data atual (SYSDATE) para calcular atraso




Sistema desenvolvido para fins educacionais em PL/SQL/Oracle.
