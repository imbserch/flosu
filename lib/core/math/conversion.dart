int parseInt(String? value, int defaultValue) =>
    int.tryParse(value ?? "") ?? defaultValue;

double parseDouble(String? value, double defaultValue) =>
    double.tryParse(value ?? "") ?? defaultValue;
