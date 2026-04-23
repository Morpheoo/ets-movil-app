import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../features/ets/domain/entities/ets_entity.dart';

// Genera y comparte un archivo .ics (iCalendar) con los exámenes recibidos.
// Compatible con Google Calendar, Apple Calendar, Outlook.
Future<void> exportToIcs(List<EtsEntity> etsList, {String filename = 'ets_escom.ics'}) async {
  final content = _buildIcs(etsList);
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$filename');
  await file.writeAsString(content);
  await SharePlus.instance.share(ShareParams(files: [XFile(file.path)], text: 'Calendario ETS — ESCOM'));
}

String _buildIcs(List<EtsEntity> etsList) {
  final sb = StringBuffer();
  sb.writeln('BEGIN:VCALENDAR');
  sb.writeln('VERSION:2.0');
  sb.writeln('PRODID:-//ESCOM ETS Manager//ES');
  sb.writeln('CALSCALE:GREGORIAN');
  sb.writeln('METHOD:PUBLISH');

  for (final ets in etsList) {
    final (start, end) = _parseTimes(ets);
    final uid = '${ets.id}-ets@escom.ipn.mx';
    final stamp = _formatDateTime(DateTime.now());

    sb.writeln('BEGIN:VEVENT');
    sb.writeln('UID:$uid');
    sb.writeln('DTSTAMP:$stamp');
    sb.writeln('DTSTART:$start');
    sb.writeln('DTEND:$end');
    sb.writeln('SUMMARY:ETS - ${_escape(ets.subject)}');
    sb.writeln('DESCRIPTION:${_buildDescription(ets)}');
    sb.writeln('LOCATION:${_escape('ESCOM - Salón ${ets.classroom}')}');
    sb.writeln('END:VEVENT');
  }

  sb.writeln('END:VCALENDAR');
  return sb.toString();
}

// Intenta extraer hora de inicio y fin del campo shift.
// Formato esperado: "07:00-10:00", "Matutino 07:00-10:00", "7:00 a 10:00"
// Si no puede parsearlo, usa evento de día completo (07:00-22:00).
(String, String) _parseTimes(EtsEntity ets) {
  final date = ets.date;
  final times = RegExp(r'(\d{1,2}):(\d{2})').allMatches(ets.shift).toList();

  if (times.length >= 2) {
    final start = _toIcsDateTime(date, int.parse(times[0].group(1)!), int.parse(times[0].group(2)!));
    final end   = _toIcsDateTime(date, int.parse(times[1].group(1)!), int.parse(times[1].group(2)!));
    return (start, end);
  } else if (times.length == 1) {
    final h = int.parse(times[0].group(1)!);
    final m = int.parse(times[0].group(2)!);
    return (_toIcsDateTime(date, h, m), _toIcsDateTime(date, h + 3, m));
  }

  // Fallback: evento de 07:00 a 10:00
  return (_toIcsDateTime(date, 7, 0), _toIcsDateTime(date, 10, 0));
}

String _toIcsDateTime(DateTime date, int hour, int minute) {
  final h = hour.clamp(0, 23);
  return '${date.year}'
      '${date.month.toString().padLeft(2, '0')}'
      '${date.day.toString().padLeft(2, '0')}'
      'T${h.toString().padLeft(2, '0')}'
      '${minute.toString().padLeft(2, '0')}00';
}

String _formatDateTime(DateTime dt) {
  return '${dt.year}'
      '${dt.month.toString().padLeft(2, '0')}'
      '${dt.day.toString().padLeft(2, '0')}'
      'T${dt.hour.toString().padLeft(2, '0')}'
      '${dt.minute.toString().padLeft(2, '0')}'
      '${dt.second.toString().padLeft(2, '0')}Z';
}

String _buildDescription(EtsEntity ets) {
  final parts = [
    'Carrera: ${ets.careerFullName}',
    'Semestre: ${ets.semester}',
    'Turno: ${ets.shift}',
    'Coordinador: ${ets.professor}',
    if (ets.email.isNotEmpty) 'Email: ${ets.email}',
    if (ets.note != null) 'Nota: ${ets.note}',
  ];
  return _escape(parts.join('\\n'));
}

String _escape(String s) => s
    .replaceAll('\\', '\\\\')
    .replaceAll('\n', '\\n')
    .replaceAll(',', '\\,')
    .replaceAll(';', '\\;');
