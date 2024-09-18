typedef ValidationRule = bool Function(dynamic value);

String? validateFields(
    Map<String, dynamic> fields, Map<String, ValidationRule> rules) {
  List<String> missingOrInvalidFields = [];

  fields.forEach((field, value) {
    if (rules.containsKey(field) && !rules[field]!(value)) {
      missingOrInvalidFields.add(field);
    }
  });

  if (missingOrInvalidFields.isEmpty) {
    return null;
  }

  return missingOrInvalidFields.join(", ");
}
