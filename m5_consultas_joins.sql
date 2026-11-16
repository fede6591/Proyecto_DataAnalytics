USE Ventas_Tech_DB;
GO

-- === CONSULTA 1: Vista base del proyecto (INNER JOIN) ===
-- Propósito: una fila por venta con cliente, ciudad, producto, categoría, cantidad, precio y total.
-- Es la fuente de datos principal para Power BI: ciudad y categoría sirven para agrupar y filtrar.
SELECT
    v.fecha_venta,
    c.id_cliente,
    c.nombre                         AS nombre_cliente,
    c.ciudad,
    p.nombre_producto,
    cat.nombre_categoria,
    v.cantidad,
    v.precio_unitario,
    v.cantidad * v.precio_unitario   AS total_venta
FROM ventas AS v
INNER JOIN clientes   AS c   ON v.id_cliente   = c.id_cliente
INNER JOIN productos  AS p   ON v.id_producto  = p.id_producto
INNER JOIN categorias AS cat ON p.id_categoria = cat.id_categoria
ORDER BY v.fecha_venta, v.id_venta;
-- Hallazgo: devuelve las 10 ventas completas, sin perder ni duplicar ninguna, con un total de 6.444.
-- Buenos Aires es la ciudad que más factura (2.640, el 41,0%) y Computación la categoría líder (4.950, el 76,8%).

-- === CONSULTA 2: Clientes sin ventas (LEFT JOIN) ===
-- Propósito: detectar clientes registrados que nunca compraron, para que CRM los contacte.
SELECT
    c.nombre,
    c.email,
    c.fecha_registro
FROM clientes AS c
LEFT JOIN ventas AS v ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL;
-- Hallazgo: 0 de los 5 clientes registrados nunca compraron: todos hicieron 2 pedidos.
-- Para CRM no hay clientes inactivos que contactar en esta base, el foco pasa a retener a los recurrentes.

-- === CONSULTA 3: Productos sin ventas (LEFT JOIN) ===
-- Propósito: identificar artículos del catálogo sin movimiento, para que el área de producto los revise.
SELECT
    p.nombre_producto,
    cat.nombre_categoria,
    p.precio
FROM productos AS p
LEFT JOIN categorias AS cat ON p.id_categoria = cat.id_categoria
LEFT JOIN ventas     AS v   ON p.id_producto  = v.id_producto
WHERE v.id_venta IS NULL;
-- Hallazgo: 0 de los 6 productos del catálogo están sin ventas: todos tuvieron movimiento.
-- Para producto no hay artículos para liquidar, y el de menor facturación es Auriculares BT Pro (360).

-- === CONSULTA 4: Consolidado por canal (UNION ALL) ===
-- Propósito: comparar la facturación de dos tramos del mes.
-- La columna canal no existe en las tablas: se crea como valor literal dentro de cada SELECT.
SELECT canal, SUM(total) AS total_canal
FROM (
    SELECT fecha_venta, cantidad * precio_unitario AS total, 'Inicio de mes (1-10)' AS canal
    FROM ventas
    WHERE fecha_venta <= '2024-03-10'
    UNION ALL
    SELECT fecha_venta, cantidad * precio_unitario AS total, 'Resto del mes (11-31)' AS canal
    FROM ventas
    WHERE fecha_venta > '2024-03-10'
) AS consolidado
GROUP BY canal
ORDER BY total_canal DESC;
-- Hallazgo: cada tramo tiene 5 ventas, pero el inicio de mes factura 3.620 (56,2%) contra 2.824 (43,8%) del resto.
-- La diferencia se explica por la venta de 2 laptops del 5 de marzo, que por sí sola suma 2.400.
GO