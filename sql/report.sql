CREATE OR REPLACE FUNCTION абоненты_с_задолженностью(
    начало_периода date,
    количество_месяцев int4
)

RETURNS TABLE (
    абонент text,
    месяцев_оплачено bigint,
    дата_последнего_платежа date,
    сумма_последнего_платежа int4
)

LANGUAGE sql
STABLE
AS $$
    WITH абоненты AS (
        SELECT id, 'ф' AS тип, фио AS имя FROM физические_лица
        UNION ALL
        SELECT id, 'ю' AS тип, наименование AS имя FROM юридические_лица
    ), платежи_периода AS (
        SELECT физическое_лицо AS id, 'ф' AS тип, сумма, дата
        FROM платежи
        WHERE физическое_лицо IS NOT NULL
          AND дата >= начало_периода
          AND дата < начало_периода + make_interval(months => количество_месяцев)
        UNION ALL
        SELECT юридическое_лицо AS id, 'ю' AS тип, сумма, дата
        FROM платежи
        WHERE юридическое_лицо IS NOT NULL
          AND дата >= начало_периода
          AND дата < начало_периода + make_interval(months => количество_месяцев)
    ), итоги AS (
        SELECT а.id, а.тип, а.имя,
               count(DISTINCT date_trunc('month', п.дата)) AS оплачено,
               max(п.дата) AS последняя_дата
        FROM абоненты а
        LEFT JOIN платежи_периода п ON п.id = а.id AND п.тип = а.тип
        GROUP BY а.id, а.тип, а.имя
        HAVING count(DISTINCT date_trunc('month', п.дата)) < количество_месяцев
    )

    SELECT и.имя, и.оплачено, и.последняя_дата, п.сумма
    FROM итоги и
    LEFT JOIN платежи_периода п
        ON п.id = и.id AND п.тип = и.тип AND п.дата = и.последняя_дата;
$$;
