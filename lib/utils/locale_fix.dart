import 'dart:ffi';
import 'dart:io';

typedef SetNumericLocaleC = Void Function();
typedef SetNumericLocaleDart = void Function();

void setNumericLocaleToC() {
  final DynamicLibrary dylib = Platform.isLinux
      ? DynamicLibrary.open('library/liblocale_fix.so')
      : DynamicLibrary.process();

  final SetNumericLocaleDart setLocale = dylib
      .lookup<NativeFunction<SetNumericLocaleC>>('set_numeric_locale_to_C')
      .asFunction();

  setLocale();
}
