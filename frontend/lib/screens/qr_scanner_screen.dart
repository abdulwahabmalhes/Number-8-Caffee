import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../core/theme.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  bool _hasScanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? rawValue = barcodes.first.rawValue;
      if (rawValue != null && rawValue.isNotEmpty) {
        setState(() {
          _hasScanned = true;
        });
        
        // Parse token if it's a URL
        String resultToken = rawValue;
        try {
          final uri = Uri.parse(rawValue);
          final tokenParam = uri.queryParameters['token'];
          if (tokenParam != null && tokenParam.isNotEmpty) {
            resultToken = tokenParam;
          }
        } catch (_) {
          // Fallback to raw value
        }

        Navigator.pop(context, resultToken);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Scan Table QR Code',
          style: GoogleFonts.tajawal(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: ValueListenableBuilder<MobileScannerState>(
              valueListenable: _controller,
              builder: (context, state, child) {
                if (!state.isInitialized || !state.isRunning) {
                  return const Icon(Icons.flash_off, color: Colors.grey);
                }
                final isTorchOn = state.torchState == TorchState.on;
                return Icon(
                  isTorchOn ? Icons.flash_on : Icons.flash_off,
                  color: Colors.white,
                );
              },
            ),
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          
          // Scanner Overlay Frame
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.successGreen, width: 3),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Stack(
                children: [
                  Positioned.fill(
                    child: Center(
                      child: SizedBox(
                        width: 230,
                        height: 2,
                        child: Divider(color: AppColors.successGreen, thickness: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          Positioned(
            bottom: 60,
            left: 20,
            right: 20,
            child: Text(
              'Align the QR code inside the box to scan',
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(
                color: Colors.white.withOpacity(0.8),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
