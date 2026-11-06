-- ENTREGA MODULO 4 - CONSULTAS SQL

-- Consulta 1: Resumen ejecutivo mensual
-- Total facturado, cantidad de pedidos y ticket promedio por mes.
SELECT
    MONTH(fecha_venta)                                      AS mes,
    SUM(cantidad * precio_unitario)                         AS total_facturado,
    COUNT(id_venta)                                         AS cantidad_pedidos,
    CAST(AVG(cantidad * precio_unitario) AS DECIMAL(12,2))  AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes;
 
-- Consulta 2: Ranking de productos (Top 5 por total facturado)
SELECT TOP 5
    id_producto,
    SUM(cantidad)                    AS unidades_vendidas,
    SUM(cantidad * precio_unitario)  AS total_generado
FROM ventas
GROUP BY id_producto
ORDER BY total_generado DESC;
 
-- Consulta 3: Clientes recurrentes (más de un pedido)
SELECT
    id_cliente,
    COUNT(*)                         AS cantidad_pedidos,
    SUM(cantidad * precio_unitario)  AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;
 
-- Consulta 4: Productos por encima / por debajo del promedio de facturación
-- El promedio se calcula sobre los totales por producto, no sobre las filas de ventas.
WITH facturacion_producto AS (
    SELECT
        id_producto,
        SUM(cantidad * precio_unitario) AS total_facturado
    FROM ventas
    GROUP BY id_producto
)
SELECT
    id_producto,
    total_facturado,
    CASE
        WHEN total_facturado > (SELECT AVG(total_facturado) FROM facturacion_producto)
            THEN 'Por encima'
        ELSE 'Por debajo'
    END AS posicion_vs_promedio
FROM facturacion_producto
ORDER BY total_facturado DESC;
GO
 
-- === HALLAZGOS ===
-- 1) El producto 1 concentra el 55,9% de la facturación (3.600 de 6.444) con solo 3 de las 29 unidades vendidas.
-- 2) El producto 2 es el más vendido por unidades (13 de 29, el 44,8%), pero aporta apenas el 5,6% de la facturación (364 de 6.444).
-- 3) Solo 2 de los 6 productos (el 1 y el 3, ambos de Computación) superan el promedio de facturación por producto (1.074); entre los dos suman el 76,8% del total.
 