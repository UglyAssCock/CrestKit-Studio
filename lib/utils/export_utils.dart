import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../data/divisions.dart';
import '../data/jerseys.dart';
import '../data/patterns.dart';
import '../data/shields.dart';
import '../models/scene_models.dart';
import '../painters/crest_painter.dart';
import '../painters/jersey_painter.dart';

class ExportUtils {
  static String _hex(int colorValue) {
    final hex = (colorValue & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase();
    return '#$hex';
  }

  static String generateCrestSvg(KitSet kit) {
    final crest = kit.crest;
    final shield = ShieldLibrary.byId(crest.shieldId);
    final division = DivisionLibrary.byId(crest.divisionId);
    final sb = StringBuffer();

    sb.writeln(
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" width="1024" height="1024">');
    sb.writeln('  <defs>');
    sb.writeln('    <clipPath id="shieldClip">');
    sb.writeln('      <path d="${shield.path}" />');
    sb.writeln('    </clipPath>');
    sb.writeln('  </defs>');

    sb.writeln(
        '  <path d="${shield.path}" fill="${_hex(crest.shieldPrimaryColor)}" />');
    if (division.path.isNotEmpty && division.id != 'solid') {
      sb.writeln(
          '  <path d="${division.path}" fill="${_hex(crest.divisionColor2)}" clip-path="url(#shieldClip)" />');
    }
    if (crest.hasBordure) {
      sb.writeln(
          '  <path d="${shield.path}" fill="none" stroke="${_hex(crest.bordureColor)}" stroke-width="${crest.shieldStrokeWidth.toStringAsFixed(1)}" />');
    }

    for (final layer in kit.layers) {
      if (!layer.visible) continue;
      sb.writeln(
          '  <g id="${layer.id}" opacity="${layer.opacity.toStringAsFixed(2)}">');
      for (final shape in layer.shapes) {
        final sx = shape.flipH ? -shape.scaleX : shape.scaleX;
        final sy = shape.flipV ? -shape.scaleY : shape.scaleY;
        final rotDeg = shape.rotation * 180.0 / 3.14159265;
        final transform =
            'translate(${shape.tx.toStringAsFixed(1)}, ${shape.ty.toStringAsFixed(1)}) rotate(${rotDeg.toStringAsFixed(1)}) scale(${sx.toStringAsFixed(2)}, ${sy.toStringAsFixed(2)}) translate(-50, -50)';
        if (shape.textContent != null && shape.textContent!.isNotEmpty) {
          sb.writeln(
              '    <text x="${shape.tx.toStringAsFixed(1)}" y="${shape.ty.toStringAsFixed(1)}" fill="${_hex(shape.fillColor)}" stroke="${_hex(shape.strokeColor)}" stroke-width="${(shape.strokeWidth * 0.2).toStringAsFixed(1)}" font-size="${shape.fontSize.toStringAsFixed(1)}" font-weight="bold" text-anchor="middle">${shape.textContent}</text>');
        } else {
          sb.writeln(
              '    <path d="${shape.svgPath}" transform="$transform" fill="${_hex(shape.fillColor)}" stroke="${_hex(shape.strokeColor)}" stroke-width="${shape.strokeWidth.toStringAsFixed(1)}" opacity="${shape.opacity.toStringAsFixed(2)}" />');
        }
      }
      sb.writeln('  </g>');
    }

    if (crest.topBannerText.isNotEmpty) {
      sb.writeln(
          '  <rect x="16" y="4" width="68" height="10" rx="2" fill="${_hex(crest.bannerColor)}" />');
      sb.writeln(
          '  <text x="50" y="11.5" fill="${_hex(crest.bannerTextColor)}" font-size="6" font-weight="bold" text-anchor="middle">${crest.topBannerText}</text>');
    }
    if (crest.bottomBannerText.isNotEmpty) {
      sb.writeln(
          '  <rect x="20" y="88" width="60" height="9" rx="2" fill="${_hex(crest.bannerColor)}" />');
      sb.writeln(
          '  <text x="50" y="94.5" fill="${_hex(crest.bannerTextColor)}" font-size="5.5" font-weight="bold" text-anchor="middle">${crest.bottomBannerText}</text>');
    }

    sb.writeln('</svg>');
    return sb.toString();
  }

  static String generateKitSvg(KitSet kit) {
    final j = kit.jersey;
    final tmpl = JerseyLibrary.templateById(j.templateId);
    final collar = JerseyLibrary.collarById(j.collarId);
    final pat = PatternLibrary.byId(j.bodyPattern.patternId);
    final bodyCol = _hex(j.zoneColors['body'] ?? 0xFFDC2626);
    final sleeveCol = _hex(j.zoneColors['sleeves'] ?? 0xFFFFFFFF);
    final collarCol = _hex(j.zoneColors['collar'] ?? 0xFF0F172A);

    final sb = StringBuffer();
    sb.writeln(
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" width="1024" height="1024">');
    sb.writeln('  <defs>');
    sb.writeln('    <clipPath id="bodyClip">');
    sb.writeln('      <path d="${tmpl.bodyFrontPath}" />');
    sb.writeln('    </clipPath>');
    sb.writeln('  </defs>');
    sb.writeln(
        '  <path d="${tmpl.sleevesFrontPath}" fill="$sleeveCol" stroke="#111827" stroke-width="0.8" />');
    sb.writeln(
        '  <path d="${tmpl.bodyFrontPath}" fill="$bodyCol" stroke="#111827" stroke-width="0.8" />');
    if (pat.svgPath.isNotEmpty) {
      sb.writeln(
          '  <path d="${pat.svgPath}" fill="${_hex(j.bodyPattern.secondaryColor)}" clip-path="url(#bodyClip)" opacity="${j.bodyPattern.opacity.toStringAsFixed(2)}" />');
    }
    if (collar.primaryPath.isNotEmpty) {
      sb.writeln('  <path d="${collar.primaryPath}" fill="$collarCol" />');
    }
    if (j.sponsorText.isNotEmpty) {
      sb.writeln(
          '  <text x="50" y="48" fill="${_hex(j.sponsorColor)}" font-size="5" font-weight="bold" text-anchor="middle">${j.sponsorText}</text>');
    }
    sb.writeln('</svg>');
    return sb.toString();
  }

  static Future<Uint8List> renderCrestPng(KitSet kit, int pixelSize) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(pixelSize.toDouble(), pixelSize.toDouble());
    final painter = CrestPainter(
      kit: kit,
      showGrid: false,
      symmetryMode: false,
      isExport: true,
    );
    painter.paint(canvas, size);
    final picture = recorder.endRecording();
    final img = await picture.toImage(pixelSize, pixelSize);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  static Future<Uint8List> renderKitPng(
    StudioProject project,
    KitSet kit,
    int pixelSize, {
    String viewMode = 'full',
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(pixelSize.toDouble(), pixelSize.toDouble());
    final painter = JerseyPainter(
      project: project,
      kit: kit,
      viewMode: viewMode,
      transparentBackground: true,
    );
    painter.paint(canvas, size);
    final picture = recorder.endRecording();
    final img = await picture.toImage(pixelSize, pixelSize);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  static Future<Uint8List> generateKitPdfSheet(
    StudioProject project,
    KitSet kit,
  ) async {
    final crestPng = await renderCrestPng(kit, 600);
    final frontPng = await renderKitPng(project, kit, 800, viewMode: 'front');
    final backPng = await renderKitPng(project, kit, 800, viewMode: 'back');

    final pdf = pw.Document();
    final crestImg = pw.MemoryImage(crestPng);
    final frontImg = pw.MemoryImage(frontPng);
    final backImg = pw.MemoryImage(backPng);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '${project.name} — ${kit.name} Kit Spec Sheet',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Generated by CrestKit Studio (2D Vector Engine)',
                    style: const pw.TextStyle(
                        fontSize: 10, color: PdfColors.grey700),
                  ),
                ],
              ),
              pw.Container(
                width: 64,
                height: 64,
                child: pw.Image(crestImg),
              ),
            ],
          ),
          pw.Divider(height: 20),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
            children: [
              pw.Column(
                children: [
                  pw.Container(
                    width: 210,
                    height: 210,
                    child: pw.Image(frontImg),
                  ),
                  pw.Text('FRONT VIEW',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.Column(
                children: [
                  pw.Container(
                    width: 210,
                    height: 210,
                    child: pw.Image(backImg),
                  ),
                  pw.Text('BACK VIEW',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            'Team Palette & Kit Specifications',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              _colorChip('Primary', project.primaryTeamColor),
              pw.SizedBox(width: 12),
              _colorChip('Secondary', project.secondaryTeamColor),
              pw.SizedBox(width: 12),
              _colorChip('Accent', project.accentTeamColor),
              pw.SizedBox(width: 16),
              pw.Text(
                'Template: ${kit.jersey.templateId} | Pattern: ${kit.jersey.bodyPattern.patternId}',
                style: const pw.TextStyle(fontSize: 10),
              ),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            'Official Squad Roster (${project.squad.length} Players)',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: ['#', 'Shirt Name', 'Role', 'Kit Variant'],
            data: project.squad
                .map((p) => [
                      p.number.toString(),
                      p.name,
                      p.role,
                      kit.name,
                    ])
                .toList(),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration:
                const pw.BoxDecoration(color: PdfColors.blueGrey900),
            cellAlignment: pw.Alignment.centerLeft,
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _colorChip(String label, int colorVal) {
    final c = PdfColor.fromInt(colorVal);
    return pw.Row(
      children: [
        pw.Container(
          width: 16,
          height: 16,
          decoration: pw.BoxDecoration(
            color: c,
            border: pw.Border.all(color: PdfColors.black, width: 0.5),
          ),
        ),
        pw.SizedBox(width: 4),
        pw.Text('$label (${_hex(colorVal)})',
            style: const pw.TextStyle(fontSize: 9)),
      ],
    );
  }

  static Future<void> shareBytes(
    Uint8List bytes,
    String filename,
    String mimeType,
  ) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: mimeType)],
      text: 'Exported from CrestKit Studio: $filename',
    );
  }

  static Future<void> shareText(
    String content,
    String filename,
    String mimeType,
  ) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsString(content, flush: true);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: mimeType)],
      text: 'Exported from CrestKit Studio: $filename',
    );
  }
}
