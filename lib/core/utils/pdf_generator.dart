import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../features/ets/domain/entities/ets_entity.dart';

class PdfGenerator {
  static Future<void> generateAndPrintEtsList(List<EtsEntity> etsList) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(),
            pw.SizedBox(height: 20),
            _buildEtsTable(etsList),
            pw.SizedBox(height: 20),
            _buildFooter(etsList.length),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'Calendario_ETS',
    );
  }

  static pw.Widget _buildHeader() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Calendario de ETS Especial - ESCOM', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Text('Generado el: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}', style: const pw.TextStyle(fontSize: 12)),
        pw.Divider(),
      ],
    );
  }

  static pw.Widget _buildEtsTable(List<EtsEntity> etsList) {
    if (etsList.isEmpty) {
      return pw.Text('No hay examenes para mostrar.');
    }

    final headers = ['Materia', 'Carrera', 'Fecha', 'Turno', 'Salon', 'Profesor'];

    final data = etsList.map((e) {
      return [
        e.subject,
        e.career,
        DateFormat('dd/MM/yyyy').format(e.date),
        e.shift,
        e.classroom,
        e.professor,
      ];
    }).toList();

    return pw.Table.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(width: 0.5),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellAlignment: pw.Alignment.centerLeft,
      headerDecoration: const pw.BoxDecoration(
        color: PdfColors.grey300,
      ),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1.5),
        4: const pw.FlexColumnWidth(1),
        5: const pw.FlexColumnWidth(2),
      },
    );
  }

  static pw.Widget _buildFooter(int total) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text('Total de examenes: $total', style: const pw.TextStyle(fontSize: 10)),
        pw.Text('Generado desde ESCOM ETS Manager', style: const pw.TextStyle(fontSize: 10)),
      ],
    );
  }
}
