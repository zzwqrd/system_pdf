import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' as intl;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart' as pdf_core;
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../company_settings/data/data_source/data_source.dart';
import '../../../shared/models/company_settings_model.dart';
import '../../../shared/models/quotation_model.dart';
import '../../../shared/models/quotation_item_model.dart';

class QuotationDetailsView extends StatefulWidget {
  final Quotation? quotation;

  const QuotationDetailsView({super.key, this.quotation});

  @override
  State<QuotationDetailsView> createState() => _QuotationDetailsViewState();
}

class _QuotationDetailsViewState extends State<QuotationDetailsView> {
  Quotation? _quotation;
  bool _isGeneratingPdf = false;
  final _shareButtonKey = GlobalKey();
  final _companyDs = CompanySettingsDataSourceImpl();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _quotation ??=
        widget.quotation ??
        ModalRoute.of(context)?.settings.arguments as Quotation?;
  }

  String _formatAmount(double amount) {
    return intl.NumberFormat('#,###', 'en_US').format(amount);
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return intl.DateFormat('yyyy/MM/dd').format(date);
    } catch (_) {
      return dateStr ?? '';
    }
  }

  Future<void> _generateAndSharePdf() async {
    if (_quotation == null) return;
    setState(() => _isGeneratingPdf = true);
    try {
      final company = await _companyDs.getSettings();
      final pdfBytes = await _buildPdf(_quotation!, company);
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/عرض_سعر_${_quotation!.quotationNumber.replaceAll('/', '_')}.pdf',
      );
      await file.writeAsBytes(pdfBytes);

      Rect? sharePositionOrigin;
      final renderBox =
          _shareButtonKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final position = renderBox.localToGlobal(Offset.zero);
        sharePositionOrigin = position & renderBox.size;
      }

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'عرض سعر - ${_quotation!.quotationNumber}',
        sharePositionOrigin: sharePositionOrigin,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في توليد PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  Future<Uint8List> _buildPdf(
    Quotation quotation,
    CompanySettings company,
  ) async {
    final pdf = pw.Document();
    final arabicFont = await _loadArabicFont();
    final arabicBoldFont = await _loadArabicBoldFont();
    final signatureFont = await _loadSignatureFont();
    final formatter = intl.NumberFormat('#,###', 'en_US');

    const navyBlue = pdf_core.PdfColor(0.102, 0.153, 0.267);
    const accentBlue = pdf_core.PdfColor(0.200, 0.400, 0.800);
    const rowAlt = pdf_core.PdfColor(0.969, 0.973, 0.984);
    const borderCl = pdf_core.PdfColor(0.878, 0.886, 0.925);
    const txtDark = pdf_core.PdfColor(0.102, 0.102, 0.180);
    const txtGrey = pdf_core.PdfColor(0.420, 0.447, 0.502);

    pw.ImageProvider? logoImage;
    if (company.logoPath != null && company.logoPath!.isNotEmpty) {
      try {
        final f = File(company.logoPath!);
        if (await f.exists()) logoImage = pw.MemoryImage(await f.readAsBytes());
      } catch (_) {}
    }
    pw.ImageProvider? stampImage;
    if (company.stampPath != null && company.stampPath!.isNotEmpty) {
      try {
        final f = File(company.stampPath!);
        if (await f.exists()) {
          stampImage = pw.MemoryImage(await f.readAsBytes());
        }
      } catch (_) {}
    }
    pw.ImageProvider? bgImage;
    if (company.backgroundImagePath != null &&
        company.backgroundImagePath!.isNotEmpty) {
      try {
        final f = File(company.backgroundImagePath!);
        if (await f.exists()) bgImage = pw.MemoryImage(await f.readAsBytes());
      } catch (_) {}
    }

    pw.ImageProvider? signatureImage;
    final finalSignaturePath =
        quotation.signatureImagePath ?? company.signaturePath;
    if (finalSignaturePath != null && finalSignaturePath.isNotEmpty) {
      try {
        final f = File(finalSignaturePath);
        if (await f.exists()) {
          signatureImage = pw.MemoryImage(await f.readAsBytes());
        }
      } catch (_) {}
    }

    final dateStr = _formatDate(quotation.createdAt);

    pdf_core.PdfColor primaryCol;
    pdf_core.PdfColor secondaryCol;

    switch (company.pdfTemplate) {
      case 'yellow':
        primaryCol = pdf_core.PdfColor.fromInt(0xff8dc63f);
        secondaryCol = pdf_core.PdfColor.fromInt(0xfff15a24);
        break;
      case 'green':
        primaryCol = pdf_core.PdfColor.fromInt(0xff009245);
        secondaryCol = pdf_core.PdfColor.fromInt(0xff333333);
        break;
      case 'corporate':
        primaryCol = pdf_core.PdfColor.fromInt(0xff3a3a3a);
        secondaryCol = pdf_core.PdfColor.fromInt(0xfffbb040);
        break;
      case 'abstract':
        primaryCol = pdf_core.PdfColor.fromInt(0xfffbb040);
        secondaryCol = pdf_core.PdfColor.fromInt(0xff2b2b2b);
        break;
      default:
        primaryCol = navyBlue;
        secondaryCol = accentBlue;
    }

    final pageTheme = pw.PageTheme(
      pageFormat: pdf_core.PdfPageFormat.a4,
      textDirection: pw.TextDirection.rtl,
      margin: pw.EdgeInsets.zero,
      buildBackground: (ctx) {
        if (company.pdfTemplate == 'yellow') {
          return pw.FullPage(
            ignoreMargins: true,
            child: pw.Stack(
              children: [
                pw.Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: pw.Container(height: 25, color: secondaryCol),
                ),
                pw.Positioned(
                  bottom: 0,
                  left: 0,
                  child: pw.Container(
                    width: 150,
                    height: 80,
                    child: pw.CustomPaint(
                      painter:
                          (
                            pdf_core.PdfGraphics canvas,
                            pdf_core.PdfPoint size,
                          ) {
                            canvas.moveTo(0, 0);
                            canvas.lineTo(40, 80);
                            canvas.lineTo(100, 0);
                            canvas.setFillColor(secondaryCol);
                            canvas.fillPath();
                            canvas.moveTo(80, 0);
                            canvas.lineTo(130, 60);
                            canvas.lineTo(150, 0);
                            canvas.setFillColor(primaryCol);
                            canvas.fillPath();
                          },
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        if (company.pdfTemplate == 'green') {
          return pw.FullPage(
            ignoreMargins: true,
            child: pw.Stack(
              children: [
                pw.Positioned(
                  bottom: 0,
                  right: 0,
                  child: pw.Container(
                    width: 200,
                    height: 100,
                    child: pw.CustomPaint(
                      painter:
                          (
                            pdf_core.PdfGraphics canvas,
                            pdf_core.PdfPoint size,
                          ) {
                            canvas.moveTo(200, 0);
                            canvas.lineTo(150, 100);
                            canvas.lineTo(0, 0);
                            canvas.setFillColor(
                              pdf_core.PdfColor.fromInt(0xffe6e6e6),
                            );
                            canvas.fillPath();
                          },
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        if (company.pdfTemplate == 'corporate') {
          return pw.FullPage(
            ignoreMargins: true,
            child: pw.Stack(
              children: [
                pw.Positioned(
                  top: 0,
                  left: 0,
                  child: pw.Container(
                    width: 220,
                    height: 180,
                    child: pw.CustomPaint(
                      painter:
                          (
                            pdf_core.PdfGraphics canvas,
                            pdf_core.PdfPoint size,
                          ) {
                            canvas.moveTo(0, 180);
                            canvas.lineTo(220, 180);
                            canvas.lineTo(0, 0);
                            canvas.setFillColor(primaryCol);
                            canvas.fillPath();
                          },
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        if (company.pdfTemplate == 'abstract') {
          return pw.FullPage(
            ignoreMargins: true,
            child: pw.Stack(
              children: [
                pw.Positioned(
                  top: 0,
                  left: 0,
                  child: pw.Container(
                    width: 120,
                    height: 120,
                    child: pw.CustomPaint(
                      painter:
                          (
                            pdf_core.PdfGraphics canvas,
                            pdf_core.PdfPoint size,
                          ) {
                            for (var i = 0; i < 3; i++) {
                              canvas.moveTo(0, 120 - (i * 25));
                              canvas.curveTo(
                                30,
                                120 - (i * 25),
                                60,
                                90 - (i * 25),
                                120 - (i * 25),
                                90 - (i * 25),
                              );
                              canvas.setStrokeColor(primaryCol);
                              canvas.setLineWidth(2);
                              canvas.strokePath();
                            }
                          },
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        if (bgImage != null) {
          return pw.Opacity(
            opacity: 0.05,
            child: pw.Image(bgImage, fit: pw.BoxFit.cover),
          );
        }
        return pw.SizedBox();
      },
    );

    pdf.addPage(
      pw.Page(
        pageTheme: pageTheme,
        build: (ctx) {
          pw.Widget header;
          if (company.pdfTemplate == 'yellow') {
            header = pw.Column(
              children: [
                pw.SizedBox(height: 35),
                pw.Center(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 12,
                    ),
                    decoration: pw.BoxDecoration(
                      color: primaryCol,
                      borderRadius: pw.BorderRadius.circular(30),
                    ),
                    child: pw.Text(
                      company.companyName,
                      style: pw.TextStyle(
                        font: arabicBoldFont,
                        fontSize: 18,
                        color: pdf_core.PdfColors.white,
                      ),
                    ),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.fromLTRB(25, 25, 25, 10),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'التاريخ: $dateStr',
                        style: pw.TextStyle(font: arabicFont, fontSize: 10),
                      ),
                      pw.Text(
                        'رقم العرض: ${quotation.quotationNumber}',
                        style: pw.TextStyle(font: arabicBoldFont, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else if (company.pdfTemplate == 'green') {
            header = pw.Container(
              padding: const pw.EdgeInsets.fromLTRB(35, 50, 35, 20),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'عرض أسعار',
                    style: pw.TextStyle(
                      font: arabicFont,
                      fontSize: 40,
                      color: primaryCol,
                    ),
                  ),
                  if (logoImage != null)
                    pw.Container(
                      width: 80,
                      height: 80,
                      padding: const pw.EdgeInsets.all(8),
                      color: primaryCol,
                      child: pw.Image(logoImage),
                    )
                  else
                    pw.Container(width: 80, height: 80, color: primaryCol),
                ],
              ),
            );
          } else if (company.pdfTemplate == 'corporate') {
            header = pw.Container(
              padding: const pw.EdgeInsets.fromLTRB(35, 40, 35, 25),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Container(
                    width: 90,
                    height: 90,
                    child: logoImage != null
                        ? pw.Image(logoImage)
                        : pw.SizedBox(),
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'عرض أسعار',
                        style: pw.TextStyle(
                          font: arabicBoldFont,
                          fontSize: 32,
                          color: secondaryCol,
                        ),
                      ),
                      pw.Text(
                        'التاريخ: $dateStr',
                        style: pw.TextStyle(font: arabicFont, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else {
            header = pw.Container(
              color: primaryCol,
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 25,
                vertical: 25,
              ),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        if (logoImage != null)
                          pw.Container(
                            width: 60,
                            height: 40,
                            child: pw.Image(logoImage),
                          ),
                        pw.Text(
                          quotation.pdfTitle ?? 'عرض سعر صيانة وتوريد',
                          style: pw.TextStyle(
                            font: arabicBoldFont,
                            fontSize: 20,
                            color: pdf_core.PdfColors.white,
                          ),
                        ),
                        pw.Text(
                          company.companyName,
                          style: pw.TextStyle(
                            font: arabicFont,
                            fontSize: 10,
                            color: pdf_core.PdfColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      color: pdf_core.PdfColor(1, 1, 1, 0.1),
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Text(
                          'رقم العرض: ${quotation.quotationNumber}',
                          style: pw.TextStyle(
                            font: arabicBoldFont,
                            fontSize: 9,
                            color: pdf_core.PdfColors.white,
                          ),
                        ),
                        pw.Text(
                          'التاريخ: $dateStr',
                          style: pw.TextStyle(
                            font: arabicFont,
                            fontSize: 8,
                            color: pdf_core.PdfColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          final List<pw.Widget> sections = [];
          for (final sectionKey in quotation.sectionOrder) {
            switch (sectionKey) {
              case 'intro':
                sections.add(
                  pw.Padding(
                    padding: const pw.EdgeInsets.fromLTRB(20, 25, 20, 10),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'السادة / ${quotation.clientName ?? ''} المحترمين',
                          style: pw.TextStyle(
                            font: arabicBoldFont,
                            fontSize: 14,
                            color: primaryCol,
                          ),
                        ),
                        pw.SizedBox(height: 6),
                        pw.Text(
                          quotation.introParagraph ??
                              'نتشرف بتقديم عرضنا لسيادتكم كما يلي:',
                          style: pw.TextStyle(font: arabicFont, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                );
                break;
              case 'specs':
                if (quotation.technicalSpecs.isNotEmpty) {
                  sections.add(
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _pdfSectionHeader(
                            'المواصفات الفنية',
                            arabicBoldFont,
                            primaryCol,
                          ),
                          pw.SizedBox(height: 10),
                          pw.Wrap(
                            spacing: 15,
                            runSpacing: 10,
                            children: quotation.technicalSpecs
                                .map(
                                  (s) => _pdfTechnicalSpecCard(
                                    s['title'] ?? '',
                                    s['desc'] ?? '',
                                    'blue',
                                    arabicBoldFont,
                                    arabicFont,
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                break;
              case 'table':
                sections.add(
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    child: pw.Table(
                      border: pw.TableBorder.all(color: borderCl, width: 0.5),
                      columnWidths: {
                        0: const pw.FlexColumnWidth(4),
                        1: const pw.FlexColumnWidth(1),
                        2: const pw.FlexColumnWidth(2),
                        3: const pw.FlexColumnWidth(2),
                      },
                      children: [
                        pw.TableRow(
                          decoration: pw.BoxDecoration(color: primaryCol),
                          children: [
                            _pdfHeaderCell(
                              'الصنف / الوصف',
                              arabicBoldFont,
                              align: pw.TextAlign.right,
                            ),
                            _pdfHeaderCell('الكمية', arabicBoldFont),
                            _pdfHeaderCell('السعر', arabicBoldFont),
                            _pdfHeaderCell('الإجمالي', arabicBoldFont),
                          ],
                        ),
                        ...quotation.items.map(
                          (it) => pw.TableRow(
                            children: [
                              _pdfDataCell(
                                it.name,
                                arabicFont,
                                txtDark,
                                align: pw.TextAlign.right,
                              ),
                              _pdfDataCell(
                                it.quantity.toString(),
                                arabicFont,
                                txtDark,
                              ),
                              _pdfDataCell(
                                formatter.format(it.unitPrice),
                                arabicFont,
                                txtDark,
                              ),
                              _pdfDataCell(
                                formatter.format(it.total),
                                arabicBoldFont,
                                txtDark,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
                break;
              case 'total':
                sections.add(
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 5,
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.Container(
                          width: 250,
                          padding: const pw.EdgeInsets.all(10),
                          decoration: pw.BoxDecoration(
                            color: rowAlt,
                            border: pw.Border(
                              right: pw.BorderSide(
                                color: secondaryCol,
                                width: 4,
                              ),
                            ),
                          ),
                          child: _pdfTotalRow(
                            'الإجمالي',
                            '${formatter.format(quotation.total)} ج.م',
                            arabicBoldFont,
                            txtDark,
                            secondaryCol,
                            isMain: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
                break;
              case 'terms':
                if (quotation.termsAndConditions.isNotEmpty) {
                  sections.add(
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 15,
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _pdfSectionHeader(
                            'الشروط والأحكام',
                            arabicBoldFont,
                            primaryCol,
                          ),
                          pw.SizedBox(height: 8),
                          ...quotation.termsAndConditions.map(
                            (t) => pw.Padding(
                              padding: const pw.EdgeInsets.only(
                                right: 15,
                                bottom: 4,
                              ),
                              child: pw.Row(
                                children: [
                                  pw.Container(
                                    width: 4,
                                    height: 4,
                                    decoration: pw.BoxDecoration(
                                      color: primaryCol,
                                      shape: pw.BoxShape.circle,
                                    ),
                                  ),
                                  pw.SizedBox(width: 8),
                                  pw.Expanded(
                                    child: pw.Text(
                                      t,
                                      style: pw.TextStyle(
                                        font: arabicFont,
                                        fontSize: 10,
                                        color: txtGrey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                break;
              case 'signature':
                sections.add(
                  pw.Padding(
                    padding: const pw.EdgeInsets.fromLTRB(25, 30, 25, 30),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              '${company.address ?? ''} | ${company.phone1 ?? ''}',
                              style: pw.TextStyle(
                                font: arabicFont,
                                fontSize: 9,
                                color: txtGrey,
                              ),
                            ),
                            pw.Text(
                              company.email ?? '',
                              style: pw.TextStyle(
                                font: arabicFont,
                                fontSize: 9,
                                color: primaryCol,
                              ),
                            ),
                          ],
                        ),
                        if (stampImage != null ||
                            signatureImage != null ||
                            quotation.signatureText != null)
                          pw.Container(
                            width: 120,
                            height: 90,
                            child: pw.Stack(
                              alignment: pw.Alignment.center,
                              children: [
                                if (stampImage != null)
                                  pw.Opacity(
                                    opacity: 0.6,
                                    child: pw.Image(
                                      stampImage,
                                      width: 70,
                                      height: 70,
                                    ),
                                  ),
                                if (signatureImage != null)
                                  pw.Image(
                                    signatureImage,
                                    width: 100,
                                    height: 70,
                                  )
                                else if (quotation.signatureText != null)
                                  pw.Text(
                                    quotation.signatureText!,
                                    style: pw.TextStyle(
                                      font: signatureFont,
                                      fontSize: 24,
                                      color: pdf_core.PdfColors.blue900,
                                    ),
                                    textAlign: pw.TextAlign.center,
                                  ),
                              ],
                            ),
                          ),
                        if (quotation.signatureText != null &&
                            signatureImage != null)
                          pw.Text(
                            quotation.signatureText!,
                            style: pw.TextStyle(
                              font: arabicFont,
                              fontSize: 10,
                              color: txtGrey,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
                break;
            }
          }

          return pw.FittedBox(
            fit: pw.BoxFit.scaleDown,
            child: pw.Directionality(
              textDirection: pw.TextDirection.rtl,
              child: pw.Container(
                width: pdf_core.PdfPageFormat.a4.width,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [header, ...sections, pw.SizedBox(height: 40)],
                ),
              ),
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  Future<void> _downloadPdfDirectly(Quotation quotation) async {
    setState(() => _isGeneratingPdf = true);
    try {
      final company = await _companyDs.getSettings();
      final pdfBytes = await _buildPdf(quotation, company);
      final fileName =
          'عرض_سعر_${quotation.quotationNumber.replaceAll('/', '_')}';

      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        bool canSave = status.isGranted;
        if (!canSave &&
            (await Permission.manageExternalStorage.request().isGranted)) {
          canSave = true;
        }

        if (canSave) {
          final downloadDir = Directory('/storage/emulated/0/Download');
          if (await downloadDir.exists()) {
            final filePath = '${downloadDir.path}/$fileName.pdf';
            final file = File(filePath);
            await file.writeAsBytes(pdfBytes);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'تم حفظ الملف بنجاح في مجلد Downloads: $fileName.pdf',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            }
            return;
          }
        }
      }

      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/$fileName.pdf');
      await tempFile.writeAsBytes(pdfBytes);
      await Share.shareXFiles([
        XFile(tempFile.path),
      ], subject: 'عرض سعر رقم ${quotation.quotationNumber}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء تنزيل الملف: $e'),
            backgroundColor: AppColors.redColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  pw.Widget _pdfSectionHeader(
    String title,
    pw.Font font,
    pdf_core.PdfColor color,
  ) {
    return pw.Row(
      children: [
        pw.Container(
          width: 12,
          height: 12,
          decoration: pw.BoxDecoration(
            color: color,
            borderRadius: pw.BorderRadius.circular(2),
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Text(
          title,
          style: pw.TextStyle(font: font, fontSize: 11, color: color),
        ),
      ],
    );
  }

  pw.Widget _pdfTechnicalSpecCard(
    String title,
    String desc,
    String colorType,
    pw.Font boldFont,
    pw.Font font,
  ) {
    pdf_core.PdfColor sideColor = pdf_core.PdfColor.fromHex('#2c3e6b');
    return pw.Container(
      width: 235,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: const pdf_core.PdfColor(0.98, 0.98, 0.99),
        border: pw.Border(right: pw.BorderSide(color: sideColor, width: 3)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 9,
              color: pdf_core.PdfColor.fromHex('#1a2744'),
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            desc,
            style: pw.TextStyle(
              font: font,
              fontSize: 8,
              color: pdf_core.PdfColor.fromHex('#666666'),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfHeaderCell(
    String text,
    pw.Font font, {
    pw.TextAlign align = pw.TextAlign.center,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: 9,
          color: pdf_core.PdfColors.white,
        ),
        textAlign: align,
      ),
    );
  }

  pw.Widget _pdfDataCell(
    String text,
    pw.Font font,
    pdf_core.PdfColor color, {
    pw.TextAlign align = pw.TextAlign.center,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 8),
      child: pw.Text(
        text,
        style: pw.TextStyle(font: font, fontSize: 8, color: color),
        textAlign: align,
      ),
    );
  }

  pw.Widget _pdfTotalRow(
    String label,
    String value,
    pw.Font font,
    pdf_core.PdfColor valColor,
    pdf_core.PdfColor labColor, {
    bool isMain = false,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            font: font,
            fontSize: isMain ? 12 : 9,
            color: valColor,
          ),
        ),
        pw.Text(
          '$label:',
          style: pw.TextStyle(
            font: font,
            fontSize: isMain ? 10 : 9,
            color: labColor,
          ),
        ),
      ],
    );
  }

  Future<pw.Font> _loadArabicFont() async {
    try {
      final fontData = await rootBundle.load('assets/fonts/Cairo-Regular.ttf');
      return pw.Font.ttf(fontData);
    } catch (_) {
      return pw.Font.helvetica();
    }
  }

  Future<pw.Font> _loadArabicBoldFont() async {
    try {
      final fontData = await rootBundle.load('assets/fonts/Cairo-Bold.ttf');
      return pw.Font.ttf(fontData);
    } catch (_) {
      return pw.Font.helveticaBold();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_quotation == null) {
      return const Scaffold(
        body: Center(child: Text('لم يتم تمرير بيانات العرض')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text(
          _quotation!.quotationNumber,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'CairoBold',
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_isGeneratingPdf)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            )
          else
            IconButton(
              onPressed: () => _downloadPdfDirectly(_quotation!),
              icon: const Icon(Icons.download_rounded, color: Colors.white),
              tooltip: 'تنزيل PDF',
            ),
          IconButton(
            key: _shareButtonKey,
            onPressed: _generateAndSharePdf,
            icon: const Icon(Icons.share_outlined, color: Colors.white),
            tooltip: 'مشاركة PDF',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            _buildInfoCard(_quotation!),
            SizedBox(height: 16.h),
            _buildItemsTable(_quotation!),
            if (_quotation!.technicalSpecs.isNotEmpty) ...[
              SizedBox(height: 24.h),
              _buildSectionHeaderUI(
                'المواصفات الفنية ونطاق العمل',
                Icons.settings_suggest_outlined,
              ),
              SizedBox(height: 12.h),
              _buildTechnicalSpecsUI(_quotation!),
            ],
            if (_quotation!.termsAndConditions.isNotEmpty) ...[
              SizedBox(height: 24.h),
              _buildSectionHeaderUI('الشروط والأحكام', Icons.rule_outlined),
              SizedBox(height: 12.h),
              _buildTermsUI(_quotation!),
            ],
            SizedBox(height: 24.h),
            _buildSignatureCardUI(_quotation!),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(Quotation quotation) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'عرض رقم: ${quotation.quotationNumber}',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontFamily: 'CairoBold',
                    fontSize: 13.sp,
                  ),
                ),
              ),
              Text(
                _formatDate(quotation.createdAt),
                style: TextStyle(color: Colors.grey, fontSize: 12.sp),
              ),
            ],
          ),
          Divider(height: 32.h, thickness: 1, color: Colors.grey.shade100),
          _infoRow('العميل', quotation.clientName ?? '', Icons.person_outline),
          SizedBox(height: 12.h),
          _infoRow(
            'الموضوع',
            quotation.pdfTitle ?? 'عرض سعر صيانة وتوريد',
            Icons.description_outlined,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: Colors.grey),
        SizedBox(width: 8.w),
        Text(
          '$label:',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12.sp,
            fontFamily: 'CairoRegular',
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: const Color(0xff1F1F39),
              fontSize: 13.sp,
              fontFamily: 'CairoBold',
            ),
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }

  Widget _buildItemsTable(Quotation quotation) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildTableHeaderRow(),
          ...quotation.items.map((item) => _buildTableDataRow(item)),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16.r),
                bottomRight: Radius.circular(16.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_formatAmount(quotation.total)} ج.م',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontFamily: 'CairoBold',
                    fontSize: 16.sp,
                  ),
                ),
                Text(
                  'المجموع الكلي',
                  style: TextStyle(
                    color: const Color(0xff1F1F39),
                    fontFamily: 'CairoBold',
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeaderRow() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'الصنف',
              style: TextStyle(
                fontSize: 12.sp,
                fontFamily: 'CairoBold',
                color: Colors.grey,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            child: Text(
              'الكمية',
              style: TextStyle(
                fontSize: 12.sp,
                fontFamily: 'CairoBold',
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'الإجمالي',
              style: TextStyle(
                fontSize: 12.sp,
                fontFamily: 'CairoBold',
                color: Colors.grey,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableDataRow(QuotationItem item) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              item.name,
              style: TextStyle(
                fontSize: 12.sp,
                fontFamily: 'CairoRegular',
                color: const Color(0xff1F1F39),
              ),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            child: Text(
              item.quantity.toString(),
              style: TextStyle(
                fontSize: 12.sp,
                fontFamily: 'CairoBold',
                color: const Color(0xff1F1F39),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${_formatAmount(item.total)} ج.م',
              style: TextStyle(
                fontSize: 12.sp,
                fontFamily: 'CairoBold',
                color: AppColors.primaryColor,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeaderUI(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20.sp, color: AppColors.primaryColor),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 15.sp,
            fontFamily: 'CairoBold',
            color: const Color(0xff1F1F39),
          ),
        ),
      ],
    );
  }

  Widget _buildTechnicalSpecsUI(Quotation quotation) {
    return Column(
      children: quotation.technicalSpecs
          .map(
            (spec) => Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    spec['title'] ?? '',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontFamily: 'CairoBold',
                      color: AppColors.primaryColor,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    spec['desc'] ?? '',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontFamily: 'CairoRegular',
                      color: const Color(0xff6E7191),
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildTermsUI(Quotation quotation) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: quotation.termsAndConditions
            .asMap()
            .entries
            .map(
              (e) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        e.value,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontFamily: 'CairoRegular',
                          color: const Color(0xff6E7191),
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '${(e.key + 1).toString().padLeft(2, '0')}.',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontFamily: 'CairoBold',
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildSignatureCardUI(Quotation quotation) {
    String identityStr = '';
    if (quotation.commercialRegister?.isNotEmpty == true) {
      identityStr += 'س.ت: ${quotation.commercialRegister} ';
    }
    if (quotation.taxId?.isNotEmpty == true) {
      identityStr +=
          (identityStr.isNotEmpty ? ' | ' : '') + 'ب.ض: ${quotation.taxId}';
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                quotation.signatureHeader ?? 'الاعتماد والتوقيع',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontFamily: 'CairoBold',
                  color: const Color(0xff1F1F39),
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.verified_user_outlined,
                color: AppColors.primaryColor,
                size: 20.sp,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      quotation.signatureText ?? 'مقدمه لسيادتكم / م. هاني',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontFamily: 'SignatureFont',
                        color: AppColors.primaryColor,
                      ),
                    ),
                    if (identityStr.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Text(
                        identityStr,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: const Color(0xff6E7191),
                          fontFamily: 'CairoRegular',
                        ),
                      ),
                    ],
                    Divider(color: Colors.grey.shade300, thickness: 0.5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ختم وتوقيع الشركة الرسمي',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.grey,
                            fontFamily: 'CairoRegular',
                          ),
                        ),
                        _buildSignaturePreviewUI(quotation),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSignaturePreviewUI(Quotation quotation) {
    // سنحاول جلب التوقيع من العرض أولاً ثم من الإعدادات
    return FutureBuilder<CompanySettings>(
      future: _companyDs.getSettings(),
      builder: (context, snapshot) {
        final signaturePath =
            quotation.signatureImagePath ?? snapshot.data?.signaturePath;
        final stampPath = snapshot.data?.stampPath;

        return SizedBox(
          width: 80.w,
          height: 60.h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (stampPath != null && File(stampPath).existsSync())
                Opacity(
                  opacity: 0.3,
                  child: Image.file(File(stampPath), width: 40.w, height: 40.h),
                ),
              if (signaturePath != null && File(signaturePath).existsSync())
                Image.file(File(signaturePath), width: 70.w, height: 50.h),
            ],
          ),
        );
      },
    );
  }

  Future<pw.Font> _loadSignatureFont() async {
    final data = await rootBundle.load("assets/fonts/Cairo-Regular.ttf");
    try {
      final signatureData = await rootBundle.load(
        "assets/fonts/SignatureFont.ttf",
      );
      return pw.Font.ttf(signatureData);
    } catch (_) {
      return pw.Font.ttf(data);
    }
  }
}
