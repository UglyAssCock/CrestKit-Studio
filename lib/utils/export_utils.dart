import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../models/scene_models.dart';
import '../data/shields.dart';
import '../data/divisions.dart';
import '../data/jerseys.dart';

class ExportUtils {
  static String _hex(int colorVal) =>
      '#${colorVal.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

  static String generateSvg(KitSet kit, {bool includeJersey = false}) {
    final sb = StringBuffer();
    sb.writeln(
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" width="1024" height="1024">');

    if (includeJersey) {
      final tpl = JerseyLibrary.templateById(kit.jersey.templateId);
      final collar = JerseyLibrary.collarById(kit.jersey.collarId);
      final bodyHex = _hex(kit.jersey.zoneColors['body'] ?? 0xFFDC2626);
      final sleevesHex = _hex(kit.jersey.zoneColors['sleeves'] ?? 0xFFFFFFFF);
      final collarHex = _hex(kit.jersey.zoneColors['collar'] ?? 0xFF0F172A);
      sb.writeln('  <path d="${tpl.bodyFrontPath}" fill="$bodyHex" stroke="#111827" stroke-width="0.8"/>');
      sb.writeln('  <path d="${tpl.sleevesFrontPath}" fill="$sleevesHex" stroke="#111827" stroke-width="0.8"/>');
      sb.writeln('  <path d="${collar.primaryPath}" fill="$collarHex"/>');
    } else {
      final shield = ShieldLibrary.byId(kit.crest.shieldId);
      final div = DivisionLibrary.byId(kit.crest.divisionId);
      sb.writeln('  <defs>');
      sb.writeln('    <clipPath id="shieldClip">');
      sb.writeln('      <path d="${shield.path}"/>');
      sb.writeln('    </clipPath>');
      sb.writeln('  </defs>');
      sb.writeln(
          '  <path d="${shield.path}" fill="${_hex(kit.crest.divisionColor1)}"/>');
      if (div.id != 'solid' && div.path.isNotEmpty) {
        sb.writeln(
            '  <path d="${div.path}" fill="${_hex(kit.crest.divisionColor2)}" clip-path="url(#shieldClip)"/>');
      }
      for (final layer in kit.layers) {
        if (!layer.visible) continue;
        sb.writeln('  <g id="${layer.id}" opacity="${layer.opacity}">');
        for (final s in layer.shapes) {
          final sx = s.scaleX * (s.flipH ? -1 : 1);
          final sy = s.scaleY * (s.flipV ? -1 : 1);
          sb.writeln(
              '    <g transform="translate(${s.tx},${s.ty}) rotate(${s.rotation}) scale($sx,$sy) translate(-50,-50)" opacity="${s.opacity}">');
          if (s.textContent != null && s.textContent!.isNotEmpty) {
            sb.writeln(
                '      <text x="50" y="54" text-anchor="middle" fill="${_hex(s.fillColor)}" font-size="${s.fontSize}" font-weight="bold">${s.textContent}</text>');
          } else {
            sb.writeln(
                '      <path d="${s.svgPath}" fill="${s.closed ? _hex(s.fillColor) : 'none'}" stroke="${_hex(s.strokeColor)}" stroke-width="${s.strokeWidth}"/>');
          }
          sb.writeln('    </g>');
        }
        sb.writeln('  </g>');
      }
      sb.writeln(
          '  <path d="${shield.path}" fill="none" stroke="${_hex(kit.crest.shieldStrokeColor)}" stroke-width="${kit.crest.shieldStrokeWidth}"/>');
    }

    sb.writeln('</svg>');
    return sb.toString();
  }

  static Future<void> shareSvgString(String svgContent, String fileName) async {
    final dir = await getTemporaryDirectory();
    final cleanName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final file = File('${dir.path}/$cleanName.svg');
    await file.writeAsString(svgContent);
    await Share.shareXFiles([XFile(file.path)], text: 'CrestKit Studio 2D SVG');
  }

  static Future<void> exportAndSharePng(
    GlobalKey boundaryKey,
    int resolution,
    String fileName,
  ) async {
    final ctx = boundaryKey.currentContext;
    if (ctx == null) return;
    final boundary = ctx.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;

    final minSide = boundary.size.shortestSide;
    final pixelRatio = (resolution / (minSide <= 0 ? 512.0 : minSide)).clamp(1.0, 12.0);
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;

    final dir = await getTemporaryDirectory();
    final cleanName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final file = File('${dir.path}/$cleanName.png');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    await Share.shareXFiles([XFile(file.path)], text: 'CrestKit Studio PNG ($resolution px)');
  }

  static Future<void> exportAndSharePdf(
    StudioProject project,
    KitSet kit,
  ) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                '${project.name.toUpperCase()} — KIT & SQUAD SPECIFICATION SHEET',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text('Active Kit: ${kit.name} • Template: ${kit.jersey.templateId}'),
              pw.Text(
                  'Crest Shield: ${kit.crest.shieldId} • Division: ${kit.crest.divisionId}'),
              pw.Text(
                  'Primary HEX: ${_hex(project.primaryTeamColor)}  |  Secondary HEX: ${_hex(project.secondaryTeamColor)}  |  Accent HEX: ${_hex(project.accentTeamColor)}'),
              pw.Divider(),
              pw.SizedBox(height: 8),
              pw.Text(
                'Official Squad Number List (${project.squad.length} Players)',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.TableHelper.fromTextArray(
                headers: const ['Number', 'Shirt Name', 'Role', 'Kit Set'],
                data: project.squad
                    .map((p) => [
                          '#${p.number}',
                          p.name,
                          p.role,
                          kit.name,
                        ])
                    .toList(),
              ),
            ],
          );
        },
      ),
    );

    final dir = await getTemporaryDirectory();
    final cleanName =
        '${project.name}_${kit.name}_Sheet'.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final file = File('${dir.path}/$cleanName.pdf');
    await file.writeAsBytes(await pdf.save());
    await Share.shareXFiles([XFile(file.path)], text: 'CrestKit Studio PDF Print Sheet');
  }
}
