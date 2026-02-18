import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'native_emulator.dart';

class EmulatorScreen extends StatefulWidget {
  const EmulatorScreen({super.key});

  @override
  State<EmulatorScreen> createState() => _EmulatorScreenState();
}

class _EmulatorScreenState extends State<EmulatorScreen> {
  final NativeEmulator _emulator = NativeEmulator();
  bool _isRomLoaded = false;

  @override
  void initState() {
    super.initState();
    _emulator.initialize();
  }

  @override
  void dispose() {
    _emulator.dispose();
    super.dispose();
  }

  void _openRom() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['sms'],
    );

    if (result != null) {
      String path = result.files.single.path!;
      bool success = _emulator.loadRom(path);
      setState(() {
        _isRomLoaded = success;
      });

      if (success) {
        _emulator.startEmulation();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sega Master System Emulator'),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: Column(
        children: [
          // Área de vídeo do emulador
          Expanded(
            child: Container(
              color: Colors.black,
              child: _isRomLoaded
                ? Image.memory(
                    _emulator.getFrameBuffer(),
                    gaplessPlayback: true,
                    fit: BoxFit.contain,
                  )
                : const Center(
                    child: Text(
                      'Nenhuma ROM carregada\nClique em "Abrir ROM" para começar',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
            ),
          ),

          // Controles
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _openRom,
                  icon: const Icon(Icons.folder_open),
                  label: const Text("Abrir ROM"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isRomLoaded ? _emulator.reset : null,
                  icon: const Icon(Icons.restart_alt),
                  label: const Text("Reset"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[700],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isRomLoaded ? () {
                    _emulator.closeRom();
                    setState(() {
                      _isRomLoaded = false;
                    });
                  } : null,
                  icon: const Icon(Icons.close),
                  label: const Text("Fechar ROM"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                  ),
                ),
              ],
            ),
          ),

          // Status
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              _isRomLoaded ? 'ROM carregada' : 'Nenhuma ROM carregada',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
