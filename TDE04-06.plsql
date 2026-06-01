--Faça a leitura do arquivo e conforme seu entendimento descreva em um parágrafo (até 10 linhas) a finalidade de Cursores no Oracle

/*  
    Em alguns casos é preciso de espaços de armazenamento mais complexos que variáveis, nesses casos utilizamos cursores.
    Estes cursores permitem definir  e inicializar tabelas armazenadas somente em memória. Com eles é possivel armazenar um conjunto de linhas e percorrer dados linha a linha.Podem ser explícitos e implícitos, o PLSQL declara um cursor implicitamente para toda instrução DML, incluindo consultas de uma linha,  explícitos são indicados quando é necessário um controle no processamento do mesmo. Declarar um cursor com DECLARE, abrir com OPEN, extrair dados com FETCH, fechar com CLOSE. Atributos do cursor explícito quando anexados retornam informações uteis sobre a execução de uma instrução .LOOP simples são usados para processamento do cursor, os atributos explícitos são usados para controlar as vezes que o LOOP é executado.
    LOOP for trata implícitamente o processamento do cursor.

*/ 

