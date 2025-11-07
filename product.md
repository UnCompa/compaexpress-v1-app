# CompaExpress

Gestion de negocio con facturación y caja simplificada.

## Producto

Aplicacion para gestion de productos de un negocio de manera simplificada. usando la nube de AWS para la logica, y flutter para la aplicacion.

## Modelos

- Negocio: Entidad que representa un negocio.
- Categoria: Entidad que representa una categoria de productos.
- Producto: Entidad que representa un producto.
- Factura: Entidad que representa una factura.
- ItemFactura: Entidad que representa un item de una factura.
- Orden: Entidad que representa una orden.
- ItemOrden: Entidad que representa un item de una orden.
- SesionDispositivo: Entidad que representa una sesion de un dispositivo.

## Nuevos modelos

- Caja: Gestiona el dinero de la caja por monto especifico (dinero en efectivo por moneda, Ej: 10 de $0.01, 5 de $0.05, 20 de $0.10, etc).
- CajaMovimiento: Gestiona los movimientos de la caja (ingresos y egresos).
- ProductoPrecios: Gestiona los precios de los productos (Por defecto debe haber una).
- CierreCaja: Gestiona el cierre de la caja (saldo final del dia, comparar con el saldo inicial).
- CierreCajaHistorial: Gestiona el historial de cierres de la caja.

## Modificaciones

- Factura: 
 - Agrega el campo cajaID para relacionar con la caja.
 - Agrega el campo cajaMovimientoID para relacionar con el movimiento de la caja.
 - Agrega el campo cierreCajaID para relacionar con el cierre de la caja.
 - Agrega el campo imagenFactura para guardar la imagen de la factura.
- Producto: 
 - Agrega el campo ofertaID para relacionar con la oferta.