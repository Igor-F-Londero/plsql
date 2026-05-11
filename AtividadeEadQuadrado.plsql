-- Criação da tabela
CREATE TABLE Quadrados (
    id         INTEGER PRIMARY KEY,
    lado       NUMBER,
    perimetro  NUMBER,
    area       NUMBER
);

-- Sequence para gerar IDs automáticos
CREATE SEQUENCE Quadrados_seq
START WITH 1
INCREMENT BY 1;

-- Procedure
CREATE OR REPLACE PROCEDURE insereQuadrado (
    p_lado IN NUMBER
)
IS
    v_perimetro NUMBER;
    v_area NUMBER;
BEGIN
    -- cálculos
    v_perimetro := p_lado * 4;
    v_area := p_lado * p_lado;

    -- inserção
    INSERT INTO Quadrados (
        id,
        lado,
        perimetro,
        area
    )
    VALUES (
        Quadrados_seq.NEXTVAL,
        p_lado,
        v_perimetro,
        v_area
    );


END;
/