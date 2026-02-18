import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

// Definições FFI
typedef InitializeFunc = Void Function();
typedef LoadRomFunc = Bool Function(Pointer<Utf8> path);
typedef CloseRomFunc = Void Function();
typedef ResetFunc = Void Function();
typedef StartEmulationFunc = Void Function();
typedef GetFrameBufferFunc = Pointer<Uint8> Function();
typedef GetFrameBufferSizeFunc = Int32 Function();

class NativeEmulator {
  late final DynamicLibrary _nativeLib;
  late final Pointer<NativeFunction<InitializeFunc>> _initialize;
  late final Pointer<NativeFunction<LoadRomFunc>> _loadRom;
  late final Pointer<NativeFunction<CloseRomFunc>> _closeRom;
  late final Pointer<NativeFunction<ResetFunc>> _reset;
  late final Pointer<NativeFunction<StartEmulationFunc>> _startEmulation;
  late final Pointer<NativeFunction<GetFrameBufferFunc>> _getFrameBuffer;
  late final Pointer<NativeFunction<GetFrameBufferSizeFunc>> _getFrameBufferSize;

  bool _initialized = false;

  void initialize() {
    if (_initialized) return;

    try {
      if (Platform.isAndroid) {
        _nativeLib = DynamicLibrary.open('libemulator_core.so');
      } else if (Platform.isIOS) {
        _nativeLib = DynamicLibrary.process();
      } else if (Platform.isMacOS) {
        _nativeLib = DynamicLibrary.executable();
      } else if (Platform.isWindows) {
        _nativeLib = DynamicLibrary.open('emulator_core.dll');
      } else if (Platform.isLinux) {
        _nativeLib = DynamicLibrary.open('libemulator_core.so');
      } else {
        throw UnsupportedError('Plataforma não suportada');
      }

      _initialize = _nativeLib.lookup<NativeFunction<InitializeFunc>>('initialize');
      _loadRom = _nativeLib.lookup<NativeFunction<LoadRomFunc>>('load_rom');
      _closeRom = _nativeLib.lookup<NativeFunction<CloseRomFunc>>('close_rom');
      _reset = _nativeLib.lookup<NativeFunction<ResetFunc>>('reset');
      _startEmulation = _nativeLib.lookup<NativeFunction<StartEmulationFunc>>('start_emulation');
      _getFrameBuffer = _nativeLib.lookup<NativeFunction<GetFrameBufferFunc>>('get_frame_buffer');
      _getFrameBufferSize =
_nativeLib.lookup<NativeFunction<GetFrameBufferSizeFunc>>('get_frame_buffer_size');

      _initialized = true;
      _initialize.asFunction<InitializeFunc>()();
    } catch (e) {
      if (kDebugMode) print('Erro ao carregar biblioteca nativa: $e');
    }
  }

  bool loadRom(String romPath) {
    if (!_initialized) return false;
    final pathPtr = Utf8.toUtf8(romPath);
    final result = _loadRom.asFunction<LoadRomFunc>()(pathPtr);
    malloc.free(pathPtr);
    return result;
  }

  void closeRom() {
    if (!_initialized) return;
    _closeRom.asFunction<CloseRomFunc>()();
  }

  void reset() {
    if (!_initialized) return;
    _reset.asFunction<ResetFunc>()();
  }

  void startEmulation() {
    if (!_initialized) return;
    _startEmulation.asFunction<StartEmulationFunc>()();
  }

  Uint8List getFrameBuffer() {
    if (!_initialized) return Uint8List(0);

    final bufferPtr = _getFrameBuffer.asFunction<GetFrameBufferFunc>()();
    final bufferSize = _getFrameBufferSize.asFunction<GetFrameBufferSizeFunc>()();

    if (bufferPtr.address == 0 || bufferSize <= 0) {
      return Uint8List(0);
    }

    final byteList = bufferPtr.asTypedList(bufferSize);
    return Uint8List.fromList(byteList);
  }

  void dispose() {
    // Liberação de recursos se necessário
  }
}
