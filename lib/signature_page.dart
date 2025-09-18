import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

class SignaturePage extends StatefulWidget {
  const SignaturePage({super.key});

  @override
  State<SignaturePage> createState() => _SignaturePageState();
}

class _SignaturePageState extends State<SignaturePage>
    with WidgetsBindingObserver {
  late final SignatureController _controller;
  ui.Image? _signatureImage;

  static const double _buttonAreaHeight = 44.0;
  static const double _buttonSpacing = 16.0;
  static const double _contentPadding = 16.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = SignatureController(
      penStrokeWidth: 3.0,
      penColor: Colors.black,
    );

    _controller.onDrawEnd = () {
      setState(() {
        // _controller.onDrawEnd の中で setState を呼ばないと、
        //_controller.isNotEmpty が false から更新されない
      });
    };
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    _handleClear();
  }

  Future<void> _handleComplete() async {
    final image = await _controller.toImage();
    setState(() {
      _signatureImage = image;
    });
  }

  void _handleClear() {
    _controller.clear();
    setState(() {
      _signatureImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('署名'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(_contentPadding),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final contentHeight = (constraints.maxHeight -
                      _buttonAreaHeight -
                      _buttonSpacing * 2) /
                  2;
              return Column(
                children: [
                  SizedBox(
                    height: contentHeight,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Signature(
                          controller: _controller,
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: _buttonSpacing),
                  SizedBox(
                    height: _buttonAreaHeight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: _controller.undo,
                          icon: const Icon(Icons.undo),
                        ),
                        IconButton(
                          onPressed: _controller.redo,
                          icon: const Icon(Icons.redo),
                        ),
                        IconButton(
                          onPressed: _handleClear,
                          icon: const Icon(Icons.clear),
                        ),
                        if (_controller.isNotEmpty)
                          ElevatedButton(
                            onPressed: _handleComplete,
                            child: const Text('完了'),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: _buttonSpacing),
                  SizedBox(
                    height: contentHeight,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _signatureImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: RawImage(
                                image: _signatureImage,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.contain,
                              ),
                            )
                          : const Center(
                              child: Text('署名を入力してください'),
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
