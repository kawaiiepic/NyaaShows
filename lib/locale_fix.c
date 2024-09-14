#include <locale.h>

void set_numeric_locale_to_C() {
    setlocale(LC_NUMERIC, "C");
}