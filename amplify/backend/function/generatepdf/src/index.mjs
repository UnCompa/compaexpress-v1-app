import { GetObjectCommand, PutObjectCommand, S3Client } from '@aws-sdk/client-s3';
import PDFDocument from 'pdfkit';

const s3Client = new S3Client();

export async function handler(event) {
   try {
      const { invoice, invoiceItems, negocio } = JSON.parse(event.body);

      if (!invoice || !invoiceItems || !negocio) {
         return {
            statusCode: 400,
            body: JSON.stringify({ error: 'Faltan datos de factura, ítems o negocio' }),
         };
      }
      if (!Array.isArray(invoiceItems) || invoiceItems.length === 0) {
         throw new Error('invoiceItems debe ser un arreglo no vacío');
      }
      invoiceItems.forEach((item, index) => {
         if (!item.subtotal || !item.quantity || item.quantity === 0) {
            throw new Error(`Item ${index + 1} tiene datos inválidos: subtotal o quantity faltante o quantity igual a 0`);
         }
         if (typeof item.subtotal !== 'number' || typeof item.quantity !== 'number') {
            throw new Error(`Item ${index + 1} tiene datos no numéricos`);
         }
      });
      if (typeof invoice.invoiceTotal !== 'number' || isNaN(invoice.invoiceTotal)) {
         throw new Error('invoiceTotal debe ser un número válido');
      }

      const doc = new PDFDocument({
         margin: 30,
         size: 'A4',
         bufferPages: true
      });
      // Configuraciones de layout
      const pageWidth = doc.page.width - 60;
      const leftColumn = 60;
      const rightColumn = 350;

      // Descargar y añadir el logo si existe
      if (negocio.logo) {
         try {
            const getObjectCommand = new GetObjectCommand({
               Bucket: process.env.S3_BUCKET,
               Key: negocio.logo
            });
            const { Body, ContentType } = await s3Client.send(getObjectCommand);
            if (!ContentType.startsWith('image/')) {
               throw new Error('El archivo del logo no es una imagen válida');
            }
            const logoBuffer = await new Promise((resolve, reject) => {
               const chunks = [];
               Body.on('data', (chunk) => chunks.push(chunk));
               Body.on('end', () => resolve(Buffer.concat(chunks)));
               Body.on('error', reject);
            });
            doc.image(logoBuffer, leftColumn, 30, { width: 100 });
         } catch (error) {
            console.error('Error al cargar el logo:', error);
         }
      }

      // ENCABEZADO PRINCIPAL
      doc.fontSize(18)
         .font('Helvetica-Bold')
         .text(negocio.nombre, leftColumn, negocio.logo ? 150 : 50, { width: 250 });

      // Información del negocio (lado izquierdo)
      doc.fontSize(10)
         .font('Helvetica')
         .text(negocio.representante || 'No especificado', leftColumn, negocio.logo ? 175 : 75)
         .text(negocio.direccion || 'No especificado', leftColumn, negocio.logo ? 190 : 90)
         .text(`Tel.: ${negocio.telefono || 'No especificado'}`, leftColumn, negocio.logo ? 205 : 105)
         .text(`Correo: ${negocio.correoElectronico || 'No especificado'}`, leftColumn, negocio.logo ? 220 : 120)
         .text(`${negocio.ciudad || 'No especificado'}, ${negocio.provincia || 'No especificado'}, ${negocio.pais || 'Ecuador'}`, leftColumn, negocio.logo ? 235 : 135)
         .text(`Accesos: Móvil ${negocio.movilAccess || 0}, PC ${negocio.pcAccess || 0}`, leftColumn, negocio.logo ? 250 : 150);

      // Cuadro de información fiscal (lado derecho)
      const fiscalBoxX = rightColumn;
      const fiscalBoxY = 50;
      const fiscalBoxWidth = 180;
      const fiscalBoxHeight = 100;

      // Dibujar el cuadro fiscal
      doc.lineWidth(1.5)
         .rect(fiscalBoxX, fiscalBoxY, fiscalBoxWidth, fiscalBoxHeight)
         .stroke();

      // Líneas internas del cuadro fiscal
      doc.lineWidth(0.5)
         .moveTo(fiscalBoxX, fiscalBoxY + 25).lineTo(fiscalBoxX + fiscalBoxWidth, fiscalBoxY + 25).stroke()
         .moveTo(fiscalBoxX, fiscalBoxY + 50).lineTo(fiscalBoxX + fiscalBoxWidth, fiscalBoxY + 50).stroke()
         .moveTo(fiscalBoxX, fiscalBoxY + 75).lineTo(fiscalBoxX + fiscalBoxWidth, fiscalBoxY + 75).stroke();

      // Contenido del cuadro fiscal
      doc.fontSize(8)
         .text(`R.U.C. ${negocio.ruc}`, fiscalBoxX + 5, fiscalBoxY + 5)
         .text('NOTA DE VENTA', fiscalBoxX + 5, fiscalBoxY + 15, { continued: true })
         .text('1-002-001-00', fiscalBoxX + 90, fiscalBoxY + 15)
         .fontSize(14)
         .fillColor('red')
         .text(invoice.invoiceNumber.padStart(7, '0'), fiscalBoxX + 5, fiscalBoxY + 30)
         .fillColor('black')
         .fontSize(8)
         .text('AUT. SRI. 1132943772', fiscalBoxX + 5, fiscalBoxY + 80);

      // INFORMACIÓN DEL CLIENTE
      let currentY = negocio.logo ? 280 : 180;

      // Fecha
      doc.fontSize(10)
         .text('Fecha: ______________________________', leftColumn, currentY);

      currentY += 20;
      // Cliente
      doc.text('Cliente: ____________________________', leftColumn, currentY);

      currentY += 20;
      // RUC y Teléfono
      doc.text('RUC: _________________________', leftColumn, currentY);
      doc.text('Telf.: _________________', rightColumn, currentY);

      currentY += 20;
      // Dirección
      doc.text('Dirección: __________________________', leftColumn, currentY);

      // TABLA DE PRODUCTOS
      currentY += 40;
      const tableStartY = currentY;
      const tableWidth = pageWidth - 30;
      const rowHeight = 25;

      // Definir colWidths antes de usarlo
      const colWidths = {
         cantidad: 60,
         descripcion: 280,
         unitario: 80,
         total: 80
      };

      // Dibujar el rectángulo principal de la tabla
      const tableHeight = 300;
      doc.rect(leftColumn, tableStartY, tableWidth, tableHeight).stroke();

      // Líneas verticales de la tabla
      let currentX = leftColumn;
      doc.moveTo(currentX + colWidths.cantidad, tableStartY)
         .lineTo(currentX + colWidths.cantidad, tableStartY + tableHeight).stroke();

      currentX += colWidths.cantidad;
      doc.moveTo(currentX + colWidths.descripcion, tableStartY)
         .lineTo(currentX + colWidths.descripcion, tableStartY + tableHeight).stroke();

      currentX += colWidths.descripcion;
      doc.moveTo(currentX + colWidths.unitario, tableStartY)
         .lineTo(currentX + colWidths.unitario, tableStartY + tableHeight).stroke();

      // Línea horizontal del encabezado
      doc.moveTo(leftColumn, tableStartY + rowHeight)
         .lineTo(leftColumn + tableWidth, tableStartY + rowHeight).stroke();

      // Encabezados de columnas
      doc.fontSize(10)
         .font('Helvetica-Bold')
         .text('CANT.', leftColumn + 5, tableStartY + 8, { width: colWidths.cantidad - 10, align: 'center' })
         .text('DESCRIPCIÓN', leftColumn + colWidths.cantidad + 5, tableStartY + 8, { width: colWidths.descripcion - 10, align: 'center' })
         .text('V. UNITARIO', leftColumn + colWidths.cantidad + colWidths.descripcion + 5, tableStartY + 8, { width: colWidths.unitario - 10, align: 'center' })
         .text('V. TOTAL', leftColumn + colWidths.cantidad + colWidths.descripcion + colWidths.unitario + 5, tableStartY + 8, { width: colWidths.total - 10, align: 'center' });

      // Productos
      doc.font('Helvetica').fontSize(9);
      let productY = tableStartY + rowHeight + 5;

      invoiceItems.forEach((item, index) => {
         if (productY < tableStartY + tableHeight - rowHeight) {
            const unitPrice = (item.subtotal / item.quantity).toFixed(2);

            doc.text(item.quantity.toString(), leftColumn + 5, productY, { width: colWidths.cantidad - 10, align: 'center' })
               .text(item.productoNombre || 'Producto', leftColumn + colWidths.cantidad + 5, productY, { width: colWidths.descripcion - 10 })
               .text(`$${unitPrice}`, leftColumn + colWidths.cantidad + colWidths.descripcion + 5, productY, { width: colWidths.unitario - 10, align: 'right' })
               .text(`$${item.total.toFixed(2)}`, leftColumn + colWidths.cantidad + colWidths.descripcion + colWidths.unitario + 5, productY, { width: colWidths.total - 10, align: 'right' });

            productY += 20;
         }
      });

      // SECCIÓN DE TOTALES Y FORMA DE PAGO
      const bottomSectionY = tableStartY + tableHeight + 20;

      // Forma de pago (lado izquierdo)
      doc.fontSize(9)
         .text('FORMA DE PAGO', leftColumn, bottomSectionY)
         .text('□ Efectivo _____ □ Dinero Electrónico ___', leftColumn, bottomSectionY + 15)
         .text('□ Tarjeta de Crédito ___ □ Débito ___ □ Otros Pagos: _______', leftColumn, bottomSectionY + 30);

      // Total (lado derecho)
      doc.fontSize(12)
         .font('Helvetica-Bold')
         .text(`TOTAL USD $`, rightColumn, bottomSectionY + 15)
         .fontSize(14)
         .text(invoice.invoiceTotal.toFixed(2), rightColumn + 80, bottomSectionY + 15);

      // FIRMAS
      const signatureY = bottomSectionY + 70;
      doc.fontSize(9)
         .font('Helvetica')
         .text('_________________', leftColumn, signatureY)
         .text('Firma Autorizada', leftColumn, signatureY + 15)
         .text('_________________', rightColumn, signatureY)
         .text('Recibí Conforme', rightColumn, signatureY + 15);

      // Texto legal
      const legalY = signatureY + 50;
      doc.fontSize(6)
         .text('ORIGINAL ADQUIRIENTE • COPIA EMISOR', leftColumn, legalY, { width: pageWidth, align: 'center' });

      // Texto vertical en el margen derecho
      doc.save();
      doc.rotate(-90, { origin: [doc.page.width - 20, doc.page.height / 2] });
      doc.fontSize(6)
         .text('VALIDO PARA SU EMISIÓN HASTA EL 02 DE JULIO DE 2024', 0, 0, { width: 200 });
      doc.restore();

      doc.end();

      const pdfBuffer = await new Promise((resolve) => {
         const buffers = [];
         doc.on('data', (chunk) => buffers.push(chunk));
         doc.on('end', () => resolve(Buffer.concat(buffers)));
      });

      const bucketName = process.env.S3_BUCKET;
      const fileName = `invoices/${negocio.nombre}/${invoice.id}/${Date.now()}.pdf`;
      const putObjectCommand = new PutObjectCommand({
         Bucket: bucketName,
         Key: fileName,
         Body: pdfBuffer,
         ContentType: 'application/pdf',
      });

      await s3Client.send(putObjectCommand);

      return {
         statusCode: 200,
         body: JSON.stringify({ pdfUrl: fileName }),
      };
   } catch (error) {
      console.error('Error generando PDF:', error);
      return {
         statusCode: 500,
         body: JSON.stringify({ error: 'Error al generar el PDF' }),
      };
   }
}