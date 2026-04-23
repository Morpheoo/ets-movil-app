// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../features/ets/domain/entities/ets_entity.dart';

class ExcelGenerator {
  static Future<void> generateAndShareEtsList(List<EtsEntity> etsList) async {
    final excel = Excel.createExcel();
    final sheet = excel['Calendario ETS'];
    
    final defaultSheet = excel.getDefaultSheet();
    if (defaultSheet != null && defaultSheet != 'Calendario ETS') {
       excel.delete(defaultSheet);
    }

    // Headers
    final headers = ['Materia', 'Carrera', 'Plan', 'Semestre', 'Fecha', 'Turno', 'Salon', 'Profesor'];
    sheet.appendRow(headers.map((h) => TextCellValue(h)).toList());

    // Make headers bold
    for (int col = 0; col < headers.length; col++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0));
      cell.cellStyle = CellStyle(
        bold: true,
        fontFamily: getFontFamily(FontFamily.Calibri),
      );
    }

    // Data rows
    for (final ets in etsList) {
      final row = [
        TextCellValue(ets.subject),
        TextCellValue(ets.career),
        TextCellValue(ets.plan),
        IntCellValue(ets.semester),
        TextCellValue(DateFormat('dd/MM/yyyy').format(ets.date)),
        TextCellValue(ets.shift),
        TextCellValue(ets.classroom),
        TextCellValue(ets.professor),
      ];
      sheet.appendRow(row);
    }

    // Save to temp path
    final dir = await getTemporaryDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    final filePath = '${dir.path}/ETS_Especial_$timestamp.xlsx';
    final file = File(filePath);
    
    final bytes = excel.encode()!;
    await file.writeAsBytes(bytes);

    // Share/Open
    await Share.shareXFiles([XFile(filePath)], text: 'Calendario de ETS Especial generado.');
  }
}
