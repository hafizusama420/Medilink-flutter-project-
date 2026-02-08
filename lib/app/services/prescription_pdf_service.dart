// lib/app/services/prescription_pdf_service.dart

import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/prescription_model.dart';

class PrescriptionPdfService {
  /// Generate a professional prescription PDF bytes
  Future<Uint8List> generatePrescriptionPDFBytes(PrescriptionModel prescription) async {
    final pdf = pw.Document();
    
    // Load custom font for better appearance
    final font = await PdfGoogleFonts.interRegular();
    final fontBold = await PdfGoogleFonts.interBold();
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(prescription, fontBold, font),
          pw.SizedBox(height: 20),
          _buildDivider(),
          pw.SizedBox(height: 20),
          _buildPatientInfo(prescription, fontBold, font),
          pw.SizedBox(height: 20),
          _buildDiagnosisSection(prescription, fontBold, font),
          pw.SizedBox(height: 20),
          _buildMedicationsTable(prescription, fontBold, font),
          pw.SizedBox(height: 20),
          if (prescription.generalInstructions != null && prescription.generalInstructions!.isNotEmpty)
            _buildInstructionsSection(prescription, fontBold, font),
          if (prescription.generalInstructions != null && prescription.generalInstructions!.isNotEmpty)
            pw.SizedBox(height: 20),
          if (prescription.followUpRequired == true)
            _buildFollowUpSection(prescription, fontBold, font),
          if (prescription.followUpRequired == true)
            pw.SizedBox(height: 20),
          if (prescription.additionalNotes != null && prescription.additionalNotes!.isNotEmpty)
            _buildNotesSection(prescription, fontBold, font),
          pw.Spacer(),
          _buildFooter(prescription, font),
        ],
      ),
    );
    
    return await pdf.save();
  }
  
  /// Build PDF header with logo and doctor info
  pw.Widget _buildHeader(PrescriptionModel prescription, pw.Font fontBold, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#00B864'),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'MediLink',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 24,
                  color: PdfColors.white,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'E-Prescription',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 12,
                  color: PdfColors.white,
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                prescription.doctorName ?? 'Doctor',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 14,
                  color: PdfColors.white,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                prescription.doctorSpecialty ?? 'Specialist',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 11,
                  color: PdfColors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// Build divider
  pw.Widget _buildDivider() {
    return pw.Container(
      height: 2,
      color: PdfColor.fromHex('#E0E0E0'),
    );
  }
  
  /// Build patient information section
  pw.Widget _buildPatientInfo(PrescriptionModel prescription, pw.Font fontBold, pw.Font font) {
    final dateFormat = DateFormat('MMM d, yyyy, h:mm a');
    
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColor.fromHex('#E0E0E0')),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Patient Information',
                style: pw.TextStyle(font: fontBold, fontSize: 12, color: PdfColor.fromHex('#666666')),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                prescription.patientName ?? 'Patient',
                style: pw.TextStyle(font: fontBold, fontSize: 16),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Date',
                style: pw.TextStyle(font: fontBold, fontSize: 12, color: PdfColor.fromHex('#666666')),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                prescription.prescribedDate != null 
                  ? dateFormat.format(prescription.prescribedDate!) 
                  : 'N/A',
                style: pw.TextStyle(font: font, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// Build diagnosis section
  pw.Widget _buildDiagnosisSection(PrescriptionModel prescription, pw.Font fontBold, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#F5F5F5'),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Diagnosis',
            style: pw.TextStyle(font: fontBold, fontSize: 14, color: PdfColor.fromHex('#00B864')),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            prescription.diagnosis ?? 'No diagnosis provided',
            style: pw.TextStyle(font: font, fontSize: 12),
          ),
          if (prescription.symptoms != null && prescription.symptoms!.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            pw.Text(
              'Symptoms: ${prescription.symptoms}',
              style: pw.TextStyle(font: font, fontSize: 11, color: PdfColor.fromHex('#666666')),
            ),
          ],
        ],
      ),
    );
  }
  
  /// Build medications table
  pw.Widget _buildMedicationsTable(PrescriptionModel prescription, pw.Font fontBold, pw.Font font) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Prescribed Medications',
          style: pw.TextStyle(font: fontBold, fontSize: 14, color: PdfColor.fromHex('#00B864')),
        ),
        pw.SizedBox(height: 12),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColor.fromHex('#E0E0E0')),
          children: [
            // Header row
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColor.fromHex('#F5F5F5')),
              children: [
                _buildTableCell('#', fontBold, isHeader: true),
                _buildTableCell('Medicine', fontBold, isHeader: true),
                _buildTableCell('Dosage', fontBold, isHeader: true),
                _buildTableCell('Frequency', fontBold, isHeader: true),
                _buildTableCell('Duration', fontBold, isHeader: true),
              ],
            ),
            // Data rows
            ...List.generate(
              prescription.medications?.length ?? 0,
              (index) {
                final med = prescription.medications![index];
                return pw.TableRow(
                  children: [
                    _buildTableCell('${index + 1}', font),
                    _buildTableCell(
                      '${med.name}\n${med.strength ?? ''}\n${med.form ?? ''}',
                      font,
                    ),
                    _buildTableCell(med.dosage ?? '-', font),
                    _buildTableCell(med.frequency ?? '-', font),
                    _buildTableCell(med.duration ?? '-', font),
                  ],
                );
              },
            ),
          ],
        ),
      ],
    );
  }
  
  /// Build table cell
  pw.Widget _buildTableCell(String text, pw.Font font, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: isHeader ? 11 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
  
  /// Build instructions section
  pw.Widget _buildInstructionsSection(PrescriptionModel prescription, pw.Font fontBold, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#E3F2FD'),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColor.fromHex('#2196F3')),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'General Instructions',
            style: pw.TextStyle(font: fontBold, fontSize: 12, color: PdfColor.fromHex('#2196F3')),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            prescription.generalInstructions!,
            style: pw.TextStyle(font: font, fontSize: 10),
          ),
        ],
      ),
    );
  }
  
  /// Build follow-up section
  pw.Widget _buildFollowUpSection(PrescriptionModel prescription, pw.Font fontBold, pw.Font font) {
    final dateFormat = DateFormat('MMM d, yyyy');
    
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#FFF3E0'),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColor.fromHex('#FF9800')),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Follow-up Required',
            style: pw.TextStyle(font: fontBold, fontSize: 12, color: PdfColor.fromHex('#FF9800')),
          ),
          pw.SizedBox(height: 6),
          if (prescription.followUpDate != null)
            pw.Text(
              'Date: ${dateFormat.format(prescription.followUpDate!)}',
              style: pw.TextStyle(font: font, fontSize: 10),
            ),
          if (prescription.followUpType != null)
            pw.Text(
              'Type: ${prescription.followUpType}',
              style: pw.TextStyle(font: font, fontSize: 10),
            ),
        ],
      ),
    );
  }
  
  /// Build notes section
  pw.Widget _buildNotesSection(PrescriptionModel prescription, pw.Font fontBold, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#FFF9C4'),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColor.fromHex('#FBC02D')),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Important Notes',
            style: pw.TextStyle(font: fontBold, fontSize: 12, color: PdfColor.fromHex('#F57C00')),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            prescription.additionalNotes!,
            style: pw.TextStyle(font: font, fontSize: 10),
          ),
        ],
      ),
    );
  }
  
  /// Build footer with validity and signature
  pw.Widget _buildFooter(PrescriptionModel prescription, pw.Font font) {
    final dateFormat = DateFormat('MMM d, yyyy');
    
    return pw.Column(
      children: [
        pw.Container(height: 1, color: PdfColor.fromHex('#E0E0E0')),
        pw.SizedBox(height: 12),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Valid Until: ${prescription.expiryDate != null ? dateFormat.format(prescription.expiryDate!) : 'N/A'}',
                  style: pw.TextStyle(font: font, fontSize: 9, color: PdfColor.fromHex('#666666')),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Prescription ID: ${prescription.id ?? 'N/A'}',
                  style: pw.TextStyle(font: font, fontSize: 8, color: PdfColor.fromHex('#999999')),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'Digital Signature',
                  style: pw.TextStyle(font: font, fontSize: 9, color: PdfColor.fromHex('#666666')),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  prescription.doctorName ?? 'Doctor',
                  style: pw.TextStyle(font: font, fontSize: 10, fontStyle: pw.FontStyle.italic),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'This is a digitally generated prescription from MediLink',
          style: pw.TextStyle(font: font, fontSize: 8, color: PdfColor.fromHex('#999999')),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }
}
